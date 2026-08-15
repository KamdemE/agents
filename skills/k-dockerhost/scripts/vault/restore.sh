#!/bin/bash
# restore_vault.sh - Sovereign Disaster Recovery for Vaultwarden
# Downloads the specified backup from Google Drive, derives the decryption key
# from your Bitwarden Master Password (never stored), and restores the vault data.
# Run from inside docker-host or a machine with rclone + SSH access.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# --- CONFIGURATION ---
VAULT_DATA_DIR="/var/lib/docker/volumes/vaultwarden_vaultwarden_data/_data"
RESTORE_TEMP_DIR="/tmp/vw_restore_$(date +%Y%m%d_%H%M%S)"
RCLONE_REMOTE="gdrive-x:Homelab/Backups/Vault"
SALT="Homelab-Sovereign-Vault-2026-KpihX"

# --- List available backups ---
echo ""
echo "☁️  Available backups on Google Drive ($RCLONE_REMOTE):"
echo "-------------------------------------------------------"
rclone lsf "$RCLONE_REMOTE" --files-only | sort -r
echo "-------------------------------------------------------"
echo ""

# --- Get backup filename ---
if [ -n "$1" ]; then
    BACKUP_FILE="$1"
else
    echo -n "📂 Enter the backup filename to restore (e.g. vault_backup_20260406_142902.tar.gz.gpg): "
    read -r BACKUP_FILE
fi

if [ -z "$BACKUP_FILE" ]; then
    echo "❌ No backup file specified. Aborting."
    exit 1
fi

# --- Derive decryption key from Bitwarden Master Password (never stored) ---
echo ""
echo "🔐 Key Derivation — enter your Bitwarden Master Password to derive the decryption key."
echo "   The key will NOT be saved to disk."
echo ""
echo -n "🔑 Enter your Bitwarden Master Password: "
read -s MASTER_PASS
echo ""

if [ -z "$MASTER_PASS" ]; then
    echo "❌ Password cannot be empty. Aborting."
    exit 1
fi

GPG_PASS=$(echo -n "${MASTER_PASS}${SALT}" | openssl dgst -sha256 | awk '{print $NF}')
unset MASTER_PASS  # Immediately wipe master password from memory

# --- Confirmation ---
echo ""
echo "⚠️  WARNING: This will OVERWRITE current vault data in:"
echo "   $VAULT_DATA_DIR"
echo ""
read -p "Are you absolutely sure? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted."
    unset GPG_PASS
    exit 1
fi

mkdir -p "$RESTORE_TEMP_DIR"

# 1. Download from Cloud
echo ""
echo "☁️  Downloading $BACKUP_FILE from Cloud..."
rclone copy "$RCLONE_REMOTE/$BACKUP_FILE" "$RESTORE_TEMP_DIR/" --progress

# 2. Decrypt
echo "🛡️  Decrypting archive..."
echo "$GPG_PASS" | gpg --batch --yes --passphrase-fd 0 \
    --decrypt -o "$RESTORE_TEMP_DIR/vault.tar.gz" "$RESTORE_TEMP_DIR/$BACKUP_FILE"
unset GPG_PASS  # Wipe derived key from memory immediately after use

# 3. Extract
echo "📦 Extracting..."
mkdir -p "$RESTORE_TEMP_DIR/extracted"
tar -xzf "$RESTORE_TEMP_DIR/vault.tar.gz" -C "$RESTORE_TEMP_DIR/extracted"

# 4. Stop Vaultwarden before restoring
echo "🛑 Stopping Vaultwarden container..."
docker stop vaultwarden 2>/dev/null || true

# 5. Inject data
echo "💉 Injecting data into Vaultwarden volume..."
cp -r "$RESTORE_TEMP_DIR/extracted/." "$VAULT_DATA_DIR/"

# 6. Restart Vaultwarden
echo "▶️  Restarting Vaultwarden..."
docker start vaultwarden 2>/dev/null || true

# 7. Cleanup
echo "🧹 Cleaning up temp files..."
rm -rf "$RESTORE_TEMP_DIR"

echo ""
echo "✅ Restoration complete! Vaultwarden has been restarted."
echo "   Decryption key was never stored on disk."
