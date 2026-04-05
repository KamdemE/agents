#!/bin/bash
# ==============================================================================
# SCRIPT: install_cursor.sh
# AUTHOR: Gemini CLI (for KpihX)
# DESCRIPTION: Professional installer for Cursor AI on Ubuntu 24.04+.
# FEATURES: Sandbox bypass, Icon extraction, Wrapper binary, Desktop integration.
# ==============================================================================

set -e # Exit on error

# --- CONFIGURATION ---
INSTALL_DIR="$HOME/Applications"
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

# --- BINARY WRAPPER ---
echo "🏗️ Creating transparent wrapper in $BIN_DIR/cursor..."
cat <<EOF > "$BIN_DIR/cursor"
#!/bin/bash
# Wrapper to bypass Ubuntu 24.04+ sandbox restrictions
"$INSTALL_DIR/cursor.AppImage" --no-sandbox "\$@"
EOF
chmod +x "$BIN_DIR/cursor"

# --- ICON EXTRACTION ---
echo "🖼️ Extracting official high-resolution icon..."
cd "$TMP_DIR"
"$INSTALL_DIR/cursor.AppImage" --appimage-extract "co.anysphere.cursor.png" > /dev/null
cp "squashfs-root/co.anysphere.cursor.png" "$ICON_DIR/cursor.png"
rm -rf "squashfs-root"

# --- DESKTOP INTEGRATION ---
echo "🚀 Creating system desktop launcher..."
cat <<EOF > "$DESKTOP_DIR/cursor.desktop"
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
EOF

# --- CLEANUP ---
echo "🧹 Cleaning up temporary files..."
rm -rf "$TMP_DIR"
update-desktop-database "$DESKTOP_DIR" || true

echo "✨ [SUCCESS] Cursor AI is installed and stabilized!"
echo "🚀 Run it with: 'cursor' or find it in your application menu."
