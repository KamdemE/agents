---
name: k-opencode
description: >
  OpenCode CLI runtime — global config (opencode.jsonc), AGENTS/skills symlink wiring,
  MCP local/remote config, provider auth flow, and operational verification commands.
  Load when installing OpenCode, configuring MCPs, or debugging OpenCode runtime behavior.
  Registry in k-clis.
license: private
metadata:
  version: 2.48.1
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
- **Plugins discovery — explicit `file://{env:HOME}` for lifecycle hooks:** Lifecycle plugins loaded via `"plugin"` array in `opencode.jsonc` with `file://{env:HOME}/...` paths (the ONLY expansion mechanism — `$HOME`, `~` and hardcoded `/home/<user>` are NOT expanded and silently fail to load). Slash-command plugin (`/context`) auto-discovered via `~/.config/opencode/plugins/` → `scripts/plugins/` (parent) → `opencode-context/` package via `index.ts`.
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

## Plugins & Hooks — Four Systems

OpenCode and its environment are extended via four distinct systems:
1. **Lifecycle plugins:** (`opencode.jsonc` → `"plugin"`, npm or local `file://{env:HOME}` JS modules). 14 active plugins (6 npm, 8 local: 7 hooks + 1 submodule tool). See **`references/plugins-architecture.md`** and coding standards in **`references/hooks-standard.md`**.
2. **TUI plugins:** (`tui.json` → `"plugin"`, `file://` sovereign fork) for console interface features (voice STT/TTS via `@kpihx/opencode-voice` `v0.4.1-kpihx.1` fork de `renjfk`). See **`references/voice.md`**.
3. **Slash commands:** (`.opencode/commands/*.md` auto-discovered markdown files) for interactive shortcuts (like `/context`). See **`references/context-plugin.md`**.
4. **Web UI plugins:** Injected via the `opencode-lens` proxy to extend the browser-based UI (like `opencode-web-voice` using the Web Speech API). See **`references/voice.md`**.

**Device auto-detection pipeline:** `tailscale status --json → Self.DNSName → assets/infras.json lookup → skills/<k-*>/SKILL.md read` (fallback `os.hostname()`).

### Voice (TUI — @kpihx/opencode-voice `v0.4.1-kpihx.1` sovereign)

STT + TTS 100% local via `@kpihx/opencode-voice` (`kpihx-labs/opencode-voice`, fork `renjfk`, `v0.4.1-kpihx.1`: siwis FR, `<leader>r`, LLM fallback). Config in `tui.json` (`file:///…/scripts/plugins/opencode-voice`, not `@renjfk` npm), tracked as `assets/tui.json` (submodule `k-opencode/plugins/opencode-voice`, `github`+`gitlab`). Dependencies (sox, whisper-cli, piper), model install/management, keybinds, and sovereign patches → **`references/voice.md`**. The sovereign wrappers `k-whisper` / `k-piper` (see `k-ai`) manage the same models and voices.

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

Systemd units tracked as `assets/opencode-web.service` (native), `assets/opencode-web-shim.service` (terminal URL shim), and `assets/opencode-lens.service` (lens proxy — plugins at `scripts/plugins/web/`).

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

**Plugins discovery — explicit `file://{env:HOME}` for lifecycle hooks:** Lifecycle plugins are loaded via `"plugin"` array in `opencode.jsonc` with `file://{env:HOME}/...` paths to `$HOME/.agents/skills/k-opencode/scripts/plugins/hooks/`. `$HOME`, `~` and hardcoded `/home/<user>` paths are NOT expanded by OpenCode — only `{env:VAR}` is (see `references/plugins-architecture.md` → Path resolution). Slash-command plugin (`/context`) auto-discovered via `~/.config/opencode/plugins/` → `scripts/plugins/` (parent) → `opencode-context/` package (via `index.ts`).

**Config source of truth:** `assets/opencode.jsonc` — symlinked to `~/.config/opencode/opencode.jsonc`. Edit the asset, never the runtime directly. **All changes are tracked in git via the `.agents` repo.**

## Scripts

| Script | Role |
|--------|------|
| `scripts/opencode-ollama.sh` | Ollama zsh wrapper + auto-sync models into `opencode.jsonc`. Sourced from `.kshrc`. Surgical sub-block replacement (preserves the other providers, e.g. `ollama6`). |
| `k-dxo/scripts/opencode-ollama6.sh` | Ollama6 zsh wrapper + auto-sync deep-pc6 (ollama6) models into `opencode.jsonc`. Sourced from `.kshrc` — exact equivalent of `opencode-ollama.sh` for the `ollama6` provider (11436 tunnel). Wraps `ollama6 pull`/`rm`/`delete`; full model names as keys. `ollama6` stays core-only (k-dxo). |
| `scripts/terminal-url-shim.js` | Terminal URL and SSE proxy shim to handle stream buffering, token injection, and origin matching. |

## References

