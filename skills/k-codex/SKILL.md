---
name: k-codex
description: >
  Codex CLI runtime — config.toml (model, sandbox, approvals, trust_level),
  MCP config (TOML syntax), memories/rules/skills system, permissions escalation.
  Load when configuring Codex, adjusting settings, managing MCPs, or debugging behavior.
license: private
metadata:
  author: KpihX
  version: "2.5.0"
  scope: agent-runtime
  target-agent: codex
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — Codex CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Home:** `$HOME/.codex/`
- **Global kernel:** `$HOME/.codex/AGENTS.md` → `$HOME/.agents/AGENTS.md`
- **Skills path:** `$HOME/.codex/skills/` → `$HOME/.agents/skills/` (symlink)
- **Config file:** `$HOME/.codex/config.toml`
- **Logs:** `$HOME/.codex/log/codex-tui.log` — check before bulk troubleshooting

## Key Config Files

| File | Role |
|------|------|
| `$HOME/.codex/config.toml` | Model, behavior (sandbox/approvals/trust), MCPs — **source of truth** |
| `$HOME/.codex/hooks.json` | Deployed hook config — symlink or copy of `$HOME/.agents/hooks/codex/hooks.json` |
| `$HOME/.codex/memories/` | Persisted insights from past sessions |
| `$HOME/.codex/rules/default.rules` | Auto-allow prefix_rule patterns (accumulated by Codex) |
| `$HOME/.codex/sessions/` | Session history |

## Hooks

Codex hook logic lives in `$HOME/.agents/hooks/codex/`; the deployed runtime entrypoint is `$HOME/.codex/hooks.json`.

| Event | Wrapper |
|------|---------|
| `SessionStart` | `$HOME/.agents/hooks/codex/session_start.py` |
| `UserPromptSubmit` | `$HOME/.agents/hooks/codex/user_prompt_submit.py` |
| `PreToolUse` | `$HOME/.agents/hooks/codex/pre_tool_use.py` |
| `Stop` | `$HOME/.agents/hooks/codex/stop.py` |

- `features.codex_hooks = true` in `$HOME/.codex/config.toml` is mandatory
- `Stop` validates the final response contract and checks dirty `$HOME/.agents/`
- `PreToolUse` is currently Bash-oriented because that is the practical Codex tool event surface in this setup

## MCP Config Format (Codex — TOML)

```toml
[mcp_servers.<name>]
command = "/absolute/path/to/binary"
args = ["serve"]
cwd = "$HOME"
```

**Login shell wrapper (secrets):**
```toml
[mcp_servers.<name>]
command = "zsh"
args = ["-l", "-c", "/path/to/binary serve"]
```

**GUI-dependent MCPs (bw-mcp with zenity):** Inject display vars:
```toml
[mcp_servers.bw_mcp.env]
DISPLAY = "$DISPLAY"
DBUS_SESSION_BUS_ADDRESS = "$DBUS_SESSION_BUS_ADDRESS"
XDG_RUNTIME_DIR = "$XDG_RUNTIME_DIR"
WAYLAND_DISPLAY = "$WAYLAND_DISPLAY"
XAUTHORITY = "$XAUTHORITY"
```
**WARNING:** Do NOT add `[mcp_servers.<name>.env]` blocks by default — can break Codex startup.

Do not enumerate MCPs here; read `$HOME/.codex/config.toml` directly.

## Permissions & Escalation

- **Sudo required** → STOP before retry loop; ask KπX to run the command manually; then resume.
- **rules/default.rules** — prefix_rule patterns auto-accumulated by Codex. Edit directly to remove stale entries.

## Project Context

When working in a project under `$HOME/Work/`, check for `.agents/AGENTS.md` at the project root.
If found: treat it as project-specific context — architecture rules, stack, evolution rules.
Template: `$HOME/.agents/skills/k-project/assets/AGENTS.md`.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.5.0 — added the live Codex hook wiring map, documented `$HOME/.codex/hooks.json` as the deployed entrypoint, and clarified the current Stop/PreToolUse behavior |
| 2026-04-03 | [CODEX] | v2.4.2 — normalized all paths to `$HOME`, updated the project AGENTS template path to `k-project/assets/AGENTS.md`, and condensed the changelog to the standard footer format |
| [SUMMARY] | — | v2.4.1 standardized name to `k-codex`; v2.4.0 project-context auto-load rule; v2.3.0 config.toml anatomy + memories/rules; v2.2.0 removed old AGENTS path; v2.1.0 Copilot extracted; v2.0.0 initial |
