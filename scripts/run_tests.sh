#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Packaging required by https://mise.jdx.dev/plugin-publishing.html
test -f metadata.lua
test -f README.md
test -f LICENSE
grep -q 'name = "cursor-agent"' metadata.lua
grep -q 'updateUrl' metadata.lua

lua5.1 test/cursor_agent_spec.lua
