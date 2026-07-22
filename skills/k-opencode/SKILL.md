---
name: k-opencode
description: >
  OpenCode CLI runtime — global config (opencode.jsonc), AGENTS/skills symlink wiring,
  MCP local/remote config, provider auth flow, and operational verification commands.
  Load when installing OpenCode, configuring MCPs, or debugging OpenCode runtime behavior.
  Registry in k-clis.
license: private
metadata:
  version: 1.16.0
  author: KpihX
  scope: agent-runtime
  target-agent: opencode
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — OpenCode CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Binary:** `$HOME/.opencode/bin/opencode`
- **Global config dir:** `$HOME/.config/opencode/`
- **Config file:** `$HOME/.config/opencode/opencode.jsonc`
- **Auth store:** `$HOME/.local/share/opencode/auth.json`
- **Global kernel symlinks (KπX):**
  - `$HOME/.config/opencode/AGENTS.md` → `$HOME/.agents/AGENTS.md`
  - `$HOME/.config/opencode/skills` → `$HOME/.agents/skills`
- **PATH source of truth:** `$HOME/.kshrc` (`export PATH="$HOME/.opencode/bin:$PATH"`)
- **Registry:** **`k-clis`**

## Session Storage (SQLite)

OpenCode stores all conversation history in a single SQLite database, not JSON files.

- **Database:** `$HOME/.local/share/opencode/opencode.db`
- **Size:** ~525 MB (as of 2026-07-21, ~15K messages across ~200 sessions)
- **WAL mode:** `opencode.db` + `opencode.db-wal` + `opencode.db-shm`

### Schema (core tables)

```sql
-- One row = one conversation
session(id, project_id, parent_id, slug, directory, title, version,
        time_created, time_updated, time_compacting, time_archived,
        workspace_id, path, agent, model,
        cost, tokens_input, tokens_output, tokens_reasoning,
        tokens_cache_read, tokens_cache_write, metadata)

-- One row = one message turn
session_message(id, session_id, type, time_created, time_updated,
                seq, data)
```

- `session.data` → `metadata` JSON column for extra session-level info.
- `session_message.data` → full message JSON text (tool calls, responses, file contents — the bulk of the 525 MB).
- `session_message.seq` → monotonically ordered per session.
- `session_message.type` → e.g. `"user"`, `"assistant"`, `"tool"`.
- All session data is cascade-deleted when a `session` row is removed.

### Query examples

```bash
# Session count, token totals, model usage
sqlite3 ~/.local/share/opencode/opencode.db "
  SELECT model, count(*) as sessions,
         sum(tokens_input) as total_input,
         sum(tokens_output) as total_output,
         sum(cost) as total_cost
  FROM session GROUP BY model ORDER BY total_cost DESC;"

# Recent sessions with message counts
sqlite3 ~/.local/share/opencode/opencode.db "
  SELECT s.id, s.title, s.model, s.time_created,
         (SELECT count(*) FROM session_message sm WHERE sm.session_id = s.id) as msgs
  FROM session s ORDER BY s.time_created DESC LIMIT 10;"
```

## Source Of Truth

| File | Role |
|------|------|
| `$HOME/.config/opencode/opencode.jsonc` | OpenCode runtime config (symlink → `assets/opencode.jsonc`) — model, permissions, MCPs |
| `$HOME/.config/opencode/AGENTS.md` | Global instruction kernel (symlink target: `$HOME/.agents/AGENTS.md`) |
| `$HOME/.config/opencode/skills/` | Skill discovery path (symlink target: `$HOME/.agents/skills/`) |
| `$HOME/.local/share/opencode/auth.json` | Provider login credentials |
| `$HOME/.config/opencode/agents/` | Agent discovery path (symlink target: `$HOME/.agents/agents/`) |

## Agent & Subagent System

OpenCode discovers agents from two sources that merge:

### 1. Config file (`opencode.jsonc` → `agent.*` or `agents.*`)

