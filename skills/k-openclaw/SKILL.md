---
name: k-openclaw
description: OpenClaw runtime — install/config, Tailscale Serve access, and KπX kernel integration.
license: private
metadata:
  author: KpihX
  version: "3.12.0"
  scope: agent-runtime
  target-agent: openclaw
allowed-tools: Bash, Read, Write, Edit
---

# OpenClaw — Runtime (Active)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **OS references:** `references/ubuntu.md` (systemd service, gateway env) · `references/windows.md` (WSL setup, manual gateway)

## Status

- **State:** active (reintroduced on 2026-05-26)
- **Gateway access (tailnet):** Tailscale Serve + identity auth (no repeated token entry on mobile)
- **Archive:** prior retirement history condensed in this skill's changelog

## Source-of-truth paths

- **OpenClaw config:** `$HOME/.openclaw/openclaw.json`
- **OpenClaw agent state:** `$HOME/.openclaw/agents/`
- **Gateway service:** `$HOME/.config/systemd/user/openclaw-gateway.service` (symlink → `assets/openclaw-gateway.service`)
- **Gateway ExecStart override:** `~/.config/systemd/user/openclaw-gateway.service.d/exec-override.conf` (symlink → `assets/exec-override.conf`) — overrides `ExecStart` and `PATH` to use openclaw CLI + fnm node
- **KπX global kernel (source + OpenClaw workspace):** `$HOME/.agents/` (= `$HOME/KpihX-Labs/.agents/` git root; `$HOME/.agents` → symlink)
- **OpenClaw workspace:** `agents.defaults.workspace = ~/.agents` — injects **`$HOME/.agents/AGENTS.md`** directly (no copy, no desync)
- **Legacy mirror (symlink only):** `$HOME/.openclaw/workspace/AGENTS.md` → `$HOME/KpihX-Labs/.agents/AGENTS.md` (not used by gateway)
- **Repo convenience:** `$HOME/KpihX-Labs/AGENTS.md` → `$HOME/KpihX-Labs/.agents/AGENTS.md`
- **OpenClaw Telegram bot:** `@kpihx_openclaw_bot` (id **8948919586**) — **not** `@k_ubuntu_bot` (infra-only)

## Telegram (KπX)

| Item | Value |
|------|--------|
| Bot | **OpenClaw** · `@kpihx_openclaw_bot` · id **8948919586** |
| Token env | `TELEGRAM_BOT_TOKEN` in `$HOME/.config/openclaw/gateway.env` |
| Ephemeral export | `/tmp/claw.env` (chmod 600; import to Vault then delete) |
| DM access | `channels.telegram.dmPolicy = allowlist` + `allowFrom: [1397540599]` — **no pairing** for owner |
| Client folder | Telegram chat folder **KpihX-Labs** (filter id **11**) — bot DM pinned at top (not a Telegram group) |
| Legacy | `@k_ubuntu_bot` — workstation infra (`bot.py`); do **not** point OpenClaw gateway at it |

## Context injection — équivalent `GEMINI.md` (general, indépendant du CWD)

OpenClaw **n'a pas** un seul fichier global type `~/.gemini/GEMINI.md`. Il injecte un **bundle workspace** configuré dans `~/.openclaw/openclaw.json` → `agents.defaults.workspace`.

**KπX :** `agents.defaults.workspace = ~/.agents` — le kernel `$HOME/.agents/AGENTS.md` est la **source unique** injectée à chaque session. Pas de `cp` vers un autre workspace.

Le gateway systemd lit cette config ; **le répertoire courant au lancement n'a aucun effet**.

### Fichiers MD injectés à chaque session (Project Context)

| Fichier | Rôle |
|---------|------|
| `AGENTS.md` | Instructions opérationnelles / kernel (équivalent le plus proche de `GEMINI.md`) |
| `SOUL.md` | Persona, ton, limites |
| `TOOLS.md` | Notes outils locales |
| `IDENTITY.md` | Nom / emoji agent |
| `USER.md` | Profil utilisateur |
| `HEARTBEAT.md` | Checklist tâches périodiques |
| `BOOTSTRAP.md` | Rituel premier run uniquement (supprimer après) |
| `MEMORY.md` | Mémoire long terme (si présent) |

`memory/*.md` **n'est pas** injecté automatiquement (accès via outils mémoire).

Docs : https://docs.openclaw.ai/concepts/agent-workspace · https://docs.openclaw.ai/concepts/system-prompt

### Config KπX (limits + injection)

