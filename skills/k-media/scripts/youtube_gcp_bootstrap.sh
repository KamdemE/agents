#!/usr/bin/env bash
# Idempotent YouTube Data API bootstrap on GCP project <github-user> (read-only checks + enable API).
set -euo pipefail

PROJECT="${GCP_PROJECT:-<github-user>}"
GWS_CFG="${GWS_LABS_CONFIG:-$HOME/.config/gws/<github-user>}"

echo "=== Project ==="
gcloud projects describe "$PROJECT" --format='table(projectId,name,projectNumber,lifecycleState)'

echo "=== Enable YouTube Data API v3 ==="
gcloud services enable youtube.googleapis.com --project="$PROJECT"

echo "=== Enabled check ==="
gcloud services list --project="$PROJECT" --enabled \
  --filter='name:youtube.googleapis.com' --format='value(name)'

echo "=== OAuth client (gws-labs) ==="
if [[ -f "$GWS_CFG/client_secret.json" ]]; then
  jq -r '
    if .installed then
      "type=installed project_id=\(.installed.project_id) redirect=\(.installed.redirect_uris[0] // "n/a")"
    elif .web then
      "type=web project_id=\(.web.project_id)"
    else "type=unknown"
    end
  ' "$GWS_CFG/client_secret.json"
else
  echo "WARN: missing $GWS_CFG/client_secret.json — create OAuth client in console"
fi

echo "=== Console links ( manual) ==="
echo "API enabled:  https://console.cloud.google.com/apis/library/youtube.googleapis.com?project=${PROJECT}"
echo "Consent:      https://console.cloud.google.com/auth/branding?project=${PROJECT}"
echo "Credentials:  https://console.cloud.google.com/apis/credentials?project=${PROJECT}"
echo "Quotas:       https://console.cloud.google.com/apis/api/youtube.googleapis.com/quotas?project=${PROJECT}"

echo "OK: gcloud bootstrap done — next: consent scopes + OAuth re-auth (see k-media/references/youtube-<github-user>.md)"
