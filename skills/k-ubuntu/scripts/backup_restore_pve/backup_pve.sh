#!/bin/bash
set -euo pipefail

# backup_pve.sh — Pull PVE backups via rsync + upload to Google Drive
# Source of truth: .agents/skills/k-ubuntu/scripts/backup_restore_pve/backup_pve.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_ENV="/home/kpihx/.agents/.env"
[ -f "$AGENTS_ENV" ] && set -a && source "$AGENTS_ENV" && set +a

# ── Config ─────────────────────────────────────────────────────────────────────
SERVER_ALIAS="homelab"
REMOTE_DIR="/var/lib/vz/dump"
HDD_MOUNT="/media/kpihx/KpihX-Backup"
HDD_DEST="$HDD_MOUNT/Backups/PVE"
RCLONE_DEST="gdrive-x:Backups/PVE"
KEEP=3

NOW=$(date +"%Y-%m-%d %H:%M:%S")

notify() { local l=$1 m=$2 t="${3:-PVE BACKUP}"
  if [ -n "${TELEGRAM_UBUNTU_BOT:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
    curl -s --max-time 10 -X POST "https://api.telegram.org/bot$TELEGRAM_UBUNTU_BOT/sendMessage" \
      -d "chat_id=$TELEGRAM_CHAT_ID" -d "text=$l PVE $t [$l]%0A%0A$m" > /dev/null || true
  fi
  echo "[$NOW] [$l] $t - $m"
}

# ── Phase 0: pre-checks ────────────────────────────────────────────────────────
echo "[$NOW] Starting PVE backup..."
ssh -q -o ConnectTimeout=5 "$SERVER_ALIAS" exit || { notify "ERROR" "PVE unreachable"; exit 1; }
[ -d "$HDD_MOUNT" ] || { notify "ERROR" "HDD not mounted at $HDD_MOUNT"; exit 1; }
mkdir -p "$HDD_DEST"

# ── Phase 1: rsync from PVE to HDD ────────────────────────────────────────────
echo "--- 1. rsync from $SERVER_ALIAS:$REMOTE_DIR/ to HDD ---"
rsync -av --progress --partial --size-only --inplace --whole-file \
  -e "ssh -T -c aes128-gcm@openssh.com -o Compression=no -o ServerAliveInterval=60 -o ServerAliveCountMax=10" \
  --exclude '*.log' --exclude '*.notes' \
  "$SERVER_ALIAS:$REMOTE_DIR/" "$HDD_DEST/" 2>&1 | grep -v "^\." || { notify "ERROR" "rsync failed"; exit 1; }

# ── Phase 2: HDD rotation (keep KEEP most recent) ──────────────────────────────
echo "--- 2. HDD rotation (keep $KEEP) ---"
cd "$HDD_DEST" || exit 1
ls -1t *.zst *.vma *.tar.gz 2>/dev/null | tail -n +$((KEEP+1)) | while read -r f; do rm -f "$f"; done

# ── Phase 3: upload latest to cloud ────────────────────────────────────────────
echo "--- 3. Cloud sync ---"
LATEST=$(ls -t "$HDD_DEST"/*.zst "$HDD_DEST"/*.vma "$HDD_DEST"/*.tar.gz 2>/dev/null | head -1)
if [ -z "$LATEST" ]; then
  notify "WARN" "No archive found on HDD to upload."; exit 0
fi

NAME=$(basename "$LATEST")
rclone copy "$LATEST" "$RCLONE_DEST" --transfers=4 --drive-chunk-size=32M --bwlimit 5M --stats-one-line -v || { notify "ERROR" "rclone upload failed"; exit 1; }

# Cloud cleanup: keep only the latest
rclone lsf "$RCLONE_DEST" --files-only | grep -v "$NAME" | while read -r f; do
  rclone deletefile "$RCLONE_DEST/$f" --drive-use-trash=false || true
done

SIZE=$(du -sh "$LATEST" | cut -f1)
notify "SUCCESS" "Backup complete!%0ASize: $SIZE ($NAME)"
echo "[$NOW] Done."
