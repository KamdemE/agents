---
name: k-opencode
description: >
  OpenCode CLI runtime — global config (opencode.jsonc), AGENTS/skills symlink wiring,
  MCP local/remote config, provider auth flow, and operational verification commands.
  Load when installing OpenCode, configuring MCPs, or debugging OpenCode runtime behavior.
  Registry in k-clis.
license: private
metadata:
  version: 2.25.0
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

Installs to `~/.opencode/bin/opencode`. Add to PATH (already in `~/.kshrc` on Ubuntu):

```bash
export PATH="$HOME/.opencode/bin:$PATH"
```

### Verification

```bash
opencode --version
```

### ⚠️ Android / Termux — Incompatible (upstream limitation)

OpenCode does **not** ship Android-compatible binaries (non-PIE glibc ARM64 binary rejected by Android's bionic `linker64`). Full root cause, workarounds tested, and build-from-source guide → **`references/android-termux.md`**.

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
- **Plugins discovery — explicit `file://` only:** No symlink — all plugins loaded via `"plugin"` array in `opencode.jsonc` with `file://` paths to `$HOME/.agents/skills/k-opencode/scripts/hooks/`.
- **PATH source of truth:** `$HOME/.kshrc` (`export PATH="$HOME/.opencode/bin:$PATH"`)
- **Registry:** **`k-clis`**

## Session Storage (SQLite)

OpenCode stores all conversation history in a single SQLite database (`$HOME/.local/share/opencode/opencode.db`, WAL mode), not JSON files. Full schema (`session`, `session_message` tables) and query examples → **`references/sqlite-storage.md`**.

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

OpenCode discovers agents from config (`opencode.jsonc` → `agent.*`) and markdown files (`~/.config/opencode/agents/<path>/<name>.md`). Modes: `primary` (Tab-visible), `subagent` (via `task`/`@`), `all` (both). Full discovery rules, YAML frontmatter pitfalls, and the complete KπX agent roster (Colab, Explore, Build, Lite, Auto, Agent, Plan, executor, curator, intent-guardian, pragmatic-checker, fact-verifier) → **`references/agent-system.md`**.

## MCP Config Format (OpenCode — JSONC)

MCP servers are configured under the top-level `mcp` key in `opencode.jsonc` — `"type": "local"` (stdio-equivalent command), `"type": "remote"` (HTTP URL, optional `headers` with `{env:VAR}` bearer tokens). Full examples → **`references/mcp-config.md`**.

## Verification Commands

```bash
opencode --version
opencode debug config
opencode mcp list
opencode providers list
opencode models
```

## Operational Rules (KπX)

- **NEVER use `/usr/bin/rm` or `/bin/rm`** — they bypass the trash-safe `rm` wrapper (see `k-clis/assets/rm`). Always use `rm` (the `~/.local/bin/rm` wrapper which moves to trash). Enforced in `opencode.jsonc` → `"bash"` via explicit path denials globally and `*rm*` wildcard in Auto's permission block.
- Keep OpenCode runtime config centralized in `$HOME/.config/opencode/opencode.jsonc`; avoid per-project overrides unless explicitly requested.
- Secrets for local MCP servers are loaded via `$HOME/.kshrc` at shell startup. Never hardcode secrets in `opencode.jsonc`; use `{env:VAR_NAME}` placeholders.
- Keep AGENTS/skills linked to `$HOME/.agents/` so OpenCode shares the same sovereign kernel as Codex, Vibe, Copilot, and Zed.

## Permission System (2026-05-30 — Confiance Totale)

3-tier hierarchy: **Global config → Agent deltas → Session runtime**, `findLast` wins. Global bash zones (🟢 read-only, 🟡 low-risk, 🟠 trusted, 🔴 explicit ask), `.env`/`*auth.json`/`*credentials.json` protection, MCP permission overrides, and `external_directory` allowlist → full detail in **`references/permissions.md`**.

## Plugins — Three Systems & KπX Hooks

OpenCode has three extension systems: **Lifecycle plugins** (`opencode.jsonc` → `"plugin"`, npm or `file://`), **TUI plugins** (`tui.json` → `"plugin"`, npm), and **Slash commands** (`.opencode/commands/*.md`, auto-discovered). The 11 active lifecycle plugins, the full KπX sovereign hooks table (`scripts/hooks/*.js` with `TARGET_AGENTS`, event, behavior), execution order, TUI plugin config, and slash command discovery → **`references/plugins-architecture.md`**. Coding standards for creating/editing hooks (mandatory `TARGET_AGENTS`, prompt/hook name matching, `libs/` helper usage) → **`references/hooks-standard.md`**.

**Device auto-detection pipeline:** `tailscale status --json → Self.DNSName → assets/infras.json lookup → skills/<k-*>/SKILL.md read` (fallback `os.hostname()`).

### Voice (TUI — @renjfk/opencode-voice)

STT + TTS 100% local via `@renjfk/opencode-voice`. Config in `tui.json` (not `opencode.jsonc`), tracked as `assets/tui.json`. Dependencies (sox, whisper-cli, piper-tts), model install/management, keybinds, and plugin patches → **`references/voice.md`**.

### Providers: Ollama (local) & Ollama6 (deep-pc6)

Two OpenAI-compatible providers auto-synced from local/remote Ollama servers: `ollama` (port 11434, via `scripts/opencode-ollama.sh`) and `ollama6` (port 11436 through the DxO tunnel, via `k-dxo/scripts/opencode-ollama6.sh`). Both do surgical sub-block JSONC replacement (other providers untouched). Full config examples → **`references/providers.md`**.

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
| `<C-a>` (visual) | `opencode.ask("@this: ", { submit = true })` |
| `<C-x>` (visual) | `opencode.select()` |
| `<C-.>` (n/t mode) | `opencode.toggle()` |

**Requires:** `opencode` binary in `$PATH` (sourced via `$HOME/.kshrc`).

## OpenCode Web (systemd + Tailscale Serve)

OpenCode Web runs as a persistent systemd user service. A reverse proxy (Lens) strips CSP and injects the Web Voice plugin. Both are exposed via `tailscale serve`. The tailnet root route is NOT opencode — it proxies the **OpenClaw Gateway** (see `k-openclaw`).

| Service | Port (local) | Tailscale Port | Ingress URL | Role |
|---------|--------------|----------------|-------------|------|
| `opencode-web` | `4097` (localhost only) | `1443` | `https://kpihx-ubuntu.tail2527bd.ts.net:1443/` | Native OpenCode (Clean/Safe Mode) |
| `opencode-lens` | `3000` (localhost only) | `2443` | `https://kpihx-ubuntu.tail2527bd.ts.net:2443/` | Lens Proxy + Injected Voice UI (Interactive Mode) |
| `openclaw-gateway` | `18789` (localhost only) | `443` (root) | `https://kpihx-ubuntu.tail2527bd.ts.net/` | OpenClaw Gateway — tailnet root route (not opencode; see `k-openclaw`) |

Systemd units tracked as `assets/opencode-web.service` (native) and `assets/opencode-lens.service` (lens proxy — plugins at `scripts/plugins/web/`).

```bash
systemctl --user status opencode-web     # status native
systemctl --user status opencode-lens    # status lens
systemctl --user restart opencode-lens   # restart lens proxy
journalctl --user -u opencode-lens -f    # logs lens proxy
tailscale serve status                   # verify tailscale routing
systemctl --user daemon-reload && systemctl --user restart opencode-lens  # reload + apply changes
```

## Init & Connectivity

OpenCode connects to the KπX kernel via:

```bash
ln -sf $HOME/.agents/AGENTS.md $HOME/.config/opencode/AGENTS.md
ln -sf $HOME/.agents/agents $HOME/.config/opencode/agents
ln -sf $HOME/.agents/skills/k-opencode/assets/opencode.jsonc $HOME/.config/opencode/opencode.jsonc
ln -sf $HOME/.agents/skills/k-opencode/assets/tui.json $HOME/.config/opencode/tui.json
```

**Agent discovery:** Agents defined in `$HOME/.agents/agents/` (`.agents` protocol) are symlinked to `$HOME/.config/opencode/agents/`. Files there become discoverable as subagents.

**Skills discovery — native:** OpenCode natively scans `$HOME/.agents/skills/` as a Global Compatibility path. No symlink necessary. See [docs](https://opencode.ai/docs/skills).

**Plugins discovery — explicit `file://` only:** Plugins are loaded exclusively via `"plugin"` array in `opencode.jsonc` with `file://` paths to `$HOME/.agents/skills/k-opencode/scripts/hooks/`. No `plugins/` symlink.

**Config source of truth:** `assets/opencode.jsonc` — symlinked to `~/.config/opencode/opencode.jsonc`. Edit the asset, never the runtime directly. **All changes are tracked in git via the `.agents` repo.**

## Scripts

| Script | Role |
|--------|------|
| `scripts/opencode-ollama.sh` | Ollama zsh wrapper + auto-sync models into `opencode.jsonc`. Sourced from `.kshrc`. Surgical sub-block replacement (preserves the other providers, e.g. `ollama6`). |
| `k-dxo/scripts/opencode-ollama6.sh` | Ollama6 zsh wrapper + auto-sync deep-pc6 (ollama6) models into `opencode.jsonc`. Sourced from `.kshrc` — exact equivalent of `opencode-ollama.sh` for the `ollama6` provider (11436 tunnel). Wraps `ollama6 pull`/`rm`/`delete`; full model names as keys. `ollama6` stays core-only (k-dxo). |

## References

- `references/hooks-standard.md` — OpenCode Hooks & Plugins Standards: coding standards, mandatory `TARGET_AGENTS`, prompt/hook name matching, and helper library integrations
- `references/plugins-architecture.md` — Three plugin systems, active lifecycle plugins, KπX sovereign hooks table, execution order, TUI plugin, slash commands
- `references/agent-system.md` — Agent & Subagent discovery, modes, YAML frontmatter pitfalls, full KπX agent roster
- `references/permissions.md` — Full permission architecture, bash zones, `.env`/auth protection, MCP overrides, `external_directory`
- `references/mcp-config.md` — MCP config format (local/remote/bearer-token examples)
- `references/sqlite-storage.md` — Session storage schema (SQLite) and query examples
- `references/providers.md` — Ollama & Ollama6 provider config examples
- `references/android-termux.md` — Android/Termux incompatibility: root cause, workarounds tested, and build-from-source guide for ARM64 devices
- `references/voice.md` — STT/TTS via @renjfk/opencode-voice and Web Voice Plugin: model install, Web Speech configuration, and browser integrations
- `references/GO.md` — OpenCode GO system reference (Go-based MCP servers and tooling)
- `references/terminal-consciousness.md` — Terminal-as-Consciousness: self-observation via tmux send-keys + capture-pane (discovered 2026-05-30)

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-opencode/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-opencode/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-11 | [COLAB] | v2.25.0 — **Fix of OpenCode session titles (silent title-gen)** : root cause found in the binary source `SessionPrompt.ensureTitle` — title generation only fires if the history contains **exactly ONE non-synthetic user message** (`if(t.history.filter(O).length!==1)return`). The lifecycle hooks injected `user` messages WITHOUT the `synthetic:true` flag (`startup-context.js` unshift + `appendMessage` of prompt-enforcer-lite/strict/math-enforcer) → 2+ "real" user messages → gate return → title never generated (regressed ~2026-08-10, hooks re-enabled 08-09). Fix = PATCH `synthetic:true` on the injected parts in `libs/message-utils.js` (`appendMessage`) and `startup-context.js` (unshift). Verified: `node --check` OK, gate simulation (BEFORE=2→skip, AFTER=1→fire), `make check` ALL_OK. ⚠️ OpenCode restart required (hooks loaded at boot). The `small_model` was NOT the cause (valid and active in this chat). |
| 2026-08-09 | [COLAB] | v2.24.0 — **`/context` plugin (IgorWarzocha) FULLY re-installed (KπX green light)** : purge of the incomplete install (only `command/context.md` existed → the command called the `context_usage` tool without implementation) ; complete install following the repo — source of truth in `.agents/skills/k-opencode/scripts/plugins/context-plugin/` (`command/context.md` + `plugin/context-usage.ts` + `tokenizer-registry` + `vendor/node_modules` with `js-tiktoken` + `@huggingface/transformers`) ; runtime symlinks `~/.config/opencode/commands/context.md` and `~/.config/opencode/plugins/` (plural discovery paths, confirmed by the official OpenCode docs) ; documentation in `references/context-plugin.md` (repo, install, deps, troubleshooting). |
| [SUMMARY] | — | v2.23.0 and earlier copied to `references/log.md` ; the live table keeps only the two most recent entries. |

Bundled: `assets/opencode.jsonc` (single source of truth — symlink target for `~/.config/opencode/opencode.jsonc`) · `assets/opencode.jsonc~` (preserved configuration backup) · `assets/opencode-web.service` (symlink target for `~/.config/systemd/user/`) · `assets/opencode-lens.service` (symlink target for `~/.config/systemd/user/`)
