#!/bin/bash
# ==============================================================================
# SCRIPT: install_cursor.sh
# AUTHOR: Gemini CLI (for KpihX) / AI
# DESCRIPTION: Professional installer for Cursor AI on Ubuntu 24.04+.
# FEATURES: Sandbox bypass via appimage extraction, Desktop integration.
# ==============================================================================

set -e # Exit on error

# --- CONFIGURATION ---
INSTALL_DIR="$HOME/Applications"
EXTRACT_DIR="$INSTALL_DIR/cursor-app"
BIN_DIR="$HOME/.local/bin"
ICON_DIR="$HOME/.local/share/icons"
DESKTOP_DIR="$HOME/.local/share/applications"
TMP_DIR="/tmp/cursor_install"

mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$ICON_DIR" "$DESKTOP_DIR" "$TMP_DIR"

echo "🏛️ [ARCHITECT] Starting Sovereign Cursor Installation..."

# --- DEPENDENCIES ---
if ! dpkg -l | grep -q libfuse2; then
    echo "📦 Installing libfuse2 dependency..."
    sudo apt update && sudo apt install -y libfuse2t64 || sudo apt install -y libfuse2
fi

# --- DOWNLOAD ---
echo "📡 Fetching latest stable download URL..."
METADATA_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
DOWNLOAD_URL=$(curl -sL "$METADATA_URL" | grep -oP '"downloadUrl":"\K[^"]+')

echo "📥 Downloading Cursor AppImage..."
wget --no-check-certificate -O "$INSTALL_DIR/cursor.AppImage" "$DOWNLOAD_URL"
chmod +x "$INSTALL_DIR/cursor.AppImage"

# --- EXTRACTION FOR SANDBOX BYPASS ---
echo "📦 Extracting AppImage to bypass AppArmor unprivileged_userns restrictions..."
cd "$INSTALL_DIR"
rm -rf "$EXTRACT_DIR"
./cursor.AppImage --appimage-extract > /dev/null
mv squashfs-root "$EXTRACT_DIR"

# --- BINARY WRAPPER ---
echo "🏗️ Creating transparent wrapper in $BIN_DIR/cursor..."
cat <<WRAPPER > "$BIN_DIR/cursor"
#!/bin/bash
# Wrapper to bypass Ubuntu 24.04+ sandbox restrictions pointing to extracted app
"$EXTRACT_DIR/AppRun" --no-sandbox "\$@"
WRAPPER
chmod +x "$BIN_DIR/cursor"

# --- ICON EXTRACTION ---
echo "🖼️ Extracting official high-resolution icon..."
cp "$EXTRACT_DIR/cursor.png" "$ICON_DIR/cursor.png" || true

# --- DESKTOP INTEGRATION ---
echo "🚀 Creating system desktop launcher..."
cat <<DESKTOP > "$DESKTOP_DIR/cursor.desktop"
[Desktop Entry]
Name=Cursor
Exec=$BIN_DIR/cursor %F
Terminal=false
Type=Application
Icon=$ICON_DIR/cursor.png
Categories=Development;IDE;
MimeType=text/plain;inode/directory;
Comment=AI-first Code Editor
StartupWMClass=cursor-url-handler
Actions=new-empty-window;
Keywords=vscode;cursor;ai;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=$BIN_DIR/cursor --new-window
Icon=$ICON_DIR/cursor.png
DESKTOP

# --- CLEANUP ---
echo "🧹 Cleaning up temporary files and raw AppImage..."
rm -f "$INSTALL_DIR/cursor.AppImage"
rm -rf "$TMP_DIR"
update-desktop-database "$DESKTOP_DIR" || true

echo "✨ [SUCCESS] Cursor AI is installed and fully extracted to bypass AppArmor!"
echo "🚀 Run it with: 'cursor' or find it in your application menu."
