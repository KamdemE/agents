# MCP Setup — k-whatsapp

> **⚠️ 2026-08-14:** `whats-mcp` was **purged** (MCP purge — only `*-proxy` real CLIs are kept). Use **`whats-proxy`** instead. The original `whats-mcp` content below is kept for the record (never deleted). See `k-node/references/purged.md`.

Generic MCP setup reference for `whats-mcp`.

## Preferred: HTTP

- **Use first** when the agent exposes both transports.
- Works on the Tailscale network (and paths that reach the homelab endpoint).
- URL: `https://whats.kpihx-labs.com/mcp`
- Cursor / runtime server id is typically **`user-whats-mcp-http`** / **`whats-mcp-http`** (see local MCP config).

## Fallback: STDIO

- Use when HTTP is unreachable, blocked, or not configured.
- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `whats-mcp serve`

## Install (required for stdio / local binary)

- npm package: local source at `$HOME/Work/AI/MCPs/whats_mcp`
- Install command: `npm install -g $HOME/Work/AI/MCPs/whats_mcp`
- Upgrade command: `npm install -g $HOME/Work/AI/MCPs/whats_mcp`

## STDIO Alternate

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `whats-mcp serve`

## Post-send verification (preferred read tool)

- After `send_text` (or another send tool), wait ≥~5s, then call **`get_messages`** with the **same chat `jid`**, a **`limit`** large enough to include the tail of the thread (e.g. 50–100), and optionally **`since`** (Unix time) set just before the send to narrow results. Confirm your outbound text appears in the returned list.
- Do **not** use **`read_messages`** for this check — that tool **marks messages as read** (read receipts), it does **not** fetch history.
