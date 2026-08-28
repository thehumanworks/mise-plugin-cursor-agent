local M = {}

local unix_installer_url = "https://cursor.com/install"
local windows_installer_url = "https://cursor.com/install?win32=true"

--- Validate a Cursor Agent release identifier.
--- @param version string
--- @return string
function M.validate_version(version)
    local value = tostring(version)
    local legacy = value:match("^%d%d%d%d%.%d%d%.%d%d%-%x+$")
    local timestamped = value:match("^%d%d%d%d%.%d%d%.%d%d%-%d%d%-%d%d%-%d%d%-%x+$")
    if legacy == nil and timestamped == nil then
        error("Invalid Cursor Agent version: " .. value)
    end
    return value
end

--- Extract a release identifier from either official installer script.
--- @param body string
--- @return string
function M.version_from_installer(body)
    local version = body:match("downloads%.cursor%.com/lab/([%w%.%-]+)/")
        or body:match("%$version%s*=%s*['\"]([%w%.%-]+)['\"]")
        or body:match("versions/([%w%.%-]+)/cursor%-agent")

    if version == nil then
        error("Could not determine the current Cursor Agent version from Cursor's installer")
    end
    return M.validate_version(version)
end

local function installer_url(os_type)
    if tostring(os_type):lower() == "windows" then
        return windows_installer_url
    end
    return unix_installer_url
end

--- Fetch the version advertised by Cursor's official installer.
--- @param os_type string
--- @return string
function M.latest(os_type)
    local http = require("http")
    local url = installer_url(os_type)
    local resp, err = http.get({
        url = url,
        headers = {
            ["Accept"] = "text/plain",
            ["User-Agent"] = "mise-cursor-agent-plugin",
        },
    })

    if err ~= nil then
        error("Failed to fetch Cursor Agent's installer: " .. tostring(err))
    end
    if resp.status_code ~= 200 then
        error("Failed to fetch Cursor Agent's installer: HTTP " .. tostring(resp.status_code))
    end
    return M.version_from_installer(resp.body)
end

--- Build an immutable Cursor CDN artifact URL.
--- @param version string
--- @param platform table
--- @return string
function M.download_url(version, platform)
    return "https://downloads.cursor.com/lab/"
        .. M.validate_version(version)
        .. "/"
        .. platform.os
        .. "/"
        .. platform.arch
        .. "/"
        .. platform.archive
end

return M
