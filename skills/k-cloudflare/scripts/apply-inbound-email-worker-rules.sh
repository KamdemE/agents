#!/usr/bin/env bash
# Point kpihx@ and contact@ routing rules to kpihx-labs-inbound-router worker.
set -euo pipefail

: "${CF_API_TOKEN:?CF_API_TOKEN required}"
CF_ZONE_ID="255f60d9f77924ac016c194300dbeb3c"
KPIHX_RULE_ID="332137f5445a4b368e0759a357cef0f9"
WORKER_NAME="kpihx-labs-inbound-router"

put_rule() {
  local id="$1" name="$2" priority="$3" matcher="$4"
  curl -sS -X PUT "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/email/routing/rules/${id}" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-raw "{\"name\":\"${name}\",\"enabled\":true,\"priority\":${priority},\"matchers\":[{\"type\":\"literal\",\"field\":\"to\",\"value\":\"${matcher}\"}],\"actions\":[{\"type\":\"worker\",\"value\":[\"${WORKER_NAME}\"]}]}" \
    | jq '{success,errors,actions:.result.actions}'
}

post_rule() {
  local name="$1" priority="$2" matcher="$3"
  curl -sS -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/email/routing/rules" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-raw "{\"name\":\"${name}\",\"enabled\":true,\"priority\":${priority},\"matchers\":[{\"type\":\"literal\",\"field\":\"to\",\"value\":\"${matcher}\"}],\"actions\":[{\"type\":\"worker\",\"value\":[\"${WORKER_NAME}\"]}]}" \
    | jq '{success,id:.result.id,errors}'
}

echo "=== Update kpihx@ rule ==="
put_rule "$KPIHX_RULE_ID" "kpihx@ inbound worker" 1 "kpihx@kpihx-labs.com"

CONTACT_RULE_ID="d510750af1ed449bbc02247c881f874a"
echo "=== Update contact@ rule (PUT; avoid duplicate POST) ==="
put_rule "$CONTACT_RULE_ID" "contact@ inbound worker" 2 "contact@kpihx-labs.com"
