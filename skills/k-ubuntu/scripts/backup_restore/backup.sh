#!/bin/bash
# ==============================================================================
# backup_workstation.sh — Workstation backup: tar+zstd archive to external HDD
# Usage: sudo ./backup_workstation.sh [DEST_DIR]
#   DEST_DIR defaults to HDD_DEST_DIR (defined below) if not provided as arg.
# Runs as root. Secrets sourced from ~/.agents/.env.
# Author: KpihX [CLAUDE]
# ==============================================================================

set -euo pipefail

# ── Machine config (edit these per machine) ───────────────────────────────────
USER_BACKUP="kpihx"
PC_NAME="KpihX-Ubuntu"
HDD_DEST_DIR="/media/kpihx/KpihX-Backup/Backups/Ubuntu"
KEEP_BACKUPS=2
PREVIEW=0

# ── Load secrets from kernel .env ─────────────────────────────────────────────
AGENTS_ENV="/home/$USER_BACKUP/.agents/.env"
if [[ -f "$AGENTS_ENV" ]]; then
    # shellcheck source=/dev/null
    source "$AGENTS_ENV"
else
    echo "❌ ~/.agents/.env not found — cannot load secrets." >&2
    exit 1
fi

# ── Validate required secrets ─────────────────────────────────────────────────
: "${TELEGRAM_UBUNTU_TOKEN:?'~/.agents/.env must define TELEGRAM_UBUNTU_TOKEN'}"
: "${TELEGRAM_CHAT_ID:?'~/.agents/.env must define TELEGRAM_CHAT_ID'}"

# ── Arg parsing ───────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            echo "Usage: $0 [--preview|-p] [DEST_DIR]"
            echo "  --preview, -p   Dry-run: show what would be backed up, don't create archive"
            echo "  DEST_DIR        Target directory (default: $HDD_DEST_DIR)"
            exit 0 ;;
        -p|--preview) PREVIEW=1; shift ;;
        *) TARGET_DIR="$1"; shift ;;
    esac
done
TARGET_DIR="${TARGET_DIR:-${HDD_DEST_DIR}}"
if [[ -z "$TARGET_DIR" ]]; then
    echo "❌ No destination provided. Set HDD_DEST_DIR at top of script or pass as argument." >&2
    echo "   Usage: sudo $0 /media/$USER_BACKUP/KpihX-Backup/Backups/Ubuntu" >&2
    exit 1
fi

KEEP_BACKUPS="${KEEP_BACKUPS:-2}"

