#!/bin/bash
# purge.sh — Disable and remove backup-restore symlinks.
# Run as root (or with sudo) to fully uninstall the scheduler.

set -euo pipefail

SYSTEMD_DIR="/etc/systemd/system"

if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root (sudo $0)" >&2; exit 1
fi

echo "→ Stopping and disabling timer..."
systemctl stop  backup-restore.timer  2>/dev/null || true
systemctl disable backup-restore.timer 2>/dev/null || true

echo "→ Stopping service (if active)..."
systemctl stop backup-restore.service 2>/dev/null || true

echo "→ Removing symlinks..."
rm -f "$SYSTEMD_DIR/backup-restore.service"
rm -f "$SYSTEMD_DIR/backup-restore.timer"

echo "→ Reloading systemd..."
systemctl daemon-reload
systemctl reset-failed 2>/dev/null || true

echo ""
echo "✅ backup-restore purged. Symlinks removed, timer disabled."
