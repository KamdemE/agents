#!/bin/bash
set -euo pipefail

# ksh — KpihX UNIVERSAL DISPATCHER
# Orchestrates system modules (clean, backup)
# Installed via 'make install' in Work/sh

ROOT="$HOME/.agents/skills/k-ubuntu/scripts"

usage() {
    echo "Usage: ksh <module> [target] | ksh status"
    echo ""
    echo "Modules: clean, backup, help"
    echo "Special: status (Global System Audit)"
}

[[ $# -lt 1 ]] && usage && exit 1

# Handle global status first
if [[ "$1" == "status" ]]; then
    echo "🔍 [ksh] Global Workstation Audit..."
    echo "--- CLEAN MODULE ---"
    make -s -C "$ROOT/clean" status || echo "Clean: Offline"
    echo ""
    echo "--- BACKUP MODULE ---"
    make -s -C "$ROOT/backup_restore" status || echo "Backup: Offline"
    echo ""
    echo "--- QMD MODULE ---"
    if [[ -x "$HOME/.agents/skills/k-qmd/scripts/check_collections.sh" ]]; then
        "$HOME/.agents/skills/k-qmd/scripts/check_collections.sh" || true
    else
        echo "QMD: check_collections.sh not installed"
    fi
    exit 0
fi

MODULE="$1"
shift

case "$MODULE" in
    clean)  DIR="clean" ;;
    backup) DIR="backup_restore" ;;
    help)   usage; exit 0 ;;
    *)      echo "❌ Unknown module '$MODULE'"; usage; exit 1 ;;
esac

# Default target is 'run'
TARGET="${1:-run}"

make -C "$ROOT/$DIR" "$TARGET"
