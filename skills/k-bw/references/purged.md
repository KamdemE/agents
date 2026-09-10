# k-bw — Purged CLI / Server (Archive)

> **Purpose:** `bw-mcp` and `bw-admin` were purged on 2026-08-14 per maintainer directive ("purge bw-admin et bw-mcp totalement partout, même dans les skills"). The live skill now documents only `bw-proxy` (the active sovereign proxy). This file preserves the historical `bw-mcp` reference for the record — never deleted (GRAVÉ).

## Purged 2026-08-14 — `bw-mcp` & `bw-admin`

| Item | State |
|------|-------|
| `~/.local/bin/bw-admin` | broken symlink → `/opt/bw-mcp/bin/bw-admin` removed |
| `~/.local/bin/bw-mcp` | broken symlink → `/opt/bw-mcp/bin/bw-mcp` removed |
| `/opt/bw-mcp/` | absent (already removed earlier) |
| `/etc/apparmor.d/opt.bw-mcp.bin.bw-mcp` | removed (needed sudo) |
| `references/mcp.md` | archived below (content preserved) |

### Archived `bw-mcp` reference (from `references/mcp.md`)

Generic MCP setup reference for `bw-mcp` (superseded — purged).

## ⚠️ Prerequisites (Mandatory)

The `bw-mcp` server is a wrapper around the Bitwarden CLI. It cannot function without the following:

- **Binaire Bitwarden CLI (`bw`)**: Must be installed and accessible in the `$PATH`.
- **Active Session**: The CLI must be logged in and targeting `https://<vault-host>`.

## Install (required before STDIO)

- PyPI package: `bw-mcp` (internal tool)
- Install command: `uv tool install bw-mcp`
- Tool location: `$HOME/.local/bin/bw-mcp`

## Configuration

- Server URL: `https://<vault-host>`

## STDIO Registration

- command: `zsh`
- args:
  - `-l`
  - `-c`
  - `bw-mcp serve`

## Usage Policy

- Use `bw-mcp` for agent-level vault queries (non-destructive).
- Ensure the vault is unlocked via `bw unlock` or equivalent before the agent attempts to fetch credentials.
