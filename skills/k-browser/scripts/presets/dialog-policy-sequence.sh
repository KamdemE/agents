#!/bin/bash
# Preset: page-dialog-policy MUST be installed AFTER a fresh page load, never before — the
# override is injected via Runtime.evaluate on the CURRENT document only (does not survive a
# reload/navigation). Installing it then reloading loses the override (live-verified 2026-08-30).
#
# Usage: dialog-policy-sequence.sh <profile> <target_id> <action:accept|dismiss> [prompt_text]

set -euo pipefail
PROFILE="${1:?profile required}"
TARGET_ID="${2:?target_id required}"
ACTION="${3:-accept}"
PROMPT_TEXT="${4:-}"

# 1. Reload the page FIRST (clean state, no policy installed yet).
browser-proxy do page-reload "{\"profile\":\"$PROFILE\",\"target_id\":\"$TARGET_ID\"}"

# 2. THEN install the policy (Runtime.evaluate overrides window.alert/confirm/prompt on the page
#    that is already loaded).
if [ -n "$PROMPT_TEXT" ]; then
  browser-proxy do page-dialog-policy "{\"profile\":\"$PROFILE\",\"target_id\":\"$TARGET_ID\",\"action\":\"$ACTION\",\"prompt_text\":\"$PROMPT_TEXT\"}"
else
  browser-proxy do page-dialog-policy "{\"profile\":\"$PROFILE\",\"target_id\":\"$TARGET_ID\",\"action\":\"$ACTION\"}"
fi

# 3. Any subsequent alert()/confirm()/prompt() on THIS page load auto-resolves instantly.
