#!/usr/bin/env bash
# ============================================================
# check_tailscale.sh — verify Tailscale is up + properly configured
# ============================================================
# Verifies:
#   1. tailscaled is running (tailscale status works)
#   2. the current user is a Tailscale operator (no sudo needed to run `tailscale`)
#   3. the up flags are correct: --accept-dns --accept-routes
# This checker is read-only: it never changes Tailscale state. When it detects
# drift, it reports the exact remediation command appropriate to that state.
#
# Tailscale is the capital backbone for EVERY KπX device — a broken tailscale
# breaks everything (SSH, mesh, drive mounts, services). This check is wired
# into `make check` via `make check-tailscale`.
#
# Source:  .agents/scripts/check_tailscale.sh
# Caller:  make check-tailscale   (joined into `make check`)
# ============================================================

set -uo pipefail

echo "  ├─ 🧩 1/4 Binary availability"

# --- 0. Infra exemption: deep-pc6 is DxO VPN-only, not on Tailscale (see k-deep-pc6) ---
if [ -f "$HOME/.agents/libs/jsonc/jsonc_lib.sh" ]; then
  # shellcheck disable=SC1091
  source "$HOME/.agents/libs/jsonc/jsonc_lib.sh" 2>/dev/null || true
  if command -v current_infra >/dev/null 2>&1; then
    _infra_ci="$(current_infra 2>/dev/null || true)"
    if [ "$_infra_ci" = "deep-pc6" ]; then
      echo "  ⊘ skip — infra 'deep-pc6' is DxO VPN-only, not on Tailscale (k-deep-pc6). Binary/daemon checks waived."
      echo "  └─ 📊 Summary: Tailscale check skipped for deep-pc6."
      exit 0
    fi
  fi
fi
# Fallback hostname check (no libs)
if [ "$(hostname 2>/dev/null | tr '[:upper:]' '[:lower:]')" = "deep-pc6" ]; then
  echo "  ⊘ skip — hostname deep-pc6 is DxO VPN-only, not on Tailscale."
  echo "  └─ 📊 Summary: Tailscale check skipped for deep-pc6."
  exit 0
fi

# --- 0. Is tailscaled present / status reachable? ---
if ! command -v tailscale >/dev/null 2>&1; then
  echo "  ✗ ERROR: 'tailscale' binary not found in PATH."
  echo "    → Install Tailscale (see skills/k-tailscale/SKILL.md) — it is MANDATORY on every infra."
  exit 1
fi

echo "  ├─ 🔌 2/4 Daemon connection"
# --- 1. tailscale status works (daemon up)? ---
if ! ts_status="$(tailscale status 2>&1)"; then
  echo "  ⚠️  tailscale status failed — daemon may be down or not logged in."
  echo "    → Run in the tmux ops pane: tailscale up --accept-dns --accept-routes"
  exit 1
fi

echo "  ├─ 👤 3/4 Operator access"
# --- 2. Read current preferences without mutating the daemon. ---
if ! prefs="$(tailscale debug prefs 2>&1)"; then
  echo "  ⚠️  Could not read Tailscale preferences."
  echo "    → Run in the tmux ops pane: sudo tailscale set --operator=$USER"
  echo "    → Then re-run make check-tailscale."
  exit 1
fi

operator_user="$(printf '%s\n' "$prefs" | jq -r '.OperatorUser // empty')"
if [ "$operator_user" = "$USER" ]; then
  echo "  ✓ user '$USER' is the Tailscale operator (no sudo needed)."
else
  echo "  ⚠️  Tailscale operator is '${operator_user:-unset}', not '$USER'."
  echo "    → Run in the tmux ops pane: sudo tailscale set --operator=$USER"
  exit 1
fi

echo "  ├─ 🌐 4/4 DNS and route acceptance"
# --- 3. Verify up flags (--accept-dns --accept-routes) from preferences. ---
accept_dns="$(printf '%s\n' "$prefs" | jq -r '.CorpDNS // false')"
accept_routes="$(printf '%s\n' "$prefs" | jq -r '.RouteAll // false')"
if [ "$accept_dns" != "true" ] || [ "$accept_routes" != "true" ]; then
  echo "  ⚠️  DNS acceptance=$accept_dns; route acceptance=$accept_routes."
  echo "    → Run in the tmux ops pane: tailscale up --accept-dns --accept-routes"
  exit 1
fi
echo "  ✓ DNS and route acceptance are enabled."

# --- 4. Final: status summary ---
echo "  ✓ Tailscale up. Current status:"
printf '%s\n' "$ts_status" | head -5
echo "  └─ 📊 Summary: Tailscale is healthy; operator access, DNS, and routes are enabled."