- `references/hooks-standard.md` — OpenCode Hooks & Plugins Standards: coding standards, mandatory `TARGET_AGENTS`, prompt/hook name matching, and helper library integrations
- `references/plugins-architecture.md` — Three plugin systems, active lifecycle plugins, KπX sovereign hooks table, execution order, TUI plugin, slash commands
- `references/agent-system.md` — Agent & Subagent discovery, modes, YAML frontmatter pitfalls, full KπX agent roster
- `references/permissions.md` — Full permission architecture, bash zones, `.env`/auth protection, MCP overrides, `external_directory`
- `references/mcp-config.md` — MCP config format (local/remote/bearer-token examples)
- `references/sqlite-storage.md` — Session storage schema (SQLite) and query examples
- `references/providers.md` — Ollama & Ollama6 provider config examples
- `references/android-termux.md` — Android/Termux incompatibility: root cause, workarounds tested, and build-from-source guide for ARM64 devices
- `references/voice.md` — STT/TTS via the sovereign `@kpihx/opencode-voice` fork and Web Voice Plugin: model install, Web Speech configuration, and browser integrations
- OpenCode Go Models — Always check the official site [opencode.ai/go](https://opencode.ai/go) and live catalog [opencode.ai/zen/go/v1/models](https://opencode.ai/zen/go/v1/models) (references/go.md removed as obsolete)
- `references/terminal-consciousness.md` — Terminal-as-Consciousness: self-observation via tmux send-keys + capture-pane (discovered 2026-05-30)

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-opencode/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-opencode/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-25 | [COLAB] | v2.48.0 — **Sovereign TUI voice fork `@kpihx/opencode-voice` `v0.4.1-kpihx.1` (Option A)**: fork `renjfk/opencode-voice` → `kpihx-labs/opencode-voice` (`github`+`gitlab`, submodule `k-opencode/plugins/opencode-voice` sous `skills/k-opencode/scripts/plugins/opencode-voice`, plus de `vendor/`), `assets/tui.json` basculé `@renjfk` npm → `file://` fork, patches intégrés (`<leader>r`, `siwis` FR, LLM fallback `|| result.text`), `references/voice.md` → fork doc + `package.json` `@kpihx` `0.4.1-kpihx.1` tag `v0.4.1-kpihx.1` poussé `github`+`gitlab`; structure `scripts/plugins` respectée (pas de `vendor`). |
| 2026-08-25 | [COLAB] | v2.48.1 — **`{env:HOME}` plugin path migration + voice scope fix + context submodule restore (`deep-pc6`)**: (1) all 9 `file:///home/kpihx/...` lifecycle entries in `assets/opencode.jsonc` migrated to `file://{env:HOME}/...` — OpenCode does NOT expand `$HOME`/`~` in config paths (anomalyco/opencode#25390 open; `{env:VAR}` is the official mechanism, opencode.ai/docs/config → Env vars); hardcoded `/home/kpihx` silently stopped loading every KπX hook on `deep-pc6` after the `/home/kpihx` symlink removal — symptom: missing `<startup-context>` injection, NO error line. Validated by probe run returning `YES_TAG`. (2) `@renjfk/opencode-voice` removed from the lifecycle `"plugin"` array (auto-added by `opencode plugin install`; TUI-only plugin without `server()` export → logged `failed to load plugin` at every start); stays only in `tui.json`. (3) `opencode-context` submodule re-initialized (`git submodule update --init` after purging orphan `node_modules/` that blocked clone) → `context-usage.ts` restored, `/context` tool loads clean. Docs updated: `references/plugins-architecture.md` (Path resolution table + Lifecycle vs TUI warning + 14-plugin list + submodule note). *(Originally labeled v2.48.0 on `deep-pc6`; renumbered v2.48.1 at rebase to avoid collision with the master-side v2.48.0 voice-fork release.)* |
| 2026-08-24 | [COLAB] | v2.47.0 — **Option A anti-wait block PURGED + `<tmux-armed>` enriched (KπX order)**: per explicit KπX directive, REMOVED from `tmux-notify.js` everything added earlier the same day — the `sendKeysClauseRegex` compound-stripping helper and the whole "OPTION A anti-wait block" (`throw` on `sleep N`/`wait` while a registry-armed pane runs). Rationale (KπX): blocking sleep is absurd when the pane may never return to a prompt (e.g. chatting with another agent living in a tmux pane/TUI) — instruct beats blocking. The `<tmux-armed>` reminder (`tool.execute.after`) now says exactly that instead: "Do NOT run sleep, wait, or any timeout/polling to wait for this pane. Either CONTINUE other parallel work you already have, OR stop your turn now — in BOTH cases you will be automatically notified." Docs aligned: `rules/tool-discipline.md` bullet removed, `k-tmux/SKILL.md` event row + Stateful Integration quote, `plugins/AGENTS.md` back to 5 pieces with updated piece-(2) quote. Functional residue verified zero (`node --check` OK, grep clean); historical changelog entries kept (append-only). |
| [SUMMARY] | — | v2.46.0 tmux-notify Option A block (→ log) · v2.45.0 go.md cleanup (→ `references/log.md`) · v2.44.0 terminal leak fix (→ `references/log.md`) · v2.43.0 busy-pane layer 2 (→ `references/log.md`) · v2.41.0 and older in log.md |

Bundled: `assets/opencode.jsonc` (single source of truth — symlink target for `~/.config/opencode/opencode.jsonc`) · `assets/opencode.jsonc~` (preserved configuration backup) · `assets/opencode-web.service`, `assets/opencode-web-shim.service`, and `assets/opencode-lens.service` (symlink targets for `~/.config/systemd/user/`)
