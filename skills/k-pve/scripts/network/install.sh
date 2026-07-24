#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ASSETS_DIR="$(cd "$SCRIPT_DIR/../../assets/network" && pwd)"
SYSTEMD_DIR="/etc/systemd/system"
[[ $EUID -ne 0 ]] && echo "❌ Must be root." >&2 && exit 1
ln -sf "$ASSETS_DIR/pve-watchdog.service" "$SYSTEMD_DIR/"
ln -sf "$ASSETS_DIR/pve-watchdog.timer"   "$SYSTEMD_DIR/"
ln -sf "$ASSETS_DIR/pve-boot-notify.service" "$SYSTEMD_DIR/"
systemctl daemon-reload
systemctl enable --now pve-watchdog.timer
systemctl enable pve-boot-notify.service
echo "✅ PVE network units installed (symlinks from assets/network/)."
