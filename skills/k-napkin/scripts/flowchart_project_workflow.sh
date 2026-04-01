#!/usr/bin/env zsh
source "$(dirname $0)/napkin_gen.sh"
cat > /tmp/napkin_content.md << 'EOF'
# KpiX New Project Creation Workflow

1. Load k-project skill
2. Choose stack: Python or TypeScript?
3. Python: uv init --package in ~/Work/
4. TypeScript: bun init in ~/Work/
5. Create .agents/AGENTS.md from template
6. Initialize git repo with SSH remote
7. Create GitLab and GitHub remotes
8. Setup Makefile with make push target
9. Deploy on homelab? Load k-docker skill
10. Create multi-stage Dockerfile
11. Create docker-compose.prod.yml
12. Setup GitLab CI pipeline
13. Deploy via Traefik with domain label
14. Document new patterns in tutos_live
EOF
napkin_gen /tmp/napkin_content.md flowchart svg
