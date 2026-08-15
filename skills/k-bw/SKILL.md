---
name: k-bw
description: "BW-Proxy operational memory - KpihX Bitwarden Sovereign Management: self-hosted Vaultwarden (@docker-host) and AI-blind vault proxy. Load before any bw-proxy work. (bw-mcp/bw-admin purged 2026-08-14 — see references/purged.md)."
license: private
metadata:
  author: KpihX
  version: "3.1.0"
  allowed-tools: Bash(tmux:*)
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

### 2. `bw-mcp` (MCP Server) — PURGED 2026-08-14

- **State:** removed. Binaries `bw-mcp` + `bw-admin` were purged from `~/.local/bin` (broken symlinks to absent `/opt/bw-mcp`), apparmor profile removed, config gone.
- **Archive:** full historical `bw-mcp` reference preserved in `references/purged.md` (never deleted, GRAVÉ).
- **Active tool:** `bw-proxy` remains the sovereign vault proxy (see section 1 above).

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

- `references/purged.md` (bw-mcp/bw-admin archive)
- `references/insights.md`
- `references/log.md`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-14 | [COLAB] | v3.1.0 — **Purged `bw-mcp` + `bw-admin`** (broken symlinks to absent `/opt/bw-mcp`); archived full reference in `references/purged.md` (GRAVÉ); kept `bw-proxy` as the sovereign vault proxy. |
| 2026-07-23 | [OPENCODE] | v3.0.0 — **MAJOR SIMPLIFICATION**. Focus: bw-mcp + bw-proxy MCP tools + Bitwarden Desktop SSH Agent. |
| [SUMMARY] | — | v2.7.0 SSH Agent restructure · v2.4.0 Fast Interface · v2.3.0 Agnostic Web Approval UI (→ `references/log.md`) · v2.2.x distribution hardening; v2.1.2 naming; v2.1.0 anatomy; v2.0.0 initial dual-utility architecture; older → git history. |