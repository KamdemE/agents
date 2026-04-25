---
name: k-bw
description: "BW-Proxy & BW-ENV operational memory - KpihX Bitwarden Sovereign Management: self-hosted Vaultwarden (@docker-host), AI-blind vault proxy, and RAM-only shell secret distribution. Load before any bw-proxy/bw-mcp or bw-env work."
license: private
metadata:
  author: KpihX
  version: "2.3.0"
allowed-tools: mcp__bw-mcp__*, sui
---

# KπX Sovereign Management — Bitwarden (Proxy & ENV)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Infrastructure Map (Sovereign)

- **Vault Server:** Unofficial Bitwarden (Vaultwarden) in Rust.
- **Location:** `@docker-host` (Container: `vaultwarden`).
- **Public URL:** `https://vault.kpihx-labs.com` (Traefik-managed).
- **Persistent Storage:** `/var/lib/docker/volumes/vaultwarden_vaultwarden_data/_data` (host) -> `/data` (container).
- **Shared Dependency:** Both utilities rely on the **Bitwarden CLI (`bw`)** installed on the local system.

## Dual-Utility Architecture

KπX uses two independent yet complementary utilities to manage secrets:

### 1. `bw-proxy` (Tool-side / Agents)
- **Nature:** MCP/CLI proxy. Runtime authentication is RAM-only: it prompts for the Master Password per operation, creates a fresh Bitwarden session, and wipes it after use.
- **Agnostic UI:** Uses a modern browser-based approval interface (Web HITL) on `localhost:1138` for cross-platform portability. Automatically falls back to Zenity (Linux) or TTY if needed.
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
| **Proxy CLI** | `bw-proxy` | `bw-proxy admin setup` · `bw-proxy admin log view` · `bw-proxy admin wal view` |
| **Audit Status** | `bw-env` | `bw-env status` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-bw/references/insights.md` before non-trivial work in this skill domain.
- Update `references/insights.md` at the end of the task with durable lessons.

## References

- `references/mcp.md`
- `references/insights.md`
- `references/log.md`

## Changelog

| 2026-04-24 | [GEMINI] | v2.3.0 - Implemented Agnostic Web Approval UI (Browser HITL) and updated AppArmor/Docker networking. |
| 2026-04-24 | [CODEX] | v2.1.2 - Updated Bitwarden proxy memory for BW-Proxy naming, RAM-only auth, and classic/hardened install split. |
| [SUMMARY] | — | v2.2.x distribution hardening; v2.1.0 unified mapping; older -> file history |
