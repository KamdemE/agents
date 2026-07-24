#!/bin/bash
set -euo pipefail

# ksh — KpihX UNIVERSAL DISPATCHER
ROOT="$HOME/.agents/skills/k-ubuntu/scripts"

usage() {
    echo "Usage: ksh <module> [args...]"
    echo ""
    echo "Modules:"
    echo "  clean [flags]        Run clean_all.sh — flags pass through"
    echo "  clean-admin [opts]   systemd/service admin via Makefile"
    echo "  backup [flags]       Run backup.sh — flags pass through"
    echo "  restore [flags]      Run restore.sh — flags pass through"
    echo "  backup-admin [opts]  systemd/admin via Makefile"
    echo "  status               Global system audit"
    echo ""
    echo "Detail: ksh clean --help | ksh backup-admin help"
}

[[ $# -lt 1 ]] && usage && exit 1

case "$1" in
    -h|--help) usage; exit 0 ;;
    status)
        shift
        echo "🔍 [ksh] Global Workstation Audit..."
        echo "--- CLEAN ---"
        make -s -C "$ROOT/clean" status 2>/dev/null || echo "Clean: Offline"
        echo "--- BACKUP ---"
        make -s -C "$ROOT/backup_restore" status 2>/dev/null || echo "Backup: Offline"
        echo "--- QMD ---"
        if [[ -x "$HOME/.agents/skills/k-qmd/scripts/check_collections.sh" ]]; then
            "$HOME/.agents/skills/k-qmd/scripts/check_collections.sh" || true
        else echo "QMD: not installed"; fi
        ;;
    clean)
        shift
        bash "$ROOT/clean/clean_all.sh" "$@"
        ;;
    clean-admin)
        shift
        make -C "$ROOT/clean" "$@"
        ;;
    backup)
        shift
        bash "$ROOT/backup_restore/backup.sh" "$@"
        ;;
    restore)
        shift
        bash "$ROOT/backup_restore/restore.sh" "$@"
        ;;
    backup-admin)
        shift
        make -C "$ROOT/backup_restore" "$@"
        ;;
    *)
        echo "❌ Unknown module '$1'" && usage && exit 1
        ;;
esac
