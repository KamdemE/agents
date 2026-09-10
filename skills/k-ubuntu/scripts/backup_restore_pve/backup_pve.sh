#!/bin/bash
set -euo pipefail

# backup_pve.sh — Pull PVE backups via rsync + upload to Google Drive
# Source of truth: .agents/skills/k-ubuntu/scripts/backup_restore_pve/backup_pve.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# systemd services do NOT export $HOME by default → under `set -u` a bare
# `$HOME` reference below would abort with "HOME: unbound variable". Set it
# explicitly to the agent user home (where .agents / rclone.conf live) before
# sourcing notifier.sh. ${HOME:-default} is safe under `set -u`.
export HOME="${HOME:-$HOME}"
# Same guard as auto_clean.sh: explicit `User=root` services preset
# $HOME=/root which misses the kernel — force the agent user home if needed.
[ -d "$HOME/.agents" ] || export HOME="$HOME"
# shellcheck source=$HOME/.agents/libs/notif/notifier.sh
source "$HOME/.agents/libs/notif/notifier.sh"
NOTIFY_TG_TOKEN="${TELEGRAM_UBUNTU_TOKEN:-}"

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
HDD_MOUNT="/media/kpihx/-Backup"
HDD_DEST="$HDD_MOUNT/Backups/PVE"
RCLONE_CONF="$HOME/.config/rclone/rclone.conf"
RCLONE_DEST="gdrive-x:Backups/PVE"
KEEP=3

SSH_OPTS=(-i "$HOME/.ssh/id_ed25519_pve" -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 -p "$PVE_PORT")
SSH_DEST="$PVE_USER@$PVE_HOST"
RSYNC_SSH="ssh -T -c aes128-gcm@openssh.com -o Compression=no -o ServerAliveInterval=60 -o ServerAliveCountMax=10 ${SSH_OPTS[*]}"

NOW=$(date +"%Y-%m-%d %H:%M:%S")

echo "[$NOW] Starting PVE backup..."
ssh -q "${SSH_OPTS[@]}" "$SSH_DEST" exit || { notify_telegram "ERROR" "PVE unreachable" "PVE BACKUP"; exit 1; }
[ -d "$HDD_MOUNT" ] || { notify_telegram "ERROR" "HDD not mounted at $HDD_MOUNT" "PVE BACKUP"; exit 1; }
mkdir -p "$HDD_DEST"

echo "--- 1. rsync from $PVE_HOST:$REMOTE_DIR/ to HDD ---"
rsync -av --progress --partial --size-only --inplace --whole-file \
  -e "$RSYNC_SSH" \
  --exclude '*.log' --exclude '*.notes' \
  "$SSH_DEST:$REMOTE_DIR/" "$HDD_DEST/" 2>&1 | grep -v "^\." || { notify_telegram "ERROR" "rsync failed" "PVE BACKUP"; exit 1; }

echo "--- 2. HDD rotation (keep $KEEP) ---"
cd "$HDD_DEST" || { echo "Cannot enter $HDD_DEST"; exit 1; }
# Rotation: list files, keep KEEP newest, delete the rest
for ext in zst vma tar.gz; do
  ls -1t ./*."$ext" 2>/dev/null | tail -n +$((KEEP+1)) | while read -r f; do rm -f "$f"; done
done || true

echo "--- 3. Cloud sync ---"
# Take the single most recent file from HDD
LATEST=$(ls -t "$HDD_DEST"/*.zst "$HDD_DEST"/*.vma "$HDD_DEST"/*.tar.gz 2>/dev/null | head -1) || true
if [ -z "$LATEST" ]; then
  notify_telegram "WARN" "No archive found on HDD to upload." "PVE BACKUP"; exit 0
fi

NAME=$(basename "$LATEST")

# Check if it is already on Drive
CLOUD_FILES=$(rclone lsf "$RCLONE_DEST" --config "$RCLONE_CONF" --files-only 2>/dev/null) || true
if echo "$CLOUD_FILES" | grep -qF "$NAME"; then
  echo "  ✅ Already on Drive: $NAME (no upload needed)"
else
  echo "  📤 Uploading: $NAME"
  rclone copy "$LATEST" "$RCLONE_DEST" --config "$RCLONE_CONF" \
    --transfers=4 --drive-chunk-size=32M --stats-one-line -v \
    || { notify_telegram "ERROR" "rclone upload failed" "PVE BACKUP"; exit 1; }
fi

# Drive: keep only the latest, purge the rest
echo "$CLOUD_FILES" | grep -vF "$NAME" | while read -r f; do
  [ -z "$f" ] && continue
  echo "  🗑️ Purging old from Drive: $f"
  rclone deletefile "$RCLONE_DEST/$f" --config "$RCLONE_CONF" --drive-use-trash=false || true
done || true

# --- 4. Empty Drive trash ---
#  directive: when pushing a new backup, empty the Drive trash so old
# trashed backups (from any rotation) do not accumulate against the quota.
# Google empties the trash in the background (can take minutes→days), the
# command returns quickly. Idempotent — safe to run every time.
echo "  🗑️ Emptying Drive trash..."
rclone cleanup gdrive-x: --config "$RCLONE_CONF" 2>/dev/null || true

SIZE=$(du -sh "$LATEST" | cut -f1)
notify_telegram "SUCCESS" "Backup complete!%0ASize: $SIZE ($NAME)" "PVE BACKUP"
echo "[$NOW] Done."
