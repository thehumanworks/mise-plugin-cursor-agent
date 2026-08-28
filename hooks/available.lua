--- List the Cursor Agent release currently advertised by Cursor.
--- @param ctx AvailableCtx
--- @return AvailableItem[]
function PLUGIN:Available(ctx)
    local cursor = require("cursor")
    local platform = require("platform").current()
    local version = cursor.latest(platform.os)

    return {
        {
            version = version,
            note = "current Cursor Agent release",
        },
    }
end
