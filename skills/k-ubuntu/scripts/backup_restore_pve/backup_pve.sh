#!/bin/bash
set -euo pipefail

# backup_pve.sh — Pull PVE backups via rsync + upload to Google Drive
# Source of truth: .agents/skills/k-ubuntu/scripts/backup_restore_pve/backup_pve.sh

AGENTS_ENV="/home/kpihx/.agents/.env"
[ -f "$AGENTS_ENV" ] && set -a && source "$AGENTS_ENV" && set +a

if [[ $# -gt 0 ]]; then
    case "$1" in
        -h|--help)
            echo "Usage: $0 [--help|-h]"
            echo "  Full backup: rsync PVE → HDD → Cloud"
            echo "  No flags needed. Runs everything."
            echo "Admin: ksh backup-pve-admin help"
            exit 0 ;;
    esac
fi

# ── Config ─────────────────────────────────────────────────────────────────────
PVE_HOST="100.123.81.21"
PVE_USER="kpihx"
PVE_PORT="2222"
REMOTE_DIR="/var/lib/vz/dump"
HDD_MOUNT="/media/kpihx/KpihX-Backup"
HDD_DEST="$HDD_MOUNT/Backups/PVE"
RCLONE_CONF="/home/kpihx/.config/rclone/rclone.conf"
RCLONE_DEST="gdrive-x:Backups/PVE"
KEEP=3

SSH_OPTS=(-i /home/kpihx/.ssh/id_ed25519_pve -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 -p "$PVE_PORT")
SSH_DEST="$PVE_USER@$PVE_HOST"
RSYNC_SSH="ssh -T -c aes128-gcm@openssh.com -o Compression=no -o ServerAliveInterval=60 -o ServerAliveCountMax=10 ${SSH_OPTS[*]}"

NOW=$(date +"%Y-%m-%d %H:%M:%S")

notify() { local l=$1 m=$2 t="${3:-PVE BACKUP}"
  if [ -n "${TELEGRAM_UBUNTU_BOT:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
    curl -s --max-time 10 -X POST "https://api.telegram.org/bot$TELEGRAM_UBUNTU_BOT/sendMessage" \
      -d "chat_id=$TELEGRAM_CHAT_ID" -d "text=$l PVE $t [$l]%0A%0A$m" > /dev/null || true
  fi
  echo "[$NOW] [$l] $t - $m"
}

echo "[$NOW] Starting PVE backup..."
ssh -q "${SSH_OPTS[@]}" "$SSH_DEST" exit || { notify "ERROR" "PVE unreachable"; exit 1; }
[ -d "$HDD_MOUNT" ] || { notify "ERROR" "HDD not mounted at $HDD_MOUNT"; exit 1; }
mkdir -p "$HDD_DEST"

echo "--- 1. rsync from $PVE_HOST:$REMOTE_DIR/ to HDD ---"
rsync -av --progress --partial --size-only --inplace --whole-file \
  -e "$RSYNC_SSH" \
  --exclude '*.log' --exclude '*.notes' \
  "$SSH_DEST:$REMOTE_DIR/" "$HDD_DEST/" 2>&1 | grep -v "^\." || { notify "ERROR" "rsync failed"; exit 1; }

echo "--- 2. HDD rotation (keep $KEEP) ---"
cd "$HDD_DEST" || { echo "Cannot enter $HDD_DEST"; exit 1; }
# Rotation: list files, keep KEEP newest, delete the rest
for ext in zst vma tar.gz; do
  ls -1t ./*."$ext" 2>/dev/null | tail -n +$((KEEP+1)) | while read -r f; do rm -f "$f"; done
done || true

echo "--- 3. Cloud sync ---"
LATEST=$(ls -t "$HDD_DEST"/*.zst "$HDD_DEST"/*.vma "$HDD_DEST"/*.tar.gz 2>/dev/null | head -1) || true
if [ -z "$LATEST" ]; then
  notify "WARN" "No archive found on HDD to upload."; exit 0
fi

NAME=$(basename "$LATEST")
rclone copy "$LATEST" "$RCLONE_DEST" --config "$RCLONE_CONF" --transfers=4 --drive-chunk-size=32M --bwlimit 5M --stats-one-line -v || { notify "ERROR" "rclone upload failed"; exit 1; }

rclone lsf "$RCLONE_DEST" --config "$RCLONE_CONF" --files-only | grep -v "$NAME" | while read -r f; do
  rclone deletefile "$RCLONE_DEST/$f" --config "$RCLONE_CONF" --drive-use-trash=false || true
done

SIZE=$(du -sh "$LATEST" | cut -f1)
notify "SUCCESS" "Backup complete!%0ASize: $SIZE ($NAME)"
echo "[$NOW] Done."
