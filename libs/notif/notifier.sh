#!/usr/bin/env bash
# ============================================================
# notifier.sh — shared notification helpers for .agents scripts
# ============================================================
# Central place for every notification concern used across  skills
# (system desktop notification, Telegram, or mixed). All skills that notify
# (k-pve, k-ubuntu, k-dockerhost, k-phones, …) source THIS file instead of shipping
# their own private notifier.sh — single source of truth, one uniform style.
#
# Provided here:
#   notify_emoji   <level>          → print the emoji for a log level
#   notify_telegram <level> <message> <title> [code] → send a Telegram message
#     (HTML parse_mode, title bold, message/code auto-escaped; optional 4th
#     arg renders as a <pre> monospace block — e.g. a bash command being
#     approved. Caller passes RAW text; escaping happens INSIDE this function.)
#   notify_system   <level> <message> <title> [code] → send a desktop notification
#   notify_mixed    <level> <message> <title> [code] → send BOTH (system + Telegram)
#   notify_levels                        → print the supported level names
#
# Telegram token/chat-id resolution (secret zero-touch — we only READ the vars,
# never print them):
#   - $NOTIFY_TG_TOKEN (explicit per-caller override — RECOMMENDED: each skill
#     sets it to its own token so the correct one is used)
#   - else the first non-empty of TELEGRAM_BOT_TOKEN (generic default for new
#     setups) then legacy per-machine names (kept as fallback)
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
env_load "$HOME/.agents/.env" || true

