local cmd = require("cmd")

function PLUGIN:PostInstall(ctx)
    local path = ctx.sdkInfo["cursor-agent"].path

    if RUNTIME.osType ~= "Windows" then
        cmd.exec("chmod +x cursor-agent && ln -sf cursor-agent agent", { cwd = path })
    end
end
