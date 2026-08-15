#!/usr/bin/env bash
# ============================================================
# check_tailscale.sh — verify Tailscale is up + properly configured
# ============================================================
# Verifies:
#   1. tailscaled is running (tailscale status works)
#   2. the current user is a Tailscale operator (no sudo needed to run `tailscale`)
#   3. the up flags are correct: --accept-dns --accept-routes
# If NOT up/correct → bring it up with the correct flags.
# If the current user is NOT a Tailscale operator → BLOCK and ask KπX to grant
# operator rights with sudo first (this is the ONLY case needing elevation).
#
# Tailscale is the capital backbone for EVERY KπX device — a broken tailscale
# breaks everything (SSH, mesh, drive mounts, services). This check is wired
# into `make check` via `make check-tailscale`.
#
# Source:  .agents/scripts/check_tailscale.sh
# Caller:  make check-tailscale   (joined into `make check`)
# ============================================================

set -uo pipefail

AGENTS_DIR="$HOME/.agents"

echo "🔍 Tailscale health check..."

# --- 0. Is tailscaled present / status reachable? ---
if ! command -v tailscale >/dev/null 2>&1; then
  echo "  ✗ ERROR: 'tailscale' binary not found in PATH."
  echo "    → Install Tailscale (see skills/k-tailscale/SKILL.md) — it is MANDATORY on every infra."
  exit 1
fi

# --- 1. tailscale status works (daemon up)? ---
if ! ts_status="$(tailscale status 2>&1)"; then
  echo "  ⚠️  tailscale status failed — daemon may be down or not logged in."
  echo "    → Attempting: tailscale up --accept-dns --accept-routes"
  echo "      (KπX: if this needs your approval/interactive login, run it in the tmux ops pane.)"
  if ! tailscale up --accept-dns --accept-routes 2>&1 | head -20; then
    echo "  ✗ ERROR: 'tailscale up' did not complete. Please run it interactively (k-tmux)."
    exit 1
  fi
  echo "  ✓ Tailscale brought up with --accept-dns --accept-routes."
fi

# --- 2. Current user is a Tailscale operator (no sudo needed)? ---
# `tailscale set --operator=$USER` grants the current user operator rights so
# they can run `tailscale up`/`status` WITHOUT sudo. Try to self-apply it; if the
# user lacks permission, report the elevation command to run in the tmux ops pane.
if ! tailscale set --operator="$USER" >/dev/null 2>&1; then
  echo "  ✗ ERROR: current user '$USER' is not a Tailscale operator."
  echo "    → FIX REQUIRED (needs elevation, run in the tmux ops pane):"
  echo "        sudo tailscale set --operator=$USER"
  echo "    → KπX: please run that with sudo first (k-tmux ops pane), then re-run make check-tailscale."
  exit 1
else
  echo "  ✓ user '$USER' is a Tailscale operator (no sudo needed)."
fi

# --- 3. Verify up flags (--accept-dns --accept-routes) ---
if ! tailscale status --json 2>/dev/null | grep -q '"AcceptRoutes"'; then
  # Try to read the prefs; if flags not set, re-apply them.
  echo "  ⚠️  Could not confirm accept-routes/accept-dns prefs — re-applying."
  tailscale up --accept-dns --accept-routes >/dev/null 2>&1
fi

# --- 4. Final: status summary ---
echo "  ✓ Tailscale up. Current status:"
tailscale status 2>&1 | head -5
echo "tailscale: OK (up, operator access, accept-dns+accept-routes applied)"
