#!/usr/bin/env bash
# Workaround: CF Email Workers only treat destinations as verified for forward()
# when each address also appears in at least one native "forward" routing rule.
# Creates low-priority _prime-* aliases (do not publish); safe to leave enabled.
set -euo pipefail

: "${CF_API_TOKEN:?CF_API_TOKEN required}"
CF_ZONE_ID="${CF_ZONE_ID:-255f60d9f77924ac016c194300dbeb3c}"

prime_rule() {
  local alias="$1" dest="$2" priority="$3"
  local existing
  existing=$(curl -sS "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/email/routing/rules" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    | jq -r --arg a "$alias" '.result[] | select(.matchers[0].value==$a) | .id' | head -1)
  local payload
  payload=$(jq -nc --arg name "prime ${dest}" --argjson p "$priority" --arg a "$alias" --arg d "$dest" \
    '{name:$name,enabled:true,priority:$p,matchers:[{type:"literal",field:"to",value:$a}],actions:[{type:"forward",value:[$d]}]}')
  if [[ -n "$existing" ]]; then
    curl -sS -X PUT "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/email/routing/rules/${existing}" \
      -H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" \
      --data-raw "$payload" | jq '{alias:"'"$alias"'",op:"put",success,errors}'
  else
    curl -sS -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/email/routing/rules" \
      -H "Authorization: Bearer ${CF_API_TOKEN}" -H "Content-Type: application/json" \
      --data-raw "$payload" | jq '{alias:"'"$alias"'",op:"post",success,id:.result.id,errors}'
  fi
}

echo "=== Prime destinations for Worker forward() ==="
prime_rule "_prime-labs@<yourdomain.com>" "<labs@gmail.com>" 10
prime_rule "_prime-primary@<yourdomain.com>" "<primary@gmail.com>" 11
prime_rule "_prime-hotmail@<yourdomain.com>" "<personal@hotmail.com>" 12
echo "OK: prime rules ensured"
