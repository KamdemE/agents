#!/bin/bash
# ==============================================================================
# restore_workstation.sh — Phoenix Protocol: bare-metal workstation restore
# Usage: sudo ./restore_workstation.sh <backup.tar.zst> [USERNAME]
#   USERNAME defaults to USER_BACKUP from .env or prompts interactively.
# Author: KpihX [CLAUDE]
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Load .env if available (provides USER_BACKUP) ─────────────────────────────
[[ -f "$SCRIPT_DIR/.env" ]] && source "$SCRIPT_DIR/.env" || true

# ── Arguments ─────────────────────────────────────────────────────────────────
ARCHIVE_PATH="${1:-}"
USER_RESTORE="${2:-${USER_BACKUP:-}}"
RESTORE_ROOT="/tmp/phoenix_restore"

if [[ "$EUID" -ne 0 ]]; then
    echo "❌ Must run as root: sudo $0 <archive.tar.zst> [username]" >&2
    exit 1
fi

if [[ -z "$ARCHIVE_PATH" ]]; then
    echo "Usage: sudo $0 <path/to/backup.tar.zst> [username]"
    echo "Example: sudo $0 /media/kpihx/KpihX-Backup/backup-kpihx-ubuntu-2026-01-01.tar.zst kpihx"
    exit 1
fi

if [[ ! -f "$ARCHIVE_PATH" ]]; then
    echo "❌ Archive not found: $ARCHIVE_PATH" >&2
    exit 1
fi

# Interactive fallback for username
if [[ -z "$USER_RESTORE" ]]; then
    read -rp "Username to restore into (e.g. kpihx): " USER_RESTORE
fi
if [[ -z "$USER_RESTORE" ]]; then
    echo "❌ No username provided." >&2; exit 1
fi

USER_HOME="/home/$USER_RESTORE"
echo "🔥 PHOENIX PROTOCOL — restoring to: $USER_HOME"
echo "   Archive: $ARCHIVE_PATH"
echo "---"

# ── Phase 1: Install tools ─────────────────────────────────────────────────────
echo "🛠️  Phase 1: Installing required tools..."
apt-get update -qq
apt-get install -y zstd pv dselect rsync

# ── Phase 2: Extract to sandbox ───────────────────────────────────────────────
echo "📦 Phase 2: Extracting archive (this may take several minutes)..."
mkdir -p "$RESTORE_ROOT"
pv "$ARCHIVE_PATH" | zstd -d | tar -x -C "$RESTORE_ROOT" --warning=no-timestamp

echo "✅ Extraction complete."

METADATA_SOURCE="$(find "$RESTORE_ROOT" -type d -name "temp_metadata" | head -n 1)"
HOME_SOURCE="$RESTORE_ROOT$USER_HOME"
ETC_SOURCE="$RESTORE_ROOT/etc"

if [[ -z "$METADATA_SOURCE" ]]; then
    echo "❌ Could not find temp_metadata in archive." >&2
    exit 1
fi

# ── Phase 3: System intelligence ──────────────────────────────────────────────
echo "🧠 Phase 3: Restoring system packages and keys..."

cp -r "$METADATA_SOURCE/sources.list"*  /etc/apt/ 2>/dev/null || true
cp -r "$METADATA_SOURCE/trusted.gpg"*   /etc/apt/ 2>/dev/null || true
[[ -d "$METADATA_SOURCE/keyrings" ]] && \
    cp -r "$METADATA_SOURCE/keyrings/"* /usr/share/keyrings/ 2>/dev/null || true

apt-get update -qq

echo "   → Reinstalling APT packages..."
dpkg --clear-selections
dpkg --set-selections < "$METADATA_SOURCE/packages_apt.txt"
DEBIAN_FRONTEND=noninteractive apt-get dselect-upgrade -y

if [[ -f "$METADATA_SOURCE/packages_snap.txt" ]]; then
    echo "   → Reinstalling Snap packages..."
    tail -n +2 "$METADATA_SOURCE/packages_snap.txt" | awk '{print $1}' | while read -r pkg; do
        snap install "$pkg" --classic 2>/dev/null || snap install "$pkg" 2>/dev/null || true
    done
fi

if [[ -f "$METADATA_SOURCE/vscode_extensions.txt" ]] && command -v code &>/dev/null; then
    echo "   → Reinstalling VSCode extensions..."
    sudo -u "$USER_RESTORE" xargs -L 1 code --install-extension \
        < "$METADATA_SOURCE/vscode_extensions.txt"
fi

# ── Phase 4: Home directory ────────────────────────────────────────────────────
echo "🏠 Phase 4: Restoring $USER_HOME..."
rsync -aAXv --info=progress2 "$HOME_SOURCE/" "$USER_HOME/"
chown -R "$USER_RESTORE:$USER_RESTORE" "$USER_HOME"

if [[ -f "$METADATA_SOURCE/gnome_settings.ini" ]] && command -v dconf &>/dev/null; then
    echo "🎨 Restoring GNOME preferences..."
    sudo -u "$USER_RESTORE" dbus-launch dconf load / < "$METADATA_SOURCE/gnome_settings.ini" || true
fi

# ── Phase 5: System configs ────────────────────────────────────────────────────
echo "⚙️  Phase 5: Restoring system configs (SSH, VPN, network, cron)..."

[[ -d "$ETC_SOURCE/ssh" ]] && {
    cp -r "$ETC_SOURCE/ssh/"* /etc/ssh/
    chmod 600 /etc/ssh/ssh_host_*_key 2>/dev/null || true
}
[[ -d "$ETC_SOURCE/wireguard" ]] && cp -r "$ETC_SOURCE/wireguard" /etc/
[[ -d "$ETC_SOURCE/nekoray"   ]] && cp -r "$ETC_SOURCE/nekoray"   /etc/
[[ -d "$ETC_SOURCE/NetworkManager/system-connections" ]] && {
    cp -r "$ETC_SOURCE/NetworkManager/system-connections/"* \
        /etc/NetworkManager/system-connections/
    chmod 600 /etc/NetworkManager/system-connections/*
}
[[ -f "$METADATA_SOURCE/crontab_root.txt" ]] && crontab "$METADATA_SOURCE/crontab_root.txt"
[[ -f "$METADATA_SOURCE/crontab_user.txt" ]] && \
    crontab -u "$USER_RESTORE" "$METADATA_SOURCE/crontab_user.txt"

# ── Cleanup ───────────────────────────────────────────────────────────────────
echo "🧹 Cleaning up temporary files..."
rm -rf "$RESTORE_ROOT"

echo ""
echo "✅ Phoenix Protocol complete. Reboot now to finalize."
echo "   Note: /etc/fstab and /etc/shadow were NOT restored (machine-specific)."