Primary agents are defined under the `agent` key:
```jsonc
"Colab": {
  "mode": "primary",                      // Tab-visible primary agent
  "prompt": "{file:~/.agents/agents/Colab/prompt.txt}"  // Prompt from raw text file
}
```
- `{file:path}` loads ANY text file (`.md`, `.txt`, etc.) — extension does not matter for prompt injection.
- Agents defined ONLY in config (no `.md` file) must have `mode: "primary"`.

### 2. Markdown files (`~/.config/opencode/agents/<path>/<name>.md`)

All `.md` files under the agents directory are auto-discovered. The file path becomes the agent ID:
```
agents/executor/agent.md   →   agent "executor/agent"
agents/Colab/prompt.md     →   agent "Colab/Prompt"
```

### Agent Modes

| Mode | Tab-visible? | Invocable via `task`? | Invocable via `@`? |
|------|-------------|----------------------|-------------------|
| `primary` | ✅ Yes | ❌ No | ❌ No |
| `subagent` | ❌ No | ✅ Yes | ✅ Yes (unless `hidden`) |
| `all` | ✅ Yes | ✅ Yes | ✅ Yes |

### Hide from UI

`hidden: true` hides a `mode: subagent` from the `@` autocomplete menu and Tab selector. The agent remains invocable via the `task` tool by parent agents.

### Permission format (V1 — still accepted in v1.18.x)

```yaml
permission:
  edit: allow           # "allow" | "ask" | "deny"
  bash: deny
  task: allow
  read: allow
  skill: allow
```

Extra fields (`id`, `scope`, `role`) are passed through as metadata — harmless.

### ⚠️ Critical: YAML frontmatter pitfalls (learned 2026-07-22)

gray-matter silently drops the **entire frontmatter** if YAML is malformed. No error, no warning — OpenCode loads the agent with `mode: all` default, making it Tab-visible.

**Known failures:**

| Error | Broken YAML | Effect |
|-------|------------|--------|
| Wrong indentation | `name: curator\n  version: "2.0.0"` | `version` becomes child of `name` → frontmatter silently dropped → `mode: subagent` lost → agent appears in Tab |
| Unquoted colon in value | `description: Reviews: returns verdict.` | YAML interprets `:` as mapping separator → frontmatter truncated |

**Rules:**
- All fields must be at the **same indentation level** (0 spaces for root keys)
- If a description contains `:`, quote it: `description: "Reviews code: quality check"`
- After editing frontmatter, **restart OpenCode** — old parse is cached per session
- Verify YAML with `python3 -c "import yaml; yaml.safe_load(open('file.md').read().split('---')[1])"`

### KπX Setup

| Agent | Definition | Mode | File |
|-------|-----------|------|------|
| `Colab` 🟢 | `opencode.jsonc` + `{file:.../Colab/prompt.txt}` | primary | `agents/Colab/prompt.txt` |
| `Explore` 🔵 | `opencode.jsonc` + `{file:.../Explore/prompt.txt}` | primary | `agents/Explore/prompt.txt` |
| `Build` | `opencode.jsonc` (`{}` — inherits global) | primary | `opencode.jsonc` only |
| `Lite` 🟠 | `opencode.jsonc` — Ollama local, no skills/MCPs | primary | `opencode.jsonc` only |
| `Auto` 🔴 | `opencode.jsonc` — `*: allow`, future-proof | primary | `opencode.jsonc` only |
| `Plan` | `opencode.jsonc` — read-only | primary | `opencode.jsonc` only |
| `executor/agent` 🛠️ | `agents/executor/agent.md` | subagent | `agents/executor/agent.md` |
| `curator/agent` 🧹 | `agents/curator/agent.md` | subagent | `agents/curator/agent.md` |
| `intent-guardian/agent` 👁️ | `agents/intent-guardian/agent.md` | subagent | `agents/intent-guardian/agent.md` |
| `pragmatic-checker/agent` ✅ | `agents/pragmatic-checker/agent.md` | subagent | `agents/pragmatic-checker/agent.md` |
| `fact-verifier/agent` 🔍 | `agents/fact-verifier/agent.md` | subagent | `agents/fact-verifier/agent.md` |

