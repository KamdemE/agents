#!/bin/bash
set -euo pipefail

# ksh —  UNIVERSAL DISPATCHER
ROOT="$HOME/.agents/skills/k-ubuntu/scripts"

usage() {
    echo "Usage: ksh <module> [args...]"
    echo ""
    echo "Modules:"
    echo "  clean [flags]            Run clean_all.sh directly"
    echo "  clean-admin [opts]       systemd/admin via Makefile"
    echo "  backup [flags]           Run backup.sh (workstation)"
    echo "  restore [flags]          Run restore.sh (workstation)"
    echo "  backup-admin [opts]      systemd/admin via Makefile"
    echo "  backup-pve [flags]       Run backup_pve.sh (PVE)"
    echo "  restore-pve [flags]      Run restore_pve.sh (PVE)"
    echo "  backup-pve-admin [opts]  systemd/admin for PVE via Makefile"
    echo "  status                   Global system audit (clean + backup + QMD)"
    echo ""
    echo "Per-module help:  ksh <module> --help   (for run modules)"
    echo "                  ksh <module>-admin help (for admin modules)"
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
        echo "--- PVE BACKUP ---"
        make -s -C "$ROOT/backup_restore_pve" status 2>/dev/null || echo "PVE Backup: Offline"
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
    backup-pve)
        shift
        bash "$ROOT/backup_restore_pve/backup_pve.sh" "$@"
        ;;
    restore-pve)
        shift
        bash "$ROOT/backup_restore_pve/restore_pve.sh" "$@"
        ;;
    backup-pve-admin)
        shift
        make -C "$ROOT/backup_restore_pve" "$@"
        ;;
    *)
        echo "❌ Unknown module '$1'" && usage && exit 1
        ;;
esac
