local http = require("http")

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

    local version = resp.body:match("(%d%d%d%d%.%d%d%.%d%d%-[a-f0-9]+)")
    if version == nil then
        error("Could not extract version from cursor.com/install")
    end

    return {
        { version = version },
    }
end
