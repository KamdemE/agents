#!/usr/bin/env bash
# ============================================================
# jsonc_lib.sh — shared JSONC helpers for .agents scripts
# ============================================================
# Central place for everything common to .agents scripts that deal with
# JSONC assets (config-with-comments — the KπX standard, see k-project).
# The per-script lib.sh files (scripts/services/lib.sh, scripts/links/lib.sh)
# source THIS file so they stay thin and non-duplicated.
#
# Provided here:
#   strip_jsonc        : remove // and /* */ comments (JSONC standard)
#   jsonc_valid        : verify a JSONC file parses (via python3 json)
#   load_jsonc         : load a JSONC file's JSON object into a var
#   current_infra      : resolve current infra from tailscale + infras_skills.jsonc
#   infra_matches      : "*" or array contains current infra → true
#   AGENTS_DIR / ASSETS_DIR / *_FILE path constants
#
# Source:  $HOME/.agents/libs/jsonc_lib.sh
# Caller:  scripts/*/lib.sh (via `source`), then the actual scripts
# ============================================================

# --- JSONC comment stripping (respects string literals) ---
strip_jsonc() {
  # Note: must use python3 -c (not a heredoc) so the JSONC data comes via stdin,
  # and use chr(34) instead of '"' inside the single-quoted shell string (the
  # literal `'"'` sequence would close the single-quote early → SyntaxError).
  python3 -c '
import sys
src = sys.stdin.read()
out = []
in_str = False
i = 0
while i < len(src):
    c = src[i]; n = src[i+1] if i+1 < len(src) else ""
    if in_str:
        out.append(c)
        if c == "\\" and i+1 < len(src): out.append(src[i+1]); i += 2; continue
        if c == chr(34): in_str = False
        i += 1; continue
    if c == chr(34): in_str = True; out.append(c); i += 1; continue
    if c == "/" and n == "/":
        while i < len(src) and src[i] != "\n": i += 1
        continue
    if c == "/" and n == "*":
        i += 2
        while i+1 < len(src) and not (src[i] == "*" and src[i+1] == "/"): i += 1
        i += 2; continue
    out.append(c); i += 1
print("".join(out))
'
}

# --- Validate a JSONC file (strip comments, then strict JSON parse) ---
jsonc_valid() {
  local file="$1"
  [ -f "$file" ] || { echo "  ✗ MISSING: $file"; return 1; }
  if ! strip_jsonc < "$file" | python3 -m json.tool >/dev/null 2>&1; then
    echo "  ✗ INVALID JSONC format: $file"
    return 1
  fi
  return 0
}

# --- Load a JSONC file's object into a var (evaluated via declare -a) ---
# Usage: eval "$(load_jsonc <file> <varname>)"  → sets $varname (json string)
load_jsonc() {
  local file="$1" var="$2"
  if ! jsonc_valid "$file"; then
    echo "export $var='{}'"
    return 1
  fi
  local obj
  obj="$(strip_jsonc < "$file")"
  echo "export $var='$obj'"
}

# --- Resolve the CURRENT infra from tailscale + infras_skills.jsonc ---
# Returns the infra name (e.g. "kpihx-ubuntu") or empty.
current_infra() {
  local hostname=""
  hostname="$(tailscale status --json 2>/dev/null \
    | python3 -c 'import sys,json
try:
  d=json.load(sys.stdin); print((d.get("Self",{}).get("DNSName","") or "").split(".")[0])
except Exception: print("")' 2>/dev/null)"
  [ -n "$hostname" ] || hostname="$(hostname | tr '[:upper:]' '[:lower:]')"
  echo "$hostname"
}

# --- Does a service/link apply to the current infra? ---
# infra_matches <current_infra> <infras-json-string-or-*>  → true if applies
# infras may be the literal "*" (all), a JSON array string like ["kpihx-ubuntu"],
# or a JSON array containing "*" like ["*"] (also ALL).
infra_matches() {
  local current="$1" infras="$2"
  # bare "*" OR JSON array containing "*" (e.g. ["*"]) → matches ALL infra.
  # Pattern: *'"*"'* = anything + the literal `"*"` + anything (single-quoted).
  case "$infras" in
    *'"*"'*) return 0 ;;
  esac
  if printf '%s' "$infras" | grep -q "\"$current\""; then
    return 0
  fi
  return 1
}

AGENTS_DIR="$HOME/.agents"
ASSETS_DIR="$AGENTS_DIR/assets"
INFRA_FILE="$ASSETS_DIR/infras_skills.jsonc"
SERVICES_FILE="$ASSETS_DIR/services.jsonc"
LINKS_FILE="$ASSETS_DIR/links.jsonc"
