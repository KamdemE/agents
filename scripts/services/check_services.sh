#!/usr/bin/env bash
# ============================================================
# check_services.sh — verify .agents-owned systemd services
# ============================================================
# Reads assets/services.jsonc (DIRECT list — no common*/optional grouping).
# Each service dict has an "infras" array of the infra names that need it;
# "*" = ALL infra (this is the new MANDATORY). A service not in the current
# infra's list is skipped.
#
# For each service that applies to the current infra:
#   - checks the canonical asset exists (path in $HOME/.agents/...)
#   - checks it is deployed in the right systemd dir (user or system) —
#     either as a symlink OR a physical copy (we check EXISTENCE, not symlink)
#   - if expect-active: checks systemctl is-active + recent journal (max verbosity)
#   - if expect-active is false: presence check only, reported informational
#
# The current infra comes from tailscale (see lib.sh current_infra).
# Tailscale is the capital backbone — see check_tailscale.sh.
#
# Source:  .agents/scripts/services/check_services.sh
# Caller:  make check-services   (renamed from check-systemd; joined into `make check`)
# Depends: .agents/scripts/services/lib.sh (JSONC loader/validator + infra resolver)
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

# --- Validate JSONC format first (mandatory) ---
if ! jsonc_valid "$SERVICES_FILE"; then
  echo "✗ services.jsonc is malformed — refusing to continue."
  exit 1
fi

# --- Resolve current infra ---
CURRENT_INFRA="$(current_infra)"
echo "🔍 check-services — infra: ${CURRENT_INFRA:-<unknown>}"

# Load services.jsonc object (strip comments). We parse per-service with python3.
SERVICES_OBJ="$(strip_jsonc < "$SERVICES_FILE")"

checked=0
failed=0
skipped=0

# IPEX backend liveness (Docker container ipex-llm). The ipex/ollama-ipex CLI is an
# EXCLUSIVE switch between native systemd ollama and the IPEX Docker backend on
# 127.0.0.1:11434 — when IPEX is the active backend, the native ollama.service is
# intentionally stopped. So when ipex-llm is alive, we SKIP the ollama.service
# is-active check (ollama stays expect-active:true in services.jsonc — we handle the
# exclusion here in code, not in the registry, for security/simplicity).
ipex_active() {
  docker ps --format '{{.Names}}' 2>/dev/null | grep -qx 'ipex-llm'
}

# Extract each service entry name from the "services" map.
for name in $(printf '%s' "$SERVICES_OBJ" \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); print("\n".join(d.get("services",{}).keys()))' 2>/dev/null); do
  # Read the service's fields (key = appellation; unit = REAL systemd unit name)
  read -r unit type path skill infras expect_active <<< "$(
    printf '%s' "$SERVICES_OBJ" | python3 -c "
import sys,json
d=json.load(sys.stdin).get('services',{}).get('$name',{})
print(d.get('unit',''), d.get('type',''), d.get('path',''), d.get('skill',''), json.dumps(d.get('infras','[]')), str(d.get('expect-active',False)).lower())
" 2>/dev/null)"

  [ -n "$name" ] || continue

  # Does this service apply to the current infra?
  if ! infra_matches "$CURRENT_INFRA" "$infras"; then
    skipped=$((skipped + 1))
    echo "  - $name — skip (not for infra '$CURRENT_INFRA')"
    continue
  fi

  checked=$((checked + 1))
  echo "  ── $name ($skill, $type) — unit: ${unit:-<none>} ──"

  # 1. Canonical asset present?
  target="${path//\$HOME/$HOME}"
  if [ ! -f "$target" ]; then
    echo "  ✗ canonical asset MISSING: $target"
    failed=$((failed + 1))
    continue
  fi
  echo "  ✓ canonical: $target"

  # 2. Deployed in the right systemd dir (user or system) — by REAL unit name
  if [ "$type" = "user" ]; then
    unit_dir="$HOME/.config/systemd/user"
  else
    unit_dir="/etc/systemd/system"
  fi
  deployed="$unit_dir/$unit"
  if [ -L "$deployed" ]; then
    echo "  ✓ deployed (symlink): $deployed -> $(readlink -f "$deployed" 2>/dev/null)"
  elif [ -f "$deployed" ]; then
    echo "  ✓ deployed (copy):    $deployed"
  else
    echo "  ✗ NOT deployed in $unit_dir (expected $deployed)"
    failed=$((failed + 1))
    continue
  fi

  # 3. Functional? (expect-active) — by REAL unit name
  if [ "$expect_active" = "true" ]; then
    scope_flag=""
    [ "$type" = "user" ] && scope_flag="--user"
    # IPEX-exclusive-switch exclusion: when the IPEX backend (ipex-llm container)
    # is alive, the native ollama.service is intentionally stopped → skip its
    # is-active check (reported informational, not a failure).
    if [ "$unit" = "ollama.service" ] && ipex_active; then
      echo "  ✓ is-active: SKIPPED (IPEX backend alive — native ollama intentionally stopped)"
    else
      active="$(systemctl $scope_flag is-active "$unit" 2>/dev/null | tr -d '\n')"
      if [ "$active" = "active" ]; then
        echo "  ✓ is-active: active"
      else
        echo "  ✗ is-active: ${active:-<not active>} (EXPECTED active)"
        failed=$((failed + 1))
      fi
    fi
    echo "  ── recent journal ($unit):"
    journalctl $scope_flag -u "$unit" -n 8 --no-pager 2>/dev/null | sed 's/^/     /' | tail -8
  else
    echo "  ✓ expect-active: false (presence only, informational)"
  fi
  echo ""
done

echo "services: $checked checked for infra '$CURRENT_INFRA', $failed failure(s), $skipped skipped (other infra)"
[ "$failed" -eq 0 ]
