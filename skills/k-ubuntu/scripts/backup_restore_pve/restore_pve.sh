#!/bin/bash
set -euo pipefail

# restore_pve.sh — Restore PVE backup from HDD or Google Drive (whichever is newer)
# Source of truth: .agents/skills/k-ubuntu/scripts/backup_restore_pve/restore_pve.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_ENV="/home/kpihx/.agents/.env"
[ -f "$AGENTS_ENV" ] && set -a && source "$AGENTS_ENV" && set +a

case "$1" in
    -h|--help)
        echo "Usage: $0 [--help|-h]"
        echo "  Restore: scans HDD + Cloud, takes newest archive."
        echo "  No flags needed. Outputs instructions for scp+restore on PVE."
        exit 0 ;;
esac

# ── Config ─────────────────────────────────────────────────────────────────────
RCLONE_REMOTE="gdrive-x:Backups/PVE"
HDD_DIR="/media/kpihx/KpihX-Backup/Backups/PVE"
RESTORE_DIR="/tmp/pve_restore"

notify() { local l=$1 m=$2 t="${3:-PVE RESTORE}"
  if [ -n "${TELEGRAM_UBUNTU_BOT:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
    curl -s --max-time 10 -X POST "https://api.telegram.org/bot$TELEGRAM_UBUNTU_BOT/sendMessage" \
      -d "chat_id=$TELEGRAM_CHAT_ID" -d "text=$l PVE $t [$l]%0A%0A$m" > /dev/null || true
  fi
  echo "[$l] $t - $m"
}

mkdir -p "$RESTORE_DIR"

# ── Phase 1: find latest from both sources ─────────────────────────────────────
echo "🔍 Scanning HDD ($HDD_DIR)..."
HDD_FILE=$(ls -t "$HDD_DIR"/*.zst "$HDD_DIR"/*.vma "$HDD_DIR"/*.tar.gz 2>/dev/null | head -1)
HDD_MTIME=""
[ -n "$HDD_FILE" ] && HDD_MTIME=$(stat -c %Y "$HDD_FILE" 2>/dev/null || echo "0")

echo "🔍 Scanning Cloud ($RCLONE_REMOTE)..."
CLOUD_FILE=$(rclone lsf "$RCLONE_REMOTE" --files-only 2>/dev/null | sort -r | head -1)
CLOUD_TMP=""
if [ -n "$CLOUD_FILE" ]; then
  CLOUD_TMP="$RESTORE_DIR/$CLOUD_FILE"
  rclone copy "$RCLONE_REMOTE/$CLOUD_FILE" "$RESTORE_DIR" --progress > /dev/null 2>&1
  CLOUD_MTIME=$(stat -c %Y "$CLOUD_TMP" 2>/dev/null || echo "0")
else
  CLOUD_MTIME="0"
fi

# ── Phase 2: pick the most recent ──────────────────────────────────────────────
if [ -z "$HDD_FILE" ] && [ -z "$CLOUD_FILE" ]; then
  notify "ERROR" "No backup found on HDD or Cloud. Aborting."; exit 1
fi

if [ -n "$HDD_FILE" ] && [ "$HDD_MTIME" -ge "$CLOUD_MTIME" ] 2>/dev/null; then
  FINAL_SRC="$HDD_FILE"
  echo "✅ Latest: HDD ($(basename "$HDD_FILE"))"
elif [ -n "$CLOUD_FILE" ]; then
  FINAL_SRC="$CLOUD_TMP"
  echo "✅ Latest: Cloud ($CLOUD_FILE)"
else
  FINAL_SRC="$HDD_FILE"
  echo "✅ Using HDD ($(basename "$HDD_FILE"))"
fi

notify "INFO" "Restoring: $(basename "$FINAL_SRC") (from $(echo "$FINAL_SRC" | grep -q 'tmp' && echo 'Cloud' || echo 'HDD'))"

cp "$FINAL_SRC" "$RESTORE_DIR/$(basename "$FINAL_SRC")"
ARCHIVE="$RESTORE_DIR/$(basename "$FINAL_SRC")"
SIZE=$(du -sh "$ARCHIVE" | cut -f1)
notify "SUCCESS" "Archive ready at $ARCHIVE%0ASize: $SIZE%0A%0AThen on PVE: pct restore <VMID> /var/lib/vz/dump/$(basename "$FINAL_SRC")"

echo ""
echo "📦 Archive: $ARCHIVE ($SIZE)"
echo "➡️  Copy to PVE: scp $ARCHIVE homelab:/var/lib/vz/dump/"
echo "➡️  Restore: ssh homelab \"pct restore <VMID> /var/lib/vz/dump/$(basename "$FINAL_SRC")\""
