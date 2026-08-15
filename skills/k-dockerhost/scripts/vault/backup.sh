#!/bin/bash
# backup_vault_server.sh - Sovereign Automated Backup for Vaultwarden
# Location: Runs inside docker-host (LXC 100) via cron
# Schedule: Every Sunday at 02:00

# Source the Homelab universal library dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/../lib/notifier.sh"

set -e

# --- CONFIGURATION ---
VAULT_DATA_DIR="/var/lib/docker/volumes/vaultwarden_vaultwarden_data/_data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_TEMP_DIR="/tmp/vw_backup_${TIMESTAMP}"
ARCHIVE_NAME="vault_backup_${TIMESTAMP}.tar.gz"
RCLONE_REMOTE="gdrive-x:Homelab/Backups/Vault"
RCLONE_CONFIG="/root/.config/rclone/rclone.conf"
SECRET_FILE="/root/.vault_secret"
LOG_FILE="/var/log/vault-backup.log"
KEEP=3  # Number of backups to retain on Cloud

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# 0. Check Secret
if [ ! -f "$SECRET_FILE" ]; then
    log "❌ Error: Secret file $SECRET_FILE missing. Run gen_encrypt_key.sh to initialise the vault secret."
    homelab_notify "ERROR" "Secret file $SECRET_FILE missing on docker-host. Run gen_encrypt_key.sh!" "VAULT BACKUP"
    exit 1
fi
GPG_PASS=$(cat "$SECRET_FILE")

log "🚀 Starting Automated Vault Backup..."
homelab_notify "LOCK" "Sovereign GPG encryption started for Vaultwarden." "VAULT BACKUP"

# 1. Create temp workspace
mkdir -p "$BACKUP_TEMP_DIR"

# 2. Hot Backup of SQLite (Atomic)
log "📦 Creating atomic SQLite backup..."
sqlite3 "$VAULT_DATA_DIR/db.sqlite3" ".backup '$BACKUP_TEMP_DIR/db.sqlite3'"

# 3. Copy essential metadata and keys
log "🔐 Copying encryption keys and config..."
cp "$VAULT_DATA_DIR/config.json" "$BACKUP_TEMP_DIR/" 2>/dev/null || true
[ -f "$VAULT_DATA_DIR/rsa_key.pem" ] && cp "$VAULT_DATA_DIR/rsa_key.pem" "$BACKUP_TEMP_DIR/"
[ -f "$VAULT_DATA_DIR/rsa_key.pub" ] && cp "$VAULT_DATA_DIR/rsa_key.pub" "$BACKUP_TEMP_DIR/"

# 4. Copy attachments (if any)
if [ -d "$VAULT_DATA_DIR/attachments" ]; then
    log "📎 Copying attachments..."
    cp -r "$VAULT_DATA_DIR/attachments" "$BACKUP_TEMP_DIR/"
fi

# 5. Compress
log "🗜️ Compressing archive..."
tar -czf "/tmp/$ARCHIVE_NAME" -C "$BACKUP_TEMP_DIR" .

# 6. Encrypt with GPG (AES-256) — key is read from .vault_secret, never hardcoded
log "🛡️ Encrypting with GPG AES-256..."
echo "$GPG_PASS" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 \
    -o "/tmp/$ARCHIVE_NAME.gpg" "/tmp/$ARCHIVE_NAME"

# 7. Upload to Cloud
log "☁️ Uploading to Google Drive via rclone..."
if rclone --config "$RCLONE_CONFIG" copy "/tmp/$ARCHIVE_NAME.gpg" "$RCLONE_REMOTE" \
    --transfers=4 --drive-chunk-size=32M --stats-one-line -v >> "$LOG_FILE" 2>&1; then

    log "✅ Upload successful."

    # 8. Cloud Retention: Keep only the $KEEP most recent
    log "🧹 Applying cloud retention (keep $KEEP most recent)..."
    rclone --config "$RCLONE_CONFIG" lsf "$RCLONE_REMOTE" --files-only \
        | sort -r \
        | tail -n +$((KEEP + 1)) \
        | while read -r FILE_TO_DELETE; do
            [ -n "$FILE_TO_DELETE" ] || continue
            log "🗑️ Deleting old remote: $FILE_TO_DELETE"
            rclone --config "$RCLONE_CONFIG" deletefile "$RCLONE_REMOTE/$FILE_TO_DELETE" >> "$LOG_FILE" 2>&1
        done

    SIZE=$(du -sh "/tmp/$ARCHIVE_NAME.gpg" | cut -f1)
    log "✅ Vault Backup complete. Size: $SIZE"
    homelab_notify "SUCCESS" "Vault Backup Secured & Uploaded! Size: $SIZE" "VAULT BACKUP"
else
    log "❌ Cloud upload failed."
    homelab_notify "ERROR" "Vault Cloud Sync FAILED." "VAULT BACKUP"
    # Cleanup even on failure
    rm -rf "$BACKUP_TEMP_DIR" "/tmp/$ARCHIVE_NAME" "/tmp/$ARCHIVE_NAME.gpg" 2>/dev/null || true
    exit 1
fi

# 9. Cleanup temp files
log "🧹 Cleaning up temp files..."
rm -rf "$BACKUP_TEMP_DIR"
rm -f "/tmp/$ARCHIVE_NAME"
rm -f "/tmp/$ARCHIVE_NAME.gpg"

log "🏁 Done."
