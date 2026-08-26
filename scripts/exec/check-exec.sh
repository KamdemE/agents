#!/usr/bin/env bash
# ============================================================
# check-exec.sh — verify script executability in .agents/
# ============================================================
# Read-only check (does NOT modify permissions) complementing chmod.sh:
#   - shebang-bearing files (entrypoints/scripts) MUST be executable
#   - non-shebang library modules (__init__.py, _*_common.py, utils.py,
#     guards, etc.) MUST NOT be executable (644) — otherwise ruff EXE002 fires
#
# Run:  make check-exec   (joined into `make check`)
# Fix:  make chmod        (normalizes via scripts/exec/chmod.sh)
# ============================================================

set -uo pipefail

cd "$(dirname "$0")/../.." || exit 1

declare -i errors=0
declare -i checked=0

echo "  ├─ 📜 1/3 scripts/ executability"

check_executable() {
  # $1 = file, $2 = mode string
  local f="$1" mode="$2"
  local has_shebang=no
  if head -c 2 "$f" | grep -q '#!'; then
    has_shebang=yes
  fi
  checked+=1
  if [ "$has_shebang" = "yes" ]; then
    # entrypoint: must be executable (any +x bit)
    if [ ! -x "$f" ]; then
      echo "  ✗ NOT executable (has shebang, entrypoint): $f ($mode)"
      errors+=1
    fi
  else
    # library module: must NOT be executable (avoid ruff EXE002)
    if [ -x "$f" ]; then
      echo "  ✗ executable but no shebang (library module, set 644): $f ($mode)"
      errors+=1
    fi
  fi
}

# ── scripts/ ──
while IFS= read -r -d '' f; do
  check_executable "$f" "$(stat -c '%A' "$f")"
done < <(find scripts/ -type f \( -name "*.py" -o -name "*.sh" -o -name "*.zsh" -o -name "*.ksh" -o -name "*.js" -o -name "*.ts" \) -print0)

echo "  ├─ 📚 2/3 libs/ executability"
# ── libs/ ──
while IFS= read -r -d '' f; do
  check_executable "$f" "$(stat -c '%A' "$f")"
done < <(find libs/ -type f \( -name "*.py" -o -name "*.sh" -o -name "*.zsh" -o -name "*.ksh" -o -name "*.js" -o -name "*.ts" \) -print0)

echo "  ├─ 🧩 3/3 skill-script executability"
# ── skills/**/scripts/ ──
while IFS= read -r -d '' f; do
  check_executable "$f" "$(stat -c '%A' "$f")"
done < <(find skills/ -path "*/scripts/*" -type f \( -name "*.py" -o -name "*.sh" -o -name "*.zsh" -o -name "*.ksh" -o -name "*.js" -o -name "*.ts" \) -print0)

echo "  └─ 📊 Summary: $checked files, $errors error(s). Fix with: make chmod"
[ "$errors" -eq 0 ]
