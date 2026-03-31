#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="${HOME}/.local/bin:/usr/local/bin:/usr/bin:${PATH}"

if ! command -v mise >/dev/null 2>&1; then
    echo "mise not found; install from https://mise.jdx.dev" >&2
    exit 1
fi

DATA="${TMPDIR:-/tmp}/mise-cursor-agent-verify-$$"
cleanup() {
    rm -rf "$DATA"
}
trap cleanup EXIT

mkdir -p "$DATA"
export MISE_DATA_DIR="$DATA"
export MISE_STATE_DIR="$DATA/state"

# Avoid loading an untrusted mise.toml from the plugin repo root
WORKDIR="${TMPDIR:-/tmp}/mise-cursor-agent-work-$$"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "==> plugin link cursor-agent -> $ROOT"
mise plugin link cursor-agent "$ROOT"

echo "==> ls-remote (fetches install script + tarball hash; may take a minute)"
mise ls-remote cursor-agent

echo "==> install latest (downloads tarball, verifies sha256)"
mise install cursor-agent@latest

echo "==> exec smoke"
mise exec cursor-agent@latest -- cursor-agent --version

PINNED="$(mise ls-remote cursor-agent | grep -E '^[0-9]{4}\.[0-9]{2}\.[0-9]{2}-[a-f0-9]+$' | head -1)"
test -n "$PINNED"
echo "==> install pinned id ${PINNED} (no install-script fetch in PreInstall)"
mise install "cursor-agent@${PINNED}"
mise exec "cursor-agent@${PINNED}" -- cursor-agent --version | grep -q "$PINNED"

echo "verify_mise: ok"
