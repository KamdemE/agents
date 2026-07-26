---
name: k-opencode
description: >
  OpenCode CLI runtime — global config (opencode.jsonc), AGENTS/skills symlink wiring,
  MCP local/remote config, provider auth flow, and operational verification commands.
  Load when installing OpenCode, configuring MCPs, or debugging OpenCode runtime behavior.
  Registry in k-clis.
license: private
metadata:
  version: 2.2.0
  author: KpihX
  scope: agent-runtime
  target-agent: opencode
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — OpenCode CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Installation

### Linux / macOS (per-user, no sudo)

```bash
curl -fsSL https://opencode.ai/install | bash
```

Installs to `~/.opencode/bin/opencode`. Add to PATH:

```bash
export PATH="$HOME/.opencode/bin:$PATH"
```

(Already in `~/.kshrc` on Ubuntu.)

### Verification

```bash
opencode --version
```

### ⚠️ Android / Termux — Incompatible (upstream limitation)

OpenCode does **not** ship Android-compatible binaries. The Linux ARM64 build fails on Termux with:

```
error: "...opencode" has unexpected e_type: 2
```

**Root cause:** The released Linux ARM64 binary is a non-PIE (`ET_EXEC`) glibc executable. Android's `linker64` rejects non-PIE binaries, and Termux uses bionic libc (not glibc).

