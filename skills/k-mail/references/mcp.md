# MCP Setup — k-mail

Generic MCP setup reference for `mail-mcp`.

## Install (required before STDIO)

- PyPI package: `k-mail-mcp`
- Install command: `uv tool install k-mail-mcp`
- Upgrade command: `uv tool install --upgrade k-mail-mcp`
- STDIO binary used in config: `mail-mcp`

## HTTP

- Works only on the Tailscale network.
- URL: `https://mail.kpihx-labs.com/mcp`

## STDIO

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `$HOME/.local/bin/mail-mcp serve`

## STDIO Alternate

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `$HOME/.local/bin/mail-mcp serve`

## Post-send verification (tooling hints)

- **Mandatory manual pass** stays in `SKILL.md`: after `send_message`, wait ≥~5s, then re-read **`Sent`** and **`INBOX`** via `list_messages` / `search_messages` (never skip).
- **Optional complement only:** on `send_message`, you may set `verify_bounce_window_seconds` to a small value (e.g. 25–30) so the server can watch for an early DSN — **after** you still perform the **manual** `Sent` + `INBOX` checks. `delivery_status` / `bounce_details` are **hints**, not a substitute for folder re-reads.
