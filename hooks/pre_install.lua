local platform = require("platform")

function PLUGIN:PreInstall(ctx)
    local os, arch = platform.get()
    local url = string.format(
        "https://downloads.cursor.com/lab/%s/%s/%s/agent-cli-package.tar.gz",
        ctx.version, os, arch
    )
    return {
        version = ctx.version,
        url = url,
    }
end
