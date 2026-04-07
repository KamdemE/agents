# MCP Setup — k-linkedin

Generic MCP setup reference for `linkedin-mcp`.

## Install (required before STDIO)

- Bun package: `k-linkedin-mcp`
- Install command: `bun install -g k-linkedin-mcp`
- Upgrade command: `bun install -g k-linkedin-mcp`
- STDIO binary used in config: `linkedin-mcp`

## HTTP

- Works only on the Tailscale network.
- URL: `https://linkedin.kpihx-labs.com/mcp`

## STDIO

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `linkedin-mcp serve`

## STDIO Alternate

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `linkedin-mcp serve`