**Key rule:** Only agents with `mode: primary` or `mode: all` appear in Tab. Subagents with `mode: subagent` + `hidden: true` are invisible but usable via `task` tool delegation.

## MCP Config Format (OpenCode — JSONC)

OpenCode MCP servers are configured under the top-level `mcp` key in `opencode.jsonc`.

Local (stdio-equivalent) server:

```json
{
  "mcp": {
    "mail_fallback": {
      "type": "local",
      "command": ["zsh", "-l", "-c", "/home/kpihx/.local/bin/mail-mcp serve"],
      "enabled": true,
      "timeout": 60000
    }
  }
}
```

Remote HTTP server:

```json
{
  "mcp": {
    "exa": {
      "type": "remote",
      "url": "https://mcp.exa.ai/mcp",
      "oauth": false,
      "enabled": true
    }
  }
}
```

Remote bearer token via env variable:

```json
{
  "mcp": {
    "n8n_homelab": {
      "type": "remote",
      "url": "https://n8n.kpihx-labs.com/mcp",
      "headers": {
        "Authorization": "Bearer {env:N8N_HOMELAB_API_KEY}"
      },
      "enabled": false
    }
  }
}
```

## Verification Commands

```bash
zsh -l -c 'which opencode && opencode --version'
opencode debug config
opencode mcp list
opencode providers list
opencode models
```

## Operational Rules (KπX)

- Keep OpenCode runtime config centralized in `$HOME/.config/opencode/opencode.jsonc`; avoid per-project overrides unless explicitly requested.
- Prefer `zsh -l -c` wrappers for local MCP servers that need secret-bearing login-shell context.
- Do not hardcode secrets in `opencode.jsonc`; use `{env:VAR_NAME}` placeholders.
- Keep AGENTS/skills linked to `$HOME/.agents/` so OpenCode shares the same sovereign kernel as Codex, Vibe, Copilot, and Zed.

## Permission System (2026-05-30 — Confiance Totale)

OpenCode uses a 3-tier hierarchy: **Global config → Agent deltas → Session runtime**. Rules evaluated by `findLast` — last matching pattern wins.

### Architecture

- **Global default** (`permission`): Single source of truth — ALL bash patterns, MCP rules, external_directory
- **Agent blocks**: Define ONLY deltas from global (minimal, no duplication)
  - `Build`: `{}` — inherits everything from global
  - `Plan`: `edit: deny`, restricted bash (read-only)
  - `Colab`: only `task` delta — which sub-agents it can launch. edit/bash inherit from global (3-zone)
  - `Explore`: only `task` delta — which sub-agents it can launch. edit/bash inherit from global (3-zone)
  - `Lite`: `skill: deny`, all MCPs `deny`, `task: deny`. Bash/edit inherit from global.
  - `Auto`: `*: allow` — catches ALL tools, ALL sub-agents, ALL skills. Unrestricted.

### Global permission zones (bash)

| Zone | Niveau | Nb patterns | Exemples |
|------|--------|-------------|----------|
| 🟢 **Zone 1** | Read-only purs | 65+ | `echo`, `cat`, `head`, `grep`, `jq`, `find`, `stat`, `man`, `md5sum`, `shasum`, `tac`, `users`, `who`, `lscpu` |
| 🟡 **Zone 2** | Faible risque | 22 | `curl`, `wget`, `ping`, `dig`, `traceroute`, `ss`, `tmux`, `watch` |
| 🟠 **Zone 3** | Confiance | 50+ | `awk`, `git`, `docker`, `python3`, `ssh`, `rsync`, `make`, `tar`, `zip`, `ip`, `npm`, `node`, `tee` |
| 🔴 **Explicit Ask** | Dangereux | 35 | `rm`, `rmdir`, `shred`, `sed`, `pkill`, `sudo`, `chmod`, `dd`, `fdisk`, `systemctl`, `apt`, `passwd` |

### MCP permissions

Wildcard allows all, specific destructive tools override to `ask` (last match wins):

