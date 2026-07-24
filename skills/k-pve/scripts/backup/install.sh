#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEMD_DIR="/etc/systemd/system"
[[ $EUID -ne 0 ]] && echo "❌ Must be root." >&2 && exit 1
ln -sf "$SCRIPT_DIR/systemd/pve-backup.service" "$SYSTEMD_DIR/"
ln -sf "$SCRIPT_DIR/systemd/pve-backup.timer"   "$SYSTEMD_DIR/"
systemctl daemon-reload
systemctl enable --now pve-backup.timer
echo "✅ PVE backup units installed (symlinks)."
