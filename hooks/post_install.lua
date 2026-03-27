function PLUGIN:PostInstall(ctx)
    local path = ctx.sdkInfo["cursor-agent"].path
    local bin = path .. "/cursor-agent"
    local link = path .. "/agent"

    if RUNTIME.osType ~= "Windows" then
        os.execute("chmod +x " .. bin)
    end

    os.execute("ln -sf cursor-agent " .. link)
end
