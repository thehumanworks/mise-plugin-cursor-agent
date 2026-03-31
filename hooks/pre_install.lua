local platform = require("platform")
local http = require("http")
local cursor_agent = require("cursor_agent")

function PLUGIN:PreInstall(ctx)
    local os_name, arch_name = platform.get()

    local current = nil
    if ctx.version == "latest" then
        local resp, err = http.get({
            url = "https://cursor.com/install",
        })
        if err ~= nil then
            error("Failed to fetch cursor.com/install: " .. err)
        end
        if resp.status_code ~= 200 then
            error("cursor.com/install returned HTTP " .. resp.status_code)
        end

        local parse_err
        current, parse_err = cursor_agent.parse_version_from_install_script(resp.body)
        if current == nil then
            error("Could not extract version from cursor.com/install: " .. (parse_err or "unknown"))
        end
    end

    local version = cursor_agent.resolve_install_version(ctx.version, current)
    local url = cursor_agent.tarball_url(version, os_name, arch_name)
    -- Full-file hash; mise verifies the downloaded archive against this value.
    local sha256 = cursor_agent.sha256_tarball_from_url(url)

    return {
        version = version,
        url = url,
        sha256 = sha256,
    }
end
