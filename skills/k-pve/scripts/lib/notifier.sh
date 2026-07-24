#!/bin/bash
# lib/homelab.sh - Shared logic for Homelab Scripts
# 100% Transparency | 0 Hardcoding | 0 Duplicate Secrets

# --- LOADER & CONFIG ---
# Secrets from kernel ~/.agents/.env
ENV_FILE="$HOME/.agents/.env"
if [ -f "$ENV_FILE" ]; then set -a; source "$ENV_FILE"; set +a; fi

# Fallback defaults if env missing
TELEGRAM_PVE_TOKEN="${TELEGRAM_PVE_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

# --- NOTIFICATION ENGINE ---
homelab_notify() {
    LEVEL="${1:-INFO}"
    MESSAGE="${2:-}"
    TITLE="${3:-HOMELAB}"
    
    [ -z "$MESSAGE" ] && return
    
    # Emoji selection
    case $LEVEL in
        "OK"|"SUCCESS") ICON="✅" ;;
        "ERROR")        ICON="❌" ;;
        "WARN"|"WARNING") ICON="⚠️" ;;
        "INFO")         ICON="ℹ️" ;;
        "LOCK")         ICON="🔒" ;;
        "CLEAN"|"PURGE") ICON="🧹" ;;
        *)              ICON="🤖" ;;
    esac

    # Telegram POST
    if [ -n "$TELEGRAM_PVE_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
        curl -s --max-time 10 -X POST "https://api.telegram.org/bot$TELEGRAM_PVE_TOKEN/sendMessage" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d text="$ICON **$TITLE** [$LEVEL]%0A%0A$MESSAGE" \
            -d parse_mode="Markdown" > /dev/null
    fi
    
    # Local log echo
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [$LEVEL] - $TITLE - $MESSAGE"
}

# --- PROCESS LOCKING (Optional) ---
# Simple lock mechanism to prevent concurrent runs
homelab_lock() {
    LOCKFILE="/tmp/$(basename "$0").lock"
    if [ -f "$LOCKFILE" ]; then
        echo "Error: $(basename "$0") already running (lock: $LOCKFILE)"
        exit 1
    fi
    touch "$LOCKFILE"
}

homelab_unlock() {
    rm -f "/tmp/$(basename "$0").lock"
}
