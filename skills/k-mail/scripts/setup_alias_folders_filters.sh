#!/usr/bin/env bash
# setup_alias_folders_filters.sh — Idempotent setup for @<yourdomain.com> folders & filters across Gmail and Outlook
# Usage: setup_alias_folders_filters.sh [--provider gmail|hotmail|all]

set -euo pipefail

PROVIDER="${1:-all}"
PROVIDER="${PROVIDER#--provider=}"
if [ "$PROVIDER" = "--provider" ]; then PROVIDER="${2:-all}"; fi

GWS="$HOME/.npm-global/bin/gws"

setup_gmail_kapoivha() {
  echo "=========================================="
  echo "=== SETUP GMAIL: <primary@gmail.com> ==="
  echo "=========================================="
  export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/kpihx"
  export GOOGLE_WORKSPACE_PROJECT_ID="kpihx-489121"

  declare -A LABEL_IDS=()
  for lbl in "Labs/You/In" "Labs/You/Out" "Labs//In" "Labs//Out" "Labs/Contact/In"; do
    ID=$("$GWS" gmail users labels list --params '{"userId":"me"}' 2>/dev/null | awk '/^\{/{p=1} p' | python3 -c "
import sys,json
d=json.load(sys.stdin)
for l in (d.get('labels') or []):
    if l.get('name')=='$lbl': print(l.get('id'))
" 2>/dev/null || true)
    if [ -z "$ID" ]; then
      echo "  [+] Creating label $lbl..."
      RAW=$("$GWS" gmail users labels create --params '{"userId":"me"}' --json "{\"name\":\"$lbl\",\"labelListVisibility\":\"labelShow\",\"messageListVisibility\":\"show\"}" 2>/dev/null || true)
      ID=$(echo "$RAW" | awk '/^\{/{p=1} p' | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null || true)
    else
      echo "  [✓] Label $lbl exists (id: $ID)"
    fi
    LABEL_IDS["$lbl"]="$ID"
  done

  echo "--- Filters ---"
  # Create filters if missing
  for pair in "to:you@<yourdomain.com>:Labs/You/In" "to:mail@<yourdomain.com>:Labs//In" "to:contact@<yourdomain.com>:Labs/Contact/In" "from:you@<yourdomain.com>:Labs/You/Out" "from:mail@<yourdomain.com>:Labs//Out"; do
    IFS=':' read -r field val lbl <<< "$pair"
    target_id="${LABEL_IDS[$lbl]:-}"
    if [ -n "$target_id" ]; then
      EXISTS=$("$GWS" gmail users settings filters list --params '{"userId":"me"}' 2>/dev/null | awk '/^\{/{p=1} p' | python3 -c "
import sys,json
d=json.load(sys.stdin)
for f in (d.get('filter') or []):
    q=f.get('criteria',{}).get('query','')
    add=f.get('action',{}).get('addLabelIds',[])
    if '$field:$val' in q and '$target_id' in add:
        print('YES')
" 2>/dev/null || true)
      if [ "$EXISTS" = "YES" ]; then
        echo "  [✓] Filter $field:$val -> $lbl exists"
      else
        echo "  [+] Creating filter $field:$val -> $lbl..."
        "$GWS" gmail users settings filters create --params '{"userId":"me"}' --json "{\"criteria\":{\"query\":\"$field:$val\"},\"action\":{\"addLabelIds\":[\"$target_id\"]}}" 2>/dev/null >/dev/null && echo "      OK"
      fi
    fi
  done
}

setup_gmail_labs() {
  echo "=========================================="
  echo "=== SETUP GMAIL: <labs@gmail.com> ==="
  echo "=========================================="
  export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/<github-user>"
  export GOOGLE_WORKSPACE_PROJECT_ID="<github-user>"

  declare -A LABEL_IDS=()
  for lbl in "Labs/Contact/In" "Labs/Contact/Out"; do
    ID=$("$GWS" gmail users labels list --params '{"userId":"me"}' 2>/dev/null | awk '/^\{/{p=1} p' | python3 -c "
import sys,json
d=json.load(sys.stdin)
for l in (d.get('labels') or []):
    if l.get('name')=='$lbl': print(l.get('id'))
" 2>/dev/null || true)
    if [ -z "$ID" ]; then
      echo "  [+] Creating label $lbl..."
      RAW=$("$GWS" gmail users labels create --params '{"userId":"me"}' --json "{\"name\":\"$lbl\",\"labelListVisibility\":\"labelShow\",\"messageListVisibility\":\"show\"}" 2>/dev/null || true)
      ID=$(echo "$RAW" | awk '/^\{/{p=1} p' | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null || true)
    else
      echo "  [✓] Label $lbl exists (id: $ID)"
    fi
    LABEL_IDS["$lbl"]="$ID"
  done

  echo "--- Filters ---"
  for pair in "to:contact@<yourdomain.com>:Labs/Contact/In" "from:contact@<yourdomain.com>:Labs/Contact/Out"; do
    IFS=':' read -r field val lbl <<< "$pair"
    target_id="${LABEL_IDS[$lbl]:-}"
    if [ -n "$target_id" ]; then
      EXISTS=$("$GWS" gmail users settings filters list --params '{"userId":"me"}' 2>/dev/null | awk '/^\{/{p=1} p' | python3 -c "
import sys,json
d=json.load(sys.stdin)
for f in (d.get('filter') or []):
    q=f.get('criteria',{}).get('query','')
    add=f.get('action',{}).get('addLabelIds',[])
    if '$field:$val' in q and '$target_id' in add:
        print('YES')
" 2>/dev/null || true)
      if [ "$EXISTS" = "YES" ]; then
        echo "  [✓] Filter $field:$val -> $lbl exists"
      else
        echo "  [+] Creating filter $field:$val -> $lbl..."
        "$GWS" gmail users settings filters create --params '{"userId":"me"}' --json "{\"criteria\":{\"query\":\"$field:$val\"},\"action\":{\"addLabelIds\":[\"$target_id\"]}}" 2>/dev/null >/dev/null && echo "      OK"
      fi
    fi
  done
}

setup_hotmail() {
  echo "=========================================="
  echo "=== SETUP OUTLOOK: <personal@hotmail.com> ==="
  echo "=========================================="
  echo "--- Checking folder hierarchy Labs ---"
  
  # Ensure root
  ROOT_ID=$(m365 request --url "https://graph.microsoft.com/v1.0/me/mailFolders" --method get --output json 2>/dev/null | python3 -c "
import sys,json
d=json.load(sys.stdin)
for f in (d.get('value') or []):
    if f.get('displayName')=='Labs': print(f.get('id'))
" 2>/dev/null || true)

  if [ -z "$ROOT_ID" ]; then
    echo "  [+] Creating root folder Labs..."
    echo '{"displayName":"Labs"}' > /tmp/_f_root.json
    ROOT_ID=$(m365 request --url "https://graph.microsoft.com/v1.0/me/mailFolders" --method post --body @/tmp/_f_root.json --content-type "application/json" --output json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null || true)
  else
    echo "  [✓] Root folder Labs exists (id: ${ROOT_ID:0:20}...)"
  fi

  # Helper for child folder
  get_or_create_child() {
    local pid="$1" name="$2"
    local cid
    cid=$(m365 request --url "https://graph.microsoft.com/v1.0/me/mailFolders/$pid/childFolders" --method get --output json 2>/dev/null | python3 -c "
import sys,json
d=json.load(sys.stdin)
for f in (d.get('value') or []):
    if f.get('displayName')=='$name': print(f.get('id'))
" 2>/dev/null || true)
    if [ -z "$cid" ]; then
      echo "  [+] Creating child folder $name..."
      echo "{\"displayName\":\"$name\"}" > /tmp/_f_child.json
      cid=$(m365 request --url "https://graph.microsoft.com/v1.0/me/mailFolders/$pid/childFolders" --method post --body @/tmp/_f_child.json --content-type "application/json" --output json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null || true)
    else
      echo "  [✓] Child folder $name exists"
    fi
    echo "$cid"
  }

  IVANN_DIR=$(get_or_create_child "$ROOT_ID" "You")
  IVANN_IN=$(get_or_create_child "$IVANN_DIR" "In")

  KPIHX_DIR=$(get_or_create_child "$ROOT_ID" "")
  KPIHX_IN=$(get_or_create_child "$KPIHX_DIR" "In")

  echo "--- Inbox rules ---"
  # Rule ivann (seq 3)
  echo "{\"displayName\":\" inbound ivann (inbox)\",\"isEnabled\":true,\"sequence\":3,\"conditions\":{\"sentToAddresses\":[{\"emailAddress\":{\"address\":\"personal@<yourdomain.com>\"}}]},\"actions\":{\"moveToFolder\":\"AQMkADAwATY3ZmYAZS02MWU0LTUyNTctMDACLTAwCgAuAAADmibqTsfad0qK5sBO56rVlAEAeLz9KL3gtEmFaLEVzkpkLAAAAgEMAAAA\",\"copyToFolder\":\"$IVANN_IN\",\"stopProcessingRules\":true}}" > /tmp/_rule_iv.json
  m365 request --url "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messageRules/AQAAAREMtq8=" --method patch --body @/tmp/_rule_iv.json --content-type "application/json" --output json 2>/dev/null >/dev/null && echo "  [✓] Rule ivann patched (copyToFolder + moveToFolder)"

  # Rule kpihx (seq 2)
  echo "{\"displayName\":\" inbound kpihx (inbox)\",\"isEnabled\":true,\"sequence\":2,\"conditions\":{\"sentToAddresses\":[{\"emailAddress\":{\"address\":\"mail@<yourdomain.com>\"}}]},\"actions\":{\"moveToFolder\":\"AQMkADAwATY3ZmYAZS02MWU0LTUyNTctMDACLTAwCgAuAAADmibqTsfad0qK5sBO56rVlAEAeLz9KL3gtEmFaLEVzkpkLAAAAgEMAAAA\",\"copyToFolder\":\"$KPIHX_IN\",\"stopProcessingRules\":true}}" > /tmp/_rule_kp.json
  m365 request --url "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messageRules/AQAAAREMtq4=" --method patch --body @/tmp/_rule_kp.json --content-type "application/json" --output json 2>/dev/null >/dev/null && echo "  [✓] Rule kpihx patched (copyToFolder + moveToFolder)"
}

case "$PROVIDER" in
  gmail)
    setup_gmail_kapoivha
    setup_gmail_labs
    ;;
  hotmail)
    setup_hotmail
    ;;
  all|*)
    setup_gmail_kapoivha
    setup_gmail_labs
    setup_hotmail
    ;;
esac

echo "✅ Folders and rules setup complete!"
