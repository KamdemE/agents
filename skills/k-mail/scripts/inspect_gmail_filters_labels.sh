#!/usr/bin/env bash
# inspect_gmail_filters_labels.sh — inspect Gmail labels & filters via gws
# Usage: inspect_gmail_filters_labels.sh [--profile kpihx|labs|both]

set -euo pipefail

PROFILE="${1:-both}"
PROFILE="${PROFILE#--profile=}"
if [ "$PROFILE" = "--profile" ]; then PROFILE="${2:-both}"; fi

GWS="$HOME/.npm-global/bin/gws"

inspect_profile() {
  local p="$1" dir="$2" proj="$3"
  echo "=========================================="
  echo "=== GMAIL PROFILE: $p ($dir) ==="
  echo "=========================================="
  echo "--- LABELS ---"
  GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/$dir" GOOGLE_WORKSPACE_PROJECT_ID="$proj" "$GWS" gmail users labels list --params '{"userId":"me"}' 2>/dev/null | awk '/^\{/{p=1} p' | python3 -c "
import sys,json
d=json.load(sys.stdin)
for l in (d.get('labels') or []):
    n=l.get('name','')
    if '' in n or 'Contact' in n or 'You' in n:
        print(f\"  [label] {l.get('id'):<12} | {n:<24} | total={l.get('messagesTotal')} unread={l.get('messagesUnread')}\")
" 2>&1 || echo "  (failed to list labels)"

  echo "--- FILTERS ---"
  GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/$dir" GOOGLE_WORKSPACE_PROJECT_ID="$proj" "$GWS" gmail users settings filters list --params '{"userId":"me"}' 2>/dev/null | awk '/^\{/{p=1} p' | python3 -c "
import sys,json
d=json.load(sys.stdin)
for f in (d.get('filter') or []):
    c=f.get('criteria',{}); a=f.get('action',{})
    q=c.get('query',''); frm=c.get('from','')
    add=a.get('addLabelIds',[]); rem=a.get('removeLabelIds',[])
    label=f'from:{frm}' if frm else f'q:{q}'
    print(f\"  [filter] {f.get('id'):<16} | {label:<35} | ADD={add} REMOVE={rem}\")
" 2>&1 || echo "  (failed to list filters)"
}

case "$PROFILE" in
  kpihx)
    inspect_profile "kapoivha" "kpihx" "kpihx-489121"
    ;;
  labs)
    inspect_profile "labs" "<github-user>" "<github-user>"
    ;;
  both|*)
    inspect_profile "kapoivha" "kpihx" "kpihx-489121"
    echo ""
    inspect_profile "labs" "<github-user>" "<github-user>"
    ;;
esac
