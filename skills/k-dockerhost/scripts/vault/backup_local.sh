#!/bin/bash
# backup_vault_local.sh - Manual Local Backup of Vaultwarden (run from PC)
# Pulls vault data from homelab LXC via SSH, encrypts locally using a key derived
# from your Bitwarden Master Password (via gen_encrypt_key.sh), and mirrors to HDD + Cloud.
# The encryption key is NEVER stored on disk — derived live and erased from memory.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source "$SCRIPT_DIR/../lib/notifier.sh"

set -e

# --- CONFIGURATION ---
# Tailscale/remote: kpihx-cloud. LAN (pve.local): homelab.
DOCKER_HOST="${DOCKER_HOST:-kpihx-cloud}"
REMOTE_VAULT_DIR="/var/lib/docker/volumes/vaultwarden_vaultwarden_data/_data"
HDD_MOUNT_POINT="/media/kpihx/KpihX-Backup"
HDD_DEST_DIR="$HDD_MOUNT_POINT/Homelab/Backups/Vault"
RCLONE_REMOTE="gdrive-x:Homelab/Backups/Vault"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
TEMP_DIR="/tmp/vw_local_backup_${TIMESTAMP}"
ARCHIVE_NAME="vault_manual_${TIMESTAMP}.tar.gz"
KEEP=3  # Number of backups to retain (HDD and Cloud)

# --- Derive encryption key from Bitwarden Master Password (never stored) ---
SALT="Homelab-Sovereign-Vault-2026-KpihX"

# Support non-interactive mode if BW_MASTER_PASSWORD is in env
if [[ -n "${BW_MASTER_PASSWORD:-}" ]]; then
    MASTER_PASS="$BW_MASTER_PASSWORD"
    echo "🔑 Using BW_MASTER_PASSWORD from environment."
else
    echo ""
    echo "🔐 Vaultwarden Local Backup — Key Derivation"
    echo "   Key is derived from your Bitwarden Master Password."
    echo "   It will NOT be stored anywhere on disk."
    echo ""
    echo -n "🔑 Enter your Bitwarden Master Password: "
    read -s MASTER_PASS
    echo ""
fi

if [[ -z "$MASTER_PASS" ]]; then
    echo "❌ Password cannot be empty."
    exit 1
fi

GPG_PASS=$(echo -n "${MASTER_PASS}${SALT}" | openssl dgst -sha256 | awk '{print $NF}')
unset MASTER_PASS  # Wipe the master password from memory immediately

# 1. Create temp workspace
mkdir -p "$TEMP_DIR/data"

homelab_notify "INFO" "Local manual backup initiated. Pulling from $DOCKER_HOST..." "VAULT BACKUP"

# 2. Remote SQLite backup via SSH (Atomic)
echo "📦 Taking atomic backup from $DOCKER_HOST..."
ssh "$DOCKER_HOST" "
    mkdir -p /tmp/vault_dump &&
    sqlite3 $REMOTE_VAULT_DIR/db.sqlite3 \".backup '/tmp/vault_dump/db.sqlite3'\" &&
    [ -f $REMOTE_VAULT_DIR/config.json ] && cp $REMOTE_VAULT_DIR/config.json /tmp/vault_dump/ || true &&
    [ -f $REMOTE_VAULT_DIR/rsa_key.pem ] && cp $REMOTE_VAULT_DIR/rsa_key.pem /tmp/vault_dump/ || true &&
    [ -f $REMOTE_VAULT_DIR/rsa_key.pub ] && cp $REMOTE_VAULT_DIR/rsa_key.pub /tmp/vault_dump/ || true
"

# 3. Pull from remote to local
echo "🚚 Pulling data from $DOCKER_HOST to local PC..."
scp -r "$DOCKER_HOST:/tmp/vault_dump/." "$TEMP_DIR/data/"
ssh "$DOCKER_HOST" "rm -rf /tmp/vault_dump"

# 4. Compress
echo "🗜️ Compressing..."
tar -czf "$TEMP_DIR/$ARCHIVE_NAME" -C "$TEMP_DIR/data" .

# 5. Encrypt (key derived, never stored)
echo "🛡️ Encrypting with GPG AES-256..."
echo "$GPG_PASS" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 \
    -o "$TEMP_DIR/$ARCHIVE_NAME.gpg" "$TEMP_DIR/$ARCHIVE_NAME"
unset GPG_PASS  # Wipe derived key from memory immediately after use

# 6. Mirror to HDD
if [ -d "$HDD_MOUNT_POINT" ]; then
    echo "🧱 Copying to HDD ($HDD_DEST_DIR)..."
    mkdir -p "$HDD_DEST_DIR"
    cp "$TEMP_DIR/$ARCHIVE_NAME.gpg" "$HDD_DEST_DIR/"
    # HDD Retention: Keep last $KEEP
    echo "🧹 Applying HDD retention (keep $KEEP most recent)..."
    ls -t "$HDD_DEST_DIR"/*.gpg 2>/dev/null | tail -n +$((KEEP + 1)) | xargs rm -f 2>/dev/null || true
    echo "✅ HDD: $(ls "$HDD_DEST_DIR"/*.gpg 2>/dev/null | wc -l) archive(s) kept."
else
    echo "⚠️ HDD not mounted at $HDD_MOUNT_POINT. Skipping HDD copy."
fi

# 7. Push to Cloud
echo "☁️ Sending to Google Drive via rclone..."
if rclone copy "$TEMP_DIR/$ARCHIVE_NAME.gpg" "$RCLONE_REMOTE" \
    --transfers=4 --drive-chunk-size=32M --stats-one-line -v; then

    # Cloud Retention: Keep last $KEEP
    echo "🧹 Applying Cloud retention (keep $KEEP most recent)..."
    rclone lsf "$RCLONE_REMOTE" --files-only \
        | sort -r \
        | tail -n +$((KEEP + 1)) \
        | while read -r FILE_TO_DELETE; do
            [ -n "$FILE_TO_DELETE" ] || continue
            echo "🗑️ Deleting old remote: $FILE_TO_DELETE"
            rclone deletefile "$RCLONE_REMOTE/$FILE_TO_DELETE"
        done

    homelab_notify "SUCCESS" "Manual Vault Backup completed! HDD + Cloud synced." "VAULT BACKUP"
else
    homelab_notify "ERROR" "Failed to Rclone upload manual vault backup." "VAULT BACKUP"
fi

# 8. Cleanup (no key files remain on disk)
echo "🧹 Cleaning up temp files..."
rm -rf "$TEMP_DIR"

echo ""
echo "🏁 Done. Encryption key was never stored on disk."
