#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ASSETS_DIR="$(cd "$SCRIPT_DIR/../../assets/backup" && pwd)"
SYSTEMD_DIR="/etc/systemd/system"
[[ $EUID -ne 0 ]] && echo "❌ Must be root." >&2 && exit 1
ln -sf "$ASSETS_DIR/pve-backup.service" "$SYSTEMD_DIR/"
ln -sf "$ASSETS_DIR/pve-backup.timer"   "$SYSTEMD_DIR/"
systemctl daemon-reload
systemctl enable --now pve-backup.timer
echo "✅ PVE backup units installed (symlinks from assets/backup/)."
