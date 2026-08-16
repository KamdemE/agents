#!/usr/bin/env bash
# ============================================================
# check_jsonc.sh — verify .agents JSONC config assets parse cleanly
# ============================================================
# Enforces the KπX JSONC standard (comments allowed, single source of truth):
#   - every registered JSONC asset (assets/*.jsonc) parses as valid JSON after
#     comment-stripping (via libs/jsonc/jsonc_lib.sh jsonc_valid — the central
#     logic, never re-implemented here)
#   - every JSONC asset referenced by the infra/skills guards is well formed
#
# This check is deliberately THIN: it only calls the shared jsonc_lib helpers.
# It does NOT contain parsing logic itself (single source of truth in libs/).
#
# Source:  .agents/scripts/jsonc/check_jsonc.sh
# Caller:  make check-jsonc   (joined into `make check`)
# Depends: .agents/libs/jsonc/jsonc_lib.sh  (jsonc_valid / strip_jsonc)
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../libs/jsonc/jsonc_lib.sh
source "$SCRIPT_DIR/../../libs/jsonc/jsonc_lib.sh"

ASSETS_DIR="$AGENTS_DIR/assets"
failed=0
checked=0

echo "🔍 check-jsonc — JSONC assets ($ASSETS_DIR)"

# --- 1. Every asset/*.jsonc must be valid (central jsonc_valid) ------------
if [ -d "$ASSETS_DIR" ]; then
  while IFS= read -r -d '' f; do
    checked=$((checked + 1))
    if jsonc_valid "$f"; then
      echo "  ✓ $f"
    else
      echo "  ✗ INVALID JSONC: $f"
      failed=$((failed + 1))
    fi
  done < <(find "$ASSETS_DIR" -maxdepth 1 -name '*.jsonc' -print0 2>/dev/null || true)
fi

# --- 2. The three infra registers must parse (infras/services/links) --------
for name in infras_skills services links; do
  file="$ASSETS_DIR/$name.jsonc"
  if [ -f "$file" ]; then
    checked=$((checked + 1))
    if jsonc_valid "$file"; then
      echo "  ✓ $file"
    else
      echo "  ✗ INVALID JSONC: $file"
      failed=$((failed + 1))
    fi
  fi
done

echo "check-jsonc: $checked JSONC asset(s) checked ($failed failure(s))."
[ "$failed" -eq 0 ]
