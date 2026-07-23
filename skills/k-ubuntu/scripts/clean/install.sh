#!/bin/bash
# install.sh — Install clean-system systemd units and enable the timer.
# Run once as root (or with sudo) on a new machine.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_SRC="$SCRIPT_DIR/systemd/clean-system.service"
TIMER_SRC="$SCRIPT_DIR/systemd/clean-system.timer"
SYSTEMD_DIR="/etc/systemd/system"

# ── 1. Pre-checks ─────────────────────────────────────────────────────────────
echo "→ [install] Pre-checks..."

if [[ $EUID -ne 0 ]]; then
    echo "❌ Must be run as root: sudo bash install.sh" >&2
    exit 1
fi

if [[ ! -f "$SERVICE_SRC" ]] || [[ ! -f "$TIMER_SRC" ]]; then
    echo "❌ Missing systemd units in $SCRIPT_DIR/systemd/ — aborting." >&2
    exit 1
fi

echo "   ✓ Running as root, unit files found"

# ── 2. Install systemd units ───────────────────────────────────────────────────
echo "→ [install] Installing systemd units..."

sed "s|@SCRIPT_DIR@|$SCRIPT_DIR|g" "$SERVICE_SRC" > "$SYSTEMD_DIR/clean-system.service"
cp "$TIMER_SRC" "$SYSTEMD_DIR/clean-system.timer"
chmod 644 "$SYSTEMD_DIR/clean-system.service" "$SYSTEMD_DIR/clean-system.timer"
mkdir -p /var/log/clean-system

echo "   ✓ Units installed to $SYSTEMD_DIR/"
echo "   ✓ Log directory: /var/log/clean-system/"

# ── 3. Enable and start timer ─────────────────────────────────────────────────
echo "→ [install] Reloading systemd and enabling timer..."

systemctl daemon-reload
systemctl enable --now clean-system.timer

echo "   ✓ Timer enabled"

# ── 4. Done ───────────────────────────────────────────────────────────────────
echo ""
echo "✅ clean-system installed."
echo "   Timer:   $(systemctl list-timers clean-system.timer --no-pager 2>/dev/null | tail -1)"
echo "   Logs:    journalctl -u clean-system"
echo "   Run now: sudo systemctl start clean-system.service"