# --- Resolve the Telegram token (first non-empty wins) ----------------------
notify_tg_token() {
  if [ -n "${NOTIFY_TG_TOKEN:-}" ]; then
    printf '%s' "$NOTIFY_TG_TOKEN"
    return
  fi
  for var in TELEGRAM_BOT_TOKEN TELEGRAM_PVE_TOKEN TELEGRAM_UBUNTU_TOKEN \
             TELEGRAM_DOCKERHOST_TOKEN TELEGRAM_S25_TOKEN \
             TELEGRAM_OPENCODE_TOKEN TELEGRAM_TOKEN; do
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

# --- HTML-escape (Telegram HTML parse_mode only needs these 3) --------------
# Order matters: escape & FIRST, or the & produced by escaping </> gets
# double-escaped.
_notify_html_escape() {
  local s="$1"
  # Bash's patsub_replacement option treats an unescaped replacement `&` as
  # "the matched character". Literal HTML entities therefore need `\&` — the
  # old unescaped replacements corrupted `2>&1` into `2>gt;&1` on Telegram.
  s="${s//&/\&amp;}"
  s="${s//</\&lt;}"
  s="${s//>/\&gt;}"
  printf '%s' "$s"
}

# --- Telegram notification (only if token + chat_id are set) ----------------
# notify_telegram <level> <message> <title> [code]
# HTML parse_mode (NOT legacy Markdown — that mode uses single *bold*, not
# **bold**, so the old ** syntax here rendered as literal asterisks, never
# bold; HTML is also far more forgiving of arbitrary caller content like bash
# command patterns, which routinely contain _, *, [, ] that legacy/V2
# Markdown would either mis-render or reject outright). Caller passes RAW
# text — title/message/code are all escaped HERE, never by the caller.
notify_telegram() {
  local level="${1:-INFO}" message="${2:-}" title="${3:-}" code="${4:-}"
  [ -n "$message" ] || return
  local token chat icon
  token="$(notify_tg_token)"
  chat="${TELEGRAM_CHAT_ID:-}"
  icon="$(notify_emoji "$level")"
  if [ -n "$token" ] && [ -n "$chat" ]; then
    # Backward compat #1: several pre-existing callers (k-pve, k-ubuntu backup
    # scripts) embed a LITERAL "%0A" substring in their message, relying on
    # the OLD `curl -d` (which never URL-encodes) passing it through
    # unencoded so Telegram's own form-decoder turned it into a newline.
    # `--data-urlencode` below encodes for real now, which would otherwise
    # send a literal visible "%0A" string instead of a line break — convert
    # it to a real newline here first (harmless no-op for callers, like
    # opencode-notify.sh, that already pass a real \n).
    local raw_title="${title//%0A/$'\n'}"
    local raw_message="${message//%0A/$'\n'}"
    local esc_title esc_message text
    esc_title="$(_notify_html_escape "$raw_title")"
    esc_message="$(_notify_html_escape "$raw_message")"
    # Backward compat #2: those same pre-existing callers use legacy
    # Markdown-style `` `code` `` and `**bold**` for styling — HTML parse_mode
    # doesn't interpret either. Convert AFTER escaping (safe: the inserted
    # tags themselves can never be re-escaped, only their already-escaped
    # inner content is captured).
    esc_title="$(printf '%s' "$esc_title" | sed -E 's/`([^`]+)`/<code>\1<\/code>/g; s/\*\*([^*]+)\*\*/<b>\1<\/b>/g')"
    esc_message="$(printf '%s' "$esc_message" | sed -E 's/`([^`]+)`/<code>\1<\/code>/g; s/\*\*([^*]+)\*\*/<b>\1<\/b>/g')"

    # Telegram Bot API hard limit — confirmed live via web search 2026-08-27:
    # sendMessage's "text" field is 1-4096 UTF-8 characters; anything longer
    # is rejected outright with 400 Bad Request. Truncate ONLY the
    # variable-length message body (never the short, fixed-size title/icon/
    # level header) so the FINAL composed text always fits. The <pre> code
    # block (if any) is appended AFTER truncation, so it is never cut
    # mid-tag — only the escaped message content is ever shortened.
    local TELEGRAM_MAX_CHARS=4096
    local header="${icon} <b>${esc_title}</b> [${level}]

"
    local code_block=""
    [ -n "$code" ] && code_block="

<pre>$(_notify_html_escape "$code")</pre>"
    local budget=$((TELEGRAM_MAX_CHARS - ${#header} - ${#code_block} - 1))
    [ "$budget" -lt 0 ] && budget=0
    if [ "${#esc_message}" -gt "$budget" ]; then
      esc_message="${esc_message:0:$budget}…"
    fi

    text="${header}${esc_message}${code_block}"
    # --data-urlencode (NOT -d): -d never URL-encodes, so any &, %, or raw
    # newline in the text would previously corrupt the POST body.
    curl -sf --max-time 10 -X POST "https://api.telegram.org/bot${token}/sendMessage" \
      --data-urlencode "chat_id=${chat}" \
      --data-urlencode "text=${text}" \
      --data-urlencode "parse_mode=HTML" > /dev/null \
      || echo "$(date '+%Y-%m-%d %H:%M:%S') - [WARN] - Telegram send failed (check token/chat_id/connectivity)" >&2
  fi
  echo "$(date '+%Y-%m-%d %H:%M:%S') - [$level] - $title - $message"
}

# --- Desktop notification (notify-send, best effort) ------------------------
# notify_system <level> <message> <title> [code]
notify_system() {
  local level="${1:-INFO}" message="${2:-}" title="${3:-}" code="${4:-}"
  [ -n "$message" ] || return
  local icon body="$message"
  icon="$(notify_emoji "$level")"
  [ -n "$code" ] && body="${body}

${code}"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$icon $title [$level]" "$body" >/dev/null 2>&1 || true
  fi
  echo "$(date '+%Y-%m-%d %H:%M:%S') - [$level] - $title - $message"
}

# --- Mixed: desktop + Telegram ----------------------------------------------
# notify_mixed <level> <message> <title> [code]
notify_mixed() {
  local level="${1:-INFO}" message="${2:-}" title="${3:-}" code="${4:-}"
  [ -n "$message" ] || return
  notify_system "$level" "$message" "$title" "$code"
  notify_telegram "$level" "$message" "$title" "$code"
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
