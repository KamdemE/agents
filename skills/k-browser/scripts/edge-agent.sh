#!/usr/bin/env zsh
# Launch Microsoft Edge for agent automation (visible, CDP, persistent login profile).
# Not the Default profile — Chrome/Edge 136+ blocks remote debugging on the main user-data dir.
set -euo pipefail

EDGE_DATA="${KPIHX_EDGE_DATA:-$HOME/.config/kpihx-edge-automation}"
EDGE_PORT="${KPIHX_EDGE_DEBUG_PORT:-9222}"

mkdir -p "$EDGE_DATA"

if command -v microsoft-edge >/dev/null 2>&1; then
  EDGE_BIN=microsoft-edge
elif command -v microsoft-edge-stable >/dev/null 2>&1; then
  EDGE_BIN=microsoft-edge-stable
else
  echo "microsoft-edge not found in PATH" >&2
  exit 1
fi

exec "$EDGE_BIN" \
  --remote-debugging-port="$EDGE_PORT" \
  --user-data-dir="$EDGE_DATA" \
  --no-first-run \
  "$@"
