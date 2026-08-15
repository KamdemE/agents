#!/bin/bash
# ==============================================================================
# SCRIPT: sync_cursor.sh
# DESCRIPTION: Synchronizes Cursor configuration with VS Code.
# ==============================================================================
set -e
FORK_NAME="Cursor"
FORK_LOWER="cursor"
FORK_CONFIG_DIR="$HOME/.config/$FORK_NAME"
FORK_EXT_BASE="$HOME/.$FORK_LOWER"

echo "🔄 Synchronizing $FORK_NAME to use VS Code configurations..."
mkdir -p "$FORK_CONFIG_DIR/User/globalStorage"
find "$FORK_CONFIG_DIR/User" -maxdepth 2 -type l -delete || true

cd "$FORK_CONFIG_DIR/User"
rm -f settings.json keybindings.json mcp.json chatLanguageModels.json
ln -s "$HOME/.agents/skills/k-code/assets/settings.json" settings.json
ln -s "$HOME/.agents/skills/k-code/assets/keybindings.json" keybindings.json
ln -s "$HOME/.agents/skills/k-code/assets/mcp.json" mcp.json
ln -s "$HOME/.agents/skills/k-code/assets/chatLanguageModels.json" chatLanguageModels.json
rm -rf profiles snippets
ln -s "$HOME/.config/Code/User/profiles" profiles
ln -s "$HOME/.agents/skills/k-code/assets/snippets" snippets
cd globalStorage
rm -f storage.json
ln -s "$HOME/.config/Code/User/globalStorage/storage.json" storage.json

mkdir -p "$FORK_EXT_BASE"
ln -sfT "$HOME/.vscode/extensions" "$FORK_EXT_BASE/extensions"
echo "✨ [SUCCESS] $FORK_NAME is now fully synchronized with VS Code!"
