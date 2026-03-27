local M = {}

local os_map = {
    darwin = "darwin",
    linux = "linux",
}

local arch_map = {
    amd64 = "x64",
    arm64 = "arm64",
}

function M.get()
    local os = os_map[RUNTIME.osType]
    if os == nil then
        error("Unsupported OS: " .. RUNTIME.osType .. " (cursor-agent only supports macOS and Linux)")
    end
    local arch = arch_map[RUNTIME.archType]
    if arch == nil then
        error("Unsupported architecture: " .. RUNTIME.archType)
    end
    return os, arch
end

return M
