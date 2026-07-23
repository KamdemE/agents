#!/usr/bin/env zsh
source "$(dirname $0)/napkin_gen.sh"
cat > /tmp/napkin_content.md << 'EOF'
# KpiX Homelab Evolution

## 2023 - Foundation
First Proxmox server setup. Basic self-hosting begins.

## Early 2024 - Infrastructure
Traefik, Vaultwarden, Portainer deployed. Docker stack established.

## Mid 2024 - AI Stack
Claude Code starts. Gemini CLI installed. Codex CLI experiments.

## Late 2024 - MCP Ecosystem
First MCP servers built. HTTP MCPs on kpihx-labs.com domain.

## Early 2025 - Agent Kernel
AGENTS.md created. Skills system standardized. k-* naming adopted.

## Mid 2025 - Multi-Agent
Additional runtimes and VIBE added. Cross-agent skill sharing via rsync. Vaultwarden built.

## Late 2025 - Automation
n8n personal ops, wa-bot, sentinel. Tailscale mesh 5 devices.

## 2026 - Personal OS
Napkin AI visuals. k-ai in development. Full sovereign stack.
EOF
napkin_gen /tmp/napkin_content.md timeline svg
