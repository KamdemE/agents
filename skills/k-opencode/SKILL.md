---
name: k-opencode
description: >
  OpenCode CLI runtime — global config (opencode.jsonc), AGENTS/skills symlink wiring,
  MCP local/remote config, provider auth flow, and operational verification commands.
  Load when installing OpenCode, configuring MCPs, or debugging OpenCode runtime behavior.
  Registry in k-clis.
license: private
metadata:
  version: 2.79.1
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
- **Live TUI permission tests** (`opencode --prompt "edit /tmp/...`) **must run with pane cwd `/tmp` (or `cd /tmp` first)** — guarantees `tmp/...` permission patterns match and keeps project workdirs clean. All `notify-*` style test files live in `/tmp`.

## Permission System (2026-05-30 — Confiance Totale)

3-tier hierarchy: **Global config → Agent deltas → Session runtime**, `findLast` wins. Global bash zones (🟢 read-only, 🟡 low-risk, 🟠 trusted, 🔴 explicit ask), `.env`/`*auth.json`/`*credentials.json` protection, MCP permission overrides, and `external_directory` allowlist → full detail in **`references/permissions.md`**.

## Plugins & Hooks — Four Systems

OpenCode and its environment are extended via four distinct systems:
1. **Lifecycle plugins:** (`opencode.jsonc` → `"plugin"`, npm or local `file://{env:HOME}` JS/TS modules). 19 active plugins (6 npm, 13 local: 9 hooks + 4 non-hooks). `opencode-claude-auth` purged totally 2026-09-05 (KπX order, Claude unused). See **`references/plugins-architecture.md`**, ecosystem research + install log in **`references/plugin-watch.md`**, and coding standards in **`references/hooks-standard.md`**.
2. **TUI plugins:** (`tui.json` → `"plugin"`, `file://` sovereign fork) for console interface features (voice STT/TTS via `@kpihx/opencode-voice` `v0.4.1-kpihx.1` fork de `renjfk`). ⚠️ **Config/link registration ≠ runtime readiness (GRAVÉ):** registering a plugin (config array, `tui.json` symlink, `file://` path) only loads its JS glue — every external binary, service, or model file the plugin invokes MUST ALSO be installed and verified **per machine** (e.g. voice: `sox`/`whisper-cli`/`piper`; hooks: `tmux` CLI; web voice: lens proxy). Run the owning skill's dependency checks before declaring the feature working. Per-machine deployment checklist → **`references/voice.md`**.
3. **Slash commands:** (`.opencode/commands/*.md` auto-discovered markdown files) for interactive shortcuts (like `/context`). See **`references/context-plugin.md`**.
4. **Web UI plugins:** Injected via the `opencode-lens` proxy to extend the browser-based UI (e.g. `opencode-web-voice` Web Speech mic, `opencode-web-model-line` model-selector own-line fix). See **`### Web UI plugins (opencode-lens proxy)`** below.

**Device auto-detection pipeline:** `tailscale status --json → Self.DNSName → assets/infras.json lookup → skills/<k-*>/SKILL.md read` (fallback `os.hostname()`).

### Voice (TUI — @kpihx/opencode-voice `v0.4.1-kpihx.1` sovereign)

STT + TTS 100% local via `@kpihx/opencode-voice` (`kpihx-labs/opencode-voice`, fork `renjfk`, `v0.4.1-kpihx.1`: siwis FR, `<leader>r`, LLM fallback). Config in `tui.json` (`file:///…/scripts/plugins/opencode-voice`, not `@renjfk` npm), tracked as `assets/tui.json` (submodule `k-opencode/plugins/opencode-voice`, `github`+`gitlab`). Dependencies (sox, whisper-cli, piper), model install/management, keybinds, and sovereign patches → **`references/voice.md`**. The sovereign wrappers `k-whisper` / `k-piper` (see `k-ai`) manage the same models and voices.

### Help (non-hook plugin — `opencode-help/`)

Durable, explicitly parent-controlled peer sessions. Source: `scripts/plugins/opencode-help/` (git submodule, `github` + `gitlab` `kpihx-labs/opencode-help`), loaded through its TypeScript entry in `assets/opencode.jsonc`.

