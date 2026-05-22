#!/bin/bash
# ==============================================================================
# SCRIPT: sync_agy.sh
# DESCRIPTION: Synchronizes Antigravity config dir(s) with VS Code (k-code hub).
# Usage:
#   sync_agy.sh                          # ~/.config/Antigravity + ~/.antigravity
#   sync_agy.sh "Antigravity IDE" antigravity-ide
# ==============================================================================
set -e

sync_one() {
  local FORK_NAME="$1"
  local FORK_LOWER="$2"
  local FORK_CONFIG_DIR="$HOME/.config/$FORK_NAME"
  local FORK_EXT_BASE="$HOME/.$FORK_LOWER"

  echo "🔄 Synchronizing $FORK_NAME to use VS Code configurations..."
  mkdir -p "$FORK_CONFIG_DIR/User/globalStorage"
  find "$FORK_CONFIG_DIR/User" -maxdepth 1 -type l -delete 2>/dev/null || true

  cd "$FORK_CONFIG_DIR/User"
  rm -f settings.json keybindings.json
  ln -sf ../../Code/User/settings.json settings.json
  ln -sf ../../Code/User/keybindings.json keybindings.json
  rm -rf profiles
  ln -sfn ../../Code/User/profiles profiles
  mkdir -p globalStorage
  cd globalStorage
  rm -f storage.json
  ln -sf ../../../Code/User/globalStorage/storage.json storage.json

  mkdir -p "$FORK_EXT_BASE"
  rm -rf "$FORK_EXT_BASE/extensions"
  ln -sfT "$HOME/.vscode/extensions" "$FORK_EXT_BASE/extensions"
  echo "✨ [SUCCESS] $FORK_NAME is now fully synchronized with VS Code!"
}

FORK_NAME="${1:-Antigravity}"
FORK_LOWER="${2:-antigravity}"
sync_one "$FORK_NAME" "$FORK_LOWER"

if [[ $# -eq 0 ]]; then
  sync_one "Antigravity IDE" "antigravity-ide"
fi
