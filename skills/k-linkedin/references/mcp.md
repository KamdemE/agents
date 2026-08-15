# MCP Setup — k-linkedin

> **⚠️ 2026-08-14:** `linkedin-mcp` was **purged** (MCP purge — only `*-proxy` real CLIs are kept; no linkedin proxy exists, use the remote HTTP endpoint or the k-x/meta CLIs). The original `linkedin-mcp` content below is kept for the record (never deleted). See `k-node/references/purged.md`.

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