- **Tools:** `help_open`, `help_list`, `help_read`, `help_message` (`steer` or durable `queue`), `help_wait`, `help_close`, and `help_resume`.
- **Lifecycle:** a peer is an ordinary root OpenCode session, owned only by its creator across restarts. `help_close` archives/detaches it without deleting conversation history; no automatic escalation, spawning, or resumption exists.
- **Agent:** `help_open` requires an explicit agent name passed directly to OpenCode server-side `promptAsync`, which validates it; invalid agent names surface the server error verbatim.
- **Models:** KπX owns the required ordered allowlist in `assets/opencode.jsonc`: `google/gemini-3-flash-preview` (default), `opencode-go/deepseek-v4-pro`, `google/gemini-3.1-pro-preview`, `opencode-go/deepseek-v4-flash`, then `opencode-go/mimo-v2.5`. A caller may omit `model` for the first entry or explicitly select one of those entries only; the selected `{ providerID, modelID }` is persisted for follow-ups.
- **Provider failure:** no automatic fallback. A failed open archives its peer and reports every permitted alternative; the parent explicitly opens a replacement. A failed steer leaves its peer active and directs `help_close` then explicit reopen. A failed queued delivery returns its final OpenCode error and permitted models through `help_wait`.
- **Escape route:** `help_open` is the technical escape route when stuck/spinning. Combined with the `question` tool (for clarification from KπX), the agent has 2 complementary paths out of any blockage. Full reflex rules → `rules/tool-discipline.md` → `## Help & Question Reflexes`.

### Providers: Ollama (local) & Ollama6 (deep-pc6)

Two OpenAI-compatible providers auto-synced from local/remote Ollama servers: `ollama` (port 11434, via `scripts/opencode-ollama.sh`) and `ollama6` (port 11436 through the DxO tunnel, via `k-dxo/scripts/opencode-ollama6.sh`). Both do surgical sub-block JSONC replacement (other providers untouched). Full config examples → **`references/providers.md`**.

### Providers: OpenCode Go 2nd account (custom provider + proxy)

Custom provider `opencode-go-2` for a 2nd OpenCode Go subscription with separate billing. Key in `auth.json` (`~/.local/share/opencode/auth.json["opencode-go-2"]`), never hardcoded in JSONC.

**⚠️ `modelsDiscovery` URL path bug (2026-09-03):** The `opencode-models-discovery` plugin's `buildAPIURL()` uses `new URL(endpoint, new URL(baseURL).origin)` — this strips the path from `baseURL`. For OpenCode Go (`https://opencode.ai/zen/go/v1`), origin = `https://opencode.ai`, so discovery hits `https://opencode.ai/v1/models` (missing `/zen/go/` prefix). **Fix:** local reverse proxy at `localhost:4999` rewrites `/v1/*` → `https://opencode.ai/zen/go/v1/*`. Provider `baseURL` points to proxy.

- **Proxy script:** `scripts/opencode-go-proxy.js` — Node.js, reads API key from `auth.json`, rewrites paths.
- **Systemd service:** `opencode-go-proxy.service` — source of truth in `assets/`, symlinked to `$HOME/.config/systemd/user/`, registered in `assets/services.jsonc` + `assets/links.jsonc`.
- **Usage:** `"model": "opencode-go-2/mimo-v2.5"` or `"small_model": "opencode-go-2/deepseek-v4-flash"`.
- **34 models discovered** via `opencode models` (auto-fetched from `/v1/models`).

**Adding a custom provider (general pattern):**
1. Run `opencode auth login -p <custom-id> -m api-key` → stores key in `auth.json["<custom-id>"]`
2. Add provider block in `opencode.jsonc` with `"npm": "@ai-sdk/openai-compatible"`, `"options": { "baseURL": "..." }`
3. If `baseURL` has a non-trivial path (not just `/v1`), the `modelsDiscovery` plugin will strip it — use a local proxy or add models manually
4. If clean `/v1` endpoint → add `"modelsDiscovery": { "enabled": true }` for auto-discovery
5. Verify: `opencode models 2>&1 | grep "<custom-id>"`

**Non-`:latest` tag bug (fixed 2026-08-27) + the `kr` reflex:** `opencode-ollama.sh` used to build its JSONC key via `name.split(":")[0]` unconditionally — safe ONLY for the `:latest` tag (Ollama resolves a bare name to `:latest` implicitly), but any other explicit tag (`:1.7b`, `:4b`, `:1b`, future `:14b`) got silently truncated, causing `model "X" not found, try pulling it first` even though the model was actually present, and **silent dict-key collisions** when two different tags of the same base model exist (`qwen3:4b` + `qwen3:1.7b` both stripped to `"qwen3"` → last one wins, the other vanishes from `opencode.jsonc` with zero error). Fixed: `model_id = name.split(":")[0] if name.endswith(":latest") else name` — full tag kept as key for any non-`:latest` pull, in both `opencode-ollama.sh` (local) and mirrored check confirmed already-correct in `k-dxo/scripts/opencode-ollama6.sh` + `k-windows/scripts/remote-server/opencode-ollama-server.sh` (both already used the full tag as key from the start, no bug there).

