#!/usr/bin/env bash
# Verify the plugin via the user-facing install path:
#   mise plugin install <name> <git-url>
# (mise clones the plugin; no manual git clone is required).
#
# Usage:
#   scripts/verify_mise.sh           # install from a temporary git URL
#   scripts/verify_mise.sh --link    # symlink this working tree (dev)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="${HOME}/.local/bin:/usr/local/bin:/usr/bin:${PATH}"

if ! command -v mise >/dev/null 2>&1; then
    echo "mise not found; install from https://mise.jdx.dev" >&2
    exit 1
fi

SOURCE="git"
if [[ "${1:-}" == "--link" ]]; then
    SOURCE="link"
elif [[ "${1:-}" != "" ]]; then
    echo "usage: $0 [--link]" >&2
    exit 2
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

if [[ "$SOURCE" == "link" ]]; then
    echo "==> plugin link cursor-agent -> $ROOT"
    mise plugin link cursor-agent "$ROOT"
else
    # Bare clone so mise plugin install uses a real git URL (file://),
    # matching `mise plugin install cursor-agent https://github.com/...`.
    BARE="${DATA}/plugin.git"
    git clone --quiet --bare "$ROOT" "$BARE"
    GIT_URL="file://${BARE}"
    echo "==> plugin install cursor-agent ${GIT_URL}"
    mise plugin install cursor-agent "$GIT_URL"
    test -f "${MISE_DATA_DIR}/plugins/cursor-agent/metadata.lua"
fi

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
