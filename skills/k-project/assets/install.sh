#!/bin/bash
# install.sh — Install <project-name>.
# Sets up systemd units, creates runtime directories, and enables the timer/service.
# Run as root: sudo bash scripts/install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ── 1. Pre-checks ─────────────────────────────────────────────────────────────
echo "→ [install] Pre-checks..."

if [[ $EUID -ne 0 ]]; then
    echo "❌ Must be run as root: sudo bash scripts/install.sh" >&2
    exit 1
fi

# Add any dependency checks here, e.g.:
# command -v jq >/dev/null 2>&1 || { echo "❌ jq is required but not installed." >&2; exit 1; }

echo "   ✓ Running as root"

# ── 2. Install systemd units ───────────────────────────────────────────────────
echo "→ [install] Installing systemd units..."

# Adjust unit file names as needed
cp "$PROJECT_ROOT/systemd/<project>.service" "/etc/systemd/system/<project>.service"
cp "$PROJECT_ROOT/systemd/<project>.timer"   "/etc/systemd/system/<project>.timer"
chmod 644 "/etc/systemd/system/<project>.service" "/etc/systemd/system/<project>.timer"

echo "   ✓ Units installed to /etc/systemd/system/"

# ── 3. Create runtime directories ─────────────────────────────────────────────
echo "→ [install] Creating runtime directories..."

mkdir -p "$PROJECT_ROOT/logs"

echo "   ✓ logs/ created"

# ── 4. Enable and start timer ─────────────────────────────────────────────────
echo "→ [install] Reloading systemd and enabling timer..."

systemctl daemon-reload
systemctl enable --now <project>.timer

echo "   ✓ Timer enabled"

# ── 5. Done ───────────────────────────────────────────────────────────────────
echo ""
echo "✅ <project-name> installed successfully."
echo "   Timer:  $(systemctl list-timers "<project>.timer" --no-pager 2>/dev/null | tail -1)"
echo "   Logs:   journalctl -u <project>"
echo "   Run now: sudo systemctl start <project>.service"
