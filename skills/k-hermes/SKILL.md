---
name: k-hermes
description: >
  KπX integration and governance for Hermes Agent (Persistent memory & Daemon).
  Use this to configure Hermes as a zero-trust headless cron executor and a cross-session
  memory layer reading from the KπX kernel.
license: private
metadata:
  author: KpihX
  version: "1.2.0"
  scope: external-agent
allowed-tools: Bash, Read, Write, Edit
---

# KπX — Hermes Integration (k-hermes)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Role

This skill governs the integration of **Hermes Agent** into the KπX sovereign ecosystem.
Hermes is used strictly as a **Memory Layer** and **Headless Daemon**, complementary to OpenCode.

## Architecture Map

```text
~/.hermes/                            <-- $HERMES_HOME (Isolated from KπX kernel)
├── config.yaml                       <-- Master config (MCPs, external_dirs)
├── SOUL.md                           <-- Symlink to ~/.agents/AGENTS.md
├── skills/                           <-- Sandbox for Hermes AUTO-GENERATED skills (Untrusted)
├── memories/                         <-- FTS5 SQLite + USER.md + MEMORY.md
└── profiles/
    └── cron/                         <-- Daemon profile (bash disabled, cron_mode approve)
```

## The Auto-Skill Governance (0-Trust)

Hermes has the ability to auto-generate skills based on successful interactions.
**RULE:** We DO NOT symlink `~/.hermes/skills` to `~/.agents/skills`.
- `~/.agents/skills` is **Production** (100% Control, strictly governed by `k-skill-creator`).
- `~/.hermes/skills` is **Staging/Sandbox** (AI-generated, untrusted).
- **Workflow:** Hermes writes its auto-skills to its own staging folder. KπX reviews them, standardizes them via `k-skill-creator`, and *promotes* them to the kernel if useful.

## Persistent Memory (USER.md)

Hermes passively updates two crucial files in `memories/` using a Honcho-style reflection loop:
- `USER.md`: Discovered user preferences, constraints, hardware specifics, and implicit rules.
- `MEMORY.md`: Key facts, ongoing background tasks, and session summaries.

## Assets & Wrappers

- `assets/hermes.sh` : The sovereign wrapper injecting `$HERMES_HOME`.
- Symlinked to `~/.local/bin/hermes`.
- The symlink overrides any system-level `hermes` binary (e.g., from pip). To use the system Hermes instead, invoke it directly via full path.

## Usage Commands

- **Interactive Co-Pilot:** `hermes chat`
- **Headless Daemon:** `hermes run "<prompt>" --profile cron`

## Multi-Provider Configuration

Hermes defaults to a single provider (`model.provider` in config.yaml). To unlock all AI providers available on the KπX workstation, configure additional providers under the `providers:` key. This section documents the discovery methodology and registration pattern.

### Provider Discovery — cross-agent reconnaissance

To find every AI provider available before configuring Hermes:

1. **Check OpenCode auth store** — the richest source of credentials:
   ```
   cat ~/.local/share/opencode/auth.json
   ```
   Lists every provider OpenCode has connected to (API key + OAuth).

2. **Check OpenClaw config** — second richest source:
   ```
   cat ~/.openclaw/openclaw.json | jq '.models.providers | keys'
   read -r sec <~/.openclaw/.env && echo "$sec"
   cat ~/.openclaw/gateway.systemd.env
   ```

3. **Check per-agent .env files** (agents stash keys independently):
   ```
   find ~ -maxdepth 2 \( -name ".env" -o -name "*.env" \) | while read f; do echo "$f:"; head -3 "$f"; done
   ```

4. **Check shell environment** for key env vars:
   ```
   env | grep -iE '_KEY|_TOKEN|_SECRET|API_KEY'
   ```

5. **Check VIBE** `~/.vibe/config.toml` — has explicit `[[providers]]` + `api_key_env_var` entries.

6. **Check Codex** `~/.codex/config.toml` — may reference `bearer_token_env_var` on MCPs.

