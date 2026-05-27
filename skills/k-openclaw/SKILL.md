---
name: k-openclaw
description: OpenClaw runtime — install/config, Tailscale Serve access, and KπX kernel integration.
license: private
metadata:
  author: KpihX
  version: "3.4.0"
  scope: agent-runtime
  target-agent: openclaw
allowed-tools: Bash, Read, Write, Edit
---

# OpenClaw — Runtime (Active)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Status

- **State:** active (reintroduced on 2026-05-26)
- **Gateway access (tailnet):** Tailscale Serve + identity auth (no repeated token entry on mobile)
- **Archive:** prior retirement notes remain in `$HOME/.agents/skills/deactive/k-openclaw/`

## Source-of-truth paths

- **OpenClaw config:** `$HOME/.openclaw/openclaw.json`
- **OpenClaw agent state:** `$HOME/.openclaw/agents/`
- **Gateway service:** `$HOME/.config/systemd/user/openclaw-gateway.service`
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

### Required Tailscale state

- `tailscale serve status` must show:
  - `https://<hostname>.ts.net` → proxy `http://127.0.0.1:18789`

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

## Security note (secrets in config)

`openclaw doctor` warns when secrets are stored plaintext in `openclaw.json`.
Preferred hardening path:

- `openclaw secrets configure`
- `openclaw secrets apply`
- `openclaw secrets audit --check`

Current KπX runtime baseline (2026-05-27):

- gateway and telegram/exa/whisper credentials are on env SecretRefs
- auth profiles (`openai`, `mistral`, `venice`) use env SecretRefs
- systemd injects env through:
  - `$HOME/.config/openclaw/gateway.env`
  - `$HOME/.config/systemd/user/openclaw-gateway.service.d/env.conf`
- keep `openclaw secrets audit` near-zero; if any plaintext remains, treat it as migration debt and clear it immediately

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-27 | [CURSOR] | v3.4.0 — OpenClaw workspace = `~/.agents` (kernel inject direct); bootstrap MD in `.agents/`; AGENTS symlinks unifiés (KpihX-Labs + legacy openclaw workspace); limits 60k/150k; verified Telegram inject. |
| 2026-05-27 | [CURSOR] | v3.3.0 — doc context injection; bootstrap limits; `/new` refresh; dedicated bot `@kpihx_openclaw_bot`. |
| [SUMMARY] | — | v3.2.0–v3.0.0: Telegram bot migration, secrets hardening, Tailscale Serve reactivation. v2.x archived under `skills/deactive/k-openclaw/`. |
