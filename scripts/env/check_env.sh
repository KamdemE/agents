#!/usr/bin/env bash
# ============================================================
# check_env.sh — verify .agents/.env + .env.example governance
# ============================================================
# Enforces the KπX env-file standard (single source of truth, secrets-safe):
#   1. exactly ONE .env and ONE .env.example, living ONLY at $HOME/.agents
#      (no stray .env* anywhere else inside .agents)   → else BLOCK
#   2. both files have restrictive permissions
#      (owner rw, group/others NO access — 600)         → else BLOCK + fix cmd
#   3. both files are well formatted (each non-blank, non-comment line is KEY=...)
#   4. every KEY present in .env has an exactly-empty `KEY=` counterpart in
#      .env.example (mirror check — no missing or pre-filled template values)
#   5. every non-commented KEY in .env has a FILLED value
#
# By "entry" we mean ALL non-commented KEY=... lines. Values are NEVER printed
# (secrets zero-touch) — we only check presence/emptiness and key names.
#
# Source:  .agents/scripts/env/check_env.sh
# Caller:  make check-env   (joined into `make check`)
# Depends: .agents/libs/env/env_lib.sh  (env_keys / env_has_value / env_has_exact_empty_value / env_validate_format)
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../libs/env/env_lib.sh
source "$SCRIPT_DIR/../../libs/env/env_lib.sh"

AGENTS_DIR="$HOME/.agents"
ENV_FILE="$AGENTS_DIR/.env"
EXAMPLE_FILE="$AGENTS_DIR/.env.example"

failed=0
fail() { failed=$((failed + 1)); echo "  $1"; }

echo "  ├─ 🔐 1/5 Required files"

# --- 0. Files must exist ------------------------------------------------
if [ ! -f "$ENV_FILE" ]; then
  fail "✗ MISSING $ENV_FILE — create it by copying $EXAMPLE_FILE and filling values."
  exit 1
fi
if [ ! -f "$EXAMPLE_FILE" ]; then
  fail "✗ MISSING $EXAMPLE_FILE — template for .env."
fi

echo "  ├─ 🧭 2/5 Unique secret-file location"
# --- 1. Exactly ONE .env + .env.example, only at $HOME/.agents -----------
# A stray .env* elsewhere inside .agents is a violation (duplicate secrets).
stray="$(find "$AGENTS_DIR" -name '.env*' -not -path "$AGENTS_DIR/.env" -not -path "$AGENTS_DIR/.env.example" -not -path "$AGENTS_DIR/.git/*" 2>/dev/null)"
if [ -n "$stray" ]; then
  fail "✗ STRAY .env* files inside .agents (must be ONLY ~/.agents/.env + .env.example):"
  printf '%s\n' "$stray" | sed 's/^/      /'
fi

echo "  ├─ 🔒 3/5 Permissions and format"
# --- 2. Permissions (owner rw, group/others NO access → 600) -------------
need_fix=0
for f in "$ENV_FILE" "$EXAMPLE_FILE"; do
  if [ -f "$f" ]; then
    perms="$(stat -c '%a' "$f" 2>/dev/null)"
    if [ "$perms" != "600" ]; then
      fail "✗ PERMISSIONS $f is $perms (expected 600: owner rw, group/others NO access)."
      echo "      Fix: chmod 600 $f"
      need_fix=$((need_fix + 1))
    fi
  fi
done

# --- 3. Format: each non-blank, non-comment line is KEY=... ---------------
if [ -f "$ENV_FILE" ] && ! env_validate_format "$ENV_FILE"; then
  fail "✗ FORMAT .env: every non-blank, non-comment line must be KEY=value."
fi
if [ -f "$EXAMPLE_FILE" ] && ! env_validate_format "$EXAMPLE_FILE"; then
  fail "✗ FORMAT .env.example: every non-blank, non-comment line must be KEY=value."
fi

echo "  ├─ 🪞 4/5 Template mirror"
# --- 4. Mirror: every .env KEY needs an exactly-empty template counterpart --
if [ -f "$EXAMPLE_FILE" ]; then
  missing="$(env_keys_not_in_example "$ENV_FILE" "$EXAMPLE_FILE")"
  if [ -n "$missing" ]; then
    fail "✗ MIRROR .env → .env.example — these keys are missing from .env.example:"
    printf '%s\n' "$missing" | sed 's/^/      /'
  fi

  template_values=0
  for k in $(env_keys "$ENV_FILE"); do
    if ! env_has_exact_empty_value "$EXAMPLE_FILE" "$k"; then
      echo "      ✗ TEMPLATE value must be exactly empty (KEY=): $k"
      template_values=$((template_values + 1))
    fi
  done
  if [ "$template_values" -gt 0 ]; then
    fail "✗ $template_values .env.example counterpart key(s) are not exactly empty."
  fi
fi

echo "  ├─ ✅ 5/5 Filled live values"
# --- 5. Filled: every non-commented .env KEY must have a value ------------
unfilled=0
if [ -f "$ENV_FILE" ]; then
  for k in $(env_keys "$ENV_FILE"); do
    if ! env_has_value "$ENV_FILE" "$k"; then
      echo "      ✗ EMPTY value for key: $k"
      unfilled=$((unfilled + 1))
    fi
  done
fi
if [ "$unfilled" -gt 0 ]; then
  fail "✗ $unfilled .env key(s) have EMPTY values (fill them)."
fi

# --- Summary ---------------------------------------------------------------
if [ "$failed" -eq 0 ]; then
  echo "  └─ 📊 Summary: 1 .env + 1 template, secure, formatted, mirrored, and filled"
else
  echo "  └─ 📊 Summary: $failed failure(s). See instructions above."
  exit 1
fi
