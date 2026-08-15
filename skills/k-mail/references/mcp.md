# MCP Setup — k-mail

> **⚠️ 2026-08-14:** `mail-mcp` / `k-mail-mcp` were **purged** (MCP purge — only `*-proxy` real CLIs are kept). Use **`mail-proxy`** instead. The original `mail-mcp` content below is kept for the record (never deleted). See `k-uv/references/purged.md` and `k-node/references/purged.md`.

Generic MCP setup reference for `mail-mcp`.

## Preferred: STDIO (KπX exception)

- **Use first** for normal agent work on KπX’s machine: **attachments**, local paths, and parity with **AGENTS.md → MCP Protocol → KπX exception — mail-mcp**.
- Binary: `mail-mcp` (see `uv tool install k-mail-mcp` below).
- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `$HOME/.local/bin/mail-mcp serve`

## Fallback / read-only: HTTP

- Use when stdio is down or not wired in the runtime.
- Works only on the Tailscale network.
- URL: `https://mail.kpihx-labs.com/mcp`

## Install (PyPI / local binary)

- PyPI package: `k-mail-mcp`
- Install command: `uv tool install k-mail-mcp`
- Upgrade command: `uv tool install --upgrade k-mail-mcp`
- STDIO binary used in config: `mail-mcp`

## STDIO Alternate

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `$HOME/.local/bin/mail-mcp serve`

## Post-send verification (tooling hints)

- **Mandatory manual pass** stays in `SKILL.md`: after `send_message`, wait ≥~5s, then re-read **`Sent`** and **`INBOX`** via `list_messages` / `search_messages` (never skip).
- **Optional complement only:** on `send_message`, you may set `verify_bounce_window_seconds` to a small value (e.g. 25–30) so the server can watch for an early DSN — **after** you still perform the **manual** `Sent` + `INBOX` checks. `delivery_status` / `bounce_details` are **hints**, not a substitute for folder re-reads.
