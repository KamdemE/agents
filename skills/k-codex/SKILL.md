---
name: agent-runtime-codex
description: >
  Codex CLI runtime — config.toml (model, sandbox, approvals, trust_level),
  MCP config (TOML syntax), memories/rules/skills system, permissions escalation.
  Load when configuring Codex, adjusting settings, managing MCPs, or debugging behavior.
license: private
metadata:
  author: KpihX
  version: "2.3.0"
  scope: agent-runtime
  target-agent: codex
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — Codex CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Home:** `~/.codex/`
- **Global kernel:** `~/.codex/AGENTS.md` → `~/.agents/KERNEL.md`
- **Skills path:** `~/.codex/skills/` → `~/.agents/skills/` (symlink)
- **Config file:** `~/.codex/config.toml`
- **Logs:** `~/.codex/log/codex-tui.log` — check before bulk troubleshooting

## Key Config Files

| File | Role |
|------|------|
| `~/.codex/config.toml` | Model, behavior (sandbox/approvals/trust), MCPs — **source of truth** |
| `~/.codex/memories/` | Persisted insights from past sessions |
| `~/.codex/rules/default.rules` | Auto-allow prefix_rule patterns (accumulated by Codex) |
| `~/.codex/sessions/` | Session history |

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

**Current MCP list:** read `~/.codex/config.toml` directly — it is the source of truth.

## Permissions & Escalation

- **Blocked action** (git push, docker, npm publish) → ask KπX to run `/permissions` and grant; retry.
- **Sudo required** → STOP before retry loop; ask KπX to run the command manually; then resume.
- **rules/default.rules** — prefix_rule patterns auto-accumulated by Codex. Edit directly to remove stale entries.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-28 | [CLAUDE] | v2.3.0 — added config.toml anatomy + memories/rules; removed TickTick duplication (→ k-ticktick); broadened description |
| [SUMMARY] | — | v2.2.0 removed ~/AGENTS.md; v2.1.0 Copilot extracted; v2.0.0 initial |
