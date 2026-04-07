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