# ── Mount point exclusion helper ─────────────────────────────────────────────
# Find all mount points under a given directory (recursive). Excludes the
# directory itself. Prevents tar from descending into rclone, NFS, USB,
# or any other separate filesystem mount.
_find_mounts_under() {
    local dir="$1" mnt
    # findmnt -l lists all mounts in flat format. Filter for those under $dir.
    findmnt -l -o TARGET -n 2>/dev/null | while IFS= read -r mnt; do
        [[ "$mnt" == "$dir" ]] && continue
        [[ "$mnt" == "$dir"/* ]] && echo "$mnt"
    done
}

# ── Helpers ───────────────────────────────────────────────────────────────────
log() { echo -e "\033[1;34m[$(date +'%H:%M:%S')]\033[0m $1"; }

alert() {
    local TYPE="$1"
    local MESSAGE="$2"
    local ICON
    case $TYPE in
        SUCCESS) ICON="✅" ;;
        ERROR)   ICON="❌" ;;
        WARN)    ICON="⚠️" ;;
        *)       ICON="ℹ️" ;;
    esac

    # Desktop notification
    local USER_ID
    USER_ID="$(id -u "$USER_BACKUP" 2>/dev/null || echo '')"
    if [[ -n "$USER_ID" ]]; then
        sudo -u "$USER_BACKUP" DISPLAY=:0 \
            DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus" \
            notify-send "Backup Workstation [$TYPE]" "$MESSAGE" 2>/dev/null || true
    fi

    # Telegram notification
    curl -s --max-time 10 -X POST \
        "https://api.telegram.org/bot${TELEGRAM_UBUNTU_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${ICON} BACKUP PC ${ICON}%0A%0A${MESSAGE}" > /dev/null || true
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"


# ── Destination validation ─────────────────────────────────────────────────────
PARENT_DIR="$(dirname "$TARGET_DIR")"
if [[ ! -d "$PARENT_DIR" ]]; then
    MSG="Drive NOT found at $PARENT_DIR. Please mount KpihX-Backup and run 'make run' in $SCRIPT_DIR."
    echo "❌ $MSG" >&2
    alert "ERROR" "$MSG"
    exit 1
fi

mkdir -p "$TARGET_DIR" || { echo "❌ Cannot create $TARGET_DIR" >&2; exit 1; }

if ! touch "$TARGET_DIR/.write_test" 2>/dev/null; then
    MSG="Drive at $TARGET_DIR appears read-only or not mounted correctly. Check permissions or remount."
    echo "❌ $MSG" >&2
    alert "ERROR" "$MSG"
    exit 1
fi
rm -f "$TARGET_DIR/.write_test"

# ── Config ────────────────────────────────────────────────────────────────────
USER_HOME="/home/$USER_BACKUP"
HDD_DEST_DIR="$TARGET_DIR"
TMP_DIR="$HDD_DEST_DIR/temp_metadata"
NOW="$(date +"%Y-%m-%d_%H-%M-%S")"
ARCHIVE_NAME="backup-${PC_NAME}-${NOW}.tar.zst"
FINAL_ARCHIVE_PATH="$HDD_DEST_DIR/$ARCHIVE_NAME"
SRC_DIRS=("$USER_HOME" "/etc")

# Universal excludes — applied on all machines.
EXCLUDES=(
    "--exclude=$USER_HOME/.cache"
    "--exclude=$USER_HOME/.local/share/Trash"
    "--exclude=$USER_HOME/.local/share/containers"
    "--exclude=$USER_HOME/Downloads"
    "--exclude=*.sock"
    "--exclude=$USER_HOME/.vscode/extensions"
    "--exclude=$USER_HOME/.vscode-server"
    "--exclude=$USER_HOME/.config/Code/CachedData"
    "--exclude=$USER_HOME/.config/Code/User/History"
    "--exclude=node_modules"
    "--exclude=target"
    "--exclude=build"
    "--exclude=dist"
    "--exclude=venv"
    "--exclude=.venv"
    "--exclude=__pycache__"
    "--exclude=.git"
    "--exclude=*.qcow2"
    "--exclude=*.iso"
    "--exclude=*.vdi"
    "--exclude=*.vmdk"
    "--exclude=*.csv"
)

# ── Dynamic mount exclusion ───────────────────────────────────────────────────
# Automatically exclude ALL mount points under each source directory.
# This catches rclone drives, USB mounts, NFS, etc. without hardcoding.
log "   🔍 Detecting mount points to exclude..."
for src_dir in "$USER_HOME" "/etc"; do
    while IFS= read -r mnt; do
        log "     → Excluding mount: $mnt"
        EXCLUDES+=("--exclude=$mnt")
    done < <(_find_mounts_under "$src_dir")
done

# Machine-specific excludes — load from excludes.conf (gitignored).
# Each non-empty non-comment line: absolute path (/...) or relative to $USER_HOME.
# To set up: cp excludes.conf.example excludes.conf and adapt.
if [[ -f "$SCRIPT_DIR/excludes.conf" ]]; then
    while IFS= read -r _line || [[ -n "$_line" ]]; do
        [[ -z "$_line" || "$_line" == \#* ]] && continue
        if [[ "$_line" == /* ]]; then
            EXCLUDES+=("--exclude=$_line")
        else
            EXCLUDES+=("--exclude=$USER_HOME/$_line")
        fi
    done < "$SCRIPT_DIR/excludes.conf"
fi


TAR_OPTIONS=(
    "--exclude-caches"
    "--warning=no-file-ignored"
    "--ignore-failed-read"
)

# ── Phase 0: Export metadata ───────────────────────────────────────────────────
log "🚀 Starting backup → $HDD_DEST_DIR"
log "📝 Phase 0: Exporting system metadata..."
mkdir -p "$TMP_DIR"

command -v code   &>/dev/null && sudo -u "$USER_BACKUP" code --list-extensions \
    > "$TMP_DIR/vscode_extensions.txt" 2>/dev/null || true
command -v dconf  &>/dev/null && sudo -u "$USER_BACKUP" dconf dump / \
    > "$TMP_DIR/gnome_settings.ini" 2>/dev/null || true

dpkg --get-selections > "$TMP_DIR/packages_apt.txt"
cp -r /etc/apt/sources.list* "$TMP_DIR/" 2>/dev/null || true
cp -r /etc/apt/trusted.gpg*  "$TMP_DIR/" 2>/dev/null || true
[[ -d /usr/share/keyrings ]] && cp -r /usr/share/keyrings "$TMP_DIR/keyrings" 2>/dev/null || true

command -v snap    &>/dev/null && snap list > "$TMP_DIR/packages_snap.txt" 2>/dev/null || true
command -v flatpak &>/dev/null && flatpak list --columns=application \
    > "$TMP_DIR/packages_flatpak.txt" 2>/dev/null || true
crontab -l                       > "$TMP_DIR/crontab_root.txt" 2>/dev/null || true
crontab -u "$USER_BACKUP" -l     > "$TMP_DIR/crontab_user.txt" 2>/dev/null || true
lsblk -f                         > "$TMP_DIR/disk_layout.txt"

SRC_DIRS+=("$TMP_DIR")

# ── Phase 1: Size estimate ─────────────────────────────────────────────────────
log "📊 Phase 1: Estimating size..."
DU_EXCLUDES=()
for item in "${EXCLUDES[@]}"; do
    [[ "$item" == --exclude=* ]] && DU_EXCLUDES+=("$item")
done
TOTAL_SIZE="$(du -scb "${DU_EXCLUDES[@]}" "${SRC_DIRS[@]}" 2>/dev/null | tail -1 | awk '{print $1}')"
READABLE_SIZE="$(numfmt --to=iec-i --suffix=B "$TOTAL_SIZE")"
log "   → Total to compress: $READABLE_SIZE"

# If in preview mode, exit here
if [[ "${PREVIEW:-0}" == "1" ]]; then
    log "🔎 Preview mode: stopping after Phase 1."
    exit 0
fi

# ── Phase 2: Compress to HDD ──────────────────────────────────────────────────
log "📦 Phase 2: Compressing (zstd) → $FINAL_ARCHIVE_PATH"
tar -cP "${TAR_OPTIONS[@]}" "${EXCLUDES[@]}" -cf - "${SRC_DIRS[@]}" | \
    pv -s "$TOTAL_SIZE" -N "Compress" -p -t -e -r -b | \
    zstd -T0 --fast=1 > "$FINAL_ARCHIVE_PATH"

if [[ ! -s "$FINAL_ARCHIVE_PATH" ]]; then
    log "❌ Compression failed."
    alert "ERROR" "Backup failed — archive empty or write error."
    rm -f "$FINAL_ARCHIVE_PATH"
    rm -rf "$TMP_DIR"
    exit 1
fi

REAL_SIZE="$(du -sh "$FINAL_ARCHIVE_PATH" | cut -f1)"
log "✅ Archive created: $FINAL_ARCHIVE_PATH ($REAL_SIZE)"
rm -rf "$TMP_DIR"

# ── Phase 3: Rotation ─────────────────────────────────────────────────────────
log "🧹 Phase 3: Rotating old archives (keep $KEEP_BACKUPS)..."
cd "$HDD_DEST_DIR" || exit 1
COUNT=0
while IFS= read -r ARCHIVE_FILE; do
    [[ -z "$ARCHIVE_FILE" ]] && continue
    COUNT=$((COUNT + 1))
    if [[ "$COUNT" -gt "$KEEP_BACKUPS" ]]; then
        log "   🗑️  Removing: $ARCHIVE_FILE"
        rm -f "$ARCHIVE_FILE"
    fi
done < <(ls -1t ./*.tar.zst 2>/dev/null)

log "🎉 Backup complete."
alert "SUCCESS" "Backup OK — $REAL_SIZE archived on $(date +'%Y-%m-%d %H:%M')"
