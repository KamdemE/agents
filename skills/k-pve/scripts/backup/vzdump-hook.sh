#!/bin/bash
# vzdump-hook.sh — Proxmox VZDump Hook Wrapper
# Called automatically by Proxmox at backup lifecycle phases.
# Delegates to the main backup script only at phase 'job-end'.

PHASE="$1"

if [ "$PHASE" == "job-end" ]; then
    exec /home/kpihx/.agents/skills/k-pve/scripts/backup/backup
fi

exit 0