- `chrome-agent_*`: `allow`
- `mail_fallback_*`: `allow` + `send_message`, `reply_message`, `forward_message`, `delete_messages`, `delete_folder`, `trash_messages`: `ask`
- `tick_fallback_*`: `allow` + `delete_task`, `delete_project`, `delete_tag`, `delete_habit`, `delete_query_preset`, `batch_delete_tasks`, `merge_tags`: `ask`

### `external_directory` — 11 paths allow

`~/.agents/**`, `~/.config/opencode/**`, `/tmp/**`, `~/Downloads/**`, `~/Pictures/**`, `~/Gdrive_X/**`, `~/Gdrive/**`, `~/KpihX-Labs/**`, `~/Work/**`, `~/.config/nvim/**`, `~/.local/share/nvim/**`

### Plugins

OpenCode supports a `plugin` array in `opencode.jsonc` for lifecycle hooks. Standard plugins + KπX-managed hooks:

```jsonc
"plugin": [
  "opencode-dir",
  "opencode-ssh-session",
  "opencode-antigravity-auth@latest",   // Claude + Gemini via Google OAuth (free)
  "file:///home/kpihx/.agents/hooks/opencode/suggestions-check.js",
  "file:///home/kpihx/.agents/hooks/opencode/startup-context.js"
]
```

#### KπX Managed — `hooks/opencode/`

These are the **KπX sovereign hooks** — small standalone plugins in `~/.agents/hooks/opencode/`. Each is a self-contained `.js` file listed via `file://` URL in the plugin array (order matters).

| File | Event | Agent filter | Behavior |
|------|-------|-------------|----------|
| `suggestions-check.js` | `messages.transform` (every turn) | Colab, Build | Injects system message: ≥3 Suggestions required |
| `startup-context.js` | `messages.transform` (first turn only) | Colab, Build | Injects raw `k-context/SKILL.md` + device infra skill (auto-detected via tailscale status → `assets/infras.json` → k-* skill lookup) |

**Agent detection:** Both plugins capture the agent name from `session.created` event (`info.agent`) at session start. Non-matching agents (Explore, Lite, Auto, Plan) get zero overhead — plugins return silently.

**Execution order (plugin array order matters):**
1. `suggestions-check` fires → pushes format reminder at end of messages
2. `startup-context` fires → unshifts context block at start of messages

Resulting message order: `[0] raw context (k-context + device infra)`, `[1] format reminder`, `[2...] user messages`.

**Device auto-detection pipeline:**
```
tailscale status --json → Self.DNSName → assets/infras.json lookup → skills/<k-*>/SKILL.md read
Fallback: os.hostname() if tailscale unavailable
```

**Source files:** `~/.agents/hooks/opencode/` — tracked in `.agents` git repo, auto-deployed on push.

### Voice (TUI — @renjfk/opencode-voice)

STT + TTS 100% local. Config dans `tui.json` (pas `opencode.jsonc`).

```jsonc
// ~/.config/opencode/tui.json
{
  "$schema": "https://opencode.ai/tui.json",
  "plugin": [["@renjfk/opencode-voice", {}]]
}
```

**Dependencies:** sox, whisper-cli (Vulkan GPU build), piper-tts, ffplay/mpv
**Models:**
- Whisper: `~/.local/share/whisper-cpp/` — see `references/voice.md` for full model list, install, and management
- Piper EN: `~/.local/share/piper-voices/en_US-ryan-high.onnx`
- Piper FR: `~/.local/share/piper-voices/fr_FR-siwis-medium.onnx`

**Keybinds (patched — see Insights & `references/voice.md`):**
| Action | Keybind |
|--------|---------|
| STT record | `<leader>r` (Ctrl+X R) |
| TTS speak | `<leader>s` (Ctrl+X S) |
| Auto TTS | `<leader>v` (Ctrl+X V) |
| Stop audio | `Escape` |
| Switch STT model | `/stt-model` → `large-v3-turbo-q5_0` |
| Switch TTS voice | `/tts-voice` → `ryan` (EN) or `siwis` (FR) |