**Upstream issue:** [`anomalyco/opencode#11689`](https://github.com/anomalyco/opencode/issues/11689) — feature request for Android ARM64 support (unresolved as of 2026-07).

**Workarounds tested on kpihx-s25 (Snapdragon 8 Elite, Android 16):**

| Method | Verdict | Detail |
|--------|---------|--------|
| `termux-elf-cleaner` | ❌ Fails | Fixes TLS alignment but `e_type` remains `ET_EXEC` |
| `patchelf` + glibc-runner | ❌ Fails | Binary is non-PIE regardless of interpreter |
| `proot -0` | ⚠️ Partial | Runs but adds overhead; not practical for daily use |
| `proot-distro ubuntu` | ✅ Works | Full Ubuntu ARM64 in proot — opencode runs normally inside |
| Build from source with `-buildmode=pie` | ✅ Guaranteed | `CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -buildmode=pie` produces a static PIE binary that Termux can exec directly |

**Recommendation for S25/Android devices:** Use `proot-distro login ubuntu` to run opencode in a glibc environment, or build from source with `-buildmode=pie`.

## Runtime Context

- **Binary:** `$HOME/.opencode/bin/opencode`
- **Global config dir:** `$HOME/.config/opencode/`
- **Config file:** `$HOME/.config/opencode/opencode.jsonc`
- **Auth store:** `$HOME/.local/share/opencode/auth.json`
- **Global kernel symlinks (KπX):**
  - `$HOME/.config/opencode/AGENTS.md` → `$HOME/.agents/AGENTS.md`
  - `$HOME/.config/opencode/opencode.jsonc` → `$HOME/.agents/skills/k-opencode/assets/opencode.jsonc`
  - `$HOME/.config/opencode/agents` → `$HOME/.agents/agents`
- **Skills discovery — native:** OpenCode natively scans `$HOME/.agents/skills/` as a Global Compatibility path. No symlink needed.
- **Plugins discovery — explicit `file://` only:** No symlink — all plugins loaded via `"plugin"` array in `opencode.jsonc` with `file://` paths to `$HOME/.agents/hooks/opencode/`.
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

| File | Role | Tracked in `.agents` |
|------|------|---------------------|
| `$HOME/.config/opencode/opencode.jsonc` | OpenCode runtime config (symlink → `assets/opencode.jsonc`) — model, permissions, MCPs, lifecycle plugins | ✅ `skills/k-opencode/assets/opencode.jsonc` |
| `$HOME/.config/opencode/tui.json` | TUI config (symlink → `assets/tui.json`) — voice plugin, UI extensions | ✅ `skills/k-opencode/assets/tui.json` |
| `$HOME/.config/opencode/AGENTS.md` | Global instruction kernel (symlink target: `$HOME/.agents/AGENTS.md`) | ✅ in repo root |
| `$HOME/.agents/skills/` | Skill discovery — OpenCode natively scans this (Global Compatibility path). No symlink required. | ✅ skills/ directory |
| `$HOME/.local/share/opencode/auth.json` | Provider login credentials | ❌ credentials (never track) |
| `$HOME/.config/opencode/agents/` | Agent discovery path (symlink target: `$HOME/.agents/agents/`) | ✅ agents/ directory |

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
      "command": ["mail-mcp", "serve"],
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
opencode --version
opencode debug config
opencode mcp list
opencode providers list
opencode models
```

## Operational Rules (KπX)

- **NEVER use `/usr/bin/rm` or `/bin/rm`** — they bypass the trash-safe `rm` wrapper (see `k-clis/assets/rm`). Always use `rm` (the `~/.local/bin/rm` wrapper which moves to trash). This is enforced in `opencode.jsonc` → `"bash"` via explicit path denials globally and `*rm*` wildcard in Auto's permission block.
- Keep OpenCode runtime config centralized in `$HOME/.config/opencode/opencode.jsonc`; avoid per-project overrides unless explicitly requested.
- Secrets for local MCP servers are loaded via `$HOME/.kshrc` at shell startup.
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

### `.env` protection (edit + bash + read — 2026-07-24)

Tous les accès aux fichiers `*.env` sont interdits (`deny`). Les `*.env.example` sont autorisés (`allow`). Appliqué sur `edit`, `bash`, et `read` via `findLast` :

```jsonc
"edit": { "*": "ask", "*.env": "deny", "*.env.example": "allow" },
"read": { "*.env": "deny", "*.env.example": "allow" },
"bash": { /* ... */ "*.env": "deny", "*.env.example": "allow" }
```

### MCP permissions

Wildcard allows all, specific destructive tools override to `ask` (last match wins):

- `chrome-agent_*`: `allow`
- `mail_fallback_*`: `allow` + `send_message`, `reply_message`, `forward_message`, `delete_messages`, `delete_folder`, `trash_messages`: `ask`
- `tick_fallback_*`: `allow` + `delete_task`, `delete_project`, `delete_tag`, `delete_habit`, `delete_query_preset`, `batch_delete_tasks`, `merge_tags`: `ask`

### `external_directory` — 11 paths allow

`~/.agents/**`, `~/.config/opencode/**`, `/tmp/**`, `~/Downloads/**`, `~/Pictures/**`, `~/Gdrive_X/**`, `~/Gdrive/**`, `~/KpihX-Labs/**`, `~/Work/**`, `~/.config/nvim/**`, `~/.local/share/nvim/**`

### Plugins — Three Systems

OpenCode has **three separate extension systems**, configured differently:

| System | Config file | Mechanism | Purpose |
|--------|------------|-----------|---------|
| **Lifecycle plugins** | `opencode.jsonc` → `"plugin"` array | npm or `file://` JS modules | `event` hooks, `messages.transform`, tool definitions |
| **TUI plugins** | `tui.json` → `"plugin"` array | npm modules | UI extensions (voice STT/TTS, visual) |
| **Slash commands** | `.opencode/commands/*.md` | Markdown files auto-discovered | Custom `/command` shortcuts in TUI |

#### Lifecycle plugins — 3 installation types

| Type | Format | Example | When to use |
|------|--------|---------|-------------|
| **npm package** | `"package-name"` | `"opencode-dir"` | Official or published npm plugins (auto-installed by OpenCode) |
| **npm with version** | `"package-name@version"` | `"opencode-antigravity-auth@latest"` | Pin a specific version or track `@latest` |
| **Local file** | `"file:///absolute/path.js"` | `"file:///home/kpihx/.agents/hooks/opencode/startup-context.js"` | Custom/private plugins tracked in `.agents` git repo |

#### Current KπX lifecycle plugins (7)

These are loaded from `opencode.jsonc` → `"plugin"` array:

```jsonc
"plugin": [
  "opencode-dir",                           // Type 1: npm — directory navigation
  "opencode-ssh-session",                   // Type 1: npm — persistent SSH sessions
  "opencode-ast",                           // Type 1: npm — AST code structure (outline, symbol, definitions, references)
  "opencode-antigravity-auth@latest",        // Type 2: npm@version — Claude + Gemini via Google OAuth (free)
  "file:///home/kpihx/.agents/hooks/opencode/suggestions-check.js",   // Type 3: file:// — KπX format reminder
  "file:///home/kpihx/.agents/hooks/opencode/startup-context.js",      // Type 3: file:// — KπX startup context injection
  "file:///home/kpihx/.agents/hooks/opencode/prompt-enforcer-strict.js" // Type 3: file:// — KπX enforcement block (strict)
]
```

#### KπX Managed — `hooks/opencode/` (file://)

These are the **KπX sovereign hooks** — self-contained `.js` files in `~/.agents/hooks/opencode/`. Each is listed via `file://` URL in the `"plugin"` array (order matters). No symlink needed.

| File | Event | Agent filter | Behavior |
|------|-------|-------------|----------|
| `suggestions-check.js` | `messages.transform` (every turn) | Colab, Build, Auto | Injects system message: ≥3 Suggestions required |
| `startup-context.js` | `messages.transform` (first turn only) | Colab, Build, Auto | Injects raw `k-context/SKILL.md` + device-identifying string (device name only) |
| `prompt-enforcer-strict.js` | `messages.transform` (every turn) | Colab, Build, Auto | Pushes raw first-person enforcement block as `role: "user"` at end of prompt |

**Agent detection:** All plugins capture the agent name from `session.created` event (`info.agent`) at session start. Non-matching agents get zero overhead — plugins return silently.

**Execution order (plugin array order matters):**
1. `startup-context` fires → unshifts context block at start of messages
2. `suggestions-check` fires → pushes format reminder at end of messages
3. `prompt-enforcer-strict` fires → pushes enforcement block at very end of messages

#### TUI plugin (`tui.json`)

```jsonc
// ~/.config/opencode/tui.json (symlink → assets/tui.json)
{
  "$schema": "https://opencode.ai/tui.json",
  "plugin": [["@renjfk/opencode-voice", {}]]
}
```

Config source: `assets/tui.json` — symlinké vers `~/.config/opencode/tui.json`.

#### Slash commands (`.opencode/commands/`)

Custom `/command` shortcuts are auto-discovered from markdown files in `.opencode/commands/`. No config entry needed.

**Discovery path (in order):**
1. Project-level: `<project-root>/.opencode/commands/*.md`
2. Global: `~/.config/opencode/commands/*.md` (NOT `.opencode/command/`)

**Example — `/context` plugin (IgorWarzocha):**
```
~/.config/opencode/commands/
  └── context.md        ← makes `/context` available in every session
```

The `/context` command shows a detailed token-usage breakdown by component (system prompt, tools, user messages, etc.) using `js-tiktoken` for estimation. Installed globally for all projects.

Resulting message order: `[0] raw context (k-context + device infra)`, `[1...N] user messages`, `[N+1] format reminder`, `[N+2] prompt enforcement`.

**Device auto-detection pipeline:**
```
tailscale status --json → Self.DNSName → assets/infras.json lookup → skills/<k-*>/SKILL.md read
Fallback: os.hostname() if tailscale unavailable
```

**Source files:** `~/.agents/hooks/opencode/` — tracked in `.agents` git repo, auto-deployed on push.

### Voice (TUI — @renjfk/opencode-voice)

STT + TTS 100% local. Config dans `tui.json` (pas `opencode.jsonc`). **Tracké dans** `assets/tui.json`, symlinké vers `~/.config/opencode/tui.json`.

```jsonc
// ~/.config/opencode/tui.json (symlink → assets/tui.json)
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

Auto-synced by `scripts/opencode-ollama.sh` (sourced from `.kshrc`) after `ollama pull`/`rm`/`delete`. See the `Scripts` section.

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
ln -sf $HOME/.agents/agents $HOME/.config/opencode/agents
ln -sf $HOME/.agents/skills/k-opencode/assets/opencode.jsonc $HOME/.config/opencode/opencode.jsonc
ln -sf $HOME/.agents/skills/k-opencode/assets/tui.json $HOME/.config/opencode/tui.json
```

**Agent discovery:** Agents defined in `$HOME/.agents/agents/` (`.agents` protocol) are symlinked to `$HOME/.config/opencode/agents/`. Files in `~/.config/opencode/agents/` become discoverable as subagents.

**Skills discovery — native:** OpenCode natively scans `$HOME/.agents/skills/` as a Global Compatibility path. No symlink necessary. See [docs](https://opencode.ai/docs/skills).

**Plugins discovery — explicit `file://` only:** Plugins are loaded exclusively via `"plugin"` array in `opencode.jsonc` with `file://` paths to `$HOME/.agents/hooks/opencode/`. No `plugins/` symlink.

**Config source of truth:** `assets/opencode.jsonc` — symlinké vers `~/.config/opencode/opencode.jsonc`. Éditer l'asset, jamais le runtime directement. Model, MCP, permissions, defaults. **Tous les changements sont tracés dans git via le repo `.agents`.**

## Scripts

| Script | Role |
|--------|------|
| `scripts/opencode-ollama.sh` | Ollama zsh wrapper + auto-sync models into `opencode.jsonc`. Sourced from `.kshrc`. |

## References

- `references/GO.md` — OpenCode GO system reference (Go-based MCP servers and tooling)
- `references/terminal-consciousness.md` — Terminal-as-Consciousness: self-observation via tmux send-keys + capture-pane (discovered 2026-05-30)
- `references/voice.md` — STT/TTS via @renjfk/opencode-voice: model install, management, commands, and configuration
- `references/android-termux.md` — Android/Termux incompatibility: root cause, workarounds tested, and build-from-source guide for ARM64 devices

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-opencode/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-opencode/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-25 | [OPENCODE] | v2.2.0 — **Symlinks cleanup**: removed `~/.config/opencode/plugins` and `~/.config/opencode/skills` (plugins use `file://` only, skills are natively discovered). Added `prompt-enforcer.js` plugin. Added `/bin/rm` deny + Auto `*rm*` wildcard in opencode.jsonc. |
| 2026-07-25 | [OPENCODE] | v2.1.0 — **`/usr/bin/rm` blocked** in opencode.jsonc global bash + Auto agent. GRAVÉ rule in AGENTS.md. Scripts section added. Legacy refs updated. |
| [SUMMARY] | — | v2.0.0 `scripts/opencode-ollama.sh` combined wrapper; v1.19.0 `.env` protection; v1.18.0 Android/Termux incompatibility docs; v1.16.0 KπX managed plugins; v1.14.0 Permission redesign; v1.13.0 Agent System; v1.12.0 service file; v1.11.0 port 443; v1.10.0 SQLite; v1.9.0 Whisper; v1.8.0 Voice; v1.7.0 Permissions. |

Bundled: `assets/opencode.jsonc` (single source of truth — symlink target for `~/.config/opencode/opencode.jsonc`) · `assets/opencode-web.service` (symlink target for `~/.config/systemd/user/`)
