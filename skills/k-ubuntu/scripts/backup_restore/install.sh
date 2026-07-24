#!/bin/bash
# install.sh — Symlink backup-restore systemd units and enable the timer.
# Run once as root (or with sudo) on a new machine.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYSTEMD_DIR="/etc/systemd/system"

echo "→ [install] Pre-checks..."
if [[ $EUID -ne 0 ]]; then
    echo "❌ Must be run as root: sudo bash install.sh" >&2; exit 1
fi
AGENTS_ENV="/home/kpihx/.agents/.env"
if [[ ! -f "$AGENTS_ENV" ]]; then
    echo "❌ $AGENTS_ENV not found — create it from .env.example first." >&2; exit 1
fi
echo "   ✓ Running as root, .env found"

echo "→ [install] Creating symlinks..."
ln -sf "$SCRIPT_DIR/systemd/backup-restore.service" "$SYSTEMD_DIR/backup-restore.service"
ln -sf "$SCRIPT_DIR/systemd/backup-restore.timer"   "$SYSTEMD_DIR/backup-restore.timer"

echo "   ✓ Symlinks: $SYSTEMD_DIR/backup-restore.{service,timer}"

echo "→ [install] Reloading systemd and enabling timer..."
systemctl daemon-reload
systemctl enable --now backup-restore.timer

echo "→ [install] Starting service once to verify..."
systemctl start backup-restore.service || echo "⚠️ Service start had issues — check logs: journalctl -u backup-restore"

echo ""
echo "✅ backup-restore installed (symlinks) and triggered."
echo "   Timer:   $(systemctl list-timers backup-restore.timer --no-pager 2>/dev/null | tail -1)"
echo "   Logs:    journalctl -u backup-restore -f"
