#!/usr/bin/env bash
# ============================================================
# env_lib.sh — shared .env helpers for .agents scripts
# ============================================================
# Central place for everything common to .agents scripts that deal with
# .env / .env.example files (secrets — never print or return values,
# only key names + whether a value is present/empty). The Python and JS twins
# (env_lib.py, env_lib.js) mirror this file EXACTLY, language apart — see
# libs/AGENTS.md for the mandatory "keep the 3 twins in sync" rule.
#
# Provided here:
#   env_keys <file>              : print non-commented KEY names (one per line)
#   env_has_value <file> <key>   : return 0 if <key> has a non-empty value
#   env_has_exact_empty_value <file> <key> : return 0 if <key>'s final value is exactly empty
#   env_validate_format <file>   : return 0 if every line is blank/comment/KEY=...
#   env_keys_not_in_example <env> <example> : print KEYs present in <env> but
#                                            absent from <example> (key names only)
#   env_load <file>              : load strict KEY=value data without evaluation
#   env_is_missing_key <env> <example> : return 0 if a KEY of <env> has no
#                                       (even empty) counterpart in <example>
#
# SECURITY: these helpers ONLY ever print KEY NAMES or "present/empty" status.
# They NEVER print or return VALUES. They may inspect values internally only to
# determine presence or load a value into the caller environment.
#
# Source:  $HOME/.agents/libs/env/env_lib.sh
# Caller:  scripts/env/*.sh (via source), then infra-skill scripts
# ============================================================

# --- List non-commented KEY names (one per line) -------------------------
# A line counts as a key only if it matches ^[A-Za-z_][A-Za-z0-9_]*= ... and is
# NOT a comment (leading #). Blank lines and full-line comments are ignored.
env_keys() {
  local file="$1"
  [ -f "$file" ] || return 1
  grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$file" | cut -d= -f1 | sort -u
}

# --- Does <key> have a non-empty value? -----------------------------------
# Prints nothing; returns 0 if the key exists AND its value is non-empty.
env_has_value() {
  local file="$1" key="$2"
  [ -f "$file" ] || return 1
  [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || return 1

  local line raw='' seen=0
  while IFS= read -r line || [ -n "$line" ]; do
    [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]] || continue
    if [ "${BASH_REMATCH[1]}" = "$key" ]; then
      raw="${BASH_REMATCH[2]}"
      seen=1
    fi
  done < "$file"

  [ "$seen" -eq 1 ] || return 1
  case "$raw" in
    ''|'""'|"''") return 1 ;;
    *) return 0 ;;
  esac
}

# --- Does <key>'s final assignment have exactly nothing after '='? ---------
env_has_exact_empty_value() {
  local file="$1" key="$2"
  [ -f "$file" ] || return 1
  [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || return 1

  local line raw='' seen=0
  while IFS= read -r line || [ -n "$line" ]; do
    [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]] || continue
    if [ "${BASH_REMATCH[1]}" = "$key" ]; then
      raw="${BASH_REMATCH[2]}"
      seen=1
    fi
  done < "$file"

  [ "$seen" -eq 1 ] && [ -z "$raw" ]
}

# --- Format validation: every non-blank, non-comment line is KEY=... ------
# Returns 0 (valid) if all lines are blank, '#...' comments, or 'KEY=...'.
env_validate_format() {
  local file="$1"
  [ -f "$file" ] || return 1
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    # skip blank lines and comments (leading #)
    case "$line" in
      ''|\#*) continue ;;
    esac
    [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*=.*$ ]] || return 1
  done < "$file"
  return 0
}

# --- KEYs present in <env> but missing from <example> (names only) --------
env_keys_not_in_example() {
  local env="$1" example="$2"
  [ -f "$env" ] || return 1
  [ -f "$example" ] || { env_keys "$env"; return 0; }
  local k
  while IFS= read -r k; do
    [ -n "$k" ] || continue
    grep -qE "^${k}=" "$example" || printf '%s\n' "$k"
  done < <(env_keys "$env")
}

# --- Load strict KEY=value data without evaluating it ---------------------
# Parses the whole file before changing the caller environment. Simple paired
# single/double quotes are unwrapped; all other content remains literal, so
# command substitutions and shell syntax are NEVER evaluated. Never echoes
# anything (secrets) and returns non-zero for a missing or malformed file.
env_load() {
  local file="$1" line key raw value i
  local -a keys=() values=()
  [ -f "$file" ] || return 1

  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|\#*) continue ;;
    esac
    [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]] || return 1
    key="${BASH_REMATCH[1]}"
    raw="${BASH_REMATCH[2]}"
    value="$raw"
    if [[ "$raw" == \"*\" && ${#raw} -ge 2 ]]; then
      value="${raw:1:${#raw}-2}"
    elif [[ "$raw" == \'*\' && ${#raw} -ge 2 ]]; then
      value="${raw:1:${#raw}-2}"
    fi
    keys+=("$key")
    values+=("$value")
  done < "$file"

  for i in "${!keys[@]}"; do
    printf -v "${keys[$i]}" '%s' "${values[$i]}"
    export "${keys[$i]}"
  done
}

# --- Is any KEY of <env> missing (even empty) from <example>? -------------
# Returns 0 if some KEY of <env> has NO counterpart in <example> (so the
# example is missing a key entirely). key names only.
env_is_missing_key() {
  local env="$1" example="$2"
  local k
  while IFS= read -r k; do
    [ -n "$k" ] || continue
    grep -qE "^${k}=" "$example" || return 0
  done < <(env_keys "$env")
  return 1
}
