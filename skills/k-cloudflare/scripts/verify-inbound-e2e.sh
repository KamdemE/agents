#!/usr/bin/env bash
# Read-only inbox verification for @<yourdomain.com> inbound routing (GWS + M365 Graph).
# Usage: verify-inbound-e2e.sh [TAG]
# Run directly — PATH and environment are set by .zshenv + .kshrc
set -euo pipefail

TAG="${1:-}"
GWS_BIN="${GWS_BIN:-}"
if [[ -z "$GWS_BIN" ]]; then
  if command -v gws >/dev/null 2>&1; then
    GWS_BIN="$(command -v gws)"
  else
    GWS_BIN="$HOME/.npm-global/bin/gws"
  fi
fi

strip_json() { awk '/^\{/{p=1} p'; }

gws_list() {
  local cfg="$1" proj="$2" q="$3"
  GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$cfg" GOOGLE_WORKSPACE_PROJECT_ID="$proj" \
    "$GWS_BIN" gmail users messages list \
    --params "$(jq -nc --arg q "$q" '{userId:"me",maxResults:8,q:$q}')" 2>&1 | strip_json
}

gws_meta() {
  local cfg="$1" proj="$2" id="$3"
  GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$cfg" GOOGLE_WORKSPACE_PROJECT_ID="$proj" \
    "$GWS_BIN" gmail users messages get \
    --params "$(jq -nc --arg id "$id" '{userId:"me",id:$id,format:"metadata",metadataHeaders:["Subject","From","Delivered-To"]}')" 2>&1 | strip_json
}

print_gmail() {
  local label=$1 cfg="$2" proj="$3" q="$4"
  echo "=== Gmail ($label) q=$q ==="
  local ids
  ids="$(gws_list "$cfg" "$proj" "$q" | jq -r '.messages[]?.id // empty' 2>/dev/null || true)"
  if [[ -z "$ids" ]]; then
    echo "  (none)"
    return 0
  fi
  while read -r id; do
    [[ -z "$id" ]] && continue
    gws_meta "$cfg" "$proj" "$id" | jq -c \
      --arg id "$id" \
      '{mailbox:"'"$label"'",id:$id,labels:.labelIds,subj:(.payload.headers[]|select(.name=="Subject")|.value),from:(.payload.headers[]|select(.name=="From")|.value),delivered:(.payload.headers[]|select(.name=="Delivered-To")|.value)}' \
      2>/dev/null || echo "  (parse error $id)"
  done <<< "$ids"
}

if [[ -z "$TAG" ]]; then
  echo "Usage: $0 <subject-tag>" >&2
  echo "Example: $0 'E2E-BILAN'" >&2
  exit 2
fi

echo "# verify-inbound-e2e TAG=$TAG"
echo "# gws=$GWS_BIN"

print_gmail "primary" "$HOME/.config/gws/kpihx" "kpihx-489121" "in:inbox $TAG"
print_gmail "primary-sent" "$HOME/.config/gws/kpihx" "kpihx-489121" "$TAG"
print_gmail "labs-inbox" "$HOME/.config/gws/<github-user>" "<github-user>" "in:inbox $TAG"
print_gmail "labs-spam" "$HOME/.config/gws/<github-user>" "<github-user>" "in:spam $TAG"

echo "=== Hotmail Graph search TAG=$TAG ==="
if ! command -v m365 >/dev/null 2>&1; then
  echo "  (m365 not in PATH — run via zsh -lic)"
  exit 0
fi

enc_tag="${TAG// /%20}"
m365_out="$(m365 request \
  --url "https://graph.microsoft.com/v1.0/me/messages?\$search=%22subject:${enc_tag}%22&\$top=10&\$select=subject,from,receivedDateTime" \
  --method get --output json 2>&1)" || true

if [[ -z "$m365_out" ]]; then
  echo "  (m365 failed or empty — complete device login)"
  exit 0
fi

echo "$m365_out" | strip_json | jq '[.value[]? | {subject,from:.from.emailAddress.address,received:.receivedDateTime}]' 2>/dev/null \
  || echo "  (parse error — auth pending?)"

echo "OK: verify complete (read-only)"
