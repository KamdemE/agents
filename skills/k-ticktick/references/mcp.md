# MCP Setup — k-ticktick

Generic MCP setup reference for `tick-mcp`.

## Install (required before STDIO)

- PyPI package: `tick-mcp`
- Install command: `uv tool install tick-mcp`
- Upgrade command: `uv tool install --upgrade tick-mcp`

## HTTP

- Works only on the Tailscale network.
- URL: `https://tick.kpihx-labs.com/mcp`

## STDIO

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `$HOME/.local/bin/tick-mcp serve`

## STDIO Fallback

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `$HOME/.local/bin/tick-mcp serve --fallback`
