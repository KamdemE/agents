---
name: k-bw
description: "BW-Proxy & BW-MCP operational memory - KpihX Bitwarden Sovereign Management: self-hosted Vaultwarden (@docker-host) and AI-blind vault proxy. Load before any bw-proxy or bw-mcp work."
license: private
metadata:
  author: KpihX
  version: "3.0.0"
  allowed-tools: mcp__bw-mcp__*, Bash(tmux:*)
---

# KπX Sovereign Management — Bitwarden (Proxy & MCP)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **OS references:** `references/ubuntu.md` (Linux setup) · `references/windows.md` (WSL bw-proxy, SSH Agent WSL bridge)

## Infrastructure Map (Sovereign)

- **Vault Server:** Unofficial Bitwarden (Vaultwarden) in Rust.
- **Location:** `@docker-host` (Container: `vaultwarden`).
- **Public URL:** `https://vault.kpihx-labs.com` (Traefik-managed).
- **Persistent Storage:** `/var/lib/docker/volumes/vaultwarden_vaultwarden_data/_data` (host) -> `/data` (container).
- **Dependency:** Bitwarden CLI (`bw`) installed locally (optional, rarely used directly).

## Dual-Utility Architecture

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

### 2. `bw-mcp` (MCP Server)

- **Nature:** Bitwarden MCP server for AI agents.
- **Location:** `/opt/bw-mcp/bin/bw-mcp` (symlinked to `~/.local/bin/bw-mcp`).
- **Usage:** Configured in agent MCP settings (OpenCode, Gemini, etc.) to provide secure vault access.
- **Binaries:** `bw-mcp`, `bw-admin` — both symlinked to `~/.local/bin/`.

## Operational Map

| Task | System | Command |
| :--- | :--- | :--- |
| **Proxy Status** | `bw-proxy` | `bw-proxy admin status` |
| **Get Vault Map** | `bw-proxy` | `bw-proxy do get-vault-map -o /tmp/map.json` |
| **Lease Unlock** | `bw-proxy` | `bw-proxy admin unlock` (creates a Docker-only temporary lease) |
| **Audit Log** | `bw-proxy` | `bw-proxy admin log view` |

## Bitwarden Desktop GUI — SSH Agent

The official Bitwarden desktop app (v2025.1.2+) includes a built-in SSH agent that replaces `ssh-agent`. SSH keys are stored encrypted in your vault, never as files on disk.

### Activation (all platforms) — dans l'app desktop

Ces étapes sont **identiques** sur Linux, Windows et macOS :

1. **Open Bitwarden desktop app**, unlock your vault.
2. **Go to Settings → SSH Agent** (gear icon, then "SSH Agent" tab).
3. **Toggle "Enable SSH agent" ON.**
4. **Set "Ask for authorization when using SSH agent" to `"Remember until vault is locked"`** (or `"Always"` for first-time testing).
5. **Create an SSH key**: click `+` → item type `SSH key` → Bitwarden generates an Ed25519 key pair automatically → name it (e.g., "kpihx-ubuntu") → **Save**.

### Linux natif (.deb, AppImage) — notre setup

Procédure documentée pour l'Ubuntu workstation (déjà en place) :

1. **Set `SSH_AUTH_SOCK` in shell rc** (déjà dans `~/.kshrc`) :
   ```bash
   export SSH_AUTH_SOCK=$HOME/.bitwarden-ssh-agent.sock
   ```
2. **Test the agent:**
   ```bash
   ssh-add -L           # doit lister les clés du vault
   ssh -T git@github.com
   # Bitwarden popup → accept → "Hi ...! You've successfully authenticated"
   ```

### Windows + WSL2

Sur Windows, Bitwarden utilise un **named pipe** (`\\.\pipe\openssh-ssh-agent`), pas un Unix socket. Le pont `npiperelay` + `socat` est nécessaire depuis WSL.

→ Voir `references/windows.md` → **Bitwarden Desktop SSH Agent — WSL Bridge** pour la procédure complète (désactiver OpenSSH, installer npiperelay, créer le bridge, tester).

### Socket paths by install method

| Install method | Socket / Pipe |
|----------------|--------------|
| **Linux natif (.deb, AppImage)** | `~/.bitwarden-ssh-agent.sock` |
| **Linux Snap** | `~/snap/bitwarden/current/.bitwarden-ssh-agent.sock` |
| **Linux Flatpak** | `~/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock` |
| **Windows natif** | `\\.\pipe\openssh-ssh-agent` (named pipe) |
| **macOS .dmg** | `~/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock` |

### Requirements

- Bitwarden desktop app **≥ 2025.1.2**
- Desktop app must be **running and unlocked** for SSH agent to work
- Flatpak builds **do not** support SSH agent — use native or Snap on Linux
- Windows : désactiver le service OpenSSH Authentication Agent avant

### Troubleshooting

- `ssh-add -L` fails → Bitwarden not running, vault locked, or SSH agent not enabled in Settings
- Socket not found → toggle SSH Agent off/on in Settings, or check install method matches socket path
- `IdentitiesOnly yes` without `IdentityFile` → SSH skips agent keys entirely, falls back to password auth
- **Windows/WSL :** si le pipe se bloque après usage prolongé → redémarrer l'app desktop Bitwarden

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-bw/references/insights.md` before non-trivial work in this skill domain.
- Update `references/insights.md` at the end of the task with durable lessons.

## References

- `references/mcp.md`
- `references/insights.md`
- `references/log.md`

## Changelog

| 2026-07-23 | [OPENCODE] | v3.0.0 — **MAJOR SIMPLIFICATION**. Removed bw-env entirely (shell secret injection). bw CLI is now optional/minimal. Focus: bw-mcp + bw-proxy MCP tools + Bitwarden Desktop SSH Agent. Deleted all bw-env references, scripts/, and shell integration. |
| 2026-07-22 | [OPENCODE] | v2.7.0 — Restructured SSH Agent section per skill-infra-scope rule. |
| 2026-04-28 | [ANTIGRAVITY] | v2.4.0 - Added Fast Interface documentation. |
| 2026-04-24 | [GEMINI] | v2.3.0 - Implemented Agnostic Web Approval UI. |
| [SUMMARY] | — | v2.2.x distribution hardening; v2.1.2 naming; v2.1.0 bw-env anatomy; v2.0.0 initial dual-utility architecture; older → git history. |