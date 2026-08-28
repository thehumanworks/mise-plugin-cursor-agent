--- Return the platform-specific Cursor Agent archive for one release.
--- @param ctx PreInstallCtx
--- @return PreInstallResult
function PLUGIN:PreInstall(ctx)
    local cursor = require("cursor")
    local platform = require("platform").current()
    local version = ctx.version

    if version == "latest" then
        version = cursor.latest(platform.os)
    else
        version = cursor.validate_version(version)
    end

    return {
        version = version,
        url = cursor.download_url(version, platform),
        note = "Installing Cursor Agent " .. version .. " for " .. platform.os .. "/" .. platform.arch,
    }
end