```bash
openclaw config set agents.defaults.workspace '~/.agents'
openclaw config set agents.defaults.skipBootstrap true
openclaw config set agents.defaults.contextInjection always
openclaw config set agents.defaults.bootstrapMaxChars 60000
openclaw config set agents.defaults.bootstrapTotalMaxChars 150000
openclaw gateway restart
```

Bootstrap persona files (`SOUL.md`, `TOOLS.md`, `IDENTITY.md`, `USER.md`, `HEARTBEAT.md`) vivent aussi sous `$HOME/.agents/` (copiés une fois depuis le template OpenClaw si absents).

### Symlinks AGENTS (une seule source, zéro duplicate)

| Chemin | Type |
|--------|------|
| `$HOME/.agents/AGENTS.md` | **Fichier réel** — éditer ici |
| `$HOME/KpihX-Labs/AGENTS.md` | Symlink → `.agents/AGENTS.md` |
| `$HOME/.openclaw/workspace/AGENTS.md` | Symlink → `.agents/AGENTS.md` (legacy / éditeur) |

**Ne jamais** `ln -sf "$HOME/.agents/AGENTS.md" "$HOME/.agents/AGENTS.md"` (boucle).

OpenClaw **rejette** les symlinks bootstrap dont la cible sort du workspace. Avec `workspace=~/.agents`, `AGENTS.md` est un **fichier réel in-place** — pas de problème. Ne pas pointer le workspace vers `~/.openclaw/workspace` avec un AGENTS symlinké hors boundary.

### Forcer une session fraîche (après config ou copie AGENTS)

Les sessions Telegram gardent d'anciennes limites bootstrap tant qu'elles ne sont pas réinitialisées :

- Envoyer **`/new`** au bot (trigger par défaut), **ou**
- Supprimer l'entrée `agent:main:telegram:direct:<userId>` dans `~/.openclaw/agents/main/sessions/sessions.json`

### Vérifier l'injection

- Telegram : demander le `name:` du frontmatter YAML → attendu **`kpihx-agents`**
- Session store : `injectedWorkspaceFiles` → `AGENTS.md` `truncated: false`, `injectedChars` ≈ 37500+ (sans frontmatter)
- Control UI / chat : commande **`/context list`**

## Assets

| Asset | Role |
|-------|------|
| `assets/openclaw-gateway.service` | Systemd service (symlink target for `~/.config/systemd/user/`) |
| `assets/exec-override.conf` | Systemd drop-in — overrides ExecStart and PATH |
| `assets/openclaw-opencode` | CLI script: sync OpenCode models into OpenClaw config. Symlinked as `~/.local/bin/openclaw-opencode`. |

### Ecosystem Tools

