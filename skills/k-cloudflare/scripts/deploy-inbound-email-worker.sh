#!/usr/bin/env bash
# Deploy kpihx-labs-inbound-router Email Worker (requires CF token with Workers Scripts Edit).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../assets/kpihx-labs-inbound-router" && pwd)"

if [[ -z "${CF_API_TOKEN:-}" && -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  echo "ERROR: set CF_API_TOKEN or CLOUDFLARE_API_TOKEN (needs Account → Workers Scripts Edit)" >&2
  exit 1
fi

export CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN:-$CF_API_TOKEN}"

cd "$ROOT"
npx --yes wrangler@3 deploy

echo "OK: worker deployed."
echo "Next: $(dirname "$0")/ensure-destination-prime-rules.sh && $(dirname "$0")/sync-inbound-email-routes.sh"
