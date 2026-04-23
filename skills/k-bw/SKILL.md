---
name: k-bw
description: "BW-MCP & BW-ENV operational memory - KpihX Bitwarden Sovereign Management: Self-hosted Vaultwarden (@docker-host) and Dual-Utility Secret Distribution (RAM-only). Load before any bw-mcp or bw-env work."
license: private
metadata:
  author: KpihX
  version: "2.1.1"
allowed-tools: mcp__bw-mcp__*, sui
---

# KπX Sovereign Management — Bitwarden (MCP & ENV)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Infrastructure Map (Sovereign)

- **Vault Server:** Unofficial Bitwarden (Vaultwarden) in Rust.
- **Location:** `@docker-host` (Container: `vaultwarden`).
- **Public URL:** `https://vault.kpihx-labs.com` (Traefik-managed).
- **Persistent Storage:** `/var/lib/docker/volumes/vaultwarden_vaultwarden_data/_data` (host) -> `/data` (container).
- **Shared Dependency:** Both utilities rely on the **Bitwarden CLI (`bw`)** installed on the local system.

## Dual-Utility Architecture

KπX uses two independent yet complementary utilities to manage secrets:

### 1. `bw-mcp` (Tool-side / Agents)
- **Purpose:** Provides Antigravity and other agents with secure, read-only access to vault items.
- **Location:** `/home/kpihx/.local/bin/bw-mcp` (installed via `uv`).
- **Nature:** High-level MCP server. Does not interact with shell variables.
- **Reference:** `$HOME/.agents/skills/k-bw/references/mcp.md`.

### 2. `bw-env` (Shell-side / Linux Environment)
- **Purpose:** Universal high-security secretion injection into Linux shell and background services. 
- **Location:** `$HOME/Work/sh/bw_env/`.
- **Working Principle:** Atomic injection into RAM-only filesystem (`/dev/shm`) to prevent sensitive variables from touching the disk in plaintext.

#### Anatomie de `bw-env`:
| Component | File | Role |
| :--- | :--- | :--- |
| **Executor** | `main.sh` | Core logic: unlock (salted), sync, lock (global revocation), and total purge. |
| **Orchestrator** | `sync-daemon.sh` | Background daemon ensuring vault freshness and handling auto-lock events. |
| **Bridge** | `load.sh` | Shell helper sourced (usually via `~/.kshrc`) to inject `/dev/shm/bw-$USER.env` into memory. |
| **Interface** | `gui/` | Python/Zenity graphical control center and system tray integration. |
| **Security** | `GPG` | Local cold-start backup encrypted with the derived master key hash. |

## Operational Map

| Task | System | Command |
| :--- | :--- | :--- |
| **Manual Sync** | `bw-env` | `bw-env sync` |
| **Full Lockdown** | `bw-env` | `bw-env lock` (triggers SIGUSR2 to all shells) |
| **Check Secrets** | `bw-mcp` | `mcp_bw-mcp_get_item` |
| **Audit Status** | `bw-env` | `bw-env status` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-bw/references/insights.md` before non-trivial work in this skill domain.
- Update `references/insights.md` at the end of the task with durable lessons.

## References

- `references/mcp.md`
- `references/insights.md`
- `references/log.md`

## Changelog

| 2026-04-23 | [ANTIGRAVITY] | v2.1.1 - Fixed YAML parsing and changelog alignment. |
| 2026-04-22 | [ANTIGRAVITY] | v2.1.0 - Unified SKILL mapping. |
| [SUMMARY] | — | v2.0.0 refactor; older -> file history |
