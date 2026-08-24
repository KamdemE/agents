#!/usr/bin/env bash
# ============================================================
# env_inspect.sh — ultra-secure key viewer for ANY *env* file
# ============================================================
# Takes an arbitrary path (even outside .agents) of kind `*.env`, `.env*`, or a
# directory containing a `.env`. By default it prints filled non-commented keys;
# `-n` also prints empty keys. It NEVER prints VALUES (secrets zero-touch). It uses env_lib.sh
# so it shares the exact same parsing logic as every other env consumer.
#
# Usage:
#   env_inspect.sh <path-to-env-or-dir>       (auto-find .env / .env.example)
#   env_inspect.sh -n <path>                  (also list keys that are empty)
#
# Source:  .agents/scripts/env/env_inspect.sh
# Caller:  manual / debugging — safe for any *env* file, inside or outside .agents
# Depends: .agents/libs/env/env_lib.sh  (env_keys / env_has_value)
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../libs/env/env_lib.sh
source "$SCRIPT_DIR/../../libs/env/env_lib.sh"

SHOW_EMPTY=0
[ "${1:-}" = "-n" ] && { SHOW_EMPTY=1; shift; }
TARGET="${1:-}"

if [ -z "$TARGET" ] || [ "$#" -ne 1 ]; then
  echo "usage: env_inspect.sh [-n] <path-to-env-or-dir>" >&2
  exit 2
fi

# Resolve the actual env file: if TARGET is a directory, look for .env / .env.example.
FILE="$TARGET"
if [ -d "$TARGET" ]; then
  for cand in "$TARGET/.env" "$TARGET/.env.example"; do
    if [ -f "$cand" ]; then FILE="$cand"; break; fi
  done
fi

if [ -f "$FILE" ]; then
  case "$(basename "$FILE")" in
    .env|.env*|*.env) ;;
    *) echo "✗ env_inspect: '$FILE' is not an env file" >&2; exit 2 ;;
  esac
fi

if [ ! -f "$FILE" ]; then
  echo "✗ env_inspect: no env file found at '$TARGET'" >&2
  exit 1
fi

echo "env_inspect: $(realpath "$FILE") — filled non-commented keys (values NEVER shown):"
for k in $(env_keys "$FILE"); do
  if env_has_value "$FILE" "$k"; then
    printf '  %-40s → [filled]\n' "$k"
  else
    if [ "$SHOW_EMPTY" -eq 1 ]; then
      printf '  %-40s → [empty]\n' "$k"
    fi
  fi
done
