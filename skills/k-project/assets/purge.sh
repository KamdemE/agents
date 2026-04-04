#!/bin/bash
# purge.sh — Remove <project-name>.
# Disables the timer/service and removes unit files. Idempotent.
# Run as root: sudo bash scripts/purge.sh

set -euo pipefail

# ── 1. Pre-checks ─────────────────────────────────────────────────────────────
echo "→ [purge] Pre-checks..."

if [[ $EUID -ne 0 ]]; then
    echo "❌ Must be run as root: sudo bash scripts/purge.sh" >&2
    exit 1
fi

echo "   ✓ Running as root"

# ── 2. Stop and disable timer ─────────────────────────────────────────────────
echo "→ [purge] Stopping and disabling timer..."

systemctl stop  <project>.timer   2>/dev/null || true
systemctl disable <project>.timer 2>/dev/null || true

echo "   ✓ Timer stopped and disabled"

# ── 3. Stop service if active ─────────────────────────────────────────────────
echo "→ [purge] Stopping service (if active)..."

systemctl stop <project>.service 2>/dev/null || true

echo "   ✓ Service stopped"

# ── 4. Remove unit files ───────────────────────────────────────────────────────
echo "→ [purge] Removing unit files..."

rm -f /etc/systemd/system/<project>.service
rm -f /etc/systemd/system/<project>.timer

echo "   ✓ Unit files removed"

# ── 5. Reload systemd ─────────────────────────────────────────────────────────
echo "→ [purge] Reloading systemd daemon..."

systemctl daemon-reload
systemctl reset-failed 2>/dev/null || true

echo "   ✓ Systemd reloaded"

# ── 6. Done ───────────────────────────────────────────────────────────────────
echo ""
echo "✅ <project-name> purged."
echo "   Logs preserved in logs/ — remove manually if no longer needed."
