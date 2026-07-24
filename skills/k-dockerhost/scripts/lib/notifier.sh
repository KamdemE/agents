#!/bin/bash
# lib/homelab.sh - Shared logic for Homelab Scripts
# 100% Transparency | 0 Hardcoding | 0 Duplicate Secrets

# --- LOADER & CONFIG ---
# Strict relative loading: The .env is always in the parent directory of this library
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ENV_FILE="$LIB_DIR/../.env"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "⚠️  [notifier.sh] Error: .envfile not found at $ENV_FILE"
fi

# Fallback defaults if env missing
TELEGRAM_HOMELAB_TOKEN="${TELEGRAM_HOMELAB_TOKEN:-}"
CHAT_ID="${CHAT_ID:-}"

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
    if [ -n "$TELEGRAM_HOMELAB_TOKEN" ] && [ -n "$CHAT_ID" ]; then
        curl -s --max-time 10 -X POST "https://api.telegram.org/bot$TELEGRAM_HOMELAB_TOKEN/sendMessage" \
            -d chat_id="$CHAT_ID" \
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
