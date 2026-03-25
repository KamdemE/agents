---
name: kpihx-kernel
description: KpihX global cross-agent kernel. Loaded by all agents at session start via agent-home symlink (e.g. ~/.claude/CLAUDE.md). Slim index pointing to modular skills.
---

# KπX — Global Agent Kernel

## Identity

- **Alias:** `KpihX` / `KπX` — KAMDEM POUOKAM Ivann Harold
- **Role:** System Architect · École Polytechnique X24 (Applied Math & CS, graduation 2028)
- **Email (academic/X):** `ivann.kamdem-pouokam@polytechnique.edu`
- **Email (pro/Outlook):** `ivann.kamdem@hotmail.com` — m365 CLI only, never mail-mcp
- **Email (generic):** `kapoivha@gmail.com`
- **Primary phone:** `+33 6 05 95 77 85`

## Skills Map

All detailed knowledge lives in `~/.agents/skills/`. Load on demand via progressive disclosure.

| Skill path | Load when |
|------------|-----------|
| `kpihx/soul` | Every session — identity, mantras, collaboration protocol |
| `kpihx/duties` | Every session — mandatory rules, security, MCP protocol |
| `kpihx/workspace` | Dev / infra tasks — ~/Work/ layout, MCPs, tools, shell arch |
| `kpihx/git` | Any git or repo operation |
| `kpihx/whatsapp` | Before any whats-mcp tool call |
| `kpihx/mail` | Before any mail-mcp tool call (Zimbra/poly ONLY — NOT Outlook/Hotmail) |
| `kpihx/linkedin` | Before any linkedin-mcp tool call |
| `kpihx/ticktick` | Before any tick-mcp tool call |
| `agents/claude` | Installing/configuring MCPs for Claude; Claude-specific tasks |
| `agents/gemini` | Installing/configuring MCPs for Gemini; Gemini-specific tasks |
| `agents/codex` | Installing/configuring MCPs for Codex |
| `agents/copilot` | Installing/configuring MCPs for Copilot |
| `agents/vibe` | Installing/configuring MCPs for VIBE |

## Session Memory

- **HOT (inject at boot):** `~/.agents/memory/context.md` — TODOs + active projects
- **LOG:** `~/.agents/memory/dailylog.md` — chronological, newest-first; max 10 entries — condense oldest into fixed-width `[SUMMARY]` row when full
- **WARM:** `~/.agents/memory/MEMORY.md` — distilled cross-session facts

## File Routing Contract

| KπX says | Agent writes to |
|----------|----------------|
| "save/update in KERNEL" | `~/.agents/KERNEL.md` |
| "save/update in CLAUDE" | `~/.agents/skills/agents/claude/SKILL.md` |
| "save/update in GEMINI" | `~/.agents/skills/agents/gemini/SKILL.md` |
| "save/update in CODEX" | `~/.agents/skills/agents/codex/SKILL.md` |
| "save/update in COPILOT" | `~/.agents/skills/agents/copilot/SKILL.md` |
| "save/update in VIBE" | `~/.agents/skills/agents/vibe/SKILL.md` |

## Critical Cross-Agent Rules

- **Language:** All `~/.agents/` files → English only by default.
- **Memory home:** `~/.agents/` is the git-versioned agent repo.
- **TODOs:** Centralized in `~/.agents/memory/context.md`. Only KπX adds them; agents execute + remove.
- **Session end mandate:** Update `context.md` + append to `dailylog.md` before closing. Stop hook enforces.
- **Kernel sync:** After any `~/.agents/` change → propose `git commit` + `make push` (see `~/.agents/Makefile`).
- **Agent provenance:** Lines edited in this file → tag with `[CLAUDE]`, `[GEMINI]`, etc. (last writer wins).
- **MCP fallback:** HTTP MCP unreachable → immediately suggest its `--fallback` stdio counterpart.
