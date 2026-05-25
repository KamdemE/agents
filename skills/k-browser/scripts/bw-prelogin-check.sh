#!/usr/bin/env zsh
# Verify Vaultwarden exposes the Bitwarden 2026.4+ prelogin/password route.
set -euo pipefail

BASE="${1:-https://vault.kpihx-labs.com}"
EMAIL="${2:-}"

echo "Checking ${BASE}/identity/accounts/prelogin/password ..."
CODE=$(curl -s -o /tmp/bw-prelogin-password.json -w '%{http_code}' -X POST \
  "${BASE}/identity/accounts/prelogin/password" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"${EMAIL:-probe@example.com}\"}")

echo "HTTP ${CODE}"
if [[ "${CODE}" == "404" ]]; then
  echo "FAIL: Vaultwarden is too old for Bitwarden extension 2026.4.x — upgrade to vaultwarden/server:1.36.0+"
  exit 1
fi

head -c 300 /tmp/bw-prelogin-password.json 2>/dev/null || true
echo
echo "OK: endpoint reachable (not 404)"
