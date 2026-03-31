local http = require("http")
local cursor_agent = require("cursor_agent")

function PLUGIN:Available(ctx)
    local resp, err = http.get({
        url = "https://cursor.com/install",
    })
    if err ~= nil then
        error("Failed to fetch cursor.com/install: " .. err)
    end
    if resp.status_code ~= 200 then
        error("cursor.com/install returned HTTP " .. resp.status_code)
    end

    local current, parse_err = cursor_agent.parse_version_from_install_script(resp.body)
    if current == nil then
        error("Could not extract version from cursor.com/install: " .. (parse_err or "unknown"))
    end

    local seen = {}
    local result = {}

    local function add_row(row)
        if seen[row.version] then
            return
        end
        seen[row.version] = true
        table.insert(result, row)
    end

    -- Rolling channel without remote checksum: avoids a full tarball download on ls-remote.
    -- `mise install cursor-agent@latest` still verifies SHA256 during install (PreInstall).
    add_row({
        version = "latest",
        note = "Resolves to the current lab build on install",
        rolling = true,
    })

    add_row({
        version = current,
        note = "Current upstream lab build",
    })

    for _, v in ipairs(cursor_agent.extra_versions_from_env()) do
        add_row({
            version = v,
            note = "From MISE_CURSOR_AGENT_EXTRA_VERSIONS",
        })
    end

    return result
end
