#!/usr/bin/env bash
# Archive inbound/outbound E2E and routing test messages (Gmail: remove INBOX; Hotmail: move to Archive).
set -euo pipefail

GWS_BIN="${GWS_BIN:-}"
[[ -z "$GWS_BIN" ]] && GWS_BIN="$(command -v gws 2>/dev/null || true)"
[[ -z "$GWS_BIN" ]] && GWS_BIN="$HOME/.npm-global/bin/gws"

# Tight query — avoids unrelated "Bilan" newsletters (use E2E-BILAN for routing proof).
GMAIL_Q='(subject:E2E OR subject:OUT-E2E OR subject:E2E-BILAN OR subject:reverify OR subject:"routing kpihx" OR subject:"labs-native" OR subject:"Ras kpihx" OR subject:hotmail-default OR subject:kpihx-verified OR subject:"from-override" OR subject:"Gmail Confirmation" kpihx-labs OR subject:"Undeliverable: E2E")'
strip_json() { awk '/^\{/{p=1} p'; }

archive_gmail_profile() {
  local cfg="$1" proj="$2" name="$3"
  local n=0
  echo "=== Gmail archive: $name ==="
  ids="$(GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$cfg" GOOGLE_WORKSPACE_PROJECT_ID="$proj" \
    "$GWS_BIN" gmail users messages list \
    --params "$(jq -nc --arg q "$GMAIL_Q" '{userId:"me",maxResults:200,q:$q}')" 2>&1 | strip_json | jq -r '.messages[]?.id // empty')"
  for id in $ids; do
    [[ -z "$id" ]] && continue
    GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$cfg" GOOGLE_WORKSPACE_PROJECT_ID="$proj" \
      "$GWS_BIN" gmail users messages modify \
      --params "$(jq -nc --arg id "$id" '{userId:"me",id:$id}')" \
      --json '{"removeLabelIds":["INBOX","UNREAD"]}' >/dev/null 2>&1 && n=$((n + 1))
  done
  echo "  archived: $n"
}

archive_gmail_profile "$HOME/.config/gws/kpihx" "kpihx-489121" "kapoivha"
archive_gmail_profile "$HOME/.config/gws/kpihx-labs" "kpihx-labs" "labs"

if command -v m365 >/dev/null 2>&1; then
  echo "=== Hotmail archive (Graph move) ==="
  python3 <<'PY'
import json, subprocess

def strip(s):
    for i, line in enumerate(s.splitlines()):
        if line.startswith('{') or line.startswith('['):
            return '\n'.join(s.splitlines()[i:])
    return s

def g(cmd):
    return subprocess.run(["zsh", "-lic", cmd], capture_output=True, text=True)

arch = json.loads(strip(g('m365 request -u "https://graph.microsoft.com/v1.0/me/mailFolders/archive" -m get -o json 2>&1').stdout))["id"]
terms = [
    "E2E-FINAL", "E2E-BILAN", "E2E kpihx", "E2E labs", "E2E contact", "E2E worker",
    "E2E contact", "E2E labs-native", "E2E kpihx-reverify", "E2E labs-reverify",
    "OUT-E2E", "reverify", "Undeliverable: E2E", "routing 20260525", "labs-native",
    "hotmail-default", "kpihx-verified", "from-override",
    "Gmail Confirmation kpihx-labs",
    "Gmail Confirmation ivann@kpihx",
]
needles = (
    "E2E", "OUT-E2E", "reverify", "routing", "labs-native", "BILAN",
    "Undeliverable", "Gmail Confirmation", "kpihx-verified", "hotmail-default",
    "from-override", "kpihx-labs.com",
)
seen = set()
moved = 0
for term in terms:
    enc = term.replace(" ", "%20").replace('"', "%22")
    url = f"https://graph.microsoft.com/v1.0/me/messages?$search=%22{enc}%22&$top=50&$select=id,subject"
    try:
        data = json.loads(strip(g(f'm365 request -u "{url}" -m get -o json 2>&1').stdout))
    except Exception:
        continue
    for m in data.get("value", []):
        mid, subj = m.get("id"), (m.get("subject") or "")
        if not mid or mid in seen:
            continue
        if not any(n in subj for n in needles):
            continue
        if "Scholarship" in subj or "Bilan collecte" in subj:
            continue
        seen.add(mid)
        body = json.dumps({"destinationId": arch})
        path = f"/tmp/archive-move-{mid[:8]}.json"
        open(path, "w").write(body)
        r = g(f'm365 request -u "https://graph.microsoft.com/v1.0/me/messages/{mid}/move" -m post -b @{path} --content-type application/json -o json 2>&1')
        if r.returncode == 0:
            moved += 1
print("  archived:", moved)
PY
else
  echo "WARN: m365 not in PATH — skip Hotmail"
fi

echo "OK: E2E test mail archived"
