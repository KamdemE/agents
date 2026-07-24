#!/bin/bash
# restore_docker_host.sh - Disaster Recovery for Proxmox Guests
# Description: Pulls the latest backup from Google Drive back to Proxmox local storage.

# Source the Homelab universal library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/../lib/notifier.sh"

set -e

# --- CONFIGURATION ---
RCLONE_REMOTE="gdrive-x:Homelab/Backups/Docker_Host"
DUMP_DIR="/var/lib/vz/dump"
VZDUMP_CONF="/etc/vzdump.conf"

homelab_notify "INFO" "Disaster Recovery process initiated. Fetching latest from Cloud." "PVE RESTORE"

# 1. Fetch latest archive name from Google Drive
LATEST_REMOTE=$(rclone lsf "$RCLONE_REMOTE" --files-only | sort -r | head -n 1)

if [ -z "$LATEST_REMOTE" ]; then
    homelab_notify "ERROR" "No archive found on Google Drive. Recovery aborted." "PVE RESTORE"
    exit 1
fi

echo "📦 Found latest remote: $LATEST_REMOTE"

# 2. Download to local dump dir
echo "🚚 Downloading to $DUMP_DIR..."
if rclone copy "$RCLONE_REMOTE/$LATEST_REMOTE" "$DUMP_DIR" --progress; then
    homelab_notify "SUCCESS" "Archive successfully recovered from Cloud. Ready for 'pct restore' or 'qmrestore'." "PVE RESTORE"
else
    homelab_notify "ERROR" "Download failed. Check networking/rclone." "PVE RESTORE"
    exit 1
fi

echo "✅ Ready to restore. Example command:"
echo "pct restore <VMID> $DUMP_DIR/$LATEST_REMOTE"