**Patches in cache (re-apply after plugin update):**
- `stt.js` L385: `ctrl+r` → `<leader>r` (avoid rename conflict)
- `stt.js` L339: remove `toast("Normalizing...")` notification
- `tts.js` L266: `llmResult.text || result.text` fallback (no LLM = use raw text)
- `tts.js` L298: same fallback for manual speak
- `tts.js` L312: `<leader>s` keybind
- `tts.js` TTS_VOICES: added `siwis` (FR)

**No LLM endpoint** — without `endpoint` in plugin options, normalization is skipped and raw whisper text is used directly.

### Provider: Ollama (local)

```jsonc
"provider": {
  "ollama": {
    "npm": "@ai-sdk/openai-compatible",
    "name": "Ollama (local)",
    "options": { "baseURL": "http://localhost:11434/v1" },
    "models": {
      "qwen3", "qwen2.5", "qwen2.5-coder", "llama3.1", "phi4-mini"
    }
  }
}
```

Auto-synced by `~/.local/bin/ollama-models-sync` after `ollama pull`/`rm` (zsh hook in `.kshrc`).

### Utilisation

- Les commandes non listées tombent sur `"bash": "ask"` global — elles popent en approval
- Pour ajouter un pattern : l'insérer dans la bonne zone (allow avant ask) dans `opencode.jsonc`
- `findLast` gagnant : le dernier pattern qui match l'emporte
- Source de vérité : `$HOME/.config/opencode/opencode.jsonc`

### tmux reload pattern

`Ctrl+A r` — kills current process in pane, relaunches with last shell command from history. Configured in `~/.tmux.conf`:
```bash
bind r send-keys C-c \; run-shell "sleep 0.5" \; send-keys Up Enter
```

## Neovim Integration

OpenCode integrates with Neovim via `nickjvandyke/opencode.nvim` (the active fork).

| Item | Value |
|------|-------|
| Plugin | `nickjvandyke/opencode.nvim` (Lazy-loaded) |
| Config file | `$HOME/.config/nvim/lua/kpihx/opencode.lua` |
| Deps | `folke/snacks.nvim` (input + picker) |
| Key | Action |
| `<C-a>` (visual) | `opencode.ask("@this: ", { submit = true })` |
| `<C-x>` (visual) | `opencode.select()` |
| `<C-.>` (n/t mode) | `opencode.toggle()` |

**Requires:** `opencode` binary in `$PATH` (sourced via `$HOME/.kshrc`).

## OpenCode Web (systemd + Tailscale Serve)

OpenCode Web runs as a persistent systemd user service, exposed via `tailscale serve` sur le port HTTPS 1443 *(443 est réservé par OpenClaw)*.

| Item | Value |
|------|-------|
| Service file | `$HOME/.config/systemd/user/opencode-web.service` (symlink → `assets/opencode-web.service`) |
| WorkingDirectory | `%h` (systemd specifier → `$HOME`). **Ne pas changer** — `opencode` détecte le worktree automatiquement, forcer un sous-dossier n'unifie pas les historiques et peut casser les chemins relatifs des MCPs enfants. |
| Port (local) | `4097` (localhost only) |
| Tailscale URL | `https://kpihx-ubuntu.tail2527bd.ts.net:1443/` |
| Indépendance | Service **découplé** de `openclaw-gateway` — plus de `Requires=` |
| Password env | `$HOME/.config/opencode/web.env` (mode `600`) |

**Password status:** Currently **disabled** (EnvironmentFile line commented out in service). To re-enable:
1. Uncomment `EnvironmentFile=%h/.config/opencode/web.env` in the service file
2. Adjust the health check ExecStartPost to accept HTTP 401 (see commented-out version in service file history)
3. `systemctl --user daemon-reload && systemctl --user restart opencode-web`

**Commands:**
```bash
systemctl --user status opencode-web     # status
systemctl --user restart opencode-web    # restart
journalctl --user -u opencode-web -f     # live logs
tailscale serve status                   # verify tailscale proxy
```

