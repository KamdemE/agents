#!/bin/bash
set -euo pipefail
SYSTEMD_DIR="/etc/systemd/system"
[[ $EUID -ne 0 ]] && echo "❌ Must be root." >&2 && exit 1
systemctl stop dockerhost-vault-backup.timer 2>/dev/null || true
systemctl disable dockerhost-vault-backup.timer 2>/dev/null || true
rm -f "$SYSTEMD_DIR/dockerhost-vault-backup.service" "$SYSTEMD_DIR/dockerhost-vault-backup.timer"
systemctl daemon-reload
echo "✅ Docker host vault units purged."
