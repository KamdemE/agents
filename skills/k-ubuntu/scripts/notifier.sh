#!/bin/bash
# lib/notifier.sh — Telegram notification for k-ubuntu scripts
# Token: TELEGRAM_UBUNTU_TOKEN (from ~/.agents/.env)

USER_BACKUP="kpihx"
ENV_FILE="/home/$USER_BACKUP/.agents/.env"
[ -f "$ENV_FILE" ] && set -a && source "$ENV_FILE" && set +a

TELEGRAM_UBUNTU_TOKEN="${TELEGRAM_UBUNTU_TOKEN:-}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-}"

notify_telegram() {
    LEVEL="${1:-INFO}"; MESSAGE="${2:-}"; TITLE="${3:-UBUNTU}"
    [ -z "$MESSAGE" ] && return
    case $LEVEL in
        "OK"|"SUCCESS") ICON="✅" ;;
        "ERROR")        ICON="❌" ;;
        "WARN"|"WARNING") ICON="⚠️" ;;
        "INFO")         ICON="ℹ️" ;;
        "CLEAN")        ICON="🧹" ;;
        *)              ICON="🤖" ;;
    esac
    if [ -n "$TELEGRAM_UBUNTU_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
        curl -s --max-time 10 -X POST "https://api.telegram.org/bot$TELEGRAM_UBUNTU_TOKEN/sendMessage" \
            -d "chat_id=$TELEGRAM_CHAT_ID" -d "text=$ICON **$TITLE** [$LEVEL]%0A%0A$MESSAGE" \
            -d parse_mode="Markdown" > /dev/null
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [$LEVEL] - $TITLE - $MESSAGE"
}
