#!/usr/bin/env bash
# ============================================================
# check_links.sh — verify .agents-owned symlinks from links.jsonc
# ============================================================
# Reads assets/links.jsonc (DIRECT list grouped by skill). For the CURRENT
# infra (from tailscale, see libs/jsonc_lib.sh), verifies every registered
# symlink whose "infras" array applies ("*" = ALL infra, or contains the
# current infra):
#   - exists and IS a symlink (not a regular file)
#   - its resolved target is NOT dangling (broken)
#   - its resolved target lives INSIDE $HOME/.agents (not reversed/outside)
#
# All sources/targets are in $HOME/.agents/... format (single source of truth).
#
# Source:  .agents/scripts/links/check_links.sh
# Caller:  make check-links   (joined into `make check`)
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
echo "🔗 check-links — infra: ${CURRENT_INFRA:-<unknown>}"

LINKS_OBJ="$(strip_jsonc < "$LINKS_FILE")"

checked=0
ok=0
broken=0
reversed=0
skipped=0
dead=0

for name in $(printf '%s' "$LINKS_OBJ" \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); print("\n".join(d.get("links",{}).keys()))' 2>/dev/null); do
  read -r source target infras <<< "$(
    printf '%s' "$LINKS_OBJ" | python3 -c "
import sys,json
d=json.load(sys.stdin).get('links',{}).get('$name',{})
print(d.get('source',''), d.get('target',''), json.dumps(d.get('infras','[]')))
" 2>/dev/null)"

  [ -n "$source" ] || continue
  if ! infra_matches "$CURRENT_INFRA" "$infras"; then
    skipped=$((skipped + 1))
    continue
  fi

  src="${source//\$HOME/$HOME}"
  checked=$((checked + 1))

  # Registered-target-exists check (mirror check-services canonical-asset check):
  # the .agents source file this links.jsonc entry points to must exist.
  tgt="${target//\$HOME/$HOME}"
  if [ ! -f "$tgt" ]; then
    echo "  ✗ DEAD links.jsonc entry: registered target missing in .agents: $tgt"
    dead=$((dead + 1))
  fi

  if [ ! -L "$src" ]; then
    if [ -e "$src" ]; then
      echo "  ✗ REGULAR-FILE (not a symlink): $src (expected -> ${target//\$HOME/$HOME})"
      reversed=$((reversed + 1))
    else
      echo "  ✗ MISSING symlink: $src"
      broken=$((broken + 1))
    fi
    continue
  fi

  resolved="$(readlink -f "$src" 2>/dev/null || true)"
  if [ -z "$resolved" ] || [ ! -e "$resolved" ]; then
    echo "  ✗ BROKEN (dangling): $src -> $resolved"
    broken=$((broken + 1))
    continue
  fi

  # Reversed check: resolved target must live inside $HOME/.agents
  case "$resolved" in
    "$AGENTS_DIR"/*|"$HOME/KpihX-Labs/.agents"/*) ;;
    *)
      echo "  ✗ REVERSED/OUTSIDE: $src -> $resolved"
      reversed=$((reversed + 1))
      continue
      ;;
  esac

  ok=$((ok + 1))
  echo "  ✓ $src -> $resolved"
done

# ── Q3: cross-ref systemd-unit links.jsonc entries ↔ services.jsonc (by unit) ──
# Every links.jsonc key whose target is a systemd unit (extension in the constant
# set below) must have a matching services.jsonc entry with the same unit name.
# Both are source-of-truth registries; drift is a real bug (e.g. clean/clean-system).
# The set is centralized here so future unit types are covered without hardcoding
# -service/-timer (future-proof: socket/path/mount/target/... handled automatically).
SYSTEMD_UNIT_EXTS="service timer socket path mount automount target device slice scope swap"
cross=0
cross_missing=0
SERVICES_OBJ="$(strip_jsonc < "$SERVICES_FILE")"
for name in $(printf '%s' "$LINKS_OBJ" \
  | python3 -c 'import sys,json; d=json.load(sys.stdin); print("\n".join(d.get("links",{}).keys()))' 2>/dev/null); do
  link_unit="$(printf '%s' "$LINKS_OBJ" | python3 -c "
import sys,json
t=json.load(sys.stdin).get('links',{}).get('$name',{}).get('target','')
print(t.rsplit('/',1)[-1])
" 2>/dev/null)"
  [ -n "$link_unit" ] || continue
  ext="${link_unit##*.}"
  case " $SYSTEMD_UNIT_EXTS " in
    *" $ext "*) ;;
    *) continue ;;
  esac
  cross=$((cross + 1))
  found="$(printf '%s' "$SERVICES_OBJ" | python3 -c "
import sys,json
d=json.load(sys.stdin).get('services',{})
u='$link_unit'
print('yes' if any(isinstance(v,dict) and v.get('unit')==u for v in d.values()) else 'no')
" 2>/dev/null)"
  if [ "$found" != "yes" ]; then
    echo "  ✗ CROSS-REF: links.jsonc key '$name' (unit $link_unit) has NO matching services.jsonc entry"
    cross_missing=$((cross_missing + 1))
  fi
done
echo "check-links cross-ref: $cross systemd-unit links, $cross_missing missing in services.jsonc"

# ── Q4: completeness — flag unregistered symlinks pointing into .agents ──
# Scan the real symlink surface (~/.local/bin, $HOME config dots, /etc/systemd/system,
# ~/.config/systemd/user) and flag any symlink resolving into .agents whose RESOLVED
# TARGET is not a registered links.jsonc target. Matching by resolved target (not
# source path) avoids false positives: systemd `enable` creates `*.wants/<unit>`
# enable-links whose canonical unit IS registered (e.g. default.target.wants/foo.service
# → registered target). Only truly unregistered manual links (target unknown) fail.
REG_TARGETS="$(printf '%s' "$LINKS_OBJ" | python3 -c "
import sys,json
d=json.load(sys.stdin).get('links',{})
for v in d.values():
    if isinstance(v,dict) and v.get('target'): print(v['target'])
")"
unreg=0
# Scan roots for incoming-link completeness (adjust here to widen/narrow).
SCAN_ROOTS=( "$HOME" "/etc" )
# Directories to PRUNE for speed (never scan into them): trash, virtualenvs,
# node deps, large model stores — they are noise / not .agents-owned symlinks.
PRUNE_DIRS=( 'Trash' '.venv' 'node_modules' 'models' )
while IFS= read -r ln; do
  [ -L "$ln" ] || continue
  resolved="$(readlink -f "$ln" 2>/dev/null || true)"
  case "$resolved" in
    "$AGENTS_DIR"/*|"$HOME/KpihX-Labs/.agents"/*) ;;
    *) continue ;;
  esac
  # Match the resolved target against registered links.jsonc targets.
  # Normalize: $HOME → placeholder, and the ~/.agents→~/KpihX-Labs/.agents
  # indirection so both real paths map to the canonical $HOME/.agents/... form.
  cand="${resolved/#$HOME/\$HOME}"
  cand="${cand//KpihX-Labs\/.agents/.agents}"
  if ! printf '%s\n' "$REG_TARGETS" | grep -Fxq -- "$cand"; then
    echo "  ✗ UNREGISTERED link into .agents: $ln -> $resolved (add to links.jsonc)"
    unreg=$((unreg + 1))
  fi
done < <(find "${SCAN_ROOTS[@]}" \( -type d -name 'Trash' -o -name '.venv' -o -name 'node_modules' -o -name 'models' \) -prune -o -type l -print 2>/dev/null)
echo "check-links completeness: $unreg unregistered symlink(s) into .agents"

echo "check-links: $checked checked for infra '$CURRENT_INFRA' ($ok ok, $broken broken, $reversed reversed, $dead dead), $skipped skipped (other infra)"
[ "$broken" -eq 0 ] && [ "$reversed" -eq 0 ] && [ "$dead" -eq 0 ] && [ "$cross_missing" -eq 0 ] && [ "$unreg" -eq 0 ]
