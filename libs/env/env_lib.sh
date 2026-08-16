#!/usr/bin/env bash
# ============================================================
# env_lib.sh — shared .env helpers for .agents scripts
# ============================================================
# Central place for everything common to .agents scripts that deal with
# .env / .env.example files (secrets — KπX NEVER reads/prints values, only
# key names + whether a value is present/empty). The Python and JS twins
# (env_lib.py, env_lib.js) mirror this file EXACTLY, language apart — see
# libs/AGENTS.md for the mandatory "keep the 3 twins in sync" rule.
#
# Provided here:
#   env_keys <file>              : print non-commented KEY names (one per line)
#   env_has_value <file> <key>   : return 0 if <key> has a non-empty value
#   env_validate_format <file>   : return 0 if every line is blank/comment/KEY=...
#   env_keys_not_in_example <env> <example> : print KEYs present in <env> but
#                                            absent from <example> (key names only)
#   env_load <file>              : source a .env file safely (set -a; source; set +a)
#   env_is_missing_key <env> <example> : return 0 if a KEY of <env> has no
#                                       (even empty) counterpart in <example>
#
# SECURITY: these helpers ONLY ever print KEY NAMES or "present/empty" status.
# They NEVER print or read the VALUES. Keep it that way (secrets zero-touch).
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
  # match a line that starts with KEY= and has something after the '='
  grep -qE "^${key}=.+$" "$file"
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
    # every other line must look like KEY=value
    case "$line" in
      [A-Za-z_][A-Za-z0-9_]*=*) ;;
      *) return 1 ;;
    esac
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

# --- Source a .env file safely -------------------------------------------
# Uses `set -a; source; set +a` so all KEY=value become exported vars. Never
# echoes anything (secrets). Returns the source status.
env_load() {
  local file="$1"
  [ -f "$file" ] || return 1
  set -a
  # shellcheck disable=SC1090
  source "$file"
  set +a
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