| Tool | Role | Source |
|------|------|--------|
| **ClawHub** (`clawhub`) | Public skill registry — discover, install, and publish OpenClaw skills/extensions | `npm i -g clawhub` or pnpm global |
| **MCPorter** (`mcporter`) | MCP server management for OpenClaw — discover, configure, call, and debug MCP servers. OpenClaw agents use mcporter to access external MCP servers (HTTP, SSE, stdio). See [docs](https://docs.openclaw.ai/cli/mcp). | `npm i -g mcporter` or pnpm global |
| **OpenClaw MCP** (`openclaw mcp ...`) | Native MCP server registry — `list`, `add`, `set`, `probe`, `doctor`, etc. Manages OpenClaw's own `mcp.servers` entries (does not read mcporter config). | Built-in |

Note: `openclaw mcp list` reads OpenClaw-managed servers only. Use `mcporter list` for the mcporter-managed registry.

## Installation (this workstation)

- OpenClaw is installed globally via pnpm. Verify:
  - `command -v openclaw`
  - `openclaw --version`

## Recommended gateway topology (KπX)

### Goals

- Keep the Gateway bound to loopback.
- Expose it to the tailnet through **Tailscale Serve** (HTTPS).
- Allow authentication via **Tailscale identity** to avoid re-entering the Gateway token on the phone.
- Keep the token as a fallback / break-glass credential.

### Required OpenClaw config keys

Use `openclaw config get ...` / `openclaw config set ...` (avoid editing JSON by hand):

- `gateway.bind = "loopback"`
- `gateway.port = 18789`
- `gateway.tailscale.mode = "serve"`
- `gateway.auth.mode = "token"`
- `gateway.auth.allowTailscale = true`
- `gateway.controlUi.allowedOrigins = ["https://<hostname>.ts.net"]`
- `gateway.tailscale.resetOnExit = false` (see Tailscale independence below)

### Required Tailscale state

- `tailscale serve status` must show:
  - `https://<hostname>.ts.net` → proxy `http://127.0.0.1:18789`
  - `https://<hostname>.ts.net:1443` → proxy `http://127.0.0.1:4097` (OpenCode Web)

### Gateway service (systemd user)

| Item | Valeur |
|------|--------|
| Service file | `~/.config/systemd/user/openclaw-gateway.service` (symlink → `assets/openclaw-gateway.service`) |
| Port local | `18789` (loopback) |
| Port Tailscale | `443` (auto via `tailscale.mode: serve`) |
| Drop-in | `~/.config/systemd/user/openclaw-gateway.service.d/env.conf` — env vars additionnels |
| Dépendance | Service **indépendant** d'opencode-web (plus de `Requires=` croisé) |

**Single source of truth :** le fichier vit dans `assets/openclaw-gateway.service`, symlinké vers `~/.config/systemd/user/`. Éditer l'asset, puis `systemctl --user daemon-reload && systemctl --user restart openclaw-gateway`.

### Tailscale independence (no port trampling)

OpenClaw manages its own Tailscale Serve route (443 → 18789) via `gateway.tailscale.mode: serve` in `openclaw.json`. However, by default OpenClaw will **reset the entire Tailscale Serve configuration on shutdown** (`resetOnExit: true`), wiping any other routes (e.g. OpenCode Web on 1443).

**Fix: `gateway.tailscale.resetOnExit = false`** in `~/.openclaw/openclaw.json`. This guarantees:

- OpenClaw only touches **its own port** (443) on startup.
- OpenClaw **never resets** other routes on shutdown.
- Zero coupling between services — each owns its own Tailscale route independently.
- Survives OpenClaw updates, restarts, and crashes.

Verify: `tailscale serve status` should show both routes after an OpenClaw restart.

Voir `k-tailscale/SKILL.md` pour la config tailscale serve et l'état des ports.

### Mobile access (no token re-entry)

1. Phone is connected to the same tailnet (Tailscale app ON).
2. Open `https://<hostname>.ts.net/` in the phone browser.
3. If device pairing is requested, approve on the host:
   - `openclaw devices list`
   - `openclaw devices approve <requestId>`

## Operational checks

- `openclaw gateway status`
- `openclaw status --deep`
- `openclaw doctor` and `openclaw doctor --fix`
- systemd service management: `openclaw-gateway.service` located at `~/.config/systemd/user/openclaw-gateway.service` (symlinked from `assets/openclaw-gateway.service`)

## Security note (secrets in config)

`openclaw doctor` warns when secrets are stored plaintext in `openclaw.json`.
Preferred hardening path:

- `openclaw secrets configure`
- `openclaw secrets apply`
- `openclaw secrets audit --check`

Current KπX runtime baseline (2026-05-27):

- gateway and telegram/exa/whisper credentials are on env SecretRefs
- auth profiles (`openai`) use env SecretRefs
- systemd injects env through:
  - `$HOME/.config/openclaw/gateway.env` (systemd user environment file)
  - `$HOME/.config/systemd/user/openclaw-gateway.service.d/env.conf` (additional environment overrides)
- Local runtime daemon configuration/secrets (such as CLI or manual execution) are read from:
  - `$HOME/.openclaw/.env` (contains primary secrets like `OPENCODE_API_KEY`)
  - `$HOME/.openclaw/gateway.systemd.env` (contains `OPENCODE_API_KEY` and `OPENCODE_ZEN_API_KEY`, referenced by the systemd service file `EnvironmentFile=-/home/kpihx/.openclaw/gateway.systemd.env`)
- keep `openclaw secrets audit` near-zero; if any plaintext remains, treat it as migration debt and clear it immediately

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-29 | [OPENCODE] | v3.12.0 — Removed Venice, Mistral, k-ai and OpenRouter from active auth profiles list to reflect configuration purge. |
| 2026-07-29 | [OPENCODE] | v3.11.0 — Documented systemd service name and path under Operational checks. |
| [SUMMARY] | — | v3.10.0 env files docs; v3.9.0–v3.8.0 Assets & Ecosystem Tools section (ClawHub, MCPorter, OpenClaw MCP, openclaw-opencode); v3.7.0 `resetOnExit: false`; v3.6.0 SSOT service file; v3.5.0 Port Tailscale 443→1443; v3.4.0 OpenClaw workspace kernel inject; v3.3.0 context injection; v3.2.0–v3.0.0 Telegram bot migration, secrets hardening. v2.x condensed. |
