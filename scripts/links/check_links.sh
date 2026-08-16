#!/usr/bin/env bash
# ============================================================
# check_links.sh — verify .agents-owned symlinks from links.jsonc
# ============================================================
# THIN ORCHESTRATOR (see scripts/AGENTS.md). Reads assets/links.jsonc (DIRECT
# list grouped by skill) and, for the CURRENT infra (from tailscale, see
# libs/jsonc/jsonc_lib.sh), IMPORTS + LAUNCHES the modular sub-checks:
#   link_basic_guard.sh        per-link existence/broken/reversed/dead
#   link_crossref_guard.sh     links.jsonc ↔ services.jsonc (by unit)
#   link_completeness_guard.sh unregistered symlinks into .agents
# This file holds NO business logic — only aggregation and reporting.
#
# Source:  .agents/scripts/links/check_links.sh
# Caller:  make check-links   (joined into `make check`)
# Depends: .agents/scripts/links/lib.sh  →  libs/jsonc/jsonc_lib.sh
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"
# shellcheck source=link_basic_guard.sh
source "$SCRIPT_DIR/link_basic_guard.sh"
# shellcheck source=link_crossref_guard.sh
source "$SCRIPT_DIR/link_crossref_guard.sh"
# shellcheck source=link_completeness_guard.sh
source "$SCRIPT_DIR/link_completeness_guard.sh"

# --- Validate links.jsonc format first (mandatory) ---
if ! jsonc_valid "$LINKS_FILE"; then
  echo "✗ links.jsonc is malformed — refusing to continue."
  exit 1
fi

CURRENT_INFRA="$(current_infra)"
echo "🔗 check-links — infra: ${CURRENT_INFRA:-<unknown>}"

LINKS_OBJ="$(strip_jsonc < "$LINKS_FILE")"
SERVICES_OBJ="$(strip_jsonc < "$SERVICES_FILE")"

# Global counters shared by the guards
CHECKED=0; OK=0; BROKEN=0; REVERSED=0; SKIPPED=0; DEAD=0
CROSS=0; CROSS_MISSING=0; UNREG=0

# ── Sub-check 1: per-link basic (existence/broken/reversed/dead) ──
for name in $(printf '%s' "$LINKS_OBJ" \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); print("\n".join(d.get("links",{}).keys()))' 2>/dev/null); do
  read -r source target infras allow_reversed <<< "$(
    printf '%s' "$LINKS_OBJ" | python3 -c "
import sys,json
d=json.load(sys.stdin).get('links',{}).get('$name',{})
print(d.get('source',''), d.get('target',''), json.dumps(d.get('infras','[]')), str(d.get('allow-reversed', False)).lower())
" 2>/dev/null)"

  [ -n "$source" ] || continue
  if ! infra_matches "$CURRENT_INFRA" "$infras"; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi
  link_basic_guard "$name" "$source" "$target" "$allow_reversed"
done

# ── Sub-check 2: cross-ref links.jsonc ↔ services.jsonc (by unit) ──
link_crossref_guard "$LINKS_OBJ" "$SERVICES_OBJ"

# ── Sub-check 3: completeness (unregistered symlinks into .agents) ──
link_completeness_guard "$LINKS_OBJ"

echo "check-links: $CHECKED checked for infra '$CURRENT_INFRA' ($OK ok, $BROKEN broken, $REVERSED reversed, $DEAD dead), $SKIPPED skipped (other infra)"
[ "$BROKEN" -eq 0 ] && [ "$REVERSED" -eq 0 ] && [ "$DEAD" -eq 0 ] && [ "$CROSS_MISSING" -eq 0 ] && [ "$UNREG" -eq 0 ]
