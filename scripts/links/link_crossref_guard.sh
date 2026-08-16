#!/usr/bin/env bash
# ============================================================
# link_crossref_guard.sh — sub-check: links.jsonc ↔ services.jsonc (by unit)
# ============================================================
# Part of check_links.sh (modular split). Every links.jsonc key whose target is
# a systemd unit (extension in the constant set) must have a matching
# services.jsonc entry with the same unit name. Both are source-of-truth
# registries; drift is a real bug (e.g. clean/clean-system). The unit-extension
# set is centralized here so future unit types are covered without hardcoding
# -service/-timer (future-proof: socket/path/mount/target/... handled).
# ============================================================

# shellcheck disable=SC1090
source "$SCRIPT_DIR/lib.sh"

SYSTEMD_UNIT_EXTS="service timer socket path mount automount target device slice scope swap"

# link_crossref_guard <LINKS_OBJ> <SERVICES_OBJ>
#   appends to $CROSS / $CROSS_MISSING counters
link_crossref_guard() {
  local links_obj="$1" services_obj="$2"
  local name link_unit ext found
  CROSS=0
  CROSS_MISSING=0

  for name in $(printf '%s' "$links_obj" \
    | python3 -c 'import sys,json; d=json.load(sys.stdin); print("\n".join(d.get("links",{}).keys()))' 2>/dev/null); do
    link_unit="$(printf '%s' "$links_obj" | python3 -c "
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
    CROSS=$((CROSS + 1))
    found="$(printf '%s' "$services_obj" | python3 -c "
import sys,json
d=json.load(sys.stdin).get('services',{})
u='$link_unit'
print('yes' if any(isinstance(v,dict) and v.get('unit')==u for v in d.values()) else 'no')
" 2>/dev/null)"
    if [ "$found" != "yes" ]; then
      echo "  ✗ CROSS-REF: links.jsonc key '$name' (unit $link_unit) has NO matching services.jsonc entry"
      CROSS_MISSING=$((CROSS_MISSING + 1))
    fi
  done
  echo "check-links cross-ref: $CROSS systemd-unit links, $CROSS_MISSING missing in services.jsonc"
}
