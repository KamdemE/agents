---
name: k-agents
description: >
  Complete registry of KπX agent runtimes, their configs, symlinks,
  injection mechanisms, ACP capabilities, and monitoring requirements.
  Source of truth for the Curator daemon.
metadata:
  author: KpihX
  version: "1.0.0"
  scope: kernel
---

# KπX — Agent Runtime Registry

This skill lists EVERY agent runtime in the KπX ecosystem.
The Curator daemon reads this to know which agents to monitor.

## Status Legend

- 🟢 Active — in daily use
- 🟡 Standby — installed, occasional use
- 🔴 Deactive — not used, kept for reference
- 🆕 Proposed — not yet installed

## Runtime Registry

| # | Runtime | Status | Config path | AGENTS.md symlink | Skills source | ACP | Sub-agents | Hooks | Injection | Curator monitor |
|---|---------|--------|-------------|-------------------|---------------|-----|------------|-------|-----------|-----------------|
| 1 | **OpenCode** | 🟢 | `~/.config/opencode/opencode.jsonc` | `AGENTS.md` → kernel | `skills/` symlink | `opencode acp` (stdio) | ✅ via `task` + `agents/` | Plugin system | AGENTS.md + skills | every session |
| 2 | **Hermes** | 🟢 | `~/.hermes/config.yaml` | `SOUL.md` → kernel | `skills/` isolated sandbox | `hermes acp` | ✅ profiles + delegation | Hooks system | SOUL.md + external_dirs | every 6h (cron) |
| 3 | **Cursor** | 🟢 | `~/.cursor/settings.json` | `.cursorrules` → kernel | `.cursor/agents/` | ✅ native | ✅ Task tool | Rule-based | `.cursorrules` | daily |
| 4 | **OpenClaw** | 🔴 | purged | — | — | ❌ | ❌ | ❌ | — | ❌ |
| 5 | **AGY (Antigravity)** | 🟢 | `~/.agy/` | via Cursor config | ~/.agy/skills/ | ✅ ACP bridge | ✅ | ❌ | AGENTS.md | daily |
| 6 | **Codex** | 🟢 | `~/.codex/config.toml` | `AGENTS.md` → kernel | `skills/` symlink | ❌ | ✅ agents/ | hooks.json | AGENTS.md + skills | weekly |
| 7 | **Gemini** | 🟢 | `~/.gemini/settings.json` | `GEMINI.md` → kernel | native scan `~/.agents/skills/` | ❌ | ❌ | 5 events | GEMINI.md + env vars | weekly |
| 8 | **Claude Code** | 🔴 | `~/.claude.json` | `CLAUDE.md` → kernel | `skills/` symlink | ❌ | ❌ | 6 events | CLAUDE.md + memory | ❌ |
| 9 | **Copilot CLI** | 🟢 | `~/.copilot/mcp-config.json` | `copilot-instructions.md` → kernel | `skills/` symlink | ❌ | ❌ | VS Code only | instructions.md | weekly |
| 10 | **VIBE** | 🟢 | `~/.vibe/config.toml` | `prompts/global.md` → kernel | `skill_paths` config | ❌ | ❌ | ❌ | global.md + skills | weekly |
| 11 | **Cline** | 🟢 | `~/.cline/` | `rules/AGENTS.md` → kernel | `skills/` symlink | ❌ | ❌ | ❌ | AGENTS.md + rules | weekly |
| 12 | **Zed** | 🟢 | `~/.config/zed/settings.json` | `AGENTS.md` → kernel | `skills/` symlink + project | ✅ ACP bridges | ✅ native agent | native | AGENTS.md + ACP | daily |
| 13 | **k-ai** | 🟢 | `~/.k-ai/config.yaml` | `AGENTS.md` → kernel | `skills.directories` | ❌ | ❌ | ❌ | AGENTS.md + config | weekly |
| 14 | **Continue** | 🟡 | `~/.continue/config.json` | — | — | ❌ | ❌ | ❌ | — | weekly |

## Per-Runtime Details

