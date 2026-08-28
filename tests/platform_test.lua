package.path = "./lib/?.lua;" .. package.path

local cursor = require("cursor")
local platform = require("platform")

local cases = {
    { "linux", "amd64", "linux", "x64", "agent-cli-package.tar.gz" },
    { "Linux", "x86_64", "linux", "x64", "agent-cli-package.tar.gz" },
    { "linux", "arm64", "linux", "arm64", "agent-cli-package.tar.gz" },
    { "linux", "aarch64", "linux", "arm64", "agent-cli-package.tar.gz" },
    { "darwin", "amd64", "darwin", "x64", "agent-cli-package.tar.gz" },
    { "Darwin", "arm64", "darwin", "arm64", "agent-cli-package.tar.gz" },
    { "macos", "aarch64", "darwin", "arm64", "agent-cli-package.tar.gz" },
    { "windows", "amd64", "windows", "x64", "agent-cli-package.zip" },
    { "Windows", "arm64", "windows", "arm64", "agent-cli-package.zip" },
    { "win32", "x64", "windows", "x64", "agent-cli-package.zip" },
}

for _, case in ipairs(cases) do
    local actual = platform.resolve(case[1], case[2])
    assert(actual.os == case[3], case[1] .. "/" .. case[2] .. ": wrong OS")
    assert(actual.arch == case[4], case[1] .. "/" .. case[2] .. ": wrong architecture")
    assert(actual.archive == case[5], case[1] .. "/" .. case[2] .. ": wrong archive")
end

local os_ok = pcall(platform.resolve, "freebsd", "amd64")
assert(not os_ok, "unsupported operating systems must be rejected")

local arch_ok = pcall(platform.resolve, "linux", "riscv64")
assert(not arch_ok, "unsupported architectures must be rejected")

local unix = platform.resolve("linux", "amd64")
local unix_url = cursor.download_url("2026.08.25-3e8eec8", unix)
assert(
    unix_url == "https://downloads.cursor.com/lab/2026.08.25-3e8eec8/linux/x64/agent-cli-package.tar.gz",
    "wrong Linux download URL"
)

local windows = platform.resolve("windows", "arm64")
local windows_url = cursor.download_url("2026.08.25-3e8eec8", windows)
assert(
    windows_url == "https://downloads.cursor.com/lab/2026.08.25-3e8eec8/windows/arm64/agent-cli-package.zip",
    "wrong Windows download URL"
)

local shell_installer = [[
DOWNLOAD_URL="https://downloads.cursor.com/lab/2026.08.25-3e8eec8/${OS}/${ARCH}/agent-cli-package.tar.gz"
]]
assert(cursor.version_from_installer(shell_installer) == "2026.08.25-3e8eec8", "shell installer parsing failed")

local powershell_installer = "$version = '2026.08.25-3e8eec8'"
assert(
    cursor.version_from_installer(powershell_installer) == "2026.08.25-3e8eec8",
    "PowerShell installer parsing failed"
)

local version_ok = pcall(cursor.validate_version, "../../malicious")
assert(not version_ok, "invalid versions must be rejected")
assert(
    cursor.validate_version("2026.08.25-22-15-30-3e8eec8") == "2026.08.25-22-15-30-3e8eec8",
    "timestamped versions must be accepted"
)

print("platform and release mappings passed")
