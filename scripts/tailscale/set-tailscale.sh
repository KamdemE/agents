#!/usr/bin/env bash
# ============================================================
# tailscale/set-tailscale.sh — converge Tailscale to KπX desired state
# ============================================================
# Idempotent: ensures tailscaled is active, then brings Tailscale up with
# the canonical KπX flags:
#   --accept-dns --accept-routes --operator=<user>
# (long form: --accept-dns=true --accept-routes=true --operator=<user>)
#
# This is the remediation for `make check-tailscale` (scripts/tailscale/check.sh).
# Covers all drifts: offline local node, BackendState != Running, missing
# operator, missing --accept-dns/--accept-routes.
#
# SUDO GATE: this script runs `sudo tailscale up ...` — launch via the tmux
# ops pane (k-tmux) when sudo may prompt for a password. See k-tailscale/SKILL.md
# and k-tailscale/references/ubuntu.md. Never raw sudo in a non-interactive agent
# shell; the ops pane is the only channel for elevation.
#
# Source:  .agents/scripts/tailscale/set-tailscale.sh
# Caller:  make set-tailscale
# Check:   make check-tailscale
# ============================================================

set -uo pipefail

USER_NAME="${USER:-kpihx}"
DESIRED_OP="--operator=$USER_NAME"

echo "🔧 [set-tailscale] Converging Tailscale — --accept-dns --accept-routes $DESIRED_OP"

# --- 0. Binary present? ---
if ! command -v tailscale >/dev/null 2>&1; then
  echo "  ✗ 'tailscale' binary not found."
  echo "    → Install: curl -fsSL https://tailscale.com/install.sh | sh  (see skills/k-tailscale/SKILL.md)"
  exit 1
fi

# --- 1. Ensure tailscaled is active ---
if ! systemctl is-active --quiet tailscaled 2>/dev/null; then
  echo "  ├─ tailscaled not active — attempting to start..."
  if sudo systemctl start tailscaled 2>&1; then
    echo "  ✓ tailscaled started."
  else
    echo "  ✗ Failed to start tailscaled."
    echo "    → Run in the tmux ops pane: sudo systemctl status tailscaled; sudo journalctl -u tailscaled -n 50"
    exit 1
  fi
else
  echo "  ├─ tailscaled is active."
fi

# --- 2. Converge with tailscale up (canonical flags) ---
# Uses long-form flags matching k-tailscale/references/ubuntu.md
echo "  ├─ Running: tailscale up --accept-dns --accept-routes $DESIRED_OP"
echo "  │  (via sudo — use tmux ops pane if password prompt appears)"
if sudo tailscale up --accept-dns --accept-routes --operator="$USER_NAME" 2>&1; then
  echo "  ✓ tailscale up converged."
else
  rc=$?
  echo "  ✗ tailscale up failed (exit $rc)."
  echo "    → Retry in tmux ops pane: sudo tailscale up --accept-dns --accept-routes --operator=$USER_NAME"
  echo "    → Debug: tailscale status --json | python3 -m json.tool | head -60"
  exit $rc
fi

# --- 3. Verify ---
echo "  ├─ Verifying..."
sleep 1
if ! tailscale status --json >/dev/null 2>&1; then
  echo "  ⚠️  tailscale status --json still failing after up."
  exit 1
fi

echo "  └─ ✅ Done. Verifying with check:"
bash "$(dirname "$0")/check-tailscale.sh"
