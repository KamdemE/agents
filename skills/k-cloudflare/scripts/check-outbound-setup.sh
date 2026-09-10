#!/usr/bin/env bash
# Read-only outbound send-as + DNS check after  completes UI setup.
set -euo pipefail

GWS_BIN="${GWS_BIN:-$(command -v gws 2>/dev/null || echo "$HOME/.npm-global/bin/gws")}"
strip_json() { awk '/^\{/{p=1} p'; }

echo "=== SPF (public DNS) ==="
dig +short TXT "<github-user>.com" 2>/dev/null | rg -i spf || true

echo "=== DMARC ==="
dig +short TXT "_dmarc.<github-user>.com" 2>/dev/null || true

echo "=== Labs Gmail sendAs ==="
GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/<github-user>" GOOGLE_WORKSPACE_PROJECT_ID="<github-user>" \
  "$GWS_BIN" gmail users settings sendAs list --params '{"userId":"me"}' 2>&1 | strip_json | \
  jq '[.sendAs[]? | {email:.sendAsEmail,verification:.verificationStatus,default:.isDefault}]'

echo "=== primary Gmail sendAs (mail@ + personal@) ==="
GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/kpihx" GOOGLE_WORKSPACE_PROJECT_ID="kpihx-489121" \
  "$GWS_BIN" gmail users settings sendAs list --params '{"userId":"me"}' 2>&1 | strip_json | \
  jq '[.sendAs[]? | {email:.sendAsEmail,verification:.verificationStatus,default:.isDefault}]'

echo "=== Hotmail (read-only; send via primary) ==="
echo "Outlook web cannot add custom SMTP — use primary Gmail send-as for mail@ and personal@."

if command -v m365 >/dev/null 2>&1; then
  m365 request -u "https://graph.microsoft.com/v1.0/me" -m get -o json 2>&1 | strip_json | jq '{mail:.mail}' 2>/dev/null || echo "m365 not authenticated"
fi
