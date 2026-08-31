---
name: k-opencode
description: >
  OpenCode CLI runtime — global config (opencode.jsonc), AGENTS/skills symlink wiring,
  MCP local/remote config, provider auth flow, and operational verification commands.
  Load when installing OpenCode, configuring MCPs, or debugging OpenCode runtime behavior.
  Registry in k-clis.
license: private
metadata:
  version: 2.69.0
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
1. **Lifecycle plugins:** (`opencode.jsonc` → `"plugin"`, npm or local `file://{env:HOME}` JS modules). 17 active plugins (8 npm, 9 local: 8 hooks + 1 submodule tool). See **`references/plugins-architecture.md`**, ecosystem research + install log in **`references/plugin-watch.md`**, and coding standards in **`references/hooks-standard.md`**.
2. **TUI plugins:** (`tui.json` → `"plugin"`, `file://` sovereign fork) for console interface features (voice STT/TTS via `@kpihx/opencode-voice` `v0.4.1-kpihx.1` fork de `renjfk`). ⚠️ **Config/link registration ≠ runtime readiness (GRAVÉ):** registering a plugin (config array, `tui.json` symlink, `file://` path) only loads its JS glue — every external binary, service, or model file the plugin invokes MUST ALSO be installed and verified **per machine** (e.g. voice: `sox`/`whisper-cli`/`piper`; hooks: `tmux` CLI; web voice: lens proxy). Run the owning skill's dependency checks before declaring the feature working. Per-machine deployment checklist → **`references/voice.md`**.
3. **Slash commands:** (`.opencode/commands/*.md` auto-discovered markdown files) for interactive shortcuts (like `/context`). See **`references/context-plugin.md`**.
4. **Web UI plugins:** Injected via the `opencode-lens` proxy to extend the browser-based UI (e.g. `opencode-web-voice` Web Speech mic, `opencode-web-model-line` model-selector own-line fix). See **`### Web UI plugins (opencode-lens proxy)`** below.

**Device auto-detection pipeline:** `tailscale status --json → Self.DNSName → assets/infras.json lookup → skills/<k-*>/SKILL.md read` (fallback `os.hostname()`).

### Voice (TUI — @kpihx/opencode-voice `v0.4.1-kpihx.1` sovereign)

STT + TTS 100% local via `@kpihx/opencode-voice` (`kpihx-labs/opencode-voice`, fork `renjfk`, `v0.4.1-kpihx.1`: siwis FR, `<leader>r`, LLM fallback). Config in `tui.json` (`file:///…/scripts/plugins/opencode-voice`, not `@renjfk` npm), tracked as `assets/tui.json` (submodule `k-opencode/plugins/opencode-voice`, `github`+`gitlab`). Dependencies (sox, whisper-cli, piper), model install/management, keybinds, and sovereign patches → **`references/voice.md`**. The sovereign wrappers `k-whisper` / `k-piper` (see `k-ai`) manage the same models and voices.

### Providers: Ollama (local) & Ollama6 (deep-pc6)

Two OpenAI-compatible providers auto-synced from local/remote Ollama servers: `ollama` (port 11434, via `scripts/opencode-ollama.sh`) and `ollama6` (port 11436 through the DxO tunnel, via `k-dxo/scripts/opencode-ollama6.sh`). Both do surgical sub-block JSONC replacement (other providers untouched). Full config examples → **`references/providers.md`**.

