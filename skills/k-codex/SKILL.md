---
name: k-codex
description: >
  Codex CLI runtime — config.toml (model, sandbox, approvals, trust_level),
  MCP config (TOML syntax), memories/rules/skills system, permissions escalation.
  Load when configuring Codex, adjusting settings, managing MCPs, or debugging behavior.
license: private
metadata:
  author: KpihX
  version: "2.6.0"
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
- Codex expects runtime-specific JSON envelopes; do not return ad hoc root keys
- `SessionStart` must return `hookSpecificOutput.hookEventName = "SessionStart"` plus `hookSpecificOutput.additionalContext`; `systemMessage` stays separate
- `UserPromptSubmit` must return `hookSpecificOutput.hookEventName = "UserPromptSubmit"` plus `hookSpecificOutput.additionalContext`
- blocking hooks such as `PreToolUse` and `Stop` must emit a non-empty block reason; `PreToolUse` hard blocks also need the same reason on stderr
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

## Maintenance Reflex

- for `.agents/` hygiene, QMD cleanliness, or optimization/cleanup posture, load `k-optim`
- keep runtime-specific details here, but do not duplicate the cross-cutting maintenance playbook that now lives in `k-optim`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.6.0 — documented the actual Codex hook payload contract (`hookSpecificOutput.additionalContext`, block reasons, stderr requirement for hard blocks) and aligned the wrapper docs with the runtime schema Codex really validates |
| 2026-04-03 | [CODEX] | v2.5.1 — added an explicit maintenance reflex toward `k-optim` so Codex runtime guidance does not duplicate the shared optimization and QMD hygiene playbook |
| [SUMMARY] | — | v2.5.1–v2.0.0 covered maintenance routing to `k-optim`, hook wiring, path normalization, project-context auto-load, config anatomy, memories/rules, and the initial Codex runtime baseline |