### 1. OpenCode
- **Config:** `~/.config/opencode/opencode.jsonc` (JSONC)
- **Injection:** `AGENTS.md` symlink → kernel + `skills/` symlink + `agents/` symlink
- **ACP:** `opencode acp` over stdio — supports `session/list`, `session/resume`, `session/prompt`
- **Sub-agents:** via `agents/` directory + `task` tool with `subagent_type`
- **Modes:** primary, subagent, all
- **Permissions:** 3-tier (global → agent delta → session runtime), `findLast` wins
- **Model:** `opencode-go/mimo-v2.5` (default)
- **Skills path:** `~/.config/opencode/skills/` → `~/.agents/skills/`
- **Curator access:** `opencode acp` to list sessions, `session/resume` to read transcripts
- **Known issues:** No native ACP → must be started separately

### 2. Hermes
- **Config:** `~/.hermes/config.yaml`
- **Injection:** `SOUL.md` → kernel + `external_dirs` for kernel skills
- **ACP:** `hermes acp` — delegate tasks via `delegate_task(acp_command="opencode")`
- **Sub-agents:** via profiles + delegation system
- **Skills path:** `~/.hermes/skills/` — isolated sandbox (NOT symlinked to kernel)
- **Cron:** `hermes --profile cron run "..."` for daemon tasks
- **Curator access:** `hermes sessions list` + `hermes skills list` + config inspection
- **Known issues:** Dashboard missing from PyPI wheel. Auto-skills untrusted.

### 3. Cursor
- **Config:** `~/.cursor/settings.json`
- **Injection:** `.cursorrules` file (not symlinked to kernel — manual copy)
- **ACP:** Native ACP support — can connect to external agents
- **Sub-agents:** via `.cursor/agents/*.md` + Task tool
- **Skills path:** `.cursor/agents/` (per-project)
- **Curator access:** Via ACP bridge + file inspection
- **Known issues:** Not symlinked to kernel AGENTS.md yet (manual .cursorrules)

### 4. AGY (Antigravity)
- **Config:** `~/.agy/config.json`
- **Injection:** AGENTS.md at workspace root
- **ACP:** Can be bridged via Zed ACP
- **Sub-agents:** Supported
- **Skills path:** `~/.agy/skills/`
- **Curator access:** Via filesystem + ACP bridge
- **Known issues:** `--no-sandbox` required, X11 on Wayland

### 5. Codex
- **Config:** `~/.codex/config.toml` (TOML)
- **Injection:** `AGENTS.md` symlink + `skills/` symlink (auto-synced by post-commit hook)
- **ACP:** No native ACP
- **Sub-agents:** via `agents/` directory
- **Hooks:** `hooks.json` with `pre_tool_use.py` (no-op shim)
- **Skills path:** `~/.codex/skills/` → `~/.agents/skills/`
- **Curator access:** Via file inspection only
- **Known issues:** No structured file-edit hook events. `make audit` decoupled.

### 6. Claude Code (deactive)
- **Config:** `~/.claude.json`
- **Injection:** `CLAUDE.md` → kernel + auto-memory at `projects/-home-kpihx/memory/`
- **ACP:** No
- **Hooks:** 6 events (richest surface)
- **Skills path:** `~/.claude/skills/` → `~/.agents/skills/`
- **Status:** Archived — `skills/deactive/k-claude/`

### 7. Gemini
- **Config:** `~/.gemini/settings.json`
- **Injection:** `GEMINI.md` → kernel + native scan `~/.agents/skills/` (1 level)
- **ACP:** No
- **Hooks:** 5 events (SessionStart, BeforeAgent, AfterAgent, BeforeTool, SessionEnd) — **no AfterTool**
- **Skills path:** Native scan — no symlink needed
- **Known issues:** No AfterTool event. Ext runner doesn't inherit shell env.

### 8. Copilot CLI
- **Config:** `~/.copilot/mcp-config.json` + `config.json`
- **Injection:** `copilot-instructions.md` → kernel
- **ACP:** No
- **Hooks:** VS Code only (Preview) — `chat.hookFilesLocations`
- **Skills path:** `~/.copilot/skills/` → `~/.agents/skills/`
- **Known issues:** No internal prune. QMD not MCP.

### 9. VIBE
- **Config:** `~/.vibe/config.toml`
- **Injection:** `prompts/global.md` → kernel + `skill_paths` array
- **ACP:** No
- **Skills path:** `skill_paths = ["~/.agents/skills"]`
- **Known issues:** No cache-busting tool. QMD not MCP.