**⚠️ Non-`:latest` tag bug (fixed 2026-08-27) + the `kr` reflex:** `opencode-ollama.sh` used to build its JSONC key via `name.split(":")[0]` unconditionally — safe ONLY for the `:latest` tag (Ollama resolves a bare name to `:latest` implicitly), but any other explicit tag (`:1.7b`, `:4b`, `:1b`, future `:14b`) got silently truncated, causing `model "X" not found, try pulling it first` even though the model was actually present, and **silent dict-key collisions** when two different tags of the same base model exist (`qwen3:4b` + `qwen3:1.7b` both stripped to `"qwen3"` → last one wins, the other vanishes from `opencode.jsonc` with zero error). Fixed: `model_id = name.split(":")[0] if name.endswith(":latest") else name` — full tag kept as key for any non-`:latest` pull, in both `opencode-ollama.sh` (local) and mirrored check confirmed already-correct in `k-dxo/scripts/opencode-ollama6.sh` + `k-windows/scripts/remote-server/opencode-ollama-server.sh` (both already used the full tag as key from the start, no bug there).

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
| 2026-08-30 | [LIVE] | v2.69.0 — **`raw-exec-guard.js` duration threshold + false-positive fix (KπX: "ne bloque les sleep/timeout que si >20s et évite les faux positifs comme --wait-for-cdp")**: `sleep` and `timeout` are now only blocked when their duration exceeds `POLL_THRESHOLD_SECS` (20s) — short inline polls (`sleep 5`, `timeout 3 curl ...`) are allowed. `wait` (bash builtin) is always blocked (indeterminate, no duration). False-positive guard: `WAIT_PATTERN` uses `(?<![a-zA-Z-])\bwait\b` so flags like `--wait-for-cdp` or `--wait-for-something` are NOT blocked — only the bare `wait` bash builtin (preceded by space, quote, or start-of-string) triggers. Error messages now include the actual duration and the threshold for clarity. 29/29 tests green (8 new cases covering threshold boundaries, `--wait-for-cdp`, `--wait-for-something`). |
| 2026-08-30 | [LIVE] | v2.68.0 — **`tmux-notify` capture depth 20→50 + automatic-result fallback (KπX request):** default `TMUX_LINES` is now 50. The proactive `<tmux-armed>` reminder now orders a one-shot larger `tmux capture-pane -p -t <pane> -S -100` diagnostic capture whenever the final automatic capture is empty, incomplete, or insufficient; it explicitly forbids turning that fallback into polling. `k-tmux` v1.30.0 + governing stateful-command docs aligned. |
| 2026-08-29 | [LIVE] | v2.67.0 — **New hook `raw-exec-guard.js` — technically enforces 2 long-standing PROSE-ONLY rules (KπX: "il faut un hook qui intercepte les sudo hors tmux send keys et qui bloque... aussi les sleep wait timeout")**: blocks any raw bash command containing `sudo` or `sleep`/`wait`/`timeout`, UNLESS it is already a compliant `tmux send-keys -t <target> ...` call (quoted payload runs in the pane, never the agent's own shell). Same `throw`-only pattern as `make-check-guard.js` (mutating `output.args` doesn't propagate, upstream opencode #31680), no `TARGET_AGENTS` (global kernel rule, `tool.execute.before` has no `messages` to scope by). A 3rd idea proposed alongside this (detect any raw command running >30s, kill it, relaunch the agent) was explicitly REJECTED by KπX as out of scope — not achievable anyway (no PID access to the real subprocess, no reliable command rewriting) — kept the hook simple and fully verifiable instead. New shared lib `libs/tmux-patterns.js` (`SEND_KEYS_REGEX`) extracted from `tmux-notify.js`, which was refactored to import it (was duplicated twice internally, would have been a 3rd copy in the new hook). 17/17 tests green (`tests/hooks/raw-exec-guard.test.mjs`, imports the real module, same style as `make-check-guard.test.mjs`). Registered in `opencode.jsonc`. |
| 2026-08-29 | [LIVE] | v2.66.0 — **`tmux-notify.js` watchdog/armed/control messages rewritten as an explicit A/B/C/D decision tree (KπX 2nd-pass correction: "je ne vois pas où tu éclaires l'agent... il risque de ne pas savoir quoi faire")**: v2.65.0's escalating guidance still wasn't concrete enough — KπX pasted a real transcript of an agent stuck looping "Understood, I will follow these instructions" without ever deciding anything. Every `<tmux-watchdog>` now opens with an unambiguous `STATUS:` line ("has NOT returned to its shell yet") + an explicit infinite-loop warning, then a lettered decision tree covering EVERY real case with the EXACT command for each: **A** interactive program you're driving → send more input or `tmux send-keys -t <pane> C-c` when done; **B** normal but slow, expect much longer → `: TMUX_ADJUST <pane> <secs>` now; **C** normal, current interval fine → do nothing, next check is automatic; **D** stuck/crashed/forgotten → `tmux send-keys -t <pane> C-c` now or be woken forever. `<tmux-armed>` (first message after send-keys) and `<tmux-control>` (owner sends follow-up input) rewritten to the same STATUS+decision-tree structure — never assuming an agent still remembers an earlier message's context, since a watchdog can fire much later in a very different part of the conversation. 26/26 pure-logic unit tests green (updated `/tmp/opencode/test-tmux-adjust.mjs`). |
| 2026-08-29 | [LIVE] | v2.65.0 — **`tmux-notify.js` timeout self-adjustment + escalating watchdog guidance (KπX request)**: a recurring watchdog on a fixed interval with an unchanging message left the agent no clear next action, and the only prior idea for widening it (`send-keys`-ing an env var into the pane) risked polluting the stdin of whatever is actually running there. Added a pure no-op meta marker `: TMUX_ADJUST <pane> <seconds>` (bash `:` builtin — always succeeds, zero side effects, NEVER a `send-keys` call) recognized by an anchored regex in `tool.execute.before`; if the calling session owns the lease, updates `entry.timeoutSecs` in-memory, clears+re-arms the watchdog (countdown restarts), resets `entry.watchdogCount`; ownership-gated like send-keys (another session → `denied`; no lease → `noop`, never a hard error) with a `<tmux-timeout-adjusted>` confirmation via `tool.execute.after`. `notificationFor()` now tracks `watchdogCount` and escalates guidance: checks 1–2 → continue in parallel or adjust if expecting longer; checks ≥3 → "genuinely long-running, not stuck", push adjusting or `Ctrl+C` to abort — every watchdog/armed message states the exact adjust syntax. 23/23 pure-logic unit tests green (`/tmp/opencode/test-tmux-adjust.mjs`, regex + escalation + confirmation shapes). Docs: `scripts/plugins/AGENTS.md` (6 pieces, was 5), `k-tmux` v1.27.0. |
| 2026-08-28 | [LIVE] | v2.64.0 — **tmux-notify owner-aware pane leases**: the session that armed a pane may now send further interactive input, corrections, or cancellation keys without overwriting the original completion watch; all other OpenCode sessions remain blocked. Prompt events are timestamp-correlated to ignore a late prompt from the prior command after a rapid relaunch. `TMUX_MODE=interactive` changes timeout output into a neutral `<tmux-watchdog>` (still open; no completion inferred); shell return remains the authoritative `<tmux-notify>`. `capture-pane` stays a diagnostic fallback, never a polling target. |
| 2026-08-27 | [COLAB] | v2.63.0 — **`openvino` auto-discovery + `opencode-models-discovery` (KπX directive: "plus de liste manuelle")**: `provider.openvino` passé de `models: {qwen3-0.6b: ...}` (hardcodé) à `modelsDiscovery: {enabled:true}` via `opencode-models-discovery@latest` (plugin `GET /v1/models` → `id`/`context_length` depuis `~/.local/share/openvino/models/<id>/config.json` `max_position_embeddings` 40960). `AI/openvino/src/k_openvino/serve.py` expose désormais `GET /v1/models` avec `context_length` + `GET /v1/models/{id}`. `openvino` provider `11436→11437` (conflit `ollama6`). Vérifié `opencode models openvino` → `openvino/qwen3-0.6b` auto, `opencode run --agent Lite --model openvino/qwen3-0.6b` → `hi` (plus de `Provider not found`). Docs `references/providers.md` + `references/plugin-watch.md` mis à jour. |
| 2026-08-27 | [COLAB] | v2.62.0 — **`opencode-notify` end-to-end harden — auto mode, lisibilité Telegram, limite 4096 (KπX: "ça marche à merveille")**: **Auto mode** (KπX: "quand j'active le mode auto plus d'approbation demandée mais pourtant les outils validés envoient toujours des notifs") — recherche web + lecture directe du binaire + `kv.json`/`session.json`/`plugin-meta.json` ont prouvé que `Z.permission.mode` (toggle `Ctrl+P` "Enable auto-approve permissions") est un état **RAM-only du process TUI**, jamais persisté ni exposé côté serveur — aucun `GET /config/yolo`, aucun champ `permission.mode` dans les `types.gen.d.ts` installés, aucun event dédié. Solution robuste (pas de pari temporel fragile): corrélation déterministe `permission.asked.id === permission.replied.requestID` avec debounce `250ms` (`pendingPermissions: Map<id, timeout>`) — `permission.asked` arme un timer, `permission.replied` (`reply:"once"` en `30ms` en auto, vs secondes en manuel) l'annule avant déclenchement. Vérifié live: manuel `edit /tmp/notify-final-manual2.txt` → `asked 16:27:30.996` → `still pending` → `dispatch WARN` → Telegram `Dir: tmp` + diff lisible; auto `edit /tmp/notify-auto-test.txt --auto` → `asked 16:28:26.518` → `replied 16:28:26.548` (`30ms`) → `notification cancelled` → zéro `WARN`, seul `OK` final à la vraie fin (`finish:"stop"`). **Lisibilité Telegram** (KπX: "je rate énormément le contenu, seul edit marche") — extraction étendue aux vrais champs `permission`/`patterns`/`metadata.filepath`/`metadata.diff` (pas `type`/`title`/`pattern` vides) + `Dir: <project>` systématique + bloc `<pre>` pour le code; **HTML escape Bash** (`2>&1` → `2>gt;&1`) fixé (`_notify_html_escape` passait `&` non échappé, interprété par `patsub_replacement`) → `\&amp;`/`\&lt;`/`\&gt;`; vérifié live `sudo ls /tmp 2>&1 <tag>` → rendu exact. **Limite Telegram 4096** (KπX: "troncature" → "mets la limite exacte") — recherche web confirmée `4096` officiel; `libs/notif/notifier.sh` tronque désormais **uniquement le corps du message** (`esc_message`) au budget `4096 - header - code_block -1`, jamais le titre ni le bloc `<pre>`; suppression du `slice(0,800)` côté `opencode-notify.js` (texte final complet). Tous les tests live `cd /tmp` `Gemini 3 Flash Preview` depuis panes vides (`ubuntu:1.0`/`2.0`), règle `/tmp` gravée en `Operational Rules` + `AGENTS.md` `3.8.3`. |
| 2026-08-27 | [COLAB] | v2.61.0 — **New Lens Web plugin `opencode-web-model-line`**: forces the model selector (`[data-action="prompt-model"]`) onto its own full-width line so a long model name never overlaps the submit button; also lets the bottom bar grow (`h-11`→auto) so wrapped controls + dropdown menus aren't clipped by `overflow:clip`. Registered in `assets/opencode-lens.service` `OPENCODE_WEB_PLUGINS` and `opencode-lens/lens.config.json`. Live-verified in a real session (Playwright): model on own line (ratio 1.0), agent dropdown opens (Live/Colab/Explore/Lite), no overlap with a 70-char model name. |
| 2026-08-27 | [COLAB] | v2.60.0 — **`opencode-ollama.sh` non-`:latest` tag truncation bug fixed + Lite compact kernel built (KπX multi-turn session: Lite option B, model research, live bug hunt)**: (1) `Lite` now gets a swapped compact `agents/Lite/AGENTS.md` (~50 lines, 8% of the full kernel) instead of the native full `AGENTS.md` injection, via new hook `scripts/plugins/hooks/lite-instructions-swap.js` (`experimental.chat.system.transform`, fingerprint-based swap, race-free — no cross-hook state) — live-verified on `ubuntu:1.0` (`Live` unaffected, `Lite` correctly swapped, logged to `/tmp/lite-swap.log`). Compact kernel later grounded with an explicit `## Tools` section (KπX: small models like `qwen3:1.7b` hallucinated "no local tool available, only webfetch" despite `bash`/`read`/`glob` being genuinely present — a capability/grounding gap in the tiny model, not a config bug) and a `.agents` minimal structure map (`Makefile`/`scripts`/`libs`/`skills`, "always check `skills/` first"). Purged 4 dead MCP `deny` entries from `Lite.permission` (`mail_fallback_*`/`tick_fallback_*`/`chrome-agent_*`/`linkedin_*` — MCPs no longer exist) and the `phi4-mini` model (Microsoft-identity hallucination override, `ollama rm` + removed from `provider.ollama.models`). (2) **Root-caused a real recurring bug**: `opencode-ollama.sh` built its JSONC model key via unconditional `name.split(":")[0]`, safe only for `:latest`-tagged pulls, silently truncating/colliding any explicitly-tagged pull (`qwen3:1.7b` → `model "qwen3" not found`; `qwen3:4b`+`qwen3:1.7b` together → dict collision, one silently vanishes) — fixed with an `endswith(":latest")` guard; confirmed `k-dxo`/`k-windows` sibling sync scripts were already correct (never had the bug). Root-caused the SECOND layer of the same incident live: editing the script on disk does not affect already-running shells' cached function — 2 live tmux panes (`%2`, `%3`) proved the fix only takes effect after `kr` (existing `.kshrc` reload alias) + a fresh `ollama sync`; an `opencode-web.service` restart was wrongly assumed determinant (KπX corrected this directly — the browser terminal in question was TUI-embedded, unrelated to that systemd unit). Full detail → `k-context` Session Log. |
| 2026-08-27 | [COLAB] | v2.59.1 — **Live TUI test pane discipline (KπX: "les tests comme ce que tu viens de faire se font toujours dans /tmp")**: `Operational Rules` compact rule added — `opencode --prompt "edit /tmp/notify-*"` permission tests must run with pane cwd `/tmp` (or `cd /tmp` first), guarantees `tmp/...` permission patterns match and keeps all `notify-*` test artefacts out of project workdirs. Same rule mirrored in root `AGENTS.md` → `File Operations Discipline` (compact). |
| 2026-08-27 | [COLAB] | v2.59.0 — **`opencode-notify.js` full rewrite, not a patch (KπX explicit demand after finding the abort-suppression patch still broken live: missing notif on a real permission-ask, spurious notifs "when nothing happens")**: web-researched the real OpenCode plugin lifecycle instead of trusting the local SDK `.d.ts` alone — confirmed via `github.com/anomalyco/opencode` issues #3815/#3744/#16626/#2021 that `session.idle` is **fundamentally unreliable**: it fires MULTIPLE TIMES per real agent turn (once per internal tool-call loop iteration), well before actual completion — exactly the root cause of "notifies when nothing happens". **Live-validated against THIS conversation's own real session data** (`curl` against the running daemon's `/session/{id}/message`): 13 of the last 15 assistant messages had `finish:"tool-calls"` (mid-loop) vs 1 with `finish:"stop"` (the one genuine completion) — the old code notified on all of them via blind `session.idle` trust. New logic: only notify when the LAST assistant message's `finish === "stop"` (a real stop, which also covers "the agent is asking me a question" — same bucket, no separate signal needed) AND `error?.name !== "MessageAbortedError"` (KπX's own Escape-Escape, explicitly excluded — validated against 4 real abort examples in session history, all `finish:undefined`, never `"stop"`, confirming the check is airtight even without the redundant explicit error-name guard). Dropped entirely: the abort-tracking `Map` (replaced by a single `finish` field check), the decorative `SCOPE_AGENTS=["*"]` gate (never filtered anything, pure dead weight). 204 lines → 105 (nearly half) — matches KπX's explicit "code unifié ultra compact, sans superflu". `permission.ask` hook kept as-is (confirmed correct/real API via the same research pass). `node --check` OK + live simulation against the real running session confirmed correct `true`/`false` output at each state. |
| 2026-08-27 | [COLAB] | v2.58.0 — **3 fixes in one pass, all live-verified after daemon restart**: (1) **Lens/Web/Shim docs restructured (KπX: "à chaque fois tu parles toujours de opencode-web pourtant celui que j'utilise c'est opencode-lens... tu oublies toujours opencode-web-shim")** — `## OpenCode Web` section rewritten to lead with `opencode-lens` (the actual day-to-day entry point) instead of `opencode-web`, and `opencode-web-shim` promoted from a single throwaway mention to its own explicit middleware row + request-chain diagram (`Tailscale :2443 → shim :3000 → lens :30001 → web :40977`) — the old table had actually been WRONG, not just under-emphasized: it listed the shim's exposed ports (4097/3000) as if they belonged to `opencode-web`/`opencode-lens` directly, hiding that Tailscale hits the shim FIRST on both routes. (2) **`opencode-notify.js` abort-suppression** (KπX: "ça me notifie même quand c'est moi qui arrête (echap echap)") — `session.error` with `error.name === "MessageAbortedError"` (fired on a user Escape-Escape) now marks the session in a short-lived `Map` instead of reporting it as an error, and the `session.idle` that follows immediately after (session settling post-abort) is suppressed too within a 5s window; a genuine idle/error still notifies normally. Root-caused first: the daemon hadn't been restarted at the time, so what KπX saw was actually the OLD `opencode-notifications` plugin (never replaced live yet) — fixed proactively anyway so the new code was correct before the eventual restart. (3) **`notifier.sh` Telegram formatting overhaul** (KπX: "je vois très bien formaté la commande qui attend validation... message final"): legacy `parse_mode=Markdown` never rendered `**bold**` (that mode only supports single `*bold*` — the title was showing literal asterisks); switched to `parse_mode=HTML` + a real `_notify_html_escape` helper + `--data-urlencode` (the old `curl -d` never URL-encoded, silently corrupting any `&`/`%`/raw-newline in the text); added an optional 4th `code` param to `notify_telegram`/`notify_system`/`notify_mixed` rendering a `<pre>` monospace block (used for the exact bash command awaiting approval). **Full regression audit of all 12 existing `notifier.sh` callers** (k-pve, k-ubuntu, k-dockerhost) surfaced 2 real backward-compat breaks from the `--data-urlencode` switch — several scripts embed a literal `%0A` token (relied on old `-d`'s no-encoding to become a Telegram-side newline; `--data-urlencode` would have sent it as literal visible text) and legacy `` `code` ``/`**bold**` markup (never interpreted by HTML mode) — both fixed with backward-compatible conversions inside `notify_telegram` itself (zero changes needed in the 12 callers), verified against the exact source patterns from `boot_notify.sh`/`network_switch.sh` via real bash execution (NOT the tool's own zsh shell — a genuine methodology trap: sourcing a bash script directly in zsh silently changes `${var//pattern/replacement}` semantics). Live end-to-end confirmed via `tg-proxy chat-read` entity reconstruction (bold/code spans present after the fix, absent before). One live testing mistake self-caught and cleaned up: a manual smoke-test command incorrectly overrode `NOTIFY_TG_TOKEN=""` and fell through to `TELEGRAM_UBUNTU_TOKEN` again — message deleted via `chat-delete-messages` after confirming the mistake was in the ad-hoc test invocation, not in `opencode-notify.sh`'s own (already-hardened) token isolation. |
| 2026-08-27 | [COLAB] | v2.57.1 — **`opencode-notify.sh` Telegram fallback bug fixed (KπX caught it live: "ton code utilise ubuntu token or ça doit être TELEGRAM_OPENCODE_TOKEN")**: `notify_mixed` resolved its token via the shared `notify_tg_token()`, whose explicit-override check only short-circuits on a NON-EMPTY `NOTIFY_TG_TOKEN` — setting it to `"${TELEGRAM_OPENCODE_TOKEN:-}"` while that var was still unset left it empty, so it silently fell through to the shared chain and picked `TELEGRAM_UBUNTU_TOKEN`. Fixed by dropping `notify_mixed` entirely in `opencode-notify.sh`: `notify_system` always fires; `notify_telegram` is called ONLY inside an explicit `[ -n "${TELEGRAM_OPENCODE_TOKEN:-}" ]` guard, with `NOTIFY_TG_TOKEN` forced to that exact value — no chain, no possible fallback to another bot. Unset token now means Telegram is silently skipped (never impersonates another skill's bot). Verified live: single system-only log line, zero Telegram attempt. |
| 2026-08-27 | [COLAB] | v2.57.0 — **`opencode-notifications` purged + sovereign `opencode-notify` plugin created (KπX directive: "desinstalle car j'aime pas" + build a dead-simple always-on system+Telegram notifier)**: removed `"opencode-notifications"` from `assets/opencode.jsonc`, its cached npm package, and an unrelated orphan `~/.config/opencode/plugin/notificator.jsonc` (dead config, zero references anywhere, wrong dir — a genuine separate leftover found during the same cleanup). Built `scripts/plugins/opencode-notify/{opencode-notify.js,opencode-notify.sh}` — fires on `event`/`session.idle` (finished), `event`/`session.error`, and `"permission.ask"` (waiting for approval), verified against the live `@opencode-ai/sdk` types (the old plugin's `question.asked`/`permission.asked` events do NOT exist in this SDK version). Delivers via the shared `libs/notif/notifier.sh` (`notify_mixed` — system `notify-send` + Telegram in one call), never a private re-implementation; added `TELEGRAM_OPENCODE_TOKEN` to the notifier's fallback chain + `.env.example`. Every notification carries device hostname, resolved agent, and session title/directory. Extracted `detectDevice()` out of `startup-context.js` into a new shared `libs/device-info.js` (was a private unexported local function, now reused by both). **Corrected live by KπX mid-task: this is NOT a hook** — a hook actively shapes agent behavior (injects/transforms/blocks), this plugin only observes and fires a side effect, same category as `tmux-notify.js`/`opencode-context/`/`opencode-voice/`. Initially misplaced in `scripts/plugins/hooks/`; `mv`'d (not rewritten) into its own `scripts/plugins/opencode-notify/` subdirectory, all path references updated (`opencode.jsonc` registration, the `.sh`'s sibling-resolution in the `.js`). Added a permanent **"Hooks vs Plugins"** distinction table + a classification test to `scripts/plugins/AGENTS.md` (directory map, checklist, registration contract all updated) so this confusion cannot recur. Also corrected a live smoke-test mistake: a manual test fired a real Telegram message through the reused `TELEGRAM_UBUNTU_TOKEN` fallback (no dedicated token existed yet) — the fallback chain worked exactly as designed but this defeats the point of a DEDICATED OpenCode bot; a real `k_opencode_bot` was created via `tg-proxy do bot-create` (HITL, tmux ops pane) to fix this, see `k-tg/SKILL.md` bot inventory. Full purge/replacement narrative → `references/plugin-watch.md` → Purged → opencode-notifications. |
| 2026-08-27 | [COLAB] | v2.56.0 — **`Live` symlinks de-duplicated to real files + minimal Colab→Live rename + k-context gate scoped to exactly `$HOME/KpihX-Labs` (KπX directive)**: `agents/Live/prompt.txt` (was `→ ../Colab/prompt.txt`) and `assets/plugins/hooks/prompt-enforcer.txt` (was `→ prompt-enforcer-strict.txt`) were symlinks — KπX flagged this as wrong (each agent/hook asset should own its content, not alias another's). Both converted to real file copies (`cp`, not the Write tool, to save tokens); `agents/Live/prompt.txt` then got the 2 minimal "Colab"→"Live" text edits (`You are Colab...` → `You are Live...`, `You (Colab) —...` → `You (Live) —...`); `prompt-enforcer.txt` needed zero edits (no "Colab" mentions in the generic strict-enforcement prose). Also fixed a genuine pre-existing documentation gap surfaced by this change: `prompt-enforcer.js`/`prompt-enforcer.txt` (the dedicated Live hook — lite-style reminder injection, `TARGET_AGENTS=["Live"]`) was never listed in either `scripts/plugins/AGENTS.md` or `assets/plugins/hooks/AGENTS.md` inventory tables — added both rows. **k-context startup-injection gate**: `startup-context.js` `buildContext()` now takes an `inLabs` flag — the k-context (TODOs/Projects/Log) sub-block only injects when `inLabs` is true; `device-context`/`tmux-context` always inject regardless. `inLabs` is resolved by a NEW `isLaunchedFromLabs(client, messages)` helper — critically, this does NOT use `process.cwd()`: live process inspection (`/proc/<pid>/cwd`) proved the hook runs inside the single persistent `opencode serve` daemon (cwd fixed at daemon boot, e.g. `$HOME`), shared by every client/session launched from anywhere, so `process.cwd()` would always report the daemon's own launch dir, never the calling client's real directory. The correct SDK-documented mechanism (confirmed via `@opencode-ai/sdk` `types.gen.d.ts`): every message carries `info.sessionID`, and `client.session.get({ path: { id } })` returns `Session.directory` — the per-session field holding the CLIENT's actual launch directory. Gate is an EXACT match (`directory === $HOME/KpihX-Labs`, no subtree/prefix — KπX explicit: "exactement ~/KpihX-Labs"). `node --check` OK. **Not yet live**: plugins load once at `opencode serve` daemon boot, so this change only takes effect after the daemon is restarted (not done yet — would kill the current session; KπX to trigger when convenient). |
| 2026-08-27 | [COLAB] | v2.55.0 — **`Live` added to `startup-context.js` `TARGET_AGENTS` (KπX directive)**: `Live` is a Colab variant (same `prompt.txt`, same permission model, only differs by lite-style reminder injection via `prompt-enforcer.js`) but was missing from the startup-context gate, so `Live` sessions never got `<startup-context>` (k-context TODOs/Projects/Log) + `<device-context>` + `<tmux-context>` injected. Fixed `TARGET_AGENTS` to `["Colab","Live","Agent","Auto","Build","Plan"]` in `scripts/plugins/hooks/startup-context.js` and updated the inventory table in `scripts/plugins/AGENTS.md`. |
| 2026-08-27 | [COLAB] | v2.54.0 — **Kagan plugin purged (KπX directive: "purge le plugin kagan")**, same-day as install, no bug involved — clean removal by request. Removed `"@kagan-sh/kagan"` from `assets/opencode.jsonc`, `uv tool uninstall kagan` (`kagan`+`kg` binaries), and all state (`~/.local/share/kagan/`, `~/.cache/kagan/`, `~/.local/state/kagan/`, `~/.cache/opencode/packages/@kagan-sh/`) via the trash-safe `rm` wrapper. Purge audit surfaced a genuine footgun worth remembering: Kagan had `git init`'d a **rogue repo directly at `$HOME`** (`/home/kpihx/.git`, one empty commit, no secrets tracked) plus a linked worktree, because it had been run at least once with `$HOME` as its target directory — cleaned via `git worktree remove --force` then removing `/home/kpihx/.git`; verified empty (`git ls-tree -r --name-only HEAD` → nothing) before removal. Post-purge `plocate -i kagan` + `find ~ -iname "*kagan*"` both clean. Full detail moved (not deleted) to `references/plugin-watch.md` → new `## Purged` → `### Kagan` section per Zero Information Loss. |
| 2026-08-27 | [COLAB] | v2.53.0 — **Ecosystem plugins pass (KπX directive, 2-turn web research + live install/debug session)**: installed & active — `@kagan-sh/kagan` (Kanban/Jira board, worktree-isolated cards, human REVIEW gate — `uv tool install kagan`), `opencode-tasks` (cron daemon, systemd `--user` timer + `/loop`; found and worked around a real upstream bug — `bunx`/`bun add -g` fail staging the daemon because bun hoists deps flat instead of npm's nested layout, fixed via `npm install -g` for the maintenance CLI only), `opencode-notifications` (desktop notify, deps `xdotool`+`libnotify-bin` already present). **`oh-my-openagent` tried, found a real bug via A/B test, purged**: it ships its own subagent literally named `explore`, which silently shadows/drops KπX's primary agent `Explore` from the registry (confirmed live: `opencode agent list` shows `Explore (primary)` present without OMO, absent with it; `--agent Explore` fails only when OMO is loaded) — removed from `opencode.jsonc` + all residual state cleaned (`~/.omo/`, `~/KpihX-Labs/.omo/`, `~/.cache/oh-my-opencode/`, `~/.local/share/oh-my-opencode/`, cached package) via the trash-safe `rm` wrapper; **kept documented in `references/plugin-watch.md` per KπX ("je préfère avoir de la flexibilité, laisse quand même sa mention dans le skill au cas où")** for future reconsideration. Also fixed the **actual root cause of the original "Kagan handshake failed" report** — unrelated to any plugin: the free-tier default model `opencode/x-preview-f-free` had rotated out of the `opencode zen` catalog, crashing any session without an explicit model (Kagan-spawned sessions, bare `opencode run`); fixed via `--print-logs --log-level DEBUG` (`ProviderModelNotFoundError`, never used before this session) → global `model`/`small_model` + `Auto` → `opencode/mimo-v2.5-free`, `Explore` → `google/gemini-3-flash-preview` (KπX explicit choice, `Lite` untouched). Documented the `--pure`/`TARGET_AGENTS`-exclusion technique for scoping hooks out of `opencode run` invocations (no invocation-mode field exists in the `Hooks` API — verified via `@opencode-ai/plugin` type defs) and the native-vs-sovereign auto-injection map for `run` mode (config 6-path merge incl. legacy `~/.opencode/`, `AGENTS.md` always native, skills catalog always native, `<startup-context>` conditional/sovereign). Plugin count corrected 14→17 (8 npm, 9 local) — see `references/plugin-watch.md` for full detail. |
| 2026-08-26 | [COLAB] | v2.52.0 — **Config-link ≠ runtime-ready rule (KπX directive, blglaptop139 voice):** `Ctrl+X R` showed "Recording in progress" while zero voice deps existed — `tui.json` symlink only loads JS glue. Added GRAVÉ warning: every plugin's external binaries/services/models MUST be installed per machine. `Plugins & Hooks` intro gets a generic guard + TUI plugins bullet now points to the per-machine checklist in `references/voice.md`. |
| 2026-08-26 | [COLAB] | v2.51.0 — **`Build` added to `TARGET_AGENTS` + flushToSession drain-before-validate data-loss bug fixed (blglaptop139, KπX directive)**: after the import fix the plugin loaded (`<tmux-armed>` proven) but `<tmux-notify>` still never arrived. Server logs showed the session streams run as `agent=build` on this machine (KπX switched agent mid-session; `currentAgent()` resolves the LAST message's agent) while `TARGET_AGENTS` was `["Colab","Agent"]` → gate rejection. Worse: `flushToSession` called `takePending()` BEFORE the gate, so every gated-out notification was permanently DESTROYED instead of left queued — silent data loss on any future agent mismatch. Fixes: (1) `"Build"` added to `TARGET_AGENTS`; (2) `flushToSession` restructured — resolve agent + gate FIRST, drain only after the gate passes, with debug lines for gate-outs; early no-op return when nothing is queued avoids a pointless `session.messages` fetch. Verified: `node --check` OK + bun import OK. *(Renumbered from v2.49.0/v2.50.0 at PR merge.)* |
| [SUMMARY] | — | v2.48.2 `{env:HOME}` plugin path migration + voice scope fix + context submodule restore (deep-pc6) · v2.48.1 `references/voice.md` Plugin Install fresh-machine section · v2.48.0 sovereign TUI voice fork @kpihx/opencode-voice v0.4.1-kpihx.1 (submodule scripts/plugins/opencode-voice, tui.json file:// fork, patches `<leader>r`/siwis/LLM-fallback) · v2.47.0 Option A anti-wait block purged + `<tmux-armed>` enriched (KπX order; instruct beats blocking → `references/log.md`) · v2.46.0 tmux-notify Option A anti-wait block (KπX directive; superseded same day by v2.47.0 purge) · v2.45.0 go.md cleanup (→ `references/log.md`) · v2.44.0 terminal leak fix (→ `references/log.md`) · v2.43.0 busy-pane layer 2 (→ `references/log.md`) · v2.41.0 and older in log.md |

Bundled: `assets/opencode.jsonc` (single source of truth — symlink target for `~/.config/opencode/opencode.jsonc`) · `assets/opencode.jsonc~` (preserved configuration backup) · `assets/opencode-lens.service` (day-to-day proxy), `assets/opencode-web.service` (native backend), and `assets/opencode-web-shim.service` (dual-port middleware — see `## OpenCode Web` for the full request chain) — all 3 symlink targets for `~/.config/systemd/user/`
