local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function executable_exists(file, directory)
    return file.exists(file.join_path(directory, "cursor-agent"))
        or file.exists(file.join_path(directory, "cursor-agent.exe"))
        or file.exists(file.join_path(directory, "cursor-agent.cmd"))
end

--- Normalize Cursor's dist-package directory and prepare its launchers.
--- @param ctx PostInstallCtx
function PLUGIN:PostInstall(ctx)
    local cmd = require("cmd")
    local file = require("file")
    local install_path = ctx.sdkInfo[PLUGIN.name].path
    local extracted_path = file.join_path(install_path, "dist-package")
    local bin_path = file.join_path(install_path, "bin")

    if executable_exists(file, extracted_path) then
        file.move(extracted_path, bin_path)
    elseif executable_exists(file, install_path) then
        bin_path = install_path
    elseif not executable_exists(file, bin_path) then
        error("Could not find cursor-agent in the extracted package at " .. install_path)
    end

    if RUNTIME.osType ~= "windows" and RUNTIME.osType ~= "win32" then
        local cursor_agent = file.join_path(bin_path, "cursor-agent")
        cmd.exec("chmod 755 " .. shell_quote(cursor_agent))

        local agent = file.join_path(bin_path, "agent")
        if not file.exists(agent) then
            file.symlink(cursor_agent, agent)
        end
    end
end
