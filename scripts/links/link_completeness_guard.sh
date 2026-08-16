#!/usr/bin/env bash
# ============================================================
# link_completeness_guard.sh — sub-check: unregistered symlinks into .agents
# ============================================================
# Part of check_links.sh (modular split). Scans the real symlink surface
# (~/.local/bin, $HOME config dots, /etc/systemd/system, ~/.config/systemd/user)
# and flags any symlink resolving INTO .agents whose RESOLVED TARGET is not a
# registered links.jsonc target. Matching by resolved target (not source path)
# avoids false positives: systemd `enable` creates `*.wants/<unit>` enable-links
# whose canonical unit IS registered (e.g. default.target.wants/foo.service →
# registered target). Only truly unregistered manual links (target unknown) fail.
# ============================================================

# shellcheck disable=SC1090
source "$SCRIPT_DIR/lib.sh"

# link_completeness_guard <LINKS_OBJ>
#   appends to $UNREG counter
link_completeness_guard() {
  local links_obj="$1"
  local REG_TARGETS cand ln resolved unreg
  REG_TARGETS="$(printf '%s' "$links_obj" | python3 -c "
import sys,json
d=json.load(sys.stdin).get('links',{})
for v in d.values():
    if isinstance(v,dict) and v.get('target'): print(v['target'])
")"
  unreg=0
  # Scan roots for incoming-link completeness (adjust here to widen/narrow).
  local -a SCAN_ROOTS=( "$HOME" "/etc" )
  # Directories to PRUNE for speed (never scan into them): trash, virtualenvs,
  # node deps, large model stores — noise / not .agents-owned symlinks.
  local -a PRUNE_DIRS=( 'Trash' '.venv' 'node_modules' 'models' )
  while IFS= read -r ln; do
    [ -L "$ln" ] || continue
    resolved="$(readlink -f "$ln" 2>/dev/null || true)"
    case "$resolved" in
      "$AGENTS_DIR"/*|"$HOME/KpihX-Labs/.agents"/*) ;;
      *) continue ;;
    esac
    # Normalize: $HOME → placeholder, and the ~/.agents→~/KpihX-Labs/.agents
    # indirection so both real paths map to the canonical $HOME/.agents/... form.
    cand="${resolved/#$HOME/\$HOME}"
    cand="${cand//KpihX-Labs\/.agents/.agents}"
    if ! printf '%s\n' "$REG_TARGETS" | grep -Fxq -- "$cand"; then
      echo "  ✗ UNREGISTERED link into .agents: $ln -> $resolved (add to links.jsonc)"
      unreg=$((unreg + 1))
    fi
  done < <(find "${SCAN_ROOTS[@]}" \( -type d -name 'Trash' -o -name '.venv' -o -name 'node_modules' -o -name 'models' \) -prune -o -type l -print 2>/dev/null)
  UNREG=$unreg
  echo "check-links completeness: $UNREG unregistered symlink(s) into .agents"
}
