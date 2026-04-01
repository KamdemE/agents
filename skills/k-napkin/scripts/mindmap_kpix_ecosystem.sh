#!/usr/bin/env zsh
source "$(dirname $0)/napkin_gen.sh"
cat > /tmp/napkin_content.md << 'EOF'
# KpiX AI Agent Ecosystem

## Claude Code
- Skills system (k-* markdown files)
- MCP servers (HTTP + stdio)
- Hooks (Stop, PreToolUse)
- Auto-memory per project

## Gemini CLI
- Extensions (gemini-extension.json)
- Env var injection for secrets

## Codex CLI
- config.toml (TOML format)
- Memories and rules system

## OpenClaw
- Workspace security root
- rsync skills (not symlinks)
- Exec approvals via Telegram

## VIBE CLI
- config.toml providers and MCPs

## Shared Infrastructure
- AGENTS.md global kernel
- ~/.agents/skills/ single source of truth
- bw-env secrets in RAM
EOF
napkin_gen /tmp/napkin_content.md mindmap svg
