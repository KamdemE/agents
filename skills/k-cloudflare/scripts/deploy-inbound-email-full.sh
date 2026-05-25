#!/usr/bin/env bash
# Full inbound email router rollout: prime destinations → sync rules → deploy worker.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
"$DIR/ensure-destination-prime-rules.sh"
"$DIR/sync-inbound-email-routes.sh"
"$DIR/deploy-inbound-email-worker.sh"
echo "OK: full inbound email deploy complete."
echo "Anti-spam: $HOME/.agents/skills/k-cloudflare/scripts/apply-inbound-antispam-filters.sh"
echo "E2E: $HOME/.agents/skills/k-cloudflare/references/inbound-email-e2e.md"
echo "Verify: $HOME/.agents/skills/k-cloudflare/scripts/verify-inbound-e2e.sh <subject-tag>"
