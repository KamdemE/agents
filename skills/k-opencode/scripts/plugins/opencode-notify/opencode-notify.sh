#!/usr/bin/env bash
# ============================================================
# opencode-notify.sh — dispatch OpenCode lifecycle notifications
# ============================================================
# Thin wrapper around the shared $HOME/.agents/libs/notif/notifier.sh
# (single source of truth — never re-implements notify-send/Telegram logic
# here, see libs/AGENTS.md → Reflex). Called by the sibling PLUGIN (NOT a
# hook — see scripts/plugins/AGENTS.md → "Hooks vs Plugins") opencode-notify.js
# in this same directory, via Node's execFile (argv array, no shell string
# interpolation — avoids escaping issues with titles/messages that contain
# quotes, unicode, or newlines).
#
# Usage: opencode-notify.sh <level> <title> <message> [code]
#   <level>   OK|SUCCESS|ERROR|WARN|WARNING|INFO (see notify_levels)
#   <title>   short headline (device + agent, built by the JS hook)
#   <message> full body (session title, dir, detail)
#   <code>    optional — rendered as a monospace <pre> block on Telegram
#             (e.g. the exact bash command/pattern awaiting approval)
#
# Delivery:
#   - System (notify-send) — best effort, silently no-op if notify-send is
#     absent (headless servers: deep-pc6, pve, dockerhost). Works out of the
#     box on any GUI machine (Ubuntu, WSL with WSLg + libnotify-bin).
#   - Telegram — STRICTLY the dedicated OpenCode bot (TELEGRAM_OPENCODE_TOKEN,
#     see .env.example) — NEVER any other skill's bot. If TELEGRAM_OPENCODE_TOKEN
#     is unset, Telegram delivery is SKIPPED entirely (system notify still
#     fires). Deliberately does NOT use notifier.sh's shared multi-token
#     fallback chain here (fixed 2026-08-27 — real bug: an empty
#     NOTIFY_TG_TOKEN override still falls through notify_tg_token()'s own
#     PVE/UBUNTU/... loop, so a live smoke test silently sent through the
#     Ubuntu bot before this bot's token existed — KπX caught it live).
#
# Source: $HOME/.agents/skills/k-opencode/scripts/plugins/opencode-notify/opencode-notify.sh
# Caller: scripts/plugins/opencode-notify/opencode-notify.js (execFile, sibling file)
# Depends: $HOME/.agents/libs/notif/notifier.sh (which sources libs/env/env_lib.sh)
# ============================================================

set -euo pipefail

# shellcheck source=../../../../../libs/notif/notifier.sh
source "$HOME/.agents/libs/notif/notifier.sh"

level="${1:-INFO}"
title="${2:-OpenCode}"
message="${3:-}"
code="${4:-}"

# Always fire the system notification (works standalone, no token needed).
notify_system "$level" "$message" "$title" "$code"

# Telegram ONLY through the dedicated OpenCode bot — no chain, no fallback.
# TELEGRAM_OPENCODE_TOKEN unset -> Telegram delivery skipped, silently.
if [ -n "${TELEGRAM_OPENCODE_TOKEN:-}" ]; then
  NOTIFY_TG_TOKEN="$TELEGRAM_OPENCODE_TOKEN"
  notify_telegram "$level" "$message" "$title" "$code"
fi
