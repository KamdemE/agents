#!/usr/bin/env bash
# ============================================================
# check-services.sh — verify .agents-owned systemd services
# ============================================================
# THIN ORCHESTRATOR (see scripts/AGENTS.md). Reads assets/services.jsonc
# (DIRECT list — no common*/optional grouping). For each service that applies
# to the current infra, it IMPORTS + LAUNCHES the modular sub-checks:
#   service_asset_guard.sh          canonical asset + deployed presence
#   service_internal_paths_guard.sh internal unit paths exist
#   service_active_guard.sh         is-active + recent journal
# This file holds NO business logic — only aggregation and reporting.
#
# Source:  .agents/scripts/services/check-services.sh
# Caller:  make check-services   (renamed from check-systemd; joined into `make check`)
# Depends: .agents/scripts/services/lib.sh (JSONC loader/validator + infra resolver)
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
# shellcheck source=service_asset_guard.sh
source "$SCRIPT_DIR/service_asset_guard.sh"
# shellcheck source=service_internal_paths_guard.sh
source "$SCRIPT_DIR/service_internal_paths_guard.sh"
# shellcheck source=service_active_guard.sh
source "$SCRIPT_DIR/service_active_guard.sh"

# --- Validate JSONC format first (mandatory) ---
if ! jsonc_valid "$SERVICES_FILE"; then
  echo "✗ services.jsonc is malformed — refusing to continue."
  exit 1
fi

# --- Resolve current infra ---
CURRENT_INFRA="$(current_infra)"
echo "  ├─ 🧭 Infra: ${CURRENT_INFRA:-<unknown>}"

# Load services.jsonc object (strip comments). We parse per-service with python3.
SERVICES_OBJ="$(strip_jsonc < "$SERVICES_FILE")"

checked=0
failed=0
skipped=0

echo "  ├─ 📦 Per-service integrity"
# Extract each service entry name from the "services" map.
for name in $(printf '%s' "$SERVICES_OBJ" \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); print("\n".join(d.get("services",{}).keys()))'); do
  # Read the service's fields (key = appellation; unit = REAL systemd unit name)
  IFS=$'\t' read -r unit type path skill infras expect_active <<< "$(
    printf '%s' "$SERVICES_OBJ" | python3 -c "
import sys,json
d=json.load(sys.stdin).get('services',{}).get('$name',{})
print('\t'.join((d.get('unit',''), d.get('type',''), d.get('path',''), d.get('skill',''), json.dumps(d.get('infras','[]')), str(d.get('expect-active',False)).lower())))
")"

  [ -n "$name" ] || continue

  # Does this service apply to the current infra?
  if ! infra_matches "$CURRENT_INFRA" "$infras"; then
    skipped=$((skipped + 1))
    echo "  - $name — skip (not for infra '$CURRENT_INFRA')"
    continue
  fi

  checked=$((checked + 1))
  echo "  ── $name ($skill, $type) — unit: ${unit:-<none>} ──"

  # Sub-check 1: canonical asset + deployed presence
  service_asset_guard "$name" "$unit" "$type" "$path"
  [ "$asset_ok" = "1" ] || failed=$((failed + 1))
  [ "$deployed_ok" = "1" ] || failed=$((failed + 1))

  echo "  │  ├─ 📁 Internal paths"
  # Sub-check 2: internal unit paths exist (only if the unit is deployed)
  if [ "$deployed_ok" = "1" ]; then
    unit_dir="$HOME/.config/systemd/user"
    [ "$type" = "system" ] && unit_dir="/etc/systemd/system"
    service_internal_paths_guard "$unit_dir/$unit"
    [ "$internal_paths_ok" = "1" ] || failed=$((failed + 1))
  fi

  echo "  │  └─ ⚡ Expected runtime state"
  # Sub-check 3: functional? (expect-active) — by REAL unit name
  if [ "$expect_active" = "true" ]; then
    service_active_guard "$unit" "$type"
    [ "$active_ok" = "1" ] || failed=$((failed + 1))
  else
    echo "  ✓ expect-active: false (presence only, informational)"
  fi
  echo ""
done

echo "  └─ 📊 Summary: $checked checked, $failed failure(s), $skipped skipped (other infra)"
[ "$failed" -eq 0 ]
