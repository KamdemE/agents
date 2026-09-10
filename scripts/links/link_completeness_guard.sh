#!/usr/bin/env bash
# ============================================================
# link_completeness_guard.sh — sub-check: unregistered symlinks into .agents
# ============================================================
# Part of check-links.sh (modular split). Reads the declarative `audit.sources`
# and `audit.exclusions` policy from links.jsonc. Each source may declare a
# max-depth; absent max-depth means recursive scanning. Every scan uses -xdev
# and the shared exclusions to avoid crossing mounts or generated trees. It
# flags any symlink resolving INTO .agents whose RESOLVED TARGET is not a
# registered links.jsonc target. Matching by resolved target avoids false
# positives from systemd `*.wants/<unit>` enable-links.
# ============================================================

# shellcheck disable=SC1090
source "$SCRIPT_DIR/lib.sh"

# link_completeness_guard <LINKS_OBJ>
#   appends to $UNREG counter
link_completeness_guard() {
  local links_obj="$1"
  local REG_TARGETS audit_config cand ln resolved unreg root depth exclusion
  local -a SCAN_ROOTS=() SCAN_DEPTHS=() PRUNE_DIRS=() FIND_ARGS=()
  REG_TARGETS="$(printf '%s' "$links_obj" | python3 -c "
import sys,json
d=json.load(sys.stdin).get('links',{})
for v in d.values():
    if isinstance(v,dict) and v.get('target'): print(v['target'])
")"
  audit_config="$(LINKS_OBJ="$links_obj" python3 -c '
import json
import os
import sys

audit = json.loads(os.environ["LINKS_OBJ"]).get("audit")
if not isinstance(audit, dict):
    sys.exit("links.jsonc audit must be an object")
sources = audit.get("sources")
exclusions = audit.get("exclusions")
if not isinstance(sources, list) or not sources:
    sys.exit("links.jsonc audit.sources must be a non-empty array")
if not isinstance(exclusions, list) or any(not isinstance(item, str) or not item for item in exclusions):
    sys.exit("links.jsonc audit.exclusions must be an array of non-empty strings")
for source in sources:
    if not isinstance(source, dict) or not isinstance(source.get("path"), str) or not source["path"]:
        sys.exit("each audit.sources item needs a non-empty path")
    depth = source.get("max-depth")
    if depth is not None and (not isinstance(depth, int) or depth < 0):
        sys.exit("audit.sources max-depth must be a non-negative integer")
    print("SOURCE\t{}\t{}".format(source["path"], "" if depth is None else depth))
for exclusion in exclusions:
    print(f"EXCLUSION\t{exclusion}")
')" || {
    echo "  ✗ links.jsonc audit configuration is invalid"
    UNREG=1
    return
  }

  while IFS=$'\t' read -r kind root depth; do
    case "$kind" in
      SOURCE)
        SCAN_ROOTS+=( "${root//\$HOME/$HOME}" )
        SCAN_DEPTHS+=( "$depth" )
        ;;
      EXCLUSION)
        PRUNE_DIRS+=( "$root" )
        ;;
    esac
  done <<< "$audit_config"

  unreg=0
  for index in "${!SCAN_ROOTS[@]}"; do
    root="${SCAN_ROOTS[$index]}"
    depth="${SCAN_DEPTHS[$index]}"
    if [ ! -d "$root" ]; then
      echo "  ⚠ audit source missing, skipped: $root"
      continue
    fi
    FIND_ARGS=( "$root" -xdev )
    [ -n "$depth" ] && FIND_ARGS+=( -maxdepth "$depth" )
    # Prune inaccessible system subtrees before find descends into them: they
    # cannot be audited by this unprivileged checker and must not emit noise.
    FIND_ARGS+=( \( -type d \( ! -readable -o ! -executable \) -prune \) -o )
    FIND_ARGS+=( \( -type d -name "${PRUNE_DIRS[0]}" )
    for exclusion in "${PRUNE_DIRS[@]:1}"; do
      FIND_ARGS+=( -o -type d -name "$exclusion" )
    done
    FIND_ARGS+=( \) -prune -o -type l -print )
  while IFS= read -r ln; do
    [ -L "$ln" ] || continue
    resolved="$(readlink -f "$ln" || true)"
    case "$resolved" in
      "$AGENTS_DIR"/*|"$HOME/Labs/.agents"/*) ;;
      *) continue ;;
    esac
    # Normalize: $HOME → placeholder, and the ~/.agents→~/Labs/.agents
    # indirection so both real paths map to the canonical $HOME/.agents/... form.
    cand="${resolved/#$HOME/\$HOME}"
    cand="${cand//Labs\/.agents/.agents}"
    if ! printf '%s\n' "$REG_TARGETS" | grep -Fxq -- "$cand"; then
      echo "  ✗ UNREGISTERED link into .agents: $ln -> $resolved (add to links.jsonc)"
      unreg=$((unreg + 1))
    fi
    done < <(find "${FIND_ARGS[@]}")
  done
  UNREG=$unreg
  echo "check-links completeness: $UNREG unregistered symlink(s) into .agents"
}
