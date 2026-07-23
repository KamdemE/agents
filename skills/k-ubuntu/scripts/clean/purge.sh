#!/bin/bash
# purge.sh — Disable and remove clean-system systemd units.
# Run as root (or with sudo) to fully uninstall the scheduler.

set -euo pipefail

SYSTEMD_DIR="/etc/systemd/system"

# ── 1. Pre-checks ─────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root (sudo $0)" >&2
    exit 1
fi

# ── 2. Stop and disable timer ─────────────────────────────────────────────────
echo "→ Stopping and disabling clean-system timer..."
systemctl stop  clean-system.timer  2>/dev/null || true
systemctl disable clean-system.timer 2>/dev/null || true

# ── 3. Stop service if running ────────────────────────────────────────────────
echo "→ Stopping clean-system service (if active)..."
systemctl stop clean-system.service 2>/dev/null || true

# ── 4. Remove unit files ───────────────────────────────────────────────────────
echo "→ Removing unit files..."
rm -f "$SYSTEMD_DIR/clean-system.service"
rm -f "$SYSTEMD_DIR/clean-system.timer"

# ── 5. Reload systemd ─────────────────────────────────────────────────────────
echo "→ Reloading systemd daemon..."
systemctl daemon-reload
systemctl reset-failed 2>/dev/null || true

echo ""
echo "✅ clean-system purged. Unit files removed, timer disabled."
echo "   Logs are preserved in /var/log/clean-system/ — remove manually if no longer needed."
