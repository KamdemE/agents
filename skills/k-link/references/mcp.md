# MCP Setup — k-link [LEGACY — DO NOT USE]

> **⚠️ LEGACY (2026-09-05):** `linkedin-mcp` is dead. The only LinkedIn transport is the `link-proxy` CLI
> (`$HOME/Labs/Proxies/link-proxy/`, see `k-link/SKILL.md`). This file is a **purged archive** —
> kept so nothing is lost, never to be used or extended.
>
> **⚠️ 2026-08-14 (original purge note):** `linkedin-mcp` was **purged** (MCP purge — only `*-proxy` real CLIs are kept; no linkedin proxy exists, use the remote HTTP endpoint or the k-x/meta CLIs). The original `linkedin-mcp` content below is kept for the record (never deleted). See `k-node/references/purged.md`.

Generic MCP setup reference for `linkedin-mcp`.

## Install (required before STDIO)

- Bun package: `k-linkedin-mcp`
- Install command: `bun install -g k-linkedin-mcp`
- Upgrade command: `bun install -g k-linkedin-mcp`
- STDIO binary used in config: `linkedin-mcp`

## HTTP

- Works only on the Tailscale network.
- URL: `https://linkedin.<github-user>.com/mcp`

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
