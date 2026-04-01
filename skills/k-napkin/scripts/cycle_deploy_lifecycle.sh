#!/usr/bin/env zsh
source "$(dirname $0)/napkin_gen.sh"
cat > /tmp/napkin_content.md << 'EOF'
# KpiX Homelab Deploy Lifecycle

## 1. Code
Write feature in ~/Work/project/
Follow AGENTS.md architecture rules

## 2. Commit and Push
git commit with co-authorship
make push sends to GitHub and GitLab simultaneously

## 3. CI Validation
GitLab CI validate job runs
Checks Dockerfile and docker-compose syntax

## 4. Deploy
SSH to docker-host via Tailscale Magic DNS
docker compose pull and up with remove-orphans

## 5. Monitor
Sentinel checks service health endpoints
Portainer shows live container status

## 6. Document
New pattern: add to tutos_live
Tool change: update k-* skill
EOF
napkin_gen /tmp/napkin_content.md cycle svg
