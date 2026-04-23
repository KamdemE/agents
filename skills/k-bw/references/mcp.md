# MCP Setup — k-bw

Generic MCP setup reference for `bw-mcp`.

## ⚠️ Prerequisites (Mandatory)

The `bw-mcp` server is a wrapper around the Bitwarden CLI. It cannot function without the following:

- **Binaire Bitwarden CLI (`bw`)**: Must be installed and accessible in the `$PATH`.
- **Active Session**: The CLI must be logged in and targeting `https://vault.kpihx-labs.com`.

## Install (required before STDIO)

- PyPI package: `bw-mcp` (internal tool)
- Install command: `uv tool install bw-mcp`
- Tool location: `/home/kpihx/.local/bin/bw-mcp`

## Configuration

- Server URL: `https://vault.kpihx-labs.com`

## STDIO Registration

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `bw-mcp serve`

## Usage Policy

- Use `bw-mcp` for agent-level vault queries (non-destructive).
- Ensure the vault is unlocked via `bw unlock` or equivalent before the agent attempts to fetch credentials.
