#!/bin/bash
# Preset: full detect -> click_checkbox sequence for browser-solve-captcha. The extension acts on
# whichever tab it considers "active" — tab-activate MUST run first or the wrong tab gets probed
# (live-verified footgun, see references/insights.md).
#
# Usage: captcha-solve-sequence.sh <profile> <target_id>

set -euo pipefail
PROFILE="${1:?profile required}"
TARGET_ID="${2:?target_id required}"

browser-proxy do tab-activate "{\"profile\":\"$PROFILE\",\"target_id\":\"$TARGET_ID\"}"
browser-proxy do browser-solve-captcha "{\"profile\":\"$PROFILE\",\"action\":\"detect\"}"
browser-proxy do browser-solve-captcha "{\"profile\":\"$PROFILE\",\"action\":\"click_checkbox\"}"

# Verify visually: browser-proxy do page-screenshot '{"profile":"...","target_id":"...","output":"/tmp/opencode/captcha-check.png"}'
# then Read the image — the checkbox should show a green checkmark.