7. **Check Continue** `~/.continue/config.yaml` — IDE plugin with explicit model+provider+apiKey.

### Known Provider Inventory (KπX workstation)

| Provider | Auth type | Credential location(s) | Base URL |
|----------|-----------|----------------------|----------|
| **opencode-go** | API key | `auth.json`, shell `$OPENCODE_API_KEY` | `https://opencode.ai/zen/go/v1` |
| **opencode** | API key | Same as opencode-go | `https://opencode.ai/zen/v1` |
| **openrouter** | API key | `auth.json`, `~/.openclaw/.env` | `https://openrouter.ai/api/v1` |
| **mistral** | API key | `auth.json`, `~/.vibe/.env`, `~/.continue/.env` | `https://api.mistral.ai/v1` |
| **venice** | API key | `auth.json`, shell `$VENICE_API_KEY` | `https://api.venice.ai/api/v1` |
| **openai** | API key | `auth.json` | `https://api.openai.com/v1` |
| **google/gemini** | OAuth | `auth.json` (refresh + access tokens) | Gemini-native |
| **github-copilot** | OAuth | `auth.json` (gho tokens) | GitHub ACP |
| **ollama** | None (local) | auto — `http://localhost:11434/v1` | local |
| **llamacpp** | None (local) | auto — `http://127.0.0.1:8080/v1` | local |

### Provider Registration (config.yaml)

Add to `~/.hermes/config.yaml`:

```yaml
providers:
  mistral:
    api_base: https://api.mistral.ai/v1
    api_key_env: MISTRAL_API_KEY
    api_mode: chat_completions
  venice:
    api_base: https://api.venice.ai/api/v1
    api_key_env: VENICE_API_KEY
    api_mode: chat_completions
  openrouter:
    api_base: https://openrouter.ai/api/v1
    api_key_env: OPENROUTER_API_KEY
    api_mode: chat_completions
  ollama:
    api_base: http://localhost:11434/v1
    api_key_env: ""
    api_mode: chat_completions
```

Then switch the active model:

```yaml
model:
  provider: venice
  name: deepseek-v3.2
  base_url: https://api.venice.ai/api/v1
```

Or toggle via CLI: `hermes config set model.provider venice && hermes config set model.name deepseek-v3.2`

### Profile-per-Provider pattern

Create dedicated profiles so switching provider doesn't clobber config:

```
~/.hermes/profiles/
├── default/config.yaml
├── venice/config.yaml
├── mistral/config.yaml
├── ollama/config.yaml
└── openrouter/config.yaml
```

Each profile needs only its own `model:` + `providers:` block. Launch with:
```
hermes --profile venice chat
hermes --profile ollama run "analyze this log"
```

### Credential injection

Hermes reads API keys from environment variables. On KπX workstation:

- `VENICE_API_KEY` — already in shell env
- `MISTRAL_API_KEY` — needs export (stored in `~/.vibe/.env`)
- `OPENROUTER_API_KEY` — needs export (stored in `~/.openclaw/.env`)
- `EXA_API_KEY` — needed for web search MCP

Source strategy:
```bash
eval $(grep -v '^#' ~/.openclaw/.env | xargs -d '\n')
```

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
uv pip install --python /home/kpihx/.local/share/uv/tools/hermes-agent/bin/python \
  fastapi uvicorn websockets python-multipart aiofiles

# 3. Copier dashboard_auth (module principal + plugins)
HERMES_SITE=/home/kpihx/.local/share/uv/tools/hermes-agent/lib/python3.12/site-packages
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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-06-05 | [OPENCODE] | v1.3.0 — Migrated HERMES_HOME from ~/.agents/hermes to ~/.hermes. Updated wrapper, all path references, and architecture map. |
| 2026-06-04 | [OPENCODE] | v1.2.0 — Added Web Dashboard (pip gap) section: dashboard_auth manquant dans le wheel PyPI, workaround copie depuis le repo, dépendances web, erreur de downgrade. |
| [SUMMARY] | | |
