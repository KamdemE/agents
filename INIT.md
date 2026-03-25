# INIT — Agent First-Contact Protocol

Bootstrap for any agent joining the KπX workspace. Read once on first session.

## Agent Registry

| Agent | Home | Global kernel link | Runtime skill | Memory shortcut |
|-------|------|--------------------|---------------|-----------------|
| CLAUDE | `~/.claude/` | `~/.claude/CLAUDE.md` → `~/.agents/KERNEL.md` | `agents/claude` | `~/CLAUDE.md` |
| GEMINI | `~/.gemini/` | `~/.gemini/GEMINI.md` → `~/.agents/KERNEL.md` | `agents/gemini` | `~/GEMINI.md` |
| CODEX | `~/.codex/` | `~/.codex/AGENTS.md` → `~/.agents/KERNEL.md` | `agents/codex` | `~/AGENTS.md` |
| COPILOT | `~/.copilot/` | `~/.copilot/COPILOT.md` → `~/.agents/KERNEL.md` | `agents/copilot` | `~/COPILOT.md` |
| VIBE | `~/.vibe/` | `~/.vibe/prompts/global.md` → `~/.agents/KERNEL.md` | `agents/vibe` | `~/VIBE.md` |

## Setup (4 steps)

1. **Global kernel:** `ln -sf ~/.agents/KERNEL.md <AGENT_HOME>/<MD_NAME>`
2. **Runtime shortcut:** `ln -sf ~/.agents/skills/agents/<name>/SKILL.md ~/<MD_NAME>`
3. **Skills discovery:** `ln -sf ~/.agents/skills <AGENT_HOME>/skills` (or configure agent skill path to `~/.agents/skills/`)
4. **Session memory:** Inject `~/.agents/memory/context.md` at boot (via `bootstrap-extra-files` hook or equivalent)

## Validation Checklist

- [ ] `<AGENT_HOME>/skills/` → `~/.agents/skills/` (symlink or configured path)
- [ ] `<AGENT_HOME>/<MD_NAME>` → `~/.agents/KERNEL.md`
- [ ] `~/<MD_NAME>` → `~/.agents/skills/agents/<name>/SKILL.md`
- [ ] `~/.agents/memory/context.md` loaded at session start
- [ ] File routing contract understood (see KERNEL.md)

## Memory Architecture

```
~/.agents/                 git-versioned repo
├── KERNEL.md              slim global kernel
├── INIT.md                this file
├── agent.yaml             GitAgent manifest
├── skills/
│   ├── kpihx/             cross-agent KπX knowledge (8 skills)
│   ├── agents/            agent runtime skills — cross-accessible by ALL agents
│   ├── microsoft-foundry/ external skill
│   └── qmd/               QMD search skill
└── memory/
    ├── context.md         HOT: TODOs + active projects (inject at boot)
    ├── dailylog.md        LOG: chronological, max 10 entries
    └── MEMORY.md          WARM: distilled cross-session facts
```
