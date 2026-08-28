local M = {}

local os_aliases = {
    darwin = "darwin",
    linux = "linux",
    macos = "darwin",
    win32 = "windows",
    windows = "windows",
}

local arch_aliases = {
    aarch64 = "arm64",
    amd64 = "x64",
    arm64 = "arm64",
    x64 = "x64",
    x86_64 = "x64",
}

--- Resolve a Mise runtime OS and architecture to Cursor's artifact naming.
--- @param os_type string
--- @param arch_type string
--- @return table
function M.resolve(os_type, arch_type)
    local runtime_os = tostring(os_type):lower()
    local runtime_arch = tostring(arch_type):lower()
    local artifact_os = os_aliases[runtime_os]
    local artifact_arch = arch_aliases[runtime_arch]

    if artifact_os == nil then
        error("Unsupported operating system for Cursor Agent: " .. tostring(os_type))
    end
    if artifact_arch == nil then
        error("Unsupported architecture for Cursor Agent: " .. tostring(arch_type))
    end

    return {
        os = artifact_os,
        arch = artifact_arch,
        archive = artifact_os == "windows" and "agent-cli-package.zip" or "agent-cli-package.tar.gz",
    }
end

--- Resolve the active Mise runtime to Cursor's artifact naming.
--- @return table
function M.current()
    return M.resolve(RUNTIME.osType, RUNTIME.archType)
end

return M
