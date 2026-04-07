#!/usr/bin/env zsh
source "$(dirname $0)/napkin_gen.sh"
cat > /tmp/napkin_content.md << 'EOF'
# KpiX Projects Priority vs Effort Matrix

## High Priority, Low Effort (Do Now)
- Document techskills entries as work happens
- Verify all MCP connections health
- Update k-* skills after tool changes

## High Priority, High Effort (Plan)
- k-ai: build custom AI agent framework
- Personal OS: achieve full sovereign stack
- polytask: personal task management platform

## Low Priority, Low Effort (Batch)
- Skill descriptions optimization
- k-ollama Intel GPU setup refinement
- WaveTerm widget configuration updates

## Low Priority, High Effort (Defer)
- Custom LLM fine-tuning for personal use
- Full homelab hardware upgrade
- Multi-region Tailscale infrastructure
EOF
napkin_gen /tmp/napkin_content.md matrix svg
