local platform = require("platform")

local M = {}

local function shell_single_quote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- Cursor lab build id embedded in the official install script download URLs.
M.VERSION_PATTERN = "^%d%d%d%d%.%d%d%.%d%d%-[a-f0-9]+$"

--- Stable version string from install script body (bash from cursor.com/install).
function M.parse_version_from_install_script(body)
    if body == nil or body == "" then
        return nil, "empty install script body"
    end
    -- Prefer the tarball URL assignment (avoids incidental matches elsewhere).
    for line in body:gmatch("[^\n]+") do
        local ver = line:match('downloads%.cursor%.com/lab/([%d]+%.[%d]+%.[%d]+%-[a-f0-9]+)/')
        if ver ~= nil then
            return ver, nil
        end
    end
    -- Fallback: any lab/… path segment with the expected shape
    local ver = body:match("lab/([%d]+%.[%d]+%.[%d]+%-[a-f0-9]+)/")
    if ver ~= nil then
        return ver, nil
    end
    return nil, "could not find lab build id in install script"
end

function M.is_valid_build_id(v)
    return type(v) == "string" and v:match(M.VERSION_PATTERN) ~= nil
end

--- @param version string requested (e.g. "latest" or a build id)
--- @param current string concrete lab build id from upstream
function M.resolve_install_version(version, current)
    if version == nil or version == "" then
        error("no version requested")
    end
    if version == "latest" then
        if current == nil or current == "" then
            error("could not resolve latest: missing current build id")
        end
        return current
    end
    if not M.is_valid_build_id(version) then
        error("invalid cursor-agent version (expected YYYY.MM.DD-<hash> or 'latest'): " .. tostring(version))
    end
    return version
end

function M.tarball_url(version, os_name, arch_name)
    return string.format(
        "https://downloads.cursor.com/lab/%s/%s/%s/agent-cli-package.tar.gz",
        version,
        os_name,
        arch_name
    )
end

--- Comma-separated extra build IDs (for tests and MISE_CURSOR_AGENT_EXTRA_VERSIONS).
function M.parse_extra_versions_string(raw)
    if raw == nil or raw == "" then
        return {}
    end
    local out = {}
    local seen = {}
    for part in string.gmatch(raw, "[^,]+") do
        local v = part:match("^%s*(.-)%s*$")
        if v ~= nil and v ~= "" and M.is_valid_build_id(v) and not seen[v] then
            seen[v] = true
            table.insert(out, v)
        end
    end
    return out
end

function M.extra_versions_from_env()
    return M.parse_extra_versions_string(os.getenv("MISE_CURSOR_AGENT_EXTRA_VERSIONS"))
end

--- Platform tuple for this host (used by Available for rolling checksum + PreInstall).
function M.host_download_targets()
    return platform.get()
end

local sha256_cache = {
    key = nil,
    hash = nil,
    t = 0,
}
local SHA256_CACHE_TTL = 900 -- seconds; avoids duplicate full downloads in Available + PreInstall

--- Full-file SHA256 of a remote tarball (streams via curl). Used for mise verify and rolling checksums.
function M.sha256_tarball_from_url(url)
    local now = os.time()
    if sha256_cache.key == url and (now - sha256_cache.t) < SHA256_CACHE_TTL and sha256_cache.hash ~= nil then
        return sha256_cache.hash
    end
    local cmd = require("cmd")
    local pipeline = string.format("curl -fsSL %s | sha256sum | awk '{print $1}'", shell_single_quote(url))
    local out = cmd.exec(pipeline)
    local h = out:match("^%s*([a-f0-9]+)%s*$")
    if h == nil or #h ~= 64 then
        error("could not compute sha256 for tarball URL")
    end
    sha256_cache.key = url
    sha256_cache.hash = h
    sha256_cache.t = now
    return h
end

return M
