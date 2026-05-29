# Agent Registry — Link & Config Map

> How each agent runtime connects to the sovereign `.agents/` kernel. Source of truth for symlinks and skills paths.

## Registry

| Agent | Home | Kernel link | Config file | Skills support |
|-------|------|-------------|-------------|----------------|
| OPENCODE | `$HOME/.config/opencode/` | `AGENTS.md` → `$HOME/.agents/AGENTS.md` | `opencode.jsonc` | Yes (skills dir + agents dir) |
| CODEX | `$HOME/.codex/` | `AGENTS.md` → `$HOME/.agents/AGENTS.md` | `config.toml` | Yes |
| GEMINI | `$HOME/.gemini/` | `GEMINI.md` → `$HOME/.agents/AGENTS.md` | `settings.json` | Yes (extensions) |
| CLAUDE | `$HOME/.claude/` | `CLAUDE.md` → `$HOME/.agents/AGENTS.md` | `$HOME/.claude.json` | Yes |
| COPILOT | `$HOME/.copilot/` | `copilot-instructions.md` → `$HOME/.agents/AGENTS.md` | `mcp-config.json` | Yes |
| VIBE | `$HOME/.vibe/` | `prompts/global.md` → `$HOME/.agents/AGENTS.md` | `config.toml` | Yes |
| K-AI | `$HOME/.k-ai/` | `AGENTS.md` → `$HOME/.agents/AGENTS.md` | `config.yaml` | Yes |

## Symlink Commands

```bash
# OpenCode (primary)
ln -sf $HOME/.agents/AGENTS.md $HOME/.config/opencode/AGENTS.md
ln -sf $HOME/.agents/skills $HOME/.config/opencode/skills
ln -sf $HOME/.agents/agents $HOME/.config/opencode/agents

# Codex
ln -sf $HOME/.agents/AGENTS.md $HOME/.codex/AGENTS.md
# skills/ auto-synced by post-commit hook ($HOME/.agents/.git/hooks/post-commit)

# Claude (legacy)
ln -sf $HOME/.agents/AGENTS.md $HOME/.claude/CLAUDE.md
ln -sf $HOME/.agents/skills $HOME/.claude/skills

# Copilot
ln -sf $HOME/.agents/AGENTS.md $HOME/.copilot/copilot-instructions.md
ln -sf $HOME/.agents/skills $HOME/.copilot/skills

# Gemini
ln -sf $HOME/.agents/AGENTS.md $HOME/.gemini/GEMINI.md
# natively scans $HOME/.agents/skills/

# Vibe (Mistral)
ln -sf $HOME/.agents/AGENTS.md $HOME/.vibe/prompts/global.md
# config.toml: system_prompt_id = "global"
# config.toml: skill_paths = ["$HOME/.agents/skills"]

# k-ai
ln -sf $HOME/.agents/AGENTS.md $HOME/.k-ai/AGENTS.md
# config.yaml: skills.directories includes $HOME/.agents/skills
```

## Self-Verification (Agent First-Contact)

Before any setup action, agents should:
1. Read their own `k-<name>/SKILL.md` for runtime-specific setup
2. Cross-check: does the registry match their actual capabilities?
3. If divergence detected: STOP, alert KπX, propose correction

## Skills Path — Per-Agent Details

- **OpenCode:** `skills/` dir linked + `agents/` dir linked
- **Codex:** auto-synced to `$HOME/.codex/skills/` via post-commit hook (preserves `.system/`)
- **Gemini:** natively scans `$HOME/.agents/skills/` (1 level deep)
- **Claude:** direct symlink `$HOME/.claude/skills`
- **Copilot:** direct symlink `$HOME/.copilot/skills`
- **Vibe:** config.toml `skill_paths`
- **k-ai:** config.yaml `skills.directories`
