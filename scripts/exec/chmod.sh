#!/bin/bash
# chmod.sh — Apply a permission mask to executable script paths discovered
# across scripts/, libs/, and skill scripts. Takes a single 3-digit octal permission.
#
# Usage:
#   scripts/chmod.sh 755    # apply 755 (default: user rwx, group rx, other rx)
#   scripts/chmod.sh 744    # apply 744 (stricter: user rwx, group r, other r)
#   scripts/chmod.sh 700    # apply 700 (locked: user rwx only)

set -euo pipefail

PERM="${1:-755}"

if ! [[ "$PERM" =~ ^[0-7]{3}$ ]]; then
    echo "❌ Invalid permission: '$PERM'. Must be 3 octal digits (e.g. 755, 744)."
    echo "Usage: $0 <XYZ>"
    exit 1
fi

cd "$(dirname "$0")/../.." || exit 1

echo "🔧 Applying permission $PERM..."

declare -i COUNT=0

# ── Only chmod shebang-bearing scripts (entrypoints) to PERM ──
# Root-cause fix for the recurring EXE002 drift (2026-08-15): non-shebang library
# modules (__init__.py, _*_common.py, utils.py, check_skills/ guards) must NOT be
# set executable — that triggers ruff EXE002 (executable-but-no-shebang). They are
# set to 644 instead. Only files starting with a #! shebang get PERM (755 default).
apply() {
    while IFS= read -r -d '' f; do
        if head -c 2 "$f" | grep -q '#!'; then
            chmod "$PERM" "$f"
            COUNT+=1
        else
            chmod 644 "$f"
            COUNT+=1
        fi
    done < <(find "$@" -print0)
}

# ── scripts/ (this script excluded so find doesn't chmod itself slightly oddly — actually it's fine) ──
apply scripts/ -type f \( -name "*.py" -o -name "*.sh" -o -name "*.zsh" -o -name "*.ksh" -o -name "*.js" -o -name "*.ts" \)

# ── libs/ (shared script libraries — same chmod policy) ──
apply libs/ -type f \( -name "*.py" -o -name "*.sh" -o -name "*.zsh" -o -name "*.ksh" -o -name "*.js" -o -name "*.ts" \)

# ── skills/**/scripts/ ──
apply skills/ -path "*/scripts/*" -type f \( -name "*.py" -o -name "*.sh" -o -name "*.zsh" -o -name "*.ksh" -o -name "*.js" -o -name "*.ts" \)

echo "✅ Done — $COUNT files set to $PERM."
