#!/bin/bash
set -euo pipefail
SYSTEMD_DIR="/etc/systemd/system"
[[ $EUID -ne 0 ]] && echo "❌ Must be root." >&2 && exit 1
systemctl stop pve-watchdog.timer pve-boot-notify.service 2>/dev/null || true
systemctl disable pve-watchdog.timer pve-boot-notify.service 2>/dev/null || true
rm -f "$SYSTEMD_DIR/pve-watchdog.service" "$SYSTEMD_DIR/pve-watchdog.timer" "$SYSTEMD_DIR/pve-boot-notify.service"
systemctl daemon-reload
echo "✅ PVE network units purged."
