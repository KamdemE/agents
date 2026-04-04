#!/usr/bin/env zsh
# BAD USAGE EXAMPLE — "comparison" visual_query with 4 items.
#
# "comparison" uses a 2-column pros/cons template.
# Sending 4 sections (4x ##) causes Napkin to pick an unexpected layout:
# the visual is generated but won't match a 4-column table expectation.
#
# The result saved in assets/examples/comparison.svg is the actual output
# of this script — kept as a reference for what NOT to expect.
#
# CORRECT ALTERNATIVES for 4-way comparison:
#   - Use visual_query: "matrix" with explicit axes
#   - Split into 2 separate "comparison" calls (2 agents each)
source "$(dirname $0)/napkin_gen.sh"
cat > /tmp/napkin_content.md << 'EOF'
# KpiX AI Agents Comparison

## Claude Code
- Config: JSON ($HOME/.claude.json)
- Skills: auto-detected from $HOME/.agents/skills/
- Strengths: best reasoning, hooks system, long context
- Weaknesses: no TOML config format

## Gemini CLI
- Config: gemini-extension.json per server
- Skills: native scan of $HOME/.agents/skills/
- Strengths: Google integration, token efficiency
- Weaknesses: env var injection required for secrets

## Codex CLI
- Config: TOML ($HOME/.codex/config.toml)
- Skills: symlink via $HOME/.codex/skills/
- Strengths: persistent memories, rules accumulation
- Weaknesses: env blocks can break startup

## Gateway Runtime
- Config: workspace-scoped tool config
- Skills: rsync copies only, no symlinks
- Strengths: security root, Telegram exec approvals
- Weaknesses: rsync overhead for skill sync
EOF
napkin_gen /tmp/napkin_content.md comparison svg
