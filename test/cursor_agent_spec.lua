#!/usr/bin/env lua5.1
-- Unit tests for lib/cursor_agent.lua (no mise runtime required).

local root = debug.getinfo(1, "S").source:sub(2):match("^(.*[/\\])") or "./"
root = root:gsub("test[/\\]$", ""):gsub("test$", "")
package.path = root .. "lib/?.lua;" .. root .. "?.lua;" .. package.path

package.loaded["platform"] = {
    get = function()
        return "linux", "x64"
    end,
}

local ca = require("cursor_agent")

local function assert_eq(a, b, msg)
    if a ~= b then
        error((msg or "assertion failed") .. ": expected " .. tostring(b) .. ", got " .. tostring(a))
    end
end

local function assert_true(x, msg)
    if not x then
        error(msg or "expected true")
    end
end

-- parse_version_from_install_script: prefer DOWNLOAD_URL line
local sample = [[
DOWNLOAD_URL="https://downloads.cursor.com/lab/2026.03.30-a5d3e17/linux/x64/agent-cli-package.tar.gz"
]]
local v, err = ca.parse_version_from_install_script(sample)
assert_eq(v, "2026.03.30-a5d3e17", "parse from DOWNLOAD_URL")
assert_eq(err, nil, "no parse error")

-- fallback: lab/ segment
local v2 = ca.parse_version_from_install_script("x lab/2025.12.01-deadbeef/y ")
assert_eq(v2, "2025.12.01-deadbeef", "parse lab fallback")

local v3, e3 = ca.parse_version_from_install_script("no version here")
assert_eq(v3, nil, "missing version")
assert_true(e3 ~= nil, "error string")

-- resolve_install_version
assert_eq(ca.resolve_install_version("latest", "2026.01.01-abc"), "2026.01.01-abc")
local ok, res = pcall(ca.resolve_install_version, "latest", nil)
assert_true(not ok, "latest without current errors")

ok, res = pcall(ca.resolve_install_version, "not-a-version", nil)
assert_true(not ok, "invalid id errors")

assert_eq(ca.resolve_install_version("2026.03.30-a5d3e17", nil), "2026.03.30-a5d3e17")

-- tarball_url
assert_eq(
    ca.tarball_url("2026.03.30-a5d3e17", "linux", "x64"),
    "https://downloads.cursor.com/lab/2026.03.30-a5d3e17/linux/x64/agent-cli-package.tar.gz"
)

-- extra versions env parsing
local extras = ca.parse_extra_versions_string(" 2026.01.01-aaa , 2026.01.01-bbb ,bad, 2026.01.01-aaa ")
assert_eq(extras[1], "2026.01.01-aaa")
assert_eq(extras[2], "2026.01.01-bbb")
assert_eq(#extras, 2)

print("cursor_agent_spec: ok")
