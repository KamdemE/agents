#!/bin/bash
# purge.sh — Disable and remove clean-system symlinks.
# Run as root (or with sudo) to fully uninstall the scheduler.

set -euo pipefail

SYSTEMD_DIR="/etc/systemd/system"

if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root (sudo $0)" >&2; exit 1
fi

echo "→ Stopping and disabling timer..."
systemctl stop  clean-system.timer  2>/dev/null || true
systemctl disable clean-system.timer 2>/dev/null || true

echo "→ Stopping service (if active)..."
systemctl stop clean-system.service 2>/dev/null || true

echo "→ Removing symlinks..."
rm -f "$SYSTEMD_DIR/clean-system.service"
rm -f "$SYSTEMD_DIR/clean-system.timer"

echo "→ Reloading systemd..."
systemctl daemon-reload
systemctl reset-failed 2>/dev/null || true

echo ""
echo "✅ clean-system purged. Symlinks removed, timer disabled."
echo "   Logs preserved in /var/log/clean-system/ — remove manually if needed."
