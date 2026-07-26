#!/bin/bash
# chmod.sh — Apply a permission mask to all executable script paths
# listed in .gitattributes. Takes a single 3-digit octal permission.
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

cd "$(dirname "$0")/.."

echo "🔧 Applying permission $PERM..."

declare -i COUNT=0

apply() {
    while IFS= read -r -d '' f; do
        chmod "$PERM" "$f"
        COUNT+=1
    done < <(find "$@" -print0 2>/dev/null || true)
}

# ── hooks/ ──
apply hooks/ -type f \( -name "*.py" -o -name "*.sh" -o -name "*.zsh" -o -name "*.ksh" -o -name "*.js" -o -name "*.ts" \)

# ── scripts/ (this script excluded so find doesn't chmod itself slightly oddly — actually it's fine) ──
apply scripts/ -type f \( -name "*.py" -o -name "*.sh" -o -name "*.zsh" -o -name "*.ksh" -o -name "*.js" -o -name "*.ts" \)

# ── skills/**/scripts/ ──
apply skills/ -path "*/scripts/*" -type f \( -name "*.py" -o -name "*.sh" -o -name "*.zsh" -o -name "*.ksh" -o -name "*.js" -o -name "*.ts" \)

# ── skills/**/assets/install.sh + purge.sh ──
apply skills/ \( -path "*/assets/install.sh" -o -path "*/assets/purge.sh" \) -type f

echo "✅ Done — $COUNT files set to $PERM."
