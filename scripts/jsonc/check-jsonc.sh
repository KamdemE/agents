#!/usr/bin/env bash
# ============================================================
# check-jsonc.sh — verify .agents JSONC config assets parse cleanly
# ============================================================
# Enforces the  JSONC standard (comments allowed, single source of truth):
#   - every registered JSONC asset (assets/*.jsonc) parses as valid JSON after
#     comment-stripping (via libs/jsonc/jsonc_lib.sh jsonc_valid — the central
#     logic, never re-implemented here)
#   - the mandatory infra registers are included in that same asset sweep
#
# This check is deliberately THIN: it only calls the shared jsonc_lib helpers.
# It does NOT contain parsing logic itself (single source of truth in libs/).
#
# Source:  .agents/scripts/jsonc/check-jsonc.sh
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

echo "  ├─ 🧾 1/2 Parse every top-level JSONC asset"

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
  done < <(find "$ASSETS_DIR" -maxdepth 1 -name '*.jsonc' -print0)
fi

echo "  ├─ 🧭 2/2 Required registry presence"
# --- 2. The two registers must exist (already parsed above) ------------------
for name in services links; do
  file="$ASSETS_DIR/$name.jsonc"
  if [ ! -f "$file" ]; then
    echo "  ✗ MISSING required JSONC register: $file"
    failed=$((failed + 1))
  fi
done

echo "  └─ 📊 Summary: $checked JSONC asset(s), $failed failure(s)"
[ "$failed" -eq 0 ]
