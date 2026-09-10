---
name: k-hermes
description: >
  integration and governance for Hermes Agent (Persistent memory & Daemon).
  Use this to configure Hermes as a zero-trust headless cron executor and a cross-session
  memory layer reading from the  kernel.
license: private
metadata:
  author: 
  version: "1.0.0"
  scope: external-agent
allowed-tools: Bash, Read, Write, Edit
---

#  — Hermes Integration (k-hermes)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

## Role

This skill governs the integration of **Hermes Agent** into the  sovereign ecosystem.
Hermes is used strictly as a **Memory Layer** and **Headless Daemon**, complementary to OpenCode.

## Architecture Map

```text
~/.hermes/                            <-- $HERMES_HOME (Isolated from the user kernel)
├── config.yaml                       <-- Master config (MCPs, external_dirs)
├── SOUL.md                           <-- Symlink to ~/.agents/AGENTS.md
├── skills/                           <-- Sandbox for Hermes AUTO-GENERATED skills (Untrusted)
├── memories/                         <-- FTS5 SQLite + USER.md + MEMORY.md
└── profiles/
    └── cron/                         <-- Daemon profile (bash disabled, cron_mode approve)
```

## Clean Runtime Reset (2026-08-24)

Hermes mutable runtime state belongs **only** in `$HOME/.hermes/`, never under `$HOME/.agents/`. The prior duplicate homes were preserved temporarily before a clean reinstall.

The complete rebuild procedure, canonical links, provider profiles, and smoke commands are in `references/setup.md`.

- Canonical non-secret configuration: `assets/config.yaml` → `$HOME/.hermes/config.yaml`.
- Kernel identity: `$HOME/.hermes/SOUL.md` → `$HOME/.agents/AGENTS.md`.
- User memory bridge: `$HOME/.hermes/memories/USER.md` → `skills/kpihx/SKILL.md`.
- Gateway service: canonical asset remains `assets/hermes-gateway.service`; stock Hermes defaults natively to `$HOME/.hermes`, so no `HERMES_HOME` override is set.

### Supported provider profiles

Only two provider profiles are configured:

| Profile | Provider | Default model | Configuration asset |
|---|---|---|---|
| `ollama` | Local Ollama | `phi4-mini:latest` | `assets/profiles/ollama/config.yaml` |
| `opencode-go` | OpenCode Go | `mimo-v2.5` | `assets/profiles/opencode-go/config.yaml` |

The local Ollama inventory at reset time is `phi4-mini:latest`, `qwen3:latest`, and `qwen2.5:latest`. Use `hermes --profile ollama …` or `hermes --profile opencode-go …`; the latter requires the existing `OPENCODE_API_KEY` environment variable and is never stored in the kernel.

## The Auto-Skill Governance (0-Trust)

Hermes has the ability to auto-generate skills based on successful interactions.
**RULE:** We DO NOT symlink `~/.hermes/skills` to `~/.agents/skills`.
- `~/.agents/skills` is **Production** (100% Control, strictly governed by `k-skill-creator`).
- `~/.hermes/skills` is **Staging/Sandbox** (AI-generated, untrusted).
- **Workflow:** Hermes writes its auto-skills to its own staging folder.  reviews them, standardizes them via `k-skill-creator`, and *promotes* them to the kernel if useful.

## Persistent Memory (USER.md)

Hermes passively updates two crucial files in `memories/` using a Honcho-style reflection loop:
- `USER.md`: Discovered user preferences, constraints, hardware specifics, and implicit rules.
- `MEMORY.md`: Key facts, ongoing background tasks, and session summaries.

## Assets

- `assets/hermes-gateway.service` : Systemd user service for the Hermes Gateway daemon.
  Symlinked to `~/.config/systemd/user/hermes-gateway.service`.
- The stock UV-installed `$HOME/.local/bin/hermes` executable is intentionally not a `.agents` link or wrapper.

### Hermes Gateway — systemd user service

```bash
# Symlink from .agents (source of truth)
systemctl --user stop hermes-gateway.service
ln -sf ~/.agents/skills/k-hermes/assets/hermes-gateway.service ~/.config/systemd/user/hermes-gateway.service
systemctl --user daemon-reload
systemctl --user enable --now hermes-gateway.service

# Logs
journalctl --user -u hermes-gateway.service -f
```

## Usage Commands

- **Interactive Co-Pilot:** `hermes chat`
- **Headless Daemon:** `hermes run "<prompt>" --profile cron`

## Provider Configuration

Hermes exposes only the local Ollama and OpenCode Go profiles above. The main configuration defaults to local `ollama` with `phi4-mini:latest`; select `opencode-go` explicitly when `mimo-v2.5` is required.

### Provider selection

Use the profile explicitly:

```bash
hermes --profile ollama chat
hermes --profile opencode-go chat
```

### Provider Registration (config.yaml)

The canonical main configuration is `assets/config.yaml`, symlinked to `~/.hermes/config.yaml`:

```yaml
providers:
  ollama:
    api_base: http://localhost:11434/v1
    api_key_env: ""
    api_mode: chat_completions
```

The OpenCode Go profile switches the active model:

```yaml
model:
  provider: opencode-go
  name: mimo-v2.5
  base_url: https://opencode.ai/zen/go/v1
```

Do not use CLI config edits against the symlinked canonical files; update the asset and the registered link instead.

### Profile-per-Provider pattern

The two dedicated profiles prevent switching from clobbering the default configuration:

```
~/.hermes/profiles/
├── default/config.yaml
├── ollama/config.yaml
└── opencode-go/config.yaml
```

Each profile has its own `model:` + `providers:` block and is a registered symlink to its `k-hermes/assets/profiles/` source.

### Credential injection

Only OpenCode Go requires credentials: `OPENCODE_API_KEY` must already be present in the invoking environment. Agents never read, print, or source secret files.

## Web Dashboard (pip gap)

`hermes dashboard` ne marche pas out-of-the-box avec le package PyPI (`hermes-agent`).
Le module `hermes_cli.dashboard_auth` et les plugins `plugins/dashboard_auth/*` (nous, basic, self_hosted)
sont présents dans le repo GitHub mais absents du wheel publié.

### Symptômes

```
ModuleNotFoundError: No module named 'hermes_cli.dashboard_auth'
```

### Workaround — copie manuelle depuis le repo

```bash
# 1. Cloner le repo
cd /tmp && git clone --depth 1 https://github.com/NousResearch/hermes-agent.git

# 2. Installer les dépendances web dans l'environnement uv du tool
uv pip install --python $HOME/.local/share/uv/tools/hermes-agent/bin/python \
  fastapi uvicorn websockets python-multipart aiofiles

# 3. Copier dashboard_auth (module principal + plugins)
HERMES_SITE=$HOME/.local/share/uv/tools/hermes-agent/lib/python3.12/site-packages
cp -r /tmp/hermes-agent/hermes_cli/dashboard_auth $HERMES_SITE/hermes_cli/dashboard_auth/
cp -r /tmp/hermes-agent/plugins/dashboard_auth $HERMES_SITE/plugins/dashboard_auth/

# 4. Nettoyer
rm -rf /tmp/hermes-agent
```

### Kanban — init + dashboard

```bash
hermes kanban init              # crée ~/.hermes/kanban.db
hermes dashboard                # ouvre http://127.0.0.1:9119 (Kanban tab)
```

### Erreur de version vue dans le process

`uv pip install -e /tmp/hermes-agent` a downgradé v0.15.2 → v0.15.1.
Toujours réinstaller depuis le canal officiel après :
```bash
uv tool install --reinstall hermes-agent
```

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-hermes/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-hermes/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

