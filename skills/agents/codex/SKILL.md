---
name: agent-runtime-codex
description: >
  Codex CLI runtime — config.toml format ([mcp_servers] TOML syntax), GUI env vars
  for bw-mcp (zenity), TickTick subtask mandatory flow, permissions escalation pattern.
  Load when installing or configuring MCPs for Codex.
license: private
metadata:
  author: KpihX
  version: "2.1.0"
  scope: agent-runtime
  target-agent: codex
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — Codex CLI

## Runtime Context

- **Home:** `~/.codex/`
- **Global kernel:** `~/.codex/AGENTS.md` → `~/.agents/KERNEL.md`
- **Runtime shortcut:** `~/AGENTS.md` → this file
- **Skills path:** `~/.codex/skills/` → `~/.agents/skills/` (symlink)
- **Config file:** `~/.codex/config.toml`
- **Logs:** `~/.codex/log/codex-tui.log` — check before changing multiple variables when troubleshooting

## MCP Config Format (Codex — TOML)

```toml
[mcp_servers.<name>]
command = "/absolute/path/to/binary"
args = ["serve"]
cwd = "/home/kpihx"
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

## Installed MCPs (Codex)

| Name | Command | Notes |
|------|---------|-------|
| `bw_mcp` | direct (no subcommand) | zenity; needs desktop env vars block |
| `tick_mcp` | HTTP `tick.kpihx-labs.com/mcp` | Primary |
| `tick_mcp_fallback` | `zsh -l -c "tick-mcp serve"` | stdio fallback |
| `whats_mcp` | HTTP `whats.kpihx-labs.com/mcp` | Primary |
| `whats_mcp_fallback` | direct (no subcommand) | stdio fallback |
| `desk_mcp` | `desk-mcp serve` | needs display env vars |
| `rag_mcp` | `npx -y @yikizi/mcp-local-rag` | local RAG |
| `memory_mcp` | `npx -y @modelcontextprotocol/server-memory` | Knowledge Graph |
| `sequential_thinking_mcp` | `npx -y @modelcontextprotocol/server-sequential-thinking` | — |
| `exa_mcp` | HTTP `https://mcp.exa.ai/mcp` | `EXA_API_KEY` required |
| `puppeteer_mcp` | `npx -y @modelcontextprotocol/server-puppeteer` | browser |
| `n8n_mcp` | `zsh -l -c "n8n-mcp"` | `N8N_API_KEY` via login shell |

## Codex-Specific Rules

- **Permissions:** When blocked (git push, docker, npm publish) → ask KπX to run `/permissions` and grant the required permission, then retry.
- **Sudo:** Stop before any retry loop; ask KπX to run the privileged command manually, then resume.
- **TickTick subtasks mandatory flow:** `create_task` → `set_subtask_parent` → verify `parentId` + `childIds`. Never assume `parentId` at creation is honored (silently ignored by V1+V2).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-25 | [CLAUDE] | v2.1.0 — Copilot section extracted to agents/copilot/, Codex-only now |
| [SUMMARY] | — | Prior: initial creation, all MCPs registered, merged with Copilot |
