#!/bin/bash
# ==============================================================================
# SCRIPT: sync_zed_settings.sh
# DESCRIPTION: Symlink k-zed skill assets/settings.json to live Zed config.
# ==============================================================================
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSETS_DIR="$SKILL_DIR/assets"
LIVE_SETTINGS="${ZED_SETTINGS:-$HOME/.config/zed/settings.json}"

mkdir -p "$ASSETS_DIR"
cd "$ASSETS_DIR"
rm -f settings.json
ln -sfn "$LIVE_SETTINGS" settings.json

echo "Linked: $ASSETS_DIR/settings.json -> $LIVE_SETTINGS"
ls -la "$ASSETS_DIR/settings.json"
