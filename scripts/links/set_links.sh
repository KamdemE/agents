#!/usr/bin/env bash
# ============================================================
# set_links.sh — create/recreate .agents-owned symlinks from links.jsonc
# ============================================================
# Reads assets/links.jsonc (DIRECT list grouped by skill). For the CURRENT
# infra (from tailscale, see libs/jsonc/jsonc_lib.sh), creates every symlink whose
# "infras" array applies ("*" = ALL infra, or contains the current infra).
#
# All sources/targets are in $HOME/.agents/... format (single source of truth).
#
# Source:  .agents/scripts/links/set_links.sh
# Caller:  make link
# Depends: .agents/scripts/links/lib.sh  →  libs/jsonc_lib.sh
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

# --- Validate links.jsonc format first (mandatory) ---
if ! jsonc_valid "$LINKS_FILE"; then
  echo "✗ links.jsonc is malformed — refusing to continue."
  exit 1
fi

CURRENT_INFRA="$(current_infra)"
echo "🔗 set-links — infra: ${CURRENT_INFRA:-<unknown>}"

LINKS_OBJ="$(strip_jsonc < "$LINKS_FILE")"

created=0
failed=0
skipped=0

for name in $(printf '%s' "$LINKS_OBJ" \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); print("\n".join(d.get("links",{}).keys()))'); do
  read -r source target infras <<< "$(
    printf '%s' "$LINKS_OBJ" | python3 -c "
import sys,json
d=json.load(sys.stdin).get('links',{}).get('$name',{})
print(d.get('source',''), d.get('target',''), json.dumps(d.get('infras','[]')))
")"

  [ -n "$source" ] && [ -n "$target" ] || { echo "  ✗ $name: missing source/target"; failed=$((failed + 1)); continue; }

  if ! infra_matches "$CURRENT_INFRA" "$infras"; then
    skipped=$((skipped + 1))
    continue
  fi

  src="${source//\$HOME/$HOME}"
  tgt="${target//\$HOME/$HOME}"
  mkdir -p "$(dirname "$src")"
  if [ ! -e "$tgt" ]; then
    echo "  ✗ target missing, skipped: $name -> $tgt"
    failed=$((failed + 1))
    continue
  fi
  ln -sfn "$tgt" "$src"
  echo "  ✓ $name: $src -> $tgt"
  created=$((created + 1))
done

echo "set-links: $created created, $skipped skipped (other infra), $failed failed"
[ "$failed" -eq 0 ]
