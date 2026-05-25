#!/usr/bin/env bash
# Idempotent Gmail + Outlook anti-spam for @kpihx-labs.com inbound aliases.
# Gmail: filter criteria to:<alias> → removeLabelIds SPAM
# Hotmail: inbox messageRules → moveToFolder inbox when sentToAddresses matches alias
set -euo pipefail

GWS_BIN="${GWS_BIN:-}"
if [[ -z "$GWS_BIN" ]]; then
  GWS_BIN="$(command -v gws 2>/dev/null || true)"
  [[ -z "$GWS_BIN" ]] && GWS_BIN="$HOME/.npm-global/bin/gws"
fi

ALIASES=(contact@kpihx-labs.com kpihx@kpihx-labs.com ivann@kpihx-labs.com)
strip_json() { awk '/^\{/{p=1} p'; }

gmail_ensure_filter() {
  local cfg="$1" proj="$2" mailbox="$3" query="$4"
  local existing
  existing="$(GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$cfg" GOOGLE_WORKSPACE_PROJECT_ID="$proj" \
    "$GWS_BIN" gmail users settings filters list --params '{"userId":"me"}' 2>&1 | strip_json \
    | jq -r --arg q "$query" '[.filter[]? | select(.criteria.query == $q) | .id][0] // empty')"
  if [[ -n "$existing" ]]; then
    echo "Gmail $mailbox: exists $query ($existing)"
    return 0
  fi
  GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$cfg" GOOGLE_WORKSPACE_PROJECT_ID="$proj" \
    "$GWS_BIN" gmail users settings filters create \
    --params '{"userId":"me"}' \
    --json "$(jq -nc --arg q "$query" '{criteria:{query:$q},action:{removeLabelIds:["SPAM"]}}')" \
    2>&1 | strip_json | jq -r --arg q "$query" '"Gmail \($q) created: " + .id'
}

echo "=== Gmail filters ==="
for alias in "${ALIASES[@]}"; do
  gmail_ensure_filter "$HOME/.config/gws/kpihx" "kpihx-489121" "kapoivha" "to:$alias"
  gmail_ensure_filter "$HOME/.config/gws/kpihx-labs" "kpihx-labs" "labs" "to:$alias"
done

if ! command -v m365 >/dev/null 2>&1; then
  echo "WARN: m365 not in PATH — skip Hotmail rules (use zsh -lic)"
  exit 0
fi

INBOX_ID="$(m365 request -u "https://graph.microsoft.com/v1.0/me/mailFolders/inbox" -m get -o json 2>&1 | strip_json | jq -r '.id')"
if [[ -z "$INBOX_ID" || "$INBOX_ID" == "null" ]]; then
  echo "WARN: Hotmail not authenticated — inbox rules skipped"
  exit 0
fi

existing_names="$(m365 request -u "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messageRules" -m get -o json 2>&1 | strip_json | jq -r '[.value[]?.displayName] | join("\n")')"

outlook_ensure_rule() {
  local short="$1" addr="$2" seq="$3"
  local dn="KpihX inbound $short (inbox)"
  if echo "$existing_names" | grep -qxF "$dn"; then
    echo "Outlook: exists $dn"
    return 0
  fi
  local f
  f="$(mktemp)"
  jq -n --arg dn "$dn" --argjson seq "$seq" --arg addr "$addr" --arg inbox "$INBOX_ID" \
    '{displayName:$dn,sequence:$seq,isEnabled:true,conditions:{sentToAddresses:[{emailAddress:{address:$addr}}]},actions:{moveToFolder:$inbox,stopProcessingRules:true}}' >"$f"
  m365 request -u "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messageRules" \
    -m post -b "@$f" --content-type "application/json" -o json 2>&1 | strip_json | jq -r '"Outlook \($dn) created: " + .id'
  rm -f "$f"
}

echo "=== Outlook inbox rules ==="
seq=1
for alias in "${ALIASES[@]}"; do
  short="${alias%%@*}"
  outlook_ensure_rule "$short" "$alias" "$seq"
  seq=$((seq + 1))
done

echo "NOTE: Graph API cannot create rules on junkemail (400). Inbox rules + Gmail filters cover normal path."
echo "OK: anti-spam filters applied"
