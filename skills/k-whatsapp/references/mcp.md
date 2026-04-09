# MCP Setup — k-whatsapp

Generic MCP setup reference for `whats-mcp`.

## Install (required before STDIO)

- npm package: local source at `$HOME/Work/AI/MCPs/whats_mcp`
- Install command: `npm install -g $HOME/Work/AI/MCPs/whats_mcp`
- Upgrade command: `npm install -g $HOME/Work/AI/MCPs/whats_mcp`

## HTTP

- Works only on the Tailscale network.
- URL: `https://whats.kpihx-labs.com/mcp`

## STDIO

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `whats-mcp serve`

## STDIO Alternate

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `whats-mcp serve`

## Post-send verification (preferred read tool)

- After `send_text` (or another send tool), wait ≥~5s, then call **`get_messages`** with the **same chat `jid`**, a **`limit`** large enough to include the tail of the thread (e.g. 50–100), and optionally **`since`** (Unix time) set just before the send to narrow results. Confirm your outbound text appears in the returned list.
- Do **not** use **`read_messages`** for this check — that tool **marks messages as read** (read receipts), it does **not** fetch history.
