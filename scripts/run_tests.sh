#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
lua5.1 test/cursor_agent_spec.lua
