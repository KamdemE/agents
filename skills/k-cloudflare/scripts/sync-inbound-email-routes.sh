#!/usr/bin/env bash
# Sync Cloudflare Email Routing rules from inbound-routes.json (worker action per alias).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../assets/<github-user>-inbound-router" && pwd)"
ROUTES_JSON="${ROOT}/inbound-routes.json"

: "${CF_API_TOKEN:?CF_API_TOKEN required}"
CF_ZONE_ID="${CF_ZONE_ID:-255f60d9f77924ac016c194300dbeb3c}"
WORKER_NAME="${WORKER_NAME:-<github-user>-inbound-router}"

put_worker_rule() {
  local id="$1" name="$2" priority="$3" address="$4"
  curl -sS -X PUT "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/email/routing/rules/${id}" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-raw "{\"name\":\"${name}\",\"enabled\":true,\"priority\":${priority},\"matchers\":[{\"type\":\"literal\",\"field\":\"to\",\"value\":\"${address}\"}],\"actions\":[{\"type\":\"worker\",\"value\":[\"${WORKER_NAME}\"]}]}" \
    | jq '{address:"'"${address}"'",success,errors,action:.result.actions[0].type}'
}

post_worker_rule() {
  local name="$1" priority="$2" address="$3"
  curl -sS -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/email/routing/rules" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-raw "{\"name\":\"${name}\",\"enabled\":true,\"priority\":${priority},\"matchers\":[{\"type\":\"literal\",\"field\":\"to\",\"value\":\"${address}\"}],\"actions\":[{\"type\":\"worker\",\"value\":[\"${WORKER_NAME}\"]}]}" \
    | jq '{address:"'"${address}"'",success,id:.result.id,errors}'
}

echo "=== Sync from ${ROUTES_JSON} ==="
jq -c '.aliases[]' "${ROUTES_JSON}" | while read -r row; do
  address=$(echo "$row" | jq -r '.address')
  name=$(echo "$row" | jq -r '.name')
  priority=$(echo "$row" | jq -r '.priority')
  rule_id=$(echo "$row" | jq -r '.rule_id // empty')
  if [[ -n "${rule_id}" ]]; then
    put_worker_rule "$rule_id" "$name" "$priority" "$address"
  else
    post_worker_rule "$name" "$priority" "$address"
  fi
done

echo "OK: rules synced. Deploy worker if routes.mjs changed: deploy-inbound-email-worker.sh"
