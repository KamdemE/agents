#!/bin/bash
# vzdump-hook.sh - Proxmox VZDump Hook Script
# Description: Automatically syncs local Proxmox backups to Google Drive
#              as soon as the backup job finishes.

# Proxmox passes arguments to the hook script during the backup lifecycle:
# $1 = phase ('job-start', 'backup-start', 'backup-end', 'job-end', 'job-abort')
# $2 = mode ('stop', 'suspend', 'snapshot')
# $3 = VMID (e.g. 100, 101)

# Source the Homelab universal library dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/../lib/notifier.sh"

PHASE="$1"

# --- CONFIGURATION ---
RCLONE_REMOTE="gdrive-x:Backups/PVE"
DUMP_DIR="/var/lib/vz/dump"
LOG_FILE="/var/log/vzdump-rclone.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# We only trigger the upload when the entire backup job is successfully completed
if [ "$PHASE" == "job-end" ]; then
    log "🚀 Phase 'job-end' detected. Starting Intelligent Cloud sync..."
    
    # Identify the latest archive (snapshot, stop, or suspend)
    LATEST_ARCHIVE=$(ls -t "$DUMP_DIR"/vzdump-*.zst "$DUMP_DIR"/vzdump-*.vma "$DUMP_DIR"/vzdump-*.tar.gz 2>/dev/null | head -n 1)

    if [ -z "$LATEST_ARCHIVE" ]; then
        log "⚠️ Warning: No archive found in $DUMP_DIR to upload."
        homelab_notify "WARN" "No archive found on Proxmox for sync." "PVE BACKUP"
    else
        ARCHIVE_NAME=$(basename "$LATEST_ARCHIVE")
        log "📂 Processing latest archive: $ARCHIVE_NAME"
        homelab_notify "INFO" "Cloud sync started for $ARCHIVE_NAME" "PVE BACKUP"
        
        # Optimized upload for Google Drive
        if /usr/bin/rclone --config /root/.config/rclone/rclone.conf copy "$LATEST_ARCHIVE" "$RCLONE_REMOTE" \
            --transfers=4 \
            --drive-chunk-size=32M \
            --stats-one-line -v >> "$LOG_FILE" 2>&1; then
            
            log "✅ Upload successful."

            # Cloud Cleanup: Only keep the latest one (purge others)
            log "🧹 Purging old archives in Cloud..."
            /usr/bin/rclone --config /root/.config/rclone/rclone.conf lsf "$RCLONE_REMOTE" --files-only | grep -v "$ARCHIVE_NAME" | while read -r FILE_TO_DELETE; do
                if [ -n "$FILE_TO_DELETE" ]; then
                    log "🗑️ Deleting remote file: $FILE_TO_DELETE"
                    /usr/bin/rclone --config /root/.config/rclone/rclone.conf deletefile "$RCLONE_REMOTE/$FILE_TO_DELETE" --drive-use-trash=false >> "$LOG_FILE" 2>&1
                fi
            done
            
            SIZE=$(du -sh "$LATEST_ARCHIVE" | cut -f1)
            log "✅ Backup complete. Size: $SIZE"
            homelab_notify "SUCCESS" "Cloud Sync Complete!%0ASize: $SIZE ($ARCHIVE_NAME)" "PVE BACKUP"
        else
            log "❌ Error: Rclone upload failed."
            homelab_notify "ERROR" "Rclone upload failed for $ARCHIVE_NAME" "PVE BACKUP"
        fi
    fi
    log "--------------------------------------------------------"
fi

exit 0