### 10. Cline
- **Config:** `~/.cline/cline_mcp_settings.json` + `providers.json`
- **Injection:** `rules/AGENTS.md` → kernel + `skills/` symlink
- **ACP:** No
- **Skills path:** `~/.cline/skills/` → `~/.agents/skills/`
- **Known issues:** v1.0.0 — recent, limited operational history.

### 11. Zed
- **Config:** `~/.config/zed/settings.json`
- **Injection:** `AGENTS.md` → kernel + user `skills/` + project `skills/`
- **ACP:** ✅ Native — `agent_servers` bridges Codex, Gemini, Cursor, Copilot
- **Sub-agents:** via native agent (profiles, tool_permissions)
- **Skills path:** `~/.config/zed/skills/` → `~/.agents/skills/` (user) + `<workspace>/.agents/skills/` (project)
- **Known issues:** LMDB rules not git-friendly. Profiles ≠ product modes. `agy` ACP not supported.

### 12. k-ai
- **Config:** `~/.k-ai/config.yaml`
- **Injection:** `AGENTS.md` → kernel + `skills.directories` in config
- **ACP:** No
- **Skills path:** `skills.directories` includes `~/.agents/skills/`
- **Known issues:** Session history in `~/.k-ai/sessions/` — runtime memory only.

### 13. Continue
- **Config:** `~/.continue/config.json`
- **Status:** 🟡 Standby — installed but not primary
- **ACP:** No

## Injection Matrix — What Each Agent Auto-Loads

| File | OpenCode | Hermes | Cursor | AGY | Codex | Claude | Gemini | Copilot | VIBE | Cline | Zed | k-ai |
|------|----------|--------|--------|-----|-------|--------|--------|---------|------|-------|-----|------|
| **AGENTS.md** | ✅ | via SOUL.md | ⚠️ manual | ✅ | ✅ | ✅ | via GEMINI.md | ✅ | ✅ | ✅ | ✅ | ✅ |
| **SOUL.md** | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **USER.md** | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **k-context** | skill load | external_dirs | ❌ | ❌ | skill load | ❌ | ❌ | ❌ | skill load | skill load | skill load | skill load |
| **k-workspace** | skill load | external_dirs | ❌ | ❌ | skill load | ❌ | ❌ | ❌ | skill load | skill load | skill load | skill load |
| **k-agents** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **skills/** | ✅ symlink | isolated | per-project | ✅ | ✅ auto-sync | ✅ symlink | ✅ native scan | ✅ symlink | ✅ config | ✅ symlink | ✅ symlink | ✅ config |

## Cross-References

| This skill | References | Is referenced by |
|------------|-----------|-----------------|
| **k-agents** | — | k-context, k-hook, k-hermes, every runtime skill |
| **k-context** | k-agents, k-workspace, k-hook | AGENTS.md (HOT every session), every agent |
| **k-workspace** | k-agents, k-project, k-git | AGENTS.md (MANDATORY), every agent |
| **k-hook** | k-agents, all per-runtime hooks | AGENTS.md (mandatory rules) |
| **k-hermes** | k-agents, k-hook | Hermes config, k-context |
| **k-clis** | k-agents, all runtime skills | k-workspace |
| **k-optim** | k-agents, k-context | k-context |
| **k-final** | k-agents, k-workspace, k-git | k-workspace (project finalization) |

## Curator Usage

The Curator daemon (`agents/curator/agent.md`) reads this skill to know:
1. Which runtimes are active and should be monitored
2. How to connect to each runtime (ACP, file system, etc.)
3. What each runtime auto-loads (to verify injection works)
4. What known issues to watch for

Run check:
```bash
# Curator loops through each ACTIVE runtime and verifies:
# 1. AGENTS.md symlink exists and points to kernel
# 2. Skills path exists and is accessible
# 3. Config file exists and is parseable
# 4. ACP (if supported) can list sessions
# 5. Any known issues have workarounds applied
```

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-06-05 | — | v1.0.0 — Initial creation: 14 runtimes, injection matrix, cross-references, curator usage. |
