#!/usr/bin/env zsh
source "$(dirname $0)/napkin_gen.sh"
cat > /tmp/napkin_content.md << 'EOF'
# KpiX Skills Architecture Hierarchy

## AGENTS.md Global Kernel
Root identity, language rules, security, mantras

### Core Sessions
- k-context: active TODOs and session log
- k-ubuntu: workstation directory layout and standards

### Dev Skills
- k-project: project initialization
- k-docker: homelab deployment
- k-git: SSH workflow and remotes

### Agent Runtime Skills
- k-claude: MCP config and hooks
- k-gemini: extensions and env vars
- k-codex: config.toml and memories
- k-vibe: providers and permissions
- k-copilot: mcp-config.json format
- deactivated runtime archive: retired workspace-root and approval notes

### Tool Integration
- k-napkin: visual generation via API
- k-rclone: Google Drive mounts
- k-homelab: infra SSH and services

### Communication
- k-whatsapp, k-mail, k-linkedin, k-ticktick
EOF
napkin_gen /tmp/napkin_content.md hierarchy svg
