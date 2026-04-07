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
