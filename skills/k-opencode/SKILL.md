---
name: k-opencode
description: >
  OpenCode CLI runtime — global config (opencode.jsonc), AGENTS/skills symlink wiring,
  MCP local/remote config, provider auth flow, and operational verification commands.
  Load when installing OpenCode, configuring MCPs, or debugging OpenCode runtime behavior.
  Registry in k-clis.
license: private
metadata:
  version: 1.12.0
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
| `$HOME/.config/opencode/opencode.jsonc` | OpenCode runtime config — model, permissions, MCPs |
| `$HOME/.config/opencode/AGENTS.md` | Global instruction kernel (symlink target: `$HOME/.agents/AGENTS.md`) |
| `$HOME/.config/opencode/skills/` | Skill discovery path (symlink target: `$HOME/.agents/skills/`) |
| `$HOME/.local/share/opencode/auth.json` | Provider login credentials |

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
  - `build`: `{}` — inherits everything from global
  - `plan`: `edit: deny`, restricted bash (read-only)
  - `colab`: `edit: allow`, `bash: allow`, restricted task subagents
  - `explore`: `edit: allow`, limited bash, teaching task subagents

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

```jsonc
"plugin": [
  "opencode-dir",
  "opencode-ssh-session",
  "opencode-antigravity-auth@latest" // Claude + Gemini via Google OAuth (free)
]
```

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

Voir `k-tailscale/SKILL.md` pour la configuration tailscale serve et l'état des ports.

## Init & Connectivity

OpenCode connects to the KπX kernel via:

```bash
ln -sf $HOME/.agents/AGENTS.md $HOME/.config/opencode/AGENTS.md
ln -sf $HOME/.agents/skills $HOME/.config/opencode/skills
ln -sf $HOME/.agents/agents $HOME/.config/opencode/agents
```

**Agent discovery:** Agents defined in `$HOME/.agents/agents/` (`.agents` protocol) are symlinked to `$HOME/.config/opencode/agents/`. Files in `~/.config/opencode/agents/` become discoverable as subagents.

**Skills discovery:** Symlink `$HOME/.config/opencode/skills` → `$HOME/.agents/skills/`. All `k-*` skills discoverable.

**Config source of truth:** `$HOME/.config/opencode/opencode.jsonc` — model, MCP, permissions, defaults. See `k-opencode` for full proxy/MCP/plugin mapping.

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
| 2026-07-21 | [OPENCODE] | v1.12.0 — Single Source of Truth : service file déplacé dans `assets/opencode-web.service`, symlinké depuis `~/.config/systemd/user/`. |
| 2026-07-21 | [OPENCODE] | v1.11.0 — OpenCode Web: màj port 443 (tailscale serve), service découplé d'openclaw-gateway, ajout du service file complet dans la doc. |
| [SUMMARY] | — | v1.10.0 Session Storage SQLite section; v1.9.0 Whisper models + voice reference doc; v1.8.0 Voice setup @renjfk/opencode-voice; v1.7.0 Permission architecture rewrite; v1.2.x OpenCode Web sysd + tailscale, Neovim integration; v1.1.0 init; v1.0.0 release. |

Bundled: `assets/opencode.jsonc~`