**Editing a `.kshrc`-sourced function does NOT affect already-running shells.** Any interactive shell (tmux pane, TUI-embedded terminal, plain terminal) that was alive BEFORE the script edit keeps the OLD function body in memory — `ollama sync`/`ollama pull` run there will silently reproduce the old bug even though the file on disk is fixed. Restarting an unrelated systemd service (`opencode-web`, etc.) does **NOT** fix this unless that specific terminal is a child process of that exact service — never assume it does. **The correct fix, in that exact terminal:** run `kr` (existing `.kshrc` alias, l.341, does `unset __KSHRC_LOADED __KSHRC_INTERACTIVE_LOADED; . ~/.kshrc; cd back`) then re-run `ollama sync`/`ollama pull` — or simply close and reopen a fresh terminal (a brand-new shell process sources `.kshrc` cleanly with zero extra steps). See `k-zsh/SKILL.md` for the `kr` alias itself.

### Web UI plugins (opencode-lens proxy)

Browser UI extensions injected by the `opencode-lens` reverse proxy (`scripts/plugins/web/opencode-lens`). Each plugin is a plain browser JS module loaded via `lens.config.json` (or the `OPENCODE_WEB_PLUGINS` env in `assets/opencode-lens.service`). Plugins run at page load — **refresh the OpenCode Web tab after any plugin change**, and restart the proxy (`systemctl --user restart opencode-lens`) since it caches plugin code at startup.

- **`opencode-web-voice`** — Web Speech API microphone button (see `references/voice.md`).
- **`opencode-web-model-line`** — Forces the model selector (`[data-action="prompt-model"]`) onto its own full-width line in the prompt composer so a long model name never overlaps the submit button. Also lets the bottom bar grow (`h-11` → auto) so the wrapped controls and their dropdown menus are not clipped by the form's `overflow: clip`. Fixes the regression where forcing the selector full-width had made the agent selector and the Fr/EN language toggles unclickable in wide (landscape) layouts. Verified live in a real session: model selector on its own line (width ratio 1.0), agent dropdown opens (Live/Colab/Explore/Lite), no overlap even with a 70-char model name.

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

## OpenCode Web — 3 services, not 2 (systemd + Tailscale Serve)

