local function executable_exists(file, directory)
    return file.exists(file.join_path(directory, "cursor-agent"))
        or file.exists(file.join_path(directory, "cursor-agent.exe"))
        or file.exists(file.join_path(directory, "cursor-agent.cmd"))
end

--- Add Cursor Agent's launchers to PATH.
--- @param ctx EnvKeysCtx
--- @return EnvKey[]
function PLUGIN:EnvKeys(ctx)
    local file = require("file")
    local bin_path = file.join_path(ctx.path, "bin")

    if not executable_exists(file, bin_path) then
        local extracted_path = file.join_path(ctx.path, "dist-package")
        bin_path = executable_exists(file, extracted_path) and extracted_path or ctx.path
    end

    return {
        {
            key = "PATH",
            value = bin_path,
        },
    }
end
