#!/usr/bin/env zsh
source "$(dirname $0)/napkin_gen.sh"
cat > /tmp/napkin_content.md << 'EOF'
# KpiX Daily AI Toolbox

## Code and Architecture
- Claude Code: primary agent for coding and architecture
- Codex CLI: focused coding with persistent memory
- GitHub Copilot: IDE inline suggestions

## Research and Exploration
- Gemini CLI: research and Google-heavy tasks
- Exa MCP: semantic web search
- QMD: local knowledge base search across 492 docs

## Infrastructure Management
- SSH via Tailscale: kpihx-labs and docker-host
- Portainer: container management UI
- Traefik: reverse proxy and routing dashboard

## Communication
- whats-mcp: WhatsApp messaging and groups
- mail-mcp: Zimbra polytechnique inbox
- linkedin-mcp: professional network posting

## Productivity and Visuals
- TickTick MCP: tasks and project tracking
- Napkin AI: instant infographic generation

## Secrets and Security
- Vaultwarden: self-hosted password manager
- bw-env: secrets injection into shell RAM
EOF
napkin_gen /tmp/napkin_content.md list svg
