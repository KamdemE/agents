# Agent Registry — Link & Config Map

> How each agent runtime connects to the sovereign `.agents/` kernel. Source of truth for symlinks and skills paths.

## Registry

| Agent | Home | Kernel link | Config file | Skills support |
|-------|------|-------------|-------------|----------------|
| OPENCODE | `$HOME/.config/opencode/` | `AGENTS.md` → kernel | `opencode.jsonc` | `skills/` + `agents/` symlinks |
| HERMES | `$HOME/.hermes/` | `SOUL.md` → `AGENTS.md` | `config.yaml` | Isolated sandbox |
| CURSOR IDE | `$HOME/.cursor/` | `.cursorrules` (manual) | `settings.json` | `.cursor/agents/` |
| AGY-IDE | `$HOME/.agy/` | workspace root AGENTS.md | `config.json` | `~/.agy/skills/` |
| OPENCLAW | `$HOME/.openclaw/` | workspace AGENTS.md scan | `openclaw.json` | workspace |
| CODEX | `$HOME/.codex/` | `AGENTS.md` → kernel | `config.toml` | Auto-synced `skills/` |
| GEMINI | `$HOME/.gemini/` | `GEMINI.md` → kernel | `settings.json` | Native scan `~/.agents/skills/` |
| CLAUDE | `$HOME/.claude/` | `CLAUDE.md` → kernel | `~/.claude.json` | `skills/` symlink |
| COPILOT | `$HOME/.copilot/` | `copilot-instructions.md` → kernel | `mcp-config.json` | `skills/` symlink |
| VIBE | `$HOME/.vibe/` | `prompts/global.md` → kernel | `config.toml` | `skill_paths` config |
| CLINE | `$HOME/.cline/` | `rules/AGENTS.md` → kernel | `cline_mcp_settings.json` | `skills/` symlink |
| ZED | `$HOME/.config/zed/` | `AGENTS.md` → kernel | `settings.json` | `skills/` symlink + project |

## Symlink Commands

```bash
# OpenCode (primary)
ln -sf $HOME/.agents/AGENTS.md $HOME/.config/opencode/AGENTS.md
ln -sf $HOME/.agents/skills $HOME/.config/opencode/skills
ln -sf $HOME/.agents/agents $HOME/.config/opencode/agents

# Hermes
ln -sf $HOME/.agents/AGENTS.md $HOME/.hermes/SOUL.md

# Cursor IDE
# .cursorrules must be manually maintained (no symlink)

# Codex
ln -sf $HOME/.agents/AGENTS.md $HOME/.codex/AGENTS.md
# skills/ auto-synced by post-commit hook ($HOME/.agents/.git/hooks/post-commit)

# Claude (deactive)
ln -sf $HOME/.agents/AGENTS.md $HOME/.claude/CLAUDE.md
ln -sf $HOME/.agents/skills $HOME/.claude/skills

# Copilot
ln -sf $HOME/.agents/AGENTS.md $HOME/.copilot/copilot-instructions.md
ln -sf $HOME/.agents/skills $HOME/.copilot/skills

# Gemini
ln -sf $HOME/.agents/AGENTS.md $HOME/.gemini/GEMINI.md
# natively scans $HOME/.agents/skills/

# Vibe
ln -sf $HOME/.agents/AGENTS.md $HOME/.vibe/prompts/global.md
# config.toml: system_prompt_id = "global"
# config.toml: skill_paths = ["$HOME/.agents/skills"]

# Cline
ln -sf $HOME/.agents/AGENTS.md $HOME/.cline/rules/AGENTS.md
ln -sf $HOME/.agents/skills $HOME/.cline/skills

# Zed
ln -sf $HOME/.agents/AGENTS.md $HOME/.config/zed/AGENTS.md
ln -sf $HOME/.agents/skills $HOME/.config/zed/skills
```

## Self-Verification (Agent First-Contact)

Before any setup action, agents should:
1. Read their own `k-<name>/SKILL.md` for runtime-specific setup
2. Cross-check: does the registry match their actual capabilities?
3. If divergence detected: STOP, alert , propose correction

## Skills Path — Per-Agent Details

- **OpenCode:** `skills/` dir linked + `agents/` dir linked
- **Hermes:** `external_dirs` includes kernel skills; `skills/` is isolated sandbox
- **Cursor:** `.cursor/agents/` per-project
- **Codex:** auto-synced to `$HOME/.codex/skills/` via post-commit hook (preserves `.system/`)
- **Gemini:** natively scans `$HOME/.agents/skills/` (1 level deep)
- **Claude:** direct symlink `$HOME/.claude/skills` (deactive)
- **Copilot:** direct symlink `$HOME/.copilot/skills`
- **Vibe:** config.toml `skill_paths`
- **Cline:** symlink `$HOME/.cline/skills`
- **Zed:** `skills/` symlink + project-level `<workspace>/.agents/skills/`