**`opencode-lens` is the day-to-day entry point (KπX uses this on the web, NOT raw `opencode-web`)** — a reverse proxy that strips CSP and injects the Web Voice plugin on top of the native backend. `opencode-web` is the underlying native OpenCode backend Lens proxies to (and can also be hit directly, unproxied — "Clean/Safe Mode"). **`opencode-web-shim` is a third, easy-to-forget middleware piece** — a dual-port terminal-URL shim sitting in FRONT of both, required to fix a real upstream OpenCode bug (PTY/terminal connection, issue #5844). All three are exposed via `tailscale serve`; the tailnet root route is NOT opencode — it proxies the **OpenClaw Gateway** (see `k-openclaw`).

**The real request chain** (the port shown in `tailscale serve status` is the SHIM's port, never the backend's own port — a frequent source of confusion):
```
Tailscale :2443 → shim :3000 → opencode-lens :30001 → opencode-web :40977   (day-to-day, Lens/Interactive Mode)
Tailscale :1443 → shim :4097 → opencode-web :40977                          (direct native, Clean/Safe Mode)
```

| Service | Real port (local) | Reached via shim port | Tailscale Port | Ingress URL | Role |
|---------|-------------------|------------------------|-----------------|--------------|------|
| **`opencode-lens`** | `30001` | `3000` | `2443` | `https://kpihx-ubuntu.tail2527bd.ts.net:2443/` | **Lens Proxy + Injected Voice UI — the one actually used day-to-day (Interactive Mode)**. Proxies to `opencode-web` at `40977` (plugins at `scripts/plugins/web/`). |
| `opencode-web` | `40977` | `4097` | `1443` | `https://kpihx-ubuntu.tail2527bd.ts.net:1443/` | Native OpenCode backend — both the direct target for Clean/Safe Mode AND what Lens itself proxies to underneath. |
| `opencode-web-shim` | — (it IS the shim) | listens on `4097` + `3000` itself | — | — | **Middleware, not optional** — `terminal-url-shim.js`, dual-port (fixes upstream PTY/terminal connection bug #5844). This is what Tailscale `1443`/`2443` actually hit FIRST, before either backend. |
| `openclaw-gateway` | `18789` | — | `443` (root) | `https://kpihx-ubuntu.tail2527bd.ts.net/` | OpenClaw Gateway — tailnet root route (not opencode; see `k-openclaw`) |

Systemd units tracked as `assets/opencode-lens.service` (lens proxy), `assets/opencode-web.service` (native backend), and `assets/opencode-web-shim.service` (terminal URL shim middleware — `scripts/terminal-url-shim.js`).

```bash
systemctl --user status opencode-lens        # status lens (the one you actually use)
systemctl --user status opencode-web         # status native backend
systemctl --user status opencode-web-shim    # status the shim middleware
systemctl --user restart opencode-lens       # restart lens proxy
systemctl --user restart opencode-web-shim   # restart the shim (rarely needed — the fix it applies is static)
journalctl --user -u opencode-lens -f        # logs lens proxy
journalctl --user -u opencode-web-shim -f    # logs the shim
tailscale serve status                       # verify tailscale routing (shown ports are the SHIM's, see chain above)
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
- `references/plugin-watch.md` — Third-party ecosystem plugin research + install log (opencode-tasks, opencode-notifications active; Kagan purged 2026-08-27 per KπX directive — also exposed a rogue `git init` at `$HOME` footgun, see entry; Oh My OpenAgent tried, found a real `Explore`-agent-shadowing collision, purged — kept for flexibility per KπX), the `opencode-tasks` bunx install bug + workaround, the default-model breakage fix (`opencode/mimo-v2.5-free` + `Explore`→`google/gemini-3-flash-preview`), the `--pure`/`TARGET_AGENTS` hook run-mode scoping technique, and the CC Safety Net mechanism reference
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
| 2026-09-05 | [LIVE] | v2.79.1 `opencode-claude-auth` purged totally (KπX order, Claude unused): dead commented line removed from `assets/opencode.jsonc` + `references/plugins-architecture.md`, prose updated, `~/.cache/opencode/packages/opencode-claude-auth*` trashed (~126 MB). |
| 2026-09-03 | [LIVE] | v2.79.0 OpenCode Go 2nd account: custom provider `opencode-go-2` with local reverse proxy (`scripts/opencode-go-proxy.js`, port 4999) to work around `modelsDiscovery` URL path stripping bug. Systemd service `opencode-go-proxy.service` in `assets/` (source of truth), symlinked to OS, registered in `services.jsonc` + `links.jsonc`. 34 models discovered. `small_model` → `opencode/mimo-v2.5-free`. `opencode-claude-auth` deactivated + purged (ISS-20260902-003). Full Claude purge (desktop + CLI + configs, ~606 MB freed). |
| [SUMMARY] | — | v2.78.0 claude-auth deactivated + full Claude purge (~606 MB) · v2.77.0 opencode-help v0.4.0 model allowlist · v2.76.0 opencode-help v0.3.0 native delegation · v2.75.0 opencode-help v0.2.0 explicit defaults · v2.74.0 opencode-help structured SDK prompt diagnostics · v2.73.0 opencode-help v0.1.1 activation · v2.72.0 raw-exec-guard runtime `.env` loading protection · v2.71.0 file-path `.env` protection · v2.69.0 raw-exec duration threshold + false-positive fix · v2.68.0 tmux-notify capture depth 20→50 · v2.67.0 raw-exec guard technical enforcement · v2.66.0 tmux-notify A/B/C/D decision tree · v2.65.0 timeout self-adjustment + escalating watchdog · v2.64.0 owner-aware pane leases · v2.63.0 openvino auto-discovery · v2.62.0 opencode-notify auto mode + Telegram hardening · v2.61.0 `opencode-web-model-line` plugin · v2.60.0 Lite compact kernel + non-`:latest` tag fix · v2.59.x live TUI test pane discipline + opencode-notify rewrite · v2.58.0 Lens/Web/Shim restructure + abort-suppression + notifier formatting · v2.57.x Telegram fallback fix + sovereign `opencode-notify` plugin · v2.56.0 Live symlinks de-duplicated + k-context gate · v2.55.0 Live added to TARGET_AGENTS · v2.54.0 Kagan plugin purged · v2.53.0 ecosystem plugins pass · v2.52.0 config-link ≠ runtime-ready · v2.51.0 Build added to TARGET_AGENTS · v2.48.x voice fork + context submodule · v2.47.0 anti-wait block purged · v2.46.0 and older in `references/log.md` |

Bundled: `assets/opencode.jsonc` (single source of truth — symlink target for `~/.config/opencode/opencode.jsonc`) · `assets/opencode.jsonc~` (preserved configuration backup) · `assets/opencode-lens.service` (day-to-day proxy), `assets/opencode-web.service` (native backend), and `assets/opencode-web-shim.service` (dual-port middleware — see `## OpenCode Web` for the full request chain) — all 3 symlink targets for `~/.config/systemd/user/`