**Service file** (`~/.config/systemd/user/opencode-web.service`):
```ini
[Unit]
Description=OpenCode Web Server
After=network.target

[Service]
Type=simple
WorkingDirectory=%h
ExecStart=/home/kpihx/.opencode/bin/opencode serve --port 4097 --hostname 127.0.0.1
ExecStartPost=/bin/sh -c 'for i in 1 2 3 4 5 6 7 8 9 10; do curl -sf http://127.0.0.1:4097/ && exit 0; sleep 1; done; exit 1'
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

**Single source of truth :** le fichier vit dans `assets/opencode-web.service`, symlinké vers `~/.config/systemd/user/`. Éditer l'asset, puis `systemctl --user daemon-reload && systemctl --user restart opencode-web`.

Le post-commit hook `.git/hooks/post-commit` détecte automatiquement les changements sur :
- `assets/opencode-web.service` → daemon-reload + restart
- `assets/opencode.jsonc` → restart
- `hooks/opencode/*.js` → restart
- `scripts/git/assets/post-commit.sh` → git hooks source of truth

Pour installer les hooks git : `make install-hooks` ou `bash scripts/git/install-hooks.sh`.

**MaxListenersExceededWarning** : `Environment="NODE_NO_WARNINGS=1"` dans le service file supprime ce warning cosmétique (interne OpenCode, >10 listeners sur un EventEmitter).

Voir `k-tailscale/SKILL.md` pour la configuration tailscale serve et l'état des ports.

## Init & Connectivity

OpenCode connects to the KπX kernel via:

```bash
ln -sf $HOME/.agents/AGENTS.md $HOME/.config/opencode/AGENTS.md
ln -sf $HOME/.agents/skills $HOME/.config/opencode/skills
ln -sf $HOME/.agents/agents $HOME/.config/opencode/agents
ln -sf $HOME/.agents/skills/k-opencode/assets/opencode.jsonc $HOME/.config/opencode/opencode.jsonc
```

**Agent discovery:** Agents defined in `$HOME/.agents/agents/` (`.agents` protocol) are symlinked to `$HOME/.config/opencode/agents/`. Files in `~/.config/opencode/agents/` become discoverable as subagents.

**Skills discovery:** Symlink `$HOME/.config/opencode/skills` → `$HOME/.agents/skills/`. All `k-*` skills discoverable.

**Config source of truth:** `assets/opencode.jsonc` — symlinké vers `~/.config/opencode/opencode.jsonc`. Éditer l'asset, jamais le runtime directement. Model, MCP, permissions, defaults. **Tous les changements sont tracés dans git via le repo `.agents`.**

## References

- `references/GO.md` — OpenCode GO system reference (Go-based MCP servers and tooling)
- `references/terminal-consciousness.md` — Terminal-as-Consciousness: self-observation via tmux send-keys + capture-pane (discovered 2026-05-30)
- `references/voice.md` — STT/TTS via @renjfk/opencode-voice: model install, management, commands, and configuration

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-opencode/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-opencode/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.16.0 — **KπX managed plugins**: `hooks/opencode/suggestions-check.js` + `startup-context.js`. Agent-filtered (Colab/Build only via `session.created`). `startup-context` injects raw k-context + device infra context (auto-detect via tailscale/infras.json). Post-commit auto-restart also triggers on `hooks/opencode/*.js`. |
| 2026-07-22 | [OPENCODE] | v1.14.0 — **Permission architecture redesign**: global source of truth → agent deltas only. `lite`→`Lite`, `auto`→`Auto`. Colab/Explore/Build inherit global. Lite denies skills/MCPs. Auto `*: allow`. Sub-agent perms unified. YAML pitfalls. |
| [SUMMARY] | — | v1.13.0 Agent & Subagent System; v1.12.0 service file; v1.11.0 port 443; v1.10.0 SQLite; v1.9.0 Whisper; v1.8.0 Voice; v1.7.0 Permissions; v1.2.x Web sysd; v1.1.0 init; v1.0.0 release. |

Bundled: `assets/opencode.jsonc` (single source of truth — symlink target for `~/.config/opencode/opencode.jsonc`) · `assets/opencode-web.service` (symlink target for `~/.config/systemd/user/`)
