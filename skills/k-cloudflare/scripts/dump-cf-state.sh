#!/usr/bin/env bash
# dump-cf-state.sh — dumps complete Cloudflare state to assets/dumps/*.json
# Usage: with-env dump-cf-state.sh (run in tmux pane via k-tmux)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DUMP_DIR="${SCRIPT_DIR}/../assets/dumps"

ACCOUNT_ID="5d0ff5e40bbc37baed99d3c7aacd0741"
ZONE_ID="255f60d9f77924ac016c194300dbeb3c"
TUNNEL_ID="db6721cb-6bfe-4750-b55a-124e6dc74388"

mkdir -p "$DUMP_DIR"

echo "🔄 Dumping Cloudflare state to $DUMP_DIR..."

curls -p cloudflare "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=100" > "$DUMP_DIR/dns-records.json" && echo "  [✓] DNS Records"
curls -p cloudflare "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/email/routing" > "$DUMP_DIR/email-routing-status.json" && echo "  [✓] Email Routing Status"
curls -p cloudflare "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/email/routing/rules" > "$DUMP_DIR/email-routing-rules.json" && echo "  [✓] Email Routing Rules"
curls -p cloudflare "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/email/routing/addresses" > "$DUMP_DIR/email-routing-addresses.json" && echo "  [✓] Email Routing Addresses"
curls -p cloudflare "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/identity_providers" > "$DUMP_DIR/access-idps.json" && echo "  [✓] Access Identity Providers"
curls -p cloudflare "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/apps" > "$DUMP_DIR/access-apps.json" && echo "  [✓] Access Applications"
curls -p cloudflare "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/access/policies" > "$DUMP_DIR/access-policies.json" && echo "  [✓] Access Policies"
curls -p cloudflare "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel" > "$DUMP_DIR/tunnels-list.json" && echo "  [✓] Tunnels List"
curls -p cloudflare "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" > "$DUMP_DIR/tunnel-ingress.json" && echo "  [✓] Tunnel Ingress Configuration"
curls -p cloudflare "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/workers/scripts" > "$DUMP_DIR/workers-list.json" && echo "  [✓] Workers List"

echo "✅ Cloudflare 360° state dump complete!"
