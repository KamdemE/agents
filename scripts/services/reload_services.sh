#!/usr/bin/env bash
# ============================================================
# reload_services.sh — reload/reload the current infra's services
# ============================================================
# Reads assets/services.jsonc (DIRECT list grouped by skill). Reloads every
# service that applies to the current infra (infras:["*"] or contains the
# current infra) and that is actually deployed in the right systemd dir
# (user or system). Reload = systemctl daemon-reload + enable + restart.
#
# The current infra comes from tailscale (see lib.sh current_infra).
# Tailscale is the capital backbone — see check_tailscale.sh.
#
# Source:  .agents/scripts/services/reload_services.sh
# Caller:  make reload-services
# Depends: .agents/scripts/services/lib.sh (JSONC loader/validator + infra)
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

if ! jsonc_valid "$SERVICES_FILE"; then
  echo "✗ services.jsonc is malformed — refusing to continue."
  exit 1
fi

CURRENT_INFRA="$(current_infra)"
echo "🔁 reload-services — infra: ${CURRENT_INFRA:-<unknown>}"

# Reload BOTH daemons (user + system) so systemd sees the latest unit files,
# then the loop below enables + restarts each service that applies to this infra.
echo "→ reloading systemd daemons (user + system)..."
systemctl --user daemon-reload 2>/dev/null
systemctl daemon-reload 2>/dev/null

SERVICES_OBJ="$(strip_jsonc < "$SERVICES_FILE")"

reloaded=0
skipped=0
failed=0

for name in $(printf '%s' "$SERVICES_OBJ" \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); print("\n".join(d.get("services",{}).keys()))' 2>/dev/null); do
  read -r unit type infras expect_active <<< "$(
    printf '%s' "$SERVICES_OBJ" | python3 -c "
import sys,json
d=json.load(sys.stdin).get('services',{}).get('$name',{})
print(d.get('unit',''), d.get('type',''), json.dumps(d.get('infras','[]')), d.get('expect-active', True))
" 2>/dev/null)"

  if ! infra_matches "$CURRENT_INFRA" "$infras"; then
    skipped=$((skipped + 1))
    continue
  fi

  # Only reload expect-active services (daemons that should be running).
  # Oneshot units (expect-active:false, e.g. backup/clean run by a timer)
  # must NOT be restarted here — systemctl restart would run them immediately.
  if [ "$expect_active" != "True" ]; then
    skipped=$((skipped + 1))
    echo "  – skip (expect-active:false, oneshot/timer-driven): $name"
    continue
  fi

  scope_flag=""
  [ "$type" = "user" ] && scope_flag="--user"
  unit_dir="$HOME/.config/systemd/user"
  [ "$type" = "system" ] && unit_dir="/etc/systemd/system"
  deployed="$unit_dir/$unit"

  if [ ! -e "$deployed" ]; then
    echo "  ✗ not deployed, skip reload: $name (unit $unit)"
    failed=$((failed + 1))
    continue
  fi

  echo "  ↻ reloading: $name ($type) — unit $unit"
  systemctl $scope_flag daemon-reload
  systemctl $scope_flag enable "$unit" 2>/dev/null
  if systemctl $scope_flag restart "$unit"; then
    reloaded=$((reloaded + 1))
  else
    failed=$((failed + 1))
  fi
done

echo "reload-services: $reloaded reloaded, $skipped skipped (other infra), $failed failed"
[ "$failed" -eq 0 ]
