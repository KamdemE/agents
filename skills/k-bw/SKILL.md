---
name: k-bw
description: "BW-Proxy & BW-ENV operational memory - KpihX Bitwarden Sovereign Management: self-hosted Vaultwarden (@docker-host), AI-blind vault proxy, and RAM-only shell secret distribution. Load before any bw-proxy/bw-mcp or bw-env work."
license: private
metadata:
  author: KpihX
  version: "2.5.0"
allowed-tools: mcp__bw-mcp__*, Bash(tmux:*)
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
- **Agnostic UI:** Uses a modern browser-based approval interface (Web HITL) on `localhost:1138` for cross-platform portability.
- **RPC 2.0 Principle (Mandatory):** All `bw-proxy do` operations follow the RPC 2.0 protocol.
    - **Core Parameters:** Must be passed inside the **JSON payload** (as a string or file).
    - **CLI Flags:** Are reserved strictly for **meta-parameters** (e.g., `-o/--output-file` for redirection, `-f/--format` for display). Never use CLI flags for tool-specific logic.
- **Fast Interface:**
    - `bw-proxy admin status`: Check proxy health and connection.
    - `bw-proxy admin config view`: See current configuration.
    - `bw-proxy do get-vault-map [-o PATH]`: Retrieve the entire redacted vault structure.
    - `bw-proxy do propose-vault-transaction`: Batch ACID operations (Atomic).
- **Output Redirection:** Use `-o` or `--output-file` to save large JSON results (like vault maps) to a file.

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
| **Proxy Status** | `bw-proxy` | `bw-proxy admin status` |
| **Get Vault Map** | `bw-proxy` | `bw-proxy do get-vault-map -o /tmp/map.json` |
| **Lease Unlock** | `bw-proxy` | `bw-proxy admin unlock` (creates a Docker-only temporary lease) |
| **Audit Log** | `bw-proxy` | `bw-proxy admin log view` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-bw/references/insights.md` before non-trivial work in this skill domain.
- Update `references/insights.md` at the end of the task with durable lessons.

## References

- `references/mcp.md`
- `references/insights.md`
- `references/log.md`

## Changelog

| 2026-04-28 | [ANTIGRAVITY] | v2.4.0 - Added Fast Interface documentation (`admin status`, `do` with `-o`) and detailed Operational Map. |
| 2026-04-24 | [GEMINI] | v2.3.0 - Implemented Agnostic Web Approval UI (Browser HITL) and updated AppArmor/Docker networking. |
| [SUMMARY] | — | v2.2.x distribution hardening; v2.1.2 naming; older -> file history |
