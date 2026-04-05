#!/bin/bash
# ==============================================================================
# SCRIPT: sync_agy.sh
# DESCRIPTION: Synchronizes Antigravity configuration with VS Code.
# ==============================================================================
set -e
FORK_NAME="Antigravity"
FORK_LOWER="antigravity"
FORK_CONFIG_DIR="$HOME/.config/$FORK_NAME"
FORK_EXT_BASE="$HOME/.$FORK_LOWER"

echo "🔄 Synchronizing $FORK_NAME to use VS Code configurations..."
mkdir -p "$FORK_CONFIG_DIR/User/globalStorage"
find "$FORK_CONFIG_DIR/User" -maxdepth 2 -type l -delete || true

cd "$FORK_CONFIG_DIR/User"
rm -f settings.json keybindings.json
ln -s ../../Code/User/settings.json settings.json
ln -s ../../Code/User/keybindings.json keybindings.json
rm -rf profiles
ln -s ../../Code/User/profiles profiles
cd globalStorage
rm -f storage.json
ln -s ../../../Code/User/globalStorage/storage.json storage.json

mkdir -p "$FORK_EXT_BASE"
ln -sfT "$HOME/.vscode/extensions" "$FORK_EXT_BASE/extensions"
echo "✨ [SUCCESS] $FORK_NAME is now fully synchronized with VS Code!"
