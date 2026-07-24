#!/bin/bash
# install.sh — Symlink clean-system systemd units and enable the timer.
# Source of truth stays in .agents/k-ubuntu/scripts/clean/systemd/.
# Run once as root (or with sudo) on a new machine.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SYSTEMD_DIR="/etc/systemd/system"

echo "→ [install] Pre-checks..."
if [[ $EUID -ne 0 ]]; then
    echo "❌ Must be run as root: sudo bash install.sh" >&2; exit 1
fi

echo "   ✓ Running as root"

echo "→ [install] Creating symlinks..."
ln -sf "$SCRIPT_DIR/systemd/clean-system.service" "$SYSTEMD_DIR/clean-system.service"
ln -sf "$SCRIPT_DIR/systemd/clean-system.timer"   "$SYSTEMD_DIR/clean-system.timer"
mkdir -p /var/log/clean-system

echo "   ✓ Symlinks: $SYSTEMD_DIR/clean-system.{service,timer}"
echo "   ✓ Log dir:  /var/log/clean-system/"

echo "→ [install] Reloading systemd and enabling timer..."
systemctl daemon-reload
systemctl enable --now clean-system.timer

echo ""
echo "✅ clean-system installed (symlinks) and timer enabled."
echo "   Timer:   $(systemctl list-timers clean-system.timer --no-pager 2>/dev/null | tail -1)"
echo "   Logs:    journalctl -u clean-system -f"
