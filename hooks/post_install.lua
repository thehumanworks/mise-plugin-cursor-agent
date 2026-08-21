local cmd = require("cmd")

function PLUGIN:PostInstall(ctx)
    local sdkInfo = ctx.sdkInfo[PLUGIN.name]
    local path = sdkInfo.path

    if RUNTIME.osType ~= "Windows" then
        cmd.exec("chmod +x cursor-agent && ln -sf cursor-agent agent", { cwd = path })
    end
end
