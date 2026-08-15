#!/bin/bash
set -euo pipefail
SYSTEMD_DIR="/etc/systemd/system"
[[ $EUID -ne 0 ]] && echo "❌ Must be root." >&2 && exit 1
systemctl stop pve-backup.timer 2>/dev/null || true
systemctl disable pve-backup.timer 2>/dev/null || true
rm -f "$SYSTEMD_DIR/pve-backup.service" "$SYSTEMD_DIR/pve-backup.timer"
systemctl daemon-reload
echo "✅ pve-backup purged."
