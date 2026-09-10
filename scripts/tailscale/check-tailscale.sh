#!/usr/bin/env bash
# ============================================================
# check-tailscale.sh — verify Tailscale is up + properly configured
# ============================================================
# Verifies:
#   1. tailscaled is running (tailscale status works)
#   2. the current user is a Tailscale operator (no sudo needed to run `tailscale`)
#   3. the up flags are correct: --accept-dns --accept-routes
# This checker is read-only: it never changes Tailscale state. When it detects
# drift, it reports the exact remediation command appropriate to that state.
#
# Tailscale is OPTIONAL in this fork — a mesh VPN used only when the operator
# wants multi-machine reachability. When the binary is absent the check
# reports SKIP (exit 0) and `make check` stays green. When present but broken,
# it still fails with the remediation, as before.
#
# Source:  .agents/scripts/tailscale/check-tailscale.sh
# Caller:  make check-tailscale   (joined into `make check`)
# Fix:     make set-tailscale     (converges --accept-dns --accept-routes --operator)
# ============================================================

set -uo pipefail

echo "  ├─ 🧩 1/5 Binary availability"

# --- 0. Is tailscaled present / status reachable? ---
if ! command -v tailscale >/dev/null 2>&1; then
  echo "  ○ 'tailscale' binary not found in PATH — optional component, skipping (see skills/k-tailscale/SKILL.md to install it)."
  exit 0
fi

echo "  ├─ 🔌 2/5 Daemon connection"
# --- 1. tailscale status works (daemon up)? ---
if ! ts_status="$(tailscale status 2>&1)"; then
  echo "  ⚠️  tailscale status failed — daemon may be down or not logged in."
  echo "    → Run in the tmux ops pane: make set-tailscale"
  echo "    → Or: sudo tailscale up --accept-dns --accept-routes --operator=$USER"
  exit 1
fi

if ! ts_json="$(tailscale status --json 2>&1)"; then
  echo "  ⚠️  tailscale status --json failed — daemon may be down."
  echo "    → Run in the tmux ops pane: make set-tailscale"
  exit 1
fi

echo "  ├─ 📡 3/5 Local node connectivity"
# --- 2. Verify local node is actually online (not just daemon reachable) ---
# Previous bug: daemon reachable ≠ mesh online. Must check Self.Online + BackendState.
read -r backend_state self_online health_len self_hostname <<< "$(printf '%s' "$ts_json" | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    bs=d.get('BackendState','')
    online=d.get('Self',{}).get('Online', False)
    health=d.get('Health') or []
    hn=d.get('Self',{}).get('HostName','')
    print(f'{bs} {str(online).lower()} {len(health)} {hn}')
except Exception as e:
    print(f'ERR {e} 0 unknown')
")"
if [ "$backend_state" != "Running" ]; then
  echo "  ✗ Tailscale BackendState is '$backend_state' (expected 'Running')."
  echo "    Self: $self_hostname  Online: $self_online  Health items: $health_len"
  if [ "$backend_state" = "NeedsLogin" ] || [ "$backend_state" = "NeedsMachineAuth" ]; then
    echo "    → Needs re-auth. Run in the tmux ops pane: sudo tailscale up --accept-dns --accept-routes --operator=$USER"
  else
    echo "    → Run in the tmux ops pane: make set-tailscale"
    echo "    → Or: sudo tailscale up --accept-dns --accept-routes --operator=$USER"
    echo "    → Debug: systemctl status tailscaled; journalctl -u tailscaled -n 50"
  fi
  exit 1
fi
if [ "$self_online" != "true" ]; then
  echo "  ✗ Local node '$self_hostname' is OFFLINE (Self.Online=false) — mesh disconnected."
  echo "    BackendState: $backend_state  Health items: $health_len"
  printf '%s\n' "$ts_status" | head -5 | sed 's/^/    │ /'
  echo "    → Run in the tmux ops pane: make set-tailscale"
  echo "    → Or: sudo tailscale up --accept-dns --accept-routes --operator=$USER"
  exit 1
fi
if [ "${health_len:-0}" -gt 0 ]; then
  health_msg="$(printf '%s' "$ts_json" | python3 -c "import json,sys; d=json.load(sys.stdin); print('; '.join(d.get('Health') or []))")"
  echo "  ⚠️  Tailscale Health warnings ($health_len): $health_msg"
  echo "    → Check: tailscale status --json | jq .Health ; tailscale netcheck"
else
  echo "  ✓ Local node '$self_hostname' is online (BackendState=Running, Self.Online=true)."
fi

echo "  ├─ 👤 4/5 Operator access"
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

echo "  ├─ 🌐 5/5 DNS and route acceptance"
# --- 3. Verify up flags (--accept-dns --accept-routes) from preferences. ---
accept_dns="$(printf '%s\n' "$prefs" | jq -r '.CorpDNS // false')"
accept_routes="$(printf '%s\n' "$prefs" | jq -r '.RouteAll // false')"
if [ "$accept_dns" != "true" ] || [ "$accept_routes" != "true" ]; then
  echo "  ⚠️  DNS acceptance=$accept_dns; route acceptance=$accept_routes."
  echo "    → Run in the tmux ops pane: tailscale up --accept-dns --accept-routes"
  exit 1
fi
echo "  ✓ DNS and route acceptance are enabled."

# --- 5. Final: status summary ---
echo "  ✓ Tailscale up. Current status:"
printf '%s\n' "$ts_status" | head -7
echo "  └─ 📊 Summary: Tailscale is healthy; local node online, operator access, DNS and routes enabled."
