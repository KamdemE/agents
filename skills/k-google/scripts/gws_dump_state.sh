#!/usr/bin/env bash
# gws_dump_state.sh — dumps complete Google Workspace state to assets/dumps-<profile>/*.json
# Usage: $HOME/.agents/skills/k-google/scripts/gws_dump_state.sh [kpihx|labs]
# Run in tmux pane via k-tmux (requires gws auth active for kpihx / labs).
# NOTE: gws-primary / gws-labs are functions defined in gws-profiles.sh — NOT available in
# a bash subshell. This script therefore sets the env vars itself (same as gws-profiles.sh)
# and calls the bare `gws` binary directly.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# Profile selection: default kpihx (kapoivha). Pass "labs" as $1 for kpihx.labs.
PROFILE="${1:-kpihx}"
case "$PROFILE" in
  kpihx)
    export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/kpihx"
    export GOOGLE_WORKSPACE_PROJECT_ID="kpihx-489121"
    ;;
  labs)
    export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/<github-user>"
    export GOOGLE_WORKSPACE_PROJECT_ID="<github-user>"
    ;;
  *)
    echo "ERROR: unknown profile '$PROFILE' (use kpihx or labs)" >&2
    exit 1
    ;;
esac

DUMP_DIR="${SCRIPT_DIR}/../assets/dumps-${PROFILE}"
mkdir -p "$DUMP_DIR"

echo "🔄 Dumping Google Workspace state ($PROFILE) to $DUMP_DIR..."

dump() {
  local name="$1"; shift
  # Do NOT use `2>&1`: the stderr message would pollute the JSON ("Extra data").
  # stdout errors still come back as a JSON {"error":...} — detected below.
  if command gws "$@" --output json 2>/dev/null | awk '/^{/{p=1} p' > "$DUMP_DIR/$name.json"; then
    if python3 -c "
import json,sys
try:
    d=json.load(open('$DUMP_DIR/$name.json'))
    sys.exit(1 if 'error' in d else 0)
except Exception:
    sys.exit(1)
" 2>/dev/null; then
      local size; size=$(wc -c < "$DUMP_DIR/$name.json" 2>/dev/null || echo 0)
      echo "  [✓] $name ($size bytes)"
    else
      echo "  [✗] $name (API error in response)"
    fi
  else
    echo "  [✗] $name (command failed)"
  fi
}

# --- Gmail ---
echo "  📧 Gmail..."
dump gmail-profile                      gmail users getProfile               --params '{"userId":"me"}'
dump gmail-labels                       gmail users labels list              --params '{"userId":"me"}'
dump gmail-messages                     gmail users messages list            --params '{"userId":"me","maxResults":20}'
dump gmail-sendas                       gmail users settings sendAs list     --params '{"userId":"me"}'
dump gmail-filters                      gmail users settings filters list    --params '{"userId":"me"}'
dump gmail-forwarding-addresses         gmail users settings forwardingAddresses list --params '{"userId":"me"}'
dump gmail-vacation                     gmail users settings getVacation     --params '{"userId":"me"}'
dump gmail-pop                          gmail users settings getPop          --params '{"userId":"me"}'
dump gmail-imap                         gmail users settings getImap         --params '{"userId":"me"}'
dump gmail-delegates                    gmail users settings delegates list  --params '{"userId":"me"}'
dump gmail-autoforwarding               gmail users settings getAutoForwarding --params '{"userId":"me"}'

# --- Calendar ---
echo "  📅 Calendar..."
dump calendar-list                      calendar calendarList list
dump calendar-primary-get               calendar calendars get                --params '{"calendarId":"primary"}'

# --- Drive ---
echo "  📁 Drive..."
dump drive-files                        drive files list                     --params '{"pageSize":50}'
dump drive-about                        drive about get                      --params '{"fields":"user,storageQuota"}'

# --- Tasks ---
echo "  📝 Tasks..."
dump tasks-lists                        tasks tasklists list

# --- Sheets / Docs / Slides / Forms (via Drive mimeType queries) ---
echo "  📊 Docs suite..."
dump sheets-files                       drive files list                     --params '{"pageSize":20,"q":"mimeType=\"application/vnd.google-apps.spreadsheet\""}'
dump docs-files                         drive files list                     --params '{"pageSize":20,"q":"mimeType=\"application/vnd.google-apps.document\""}'
dump slides-files                       drive files list                     --params '{"pageSize":20,"q":"mimeType=\"application/vnd.google-apps.presentation\""}'
dump forms-files                        drive files list                     --params '{"pageSize":20,"q":"mimeType=\"application/vnd.google-apps.form\""}'
dump keep-files                         drive files list                     --params '{"pageSize":20,"q":"mimeType=\"application/vnd.google-apps.keep\""}'

# --- Contacts (People API — gws native: gws people people connections list) ---
echo "  👤 Contacts (People API)..."
dump contacts-people                    people people connections list        --params '{"resourceName":"people/me","pageSize":200,"personFields":"names,emailAddresses,phoneNumbers,organizations"}'

echo "✅ Google Workspace 360° state dump complete ($PROFILE)!"
ls -lh "$DUMP_DIR"/*.json 2>/dev/null | awk '{print "  " $NF " (" $5 ")"}'