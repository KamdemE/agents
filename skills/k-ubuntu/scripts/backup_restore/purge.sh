#!/bin/bash
# purge.sh — Disable and remove backup-restore systemd units.
# Run as root (or with sudo) to fully uninstall the scheduler.

set -euo pipefail

SYSTEMD_DIR="/etc/systemd/system"

# ── 1. Pre-checks ─────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root (sudo $0)" >&2
    exit 1
fi

# ── 2. Stop and disable timer ─────────────────────────────────────────────────
echo "→ Stopping and disabling backup-restore timer..."
systemctl stop    backup-restore.timer   2>/dev/null || true
systemctl disable backup-restore.timer   2>/dev/null || true

# ── 3. Stop service if running ────────────────────────────────────────────────
echo "→ Stopping backup-restore service (if active)..."
systemctl stop backup-restore.service 2>/dev/null || true

# ── 4. Remove unit files ──────────────────────────────────────────────────────
echo "→ Removing unit files..."
rm -f "$SYSTEMD_DIR/backup-restore.service"
rm -f "$SYSTEMD_DIR/backup-restore.timer"

# ── 5. Reload systemd ─────────────────────────────────────────────────────────
echo "→ Reloading systemd daemon..."
systemctl daemon-reload
systemctl reset-failed 2>/dev/null || true

echo ""
echo "✅ backup-restore purged. Unit files removed, timer disabled."
echo "   Archives on external HDD are preserved — remove manually if no longer needed."
