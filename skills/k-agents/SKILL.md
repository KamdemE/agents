---
name: k-agents
description: >
  Registry of KπX agent runtimes. Source of truth for the Curator daemon.
  Only agentic systems — no CLI tools, no MCPs, no infra.
metadata:
  author: KpihX
  version: "2.0.0"
  scope: kernel
---

# KπX — Agent Runtime Registry

## Status

- 🟢 Active — in daily use
- 🟡 Standby — installed, occasional use
- 🔴 Deactive

## Runtimes

### 1. OpenCode
- **Status:** 🟢 Active
- **Skill:** `skills/k-opencode/SKILL.md`
- **Config:** `~/.config/opencode/opencode.jsonc`
- **Kernel symlink:** `AGENTS.md` → kernel · `skills/` → kernel · `agents/` → kernel
- **ACP:** `opencode acp` over stdio — session/list, session/resume, session/prompt
- **Sub-agents:** Native via `agents/` + `task` tool with `subagent_type`
- **Hooks:** Plugin system — `experimental.chat.messages.transform`, `experimental.chat.system.transform`, `chat.message`, `event`
- **Curator:** Every session — ACP list + resume to read transcripts

### 2. Hermes
- **Status:** 🟢 Active
- **Skill:** `skills/k-hermes/SKILL.md`
- **Config:** `~/.hermes/config.yaml`
- **Kernel symlink:** `SOUL.md` → kernel · `external_dirs` for kernel skills
- **ACP:** ❌ No native ACP
- **Sub-agents:** Profiles + delegation system
- **Hooks:** ❌
- **Curator:** Every 6h (cron) — file inspection, `hermes sessions list`

### 3. Cursor IDE
- **Status:** 🟢 Active
- **Skill:** `skills/k-code/SKILL.md` (covered with VS Code ecosystem)
- **Config:** `~/.cursor/settings.json` · `.cursor/mcp.json`
- **Kernel symlink:** ❌ Not symlinked (`.cursorrules` must be manually maintained)
- **ACP:** Yes — native ACP support
- **Sub-agents:** Via `.cursor/agents/*.md` + native Task tool
- **Hooks:** Rule-based (`beforeSubmitPrompt`, `afterAgentResponse`, `afterFileEdit`, `sessionStart`, `sessionEnd`)
- **Curator:** Daily — ACP bridge + file inspection

### 4. AGY-IDE (Antigravity)
- **Status:** 🟢 Active
- **Skill:** `skills/k-code/SKILL.md` (covered with VS Code ecosystem)
- **Config:** `~/.agy/config.json`
- **Kernel symlink:** AGENTS.md at workspace root
- **ACP:** Via Zed ACP bridge
- **Sub-agents:** Yes
- **Hooks:** ❌
- **Curator:** Daily — ACP bridge + file inspection

### 5. OpenClaw
- **Status:** 🟢 Active (reinstated)
- **Skill:** ❌ Not maintained as a skill
- **Config:** `~/.openclaw/openclaw.json` + `.env`
- **Kernel symlink:** Workspace inject scanning workspace root for AGENTS.md
- **ACP:** Yes — `sessions_spawn({ runtime: "acp", agentId: "opencode" })`
- **Sub-agents:** Native via workspace agent definitions
- **Hooks:** ❌
- **Curator:** Daily — ACP + workspace file inspection

### 6. Codex CLI
- **Status:** 🟢 Active
- **Skill:** `skills/k-codex/SKILL.md`
- **Config:** `~/.codex/config.toml`
- **Kernel symlink:** `AGENTS.md` → kernel · `skills/` → kernel (auto-synced)
- **ACP:** ❌
- **Sub-agents:** Via `agents/` directory
- **Hooks:** `hooks.json` — session_start, user_prompt_submit, stop (pre_tool_use as shim)
- **Curator:** Weekly — file inspection

### 7. Gemini CLI
- **Status:** 🟢 Active
- **Skill:** `skills/k-gemini/SKILL.md`
- **Config:** `~/.gemini/settings.json`
- **Kernel symlink:** `GEMINI.md` → kernel (native scan `skills/` 1 level deep)
- **ACP:** ❌
- **Sub-agents:** ❌
- **Hooks:** 5 events — SessionStart, BeforeAgent, AfterAgent, BeforeTool, SessionEnd (no AfterTool)
- **Curator:** Weekly — file inspection, hook verification

### 8. GitHub Copilot CLI
- **Status:** 🟢 Active
- **Skill:** `skills/k-copilot/SKILL.md`
- **Config:** `~/.copilot/mcp-config.json` · `~/.copilot/config.json`
- **Kernel symlink:** `copilot-instructions.md` → kernel · `skills/` → kernel
- **ACP:** ❌
- **Sub-agents:** ❌
- **Hooks:** VS Code only — `chat.hookFilesLocations` → `hooks/copilot/hooks.json`
- **Curator:** Weekly — file inspection

### 9. VIBE CLI
- **Status:** 🟢 Active
- **Skill:** `skills/k-vibe/SKILL.md`
- **Config:** `~/.vibe/config.toml`
- **Kernel symlink:** `prompts/global.md` → kernel · `skill_paths` includes kernel skills
- **ACP:** ❌
- **Sub-agents:** ❌
- **Hooks:** ❌
- **Curator:** Weekly — file inspection, skill_paths verification

### 10. Cline CLI
- **Status:** 🟢 Active
- **Skill:** `skills/k-cline/SKILL.md`
- **Config:** `~/.cline/data/settings/cline_mcp_settings.json`
- **Kernel symlink:** `rules/AGENTS.md` → kernel · `skills/` → kernel
- **ACP:** ❌
- **Sub-agents:** ❌
- **Hooks:** ❌
- **Curator:** Weekly — file inspection

### 11. Zed Editor
- **Status:** 🟢 Active
- **Skill:** `skills/k-zed/SKILL.md`
- **Config:** `~/.config/zed/settings.json`
- **Kernel symlink:** `AGENTS.md` → kernel · `skills/` → kernel (recommended)
- **ACP:** Yes — native `agent_servers` bridges Codex, Gemini, Cursor, Copilot in same panel
- **Sub-agents:** Native profiles + `tool_permissions`; external via ACP bridges
- **Hooks:** ❌ (relies on AGENTS.md + skills)
- **Curator:** Daily — ACP bridge + project file inspection

### 12. Claude Code
- **Status:** 🔴 Deactive
- **Skill:** `skills/deactive/k-claude/SKILL.md`
- **Kernel symlink:** `CLAUDE.md` → kernel · `skills/` → kernel

## Curator State File

The Curator maintains `memories/curator-state.md` to track progress across runs:

```markdown
# Curator State
# Format: runtime/sessionId → last_checked_timestamp
opencode:
  ses_xxx: 2026-06-05T11:41:00
  ses_yyy: 2026-06-05T10:00:00
cursor:
  ses_zzz: 2026-06-04T08:00:00
```

On each run, the Curator:
1. Reads `memories/curator-state.md` to know what was checked
2. For each 🟢 runtime with ACP: lists sessions, compares with state file
3. New sessions → inspect fully. Active existing sessions → check for new content since last position
4. Dead sessions → remove from state file
5. Updates state file after each inspection
6. Also checks: symlinks exist, config files exist, skills paths accessible

## Notes

- **Cursor IDE** and **AGY-IDE** are VS Code forks — they share the `k-code` skill ecosystem
- **OpenClaw** was reinstated on 2026-06-05 — has its own agent system with ACP support
- **k-ai** and **Continue** are no longer in the registry (not active agent runtimes)
