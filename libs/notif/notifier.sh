#!/usr/bin/env bash
# ============================================================
# notifier.sh — shared notification helpers for .agents scripts
# ============================================================
# Central place for every notification concern used across KπX skills
# (system desktop notification, Telegram, or mixed). All skills that notify
# (k-pve, k-ubuntu, k-dockerhost, k-25, …) source THIS file instead of shipping
# their own private notifier.sh — single source of truth, one uniform style.
#
# Provided here:
#   notify_emoji   <level>          → print the emoji for a log level
#   notify_telegram <level> <message> <title>  → send a Telegram message
#   notify_system   <level> <message> <title>  → send a desktop notification
#   notify_mixed    <level> <message> <title>  → send BOTH (system + Telegram)
#   notify_levels                        → print the supported level names
#
# Telegram token/chat-id resolution (secret zero-touch — we only READ the vars,
# never print them):
#   - $NOTIFY_TG_TOKEN (explicit per-caller override — RECOMMENDED: each skill
#     sets it to its own token so the correct one is used, e.g. k-ubuntu scripts
#     set NOTIFY_TG_TOKEN="${TELEGRAM_UBUNTU_TOKEN:-}")
#   - else the first non-empty of TELEGRAM_PVE_TOKEN / TELEGRAM_UBUNTU_TOKEN /
#     TELEGRAM_DOCKERHOST_TOKEN / TELEGRAM_S25_TOKEN / TELEGRAM_TOKEN
#   - chat id from $TELEGRAM_CHAT_ID
# Values are loaded from ~/.agents/.env via env_lib.sh (env_load) when present.
#
# Style: levels map to emojis; message/title are echoed locally too (log trail).
#
# Source:  $HOME/.agents/libs/notif/notifier.sh
# Caller:  skills/*/scripts (via `source`), then the actual scripts
# Depends: .agents/libs/env/env_lib.sh  (env_load)
# ============================================================

# --- Load .env (optional) for token/chat-id resolution ----------------------
# shellcheck source=../env/env_lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/../env/env_lib.sh"
env_load "$HOME/.agents/.env" 2>/dev/null || true

# --- Resolve the Telegram token (first non-empty wins) ----------------------
notify_tg_token() {
  if [ -n "${NOTIFY_TG_TOKEN:-}" ]; then
    printf '%s' "$NOTIFY_TG_TOKEN"
    return
  fi
  for var in TELEGRAM_PVE_TOKEN TELEGRAM_UBUNTU_TOKEN \
             TELEGRAM_DOCKERHOST_TOKEN TELEGRAM_S25_TOKEN TELEGRAM_TOKEN; do
    if [ -n "${!var:-}" ]; then
      printf '%s' "${!var}"
      return
    fi
  done
}

# --- Level → emoji map -------------------------------------------------------
notify_emoji() {
  case "${1:-INFO}" in
    OK|SUCCESS) printf '✅' ;;
    ERROR)      printf '❌' ;;
    WARN|WARNING) printf '⚠️' ;;
    LOCK)       printf '🔒' ;;
    CLEAN|PURGE) printf '🧹' ;;
    INFO)       printf 'ℹ️' ;;
    *)          printf '🤖' ;;
  esac
}

notify_levels() {
  echo "OK SUCCESS ERROR WARN WARNING LOCK CLEAN PURGE INFO"
}

# --- Telegram notification (only if token + chat_id are set) ----------------
# notify_telegram <level> <message> <title>
notify_telegram() {
  local level="${1:-INFO}" message="${2:-}" title="${3:-}"
  [ -n "$message" ] || return
  local token chat icon
  token="$(notify_tg_token)"
  chat="${TELEGRAM_CHAT_ID:-}"
  icon="$(notify_emoji "$level")"
  if [ -n "$token" ] && [ -n "$chat" ]; then
    curl -s --max-time 10 -X POST "https://api.telegram.org/bot${token}/sendMessage" \
      -d "chat_id=$chat" \
      -d "text=${icon} **${title}** [$level]%0A%0A${message}" \
      -d parse_mode="Markdown" > /dev/null
  fi
  echo "$(date '+%Y-%m-%d %H:%M:%S') - [$level] - $title - $message"
}

# --- Desktop notification (notify-send, best effort) ------------------------
# notify_system <level> <message> <title>
notify_system() {
  local level="${1:-INFO}" message="${2:-}" title="${3:-}"
  [ -n "$message" ] || return
  local icon
  icon="$(notify_emoji "$level")"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$icon $title [$level]" "$message" >/dev/null 2>&1 || true
  fi
  echo "$(date '+%Y-%m-%d %H:%M:%S') - [$level] - $title - $message"
}

# --- Mixed: desktop + Telegram ----------------------------------------------
# notify_mixed <level> <message> <title>
notify_mixed() {
  local level="${1:-INFO}" message="${2:-}" title="${3:-}"
  [ -n "$message" ] || return
  notify_system "$level" "$message" "$title"
  notify_telegram "$level" "$message" "$title"
}

# --- Simple process lock (prevent concurrent runs) --------------------------
# homelab_lock  → create /tmp/<basename>.lock or exit if already running
# homelab_unlock → remove the lock
homelab_lock() {
  local lockfile="/tmp/$(basename "$0").lock"
  if [ -f "$lockfile" ]; then
    echo "Error: $(basename "$0") already running (lock: $lockfile)"
    exit 1
  fi
  touch "$lockfile"
}

homelab_unlock() {
  rm -f "/tmp/$(basename "$0").lock"
}
