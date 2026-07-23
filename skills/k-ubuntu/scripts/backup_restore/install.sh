#!/bin/bash
# install.sh — Install backup-restore systemd units and enable the timer.
# Run once as root (or with sudo) on a new machine.
# Requires .env to be configured first (copy from .env.example).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_SRC="$SCRIPT_DIR/systemd/backup-restore.service"
TIMER_SRC="$SCRIPT_DIR/systemd/backup-restore.timer"
SYSTEMD_DIR="/etc/systemd/system"

# ── 1. Pre-checks ─────────────────────────────────────────────────────────────
echo "→ [install] Pre-checks..."

if [[ $EUID -ne 0 ]]; then
    echo "❌ Must be run as root: sudo bash install.sh" >&2
    exit 1
fi

if [[ ! -f "$SCRIPT_DIR/.env" ]]; then
    echo "❌ .env not found — copy .env.example to .env and fill in values first." >&2
    exit 1
fi

if [[ ! -f "$SERVICE_SRC" ]] || [[ ! -f "$TIMER_SRC" ]]; then
    echo "❌ Missing systemd units in $SCRIPT_DIR/systemd/ — aborting." >&2
    exit 1
fi

echo "   ✓ Running as root, .env and unit files found"

# ── 2. Stop old backup-pc units if present ────────────────────────────────────
echo "→ [install] Removing legacy backup-pc units (if present)..."
systemctl stop   backup-pc.timer   2>/dev/null || true
systemctl disable backup-pc.timer  2>/dev/null || true
systemctl stop   backup-pc.service 2>/dev/null || true
rm -f "$SYSTEMD_DIR/backup-pc.service" "$SYSTEMD_DIR/backup-pc.timer"
echo "   ✓ Legacy units removed (if existed)"

# ── 3. Install systemd units ──────────────────────────────────────────────────
echo "→ [install] Installing systemd units..."

sed "s|@SCRIPT_DIR@|$SCRIPT_DIR|g" "$SERVICE_SRC" > "$SYSTEMD_DIR/backup-restore.service"
cp "$TIMER_SRC" "$SYSTEMD_DIR/backup-restore.timer"
chmod 644 "$SYSTEMD_DIR/backup-restore.service" "$SYSTEMD_DIR/backup-restore.timer"

echo "   ✓ Units installed to $SYSTEMD_DIR/"

# ── 4. Secure .env ────────────────────────────────────────────────────────────
chmod 600 "$SCRIPT_DIR/.env"
echo "   ✓ .env permissions set to 600"

# ── 5. Enable and start timer ─────────────────────────────────────────────────
echo "→ [install] Reloading systemd and enabling timer..."

systemctl daemon-reload
systemctl enable --now backup-restore.timer

echo "   ✓ Timer enabled"

# ── 6. Done ───────────────────────────────────────────────────────────────────
echo ""
echo "✅ backup-restore installed."
echo "   Timer:   $(systemctl list-timers backup-restore.timer --no-pager 2>/dev/null | tail -1)"
echo "   Logs:    journalctl -u backup-restore"
echo "   Run now: sudo systemctl start backup-restore.service"
