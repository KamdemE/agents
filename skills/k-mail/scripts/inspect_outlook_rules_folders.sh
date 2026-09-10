#!/usr/bin/env bash
# inspect_outlook_rules_folders.sh — inspect Hotmail/Outlook inbox rules & folders via m365 CLI
# Usage: inspect_outlook_rules_folders.sh

set -euo pipefail

echo "=========================================="
echo "=== OUTLOOK (<personal@hotmail.com>) ==="
echo "=========================================="
echo "--- INBOX RULES ---"
m365 request --url "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messageRules" --method get --output json 2>/dev/null | python3 -c "
import sys,json
d=json.load(sys.stdin)
for r in (d.get('value') or []):
    conds=list(r.get('conditions',{}).keys())
    acts=list(r.get('actions',{}).keys())
    print(f\"  [rule] seq={r.get('sequence')} | {r.get('displayName'):<30} | enabled={r.get('isEnabled')} | actions={acts}\")
" 2>&1 || echo "  (failed to list rules)"

echo "--- FOLDERS ( hierarchy) ---"
m365 request --url "https://graph.microsoft.com/v1.0/me/mailFolders" --method get --output json 2>/dev/null | python3 -c "
import sys,json
d=json.load(sys.stdin)
def walk(f, depth=0):
    name=f.get('displayName','')
    if '' in name or depth>0:
        print('  '*(depth+1)+f\"[folder] {name} (id: {f.get('id')[:20]}...)\")
    for c in (f.get('childFolders') or []):
        walk(c, depth+1)
for f in (d.get('value') or []):
    if '' in f.get('displayName',''):
        walk(f)
" 2>&1 || echo "  (failed to list folders)"
