# Plugins — Four Systems

OpenCode has **four separate extension systems**, configured or injected differently:

| System | Config file / Injection | Mechanism | Purpose |
|--------|------------|-----------|---------|
| **Lifecycle plugins** | `opencode.jsonc` → `"plugin"` array | npm or `file://` JS modules | `event` hooks, `messages.transform`, tool definitions |
| **TUI plugins** | `tui.json` → `"plugin"` array | npm modules | UI extensions (voice STT/TTS, visual) |
| **Slash commands** | `.opencode/commands/*.md` | Markdown files auto-discovered | Custom `/command` shortcuts in TUI |
| **Web UI plugins** | Injected via `opencode-lens` proxy | Client-side JS script | Web browser interface extensions (e.g. voice mic and language selector) |

## Lifecycle plugins — 3 installation types

| Type | Format | Example | When to use |
|------|--------|---------|-------------|
| **npm package** | `"package-name"` | `"opencode-dir"` | Official or published npm plugins (auto-installed by OpenCode) |
| **npm with version** | `"package-name@version"` | `"opencode-antigravity-auth@latest"` | Pin a specific version or track `@latest` |
| **Local file** | `"file:///absolute/path.js"` | `"file:///home/kpihx/.agents/skills/k-opencode/scripts/hooks/startup-context.js"` | Custom/private plugins tracked in `.agents` git repo |

## Current KπX lifecycle plugins (11)

These are loaded from `opencode.jsonc` → `"plugin"` array:

```jsonc
"plugin": [
  "opencode-dir",                           // Type 1: npm — directory navigation
  "opencode-ssh-session",                   // Type 1: npm — persistent SSH sessions
  "opencode-ast",                           // Type 1: npm — AST code structure (outline, symbol, definitions, references)
  "opencode-antigravity-auth@latest",        // Type 2: npm@version — Claude + Gemini via Google OAuth (free)
  "opencode-claude-auth@latest",             // Type 2: npm@version — Claude Code credentials reuse (no separate login)
  "file:///home/kpihx/.agents/skills/k-opencode/scripts/hooks/startup-context.js",      // Type 3: file:// — KπX startup context injection
  "file:///home/kpihx/.agents/skills/k-opencode/scripts/hooks/prompt-enforcer-lite.js",   // Type 3: file:// — KπX enforcement block (Agent only, after real user msg)
  "file:///home/kpihx/.agents/skills/k-opencode/scripts/hooks/prompt-enforcer-strict.js", // Type 3: file:// — KπX enforcement block (strict)
  "file:///home/kpihx/.agents/skills/k-opencode/scripts/hooks/stop-enforcer.js",          // Type 3: file:// — KπX stop enforcer (Agent only)
  "file:///home/kpihx/.agents/skills/k-opencode/scripts/hooks/math-enforcer.js",          // Type 3: file:// — KπX math formatting rule (Explore only)
  "file:///home/kpihx/.agents/skills/k-opencode/scripts/hooks/suggestions-check.js"       // Type 3: file:// — KπX format reminder (MUST run last)
]
```

## KπX Managed — `scripts/hooks/` (file://)

These are the **KπX sovereign hooks** — self-contained `.js` files in `skills/k-opencode/scripts/hooks/` (helper libs in `scripts/hooks/libs/`). Each is listed via `file://` URL in the `"plugin"` array (order matters). No symlink needed. Full standard: `references/hooks-standard.md`.

| File | Event | Agent filter (`TARGET_AGENTS`) | Behavior |
|------|-------|-------------|----------|
| `libs/agent-scope.js` | shared utility | all scoped hooks | Resolves only the latest explicit `info.agent`; historical agent names never authorize an injection after an in-session switch |
| `startup-context.js` | `messages.transform` (first turn only) | `["Colab", "Agent", "Auto"]` | Injects raw `k-context/SKILL.md` + device-identifying string (device name only) |
| `prompt-enforcer-lite.js` | `messages.transform` (backward scan, after real user msg) | `["Agent"]` | Injects the enforcement block as `role: "user"` ONLY after a real user message (never during tool cycles) |
| `prompt-enforcer-strict.js` | `messages.transform` (every turn) | `["Colab", "Auto"]` | Pushes raw first-person enforcement block as `role: "user"` at end of prompt |
| `stop-enforcer.js` | `session.idle` | `["Agent"]` | Reads `/session/{id}/message` through `client.session.messages()`; after real tool activity, injects first-person STOP CHECK (re-read request, completion check, verification rules, renewable-sleep mandate), forces summary + pending answers |
| `math-enforcer.js` | `messages.transform` (every turn) | `["Explore"]` | Injects LaTeX/math formatting rules for the Explore agent |
| `suggestions-check.js` | `messages.transform` (every turn, MUST run last) | `["*"]` | Injects system message: ≥3 Suggestions required |

**Agent detection:** Every scoped plugin resolves the **latest** explicit `info.agent` through `libs/agent-scope.js`. `stop-enforcer.js` reads history with `client.session.messages()` on idle; transform hooks receive the same message history. Historical agent names never authorize an injection after an in-session switch, so non-matching agents get zero injection and return silently.

**Execution order (plugin array order matters — CRITICAL, see `references/hooks-standard.md` → "Ordering rule"):**
1. `startup-context` fires → unshifts context block at start of messages
2. `prompt-enforcer-lite` fires → checks `messages.at(-1)` is a real fresh user text message, pushes enforcement block after it for Agent
3. `prompt-enforcer-strict` fires → pushes enforcement block at end of messages for Colab/Auto
4. `stop-enforcer` fires → `session.idle` reads message history, detects only Agent, and re-prompts with completion check after tool activity
5. `math-enforcer` fires → pushes math formatting rules at end of messages for Explore
6. `suggestions-check` fires → pushes format reminder at the very end (MUST be last — see `ISS-2026-08-09` below)

### ⚠️ Ordering bug fixed 2026-08-09 (`prompt-enforcer-lite.js` silently never fired)

`suggestions-check.js` used to be **first** in the `"plugin"` array and unconditionally appends a `role: "system"` message at the end of `output.messages` for **every** agent, on **every** turn. Since `prompt-enforcer-lite.js` checks `messages.at(-1)` to decide "is the last message a fresh user text?", running `suggestions-check` before it meant `prompt-enforcer-lite.js` always saw the trailing `system` message instead of the real last user message — its guard failed **every single time, for the entire lifetime of the hook**, and it never once injected. Confirmed via a standalone Node script that replayed the exact plugin-array execution order (`node --input-type=module`, see session log). Fixed by moving `suggestions-check.js` to the **end** of the `"plugin"` array — any hook that inspects `messages.at(-1)` must run before any hook that unconditionally appends a trailing message.

## TUI plugin (`tui.json`)

```jsonc
// ~/.config/opencode/tui.json (symlink → assets/tui.json)
{
  "$schema": "https://opencode.ai/tui.json",
  "plugin": [["@renjfk/opencode-voice", {}]]
}
```

Config source: `assets/tui.json` — symlinked to `~/.config/opencode/tui.json`. Full voice setup, models, keybinds → `references/voice.md`.

## Slash commands (`.opencode/commands/`)

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

## Web UI plugins (injected via `opencode-lens` proxy)

These plugins do not run within the OpenCode core process, but are injected into the DOM of the OpenCode Web UI via the `opencode-lens` reverse proxy.

*   **Example — `opencode-web-voice-plugin`:**
    *   **Rôle :** Ajoute un bouton microphone et un sélecteur de langue (EN/FR/Auto) à l'interface web pour le Speech-to-Text utilisant la Web Speech API du navigateur.
    *   **Emplacement :** Les fichiers d'injection se trouvent sous `.agents/skills/k-opencode/scripts/plugins/web/`.
    *   **Installation :** Chargé dynamiquement par le proxy Node.js `opencode-lens` qui intercepte le trafic web (exposé sur le port Tailscale `2443` via `tailscale serve`), désactive le Content-Security-Policy (CSP) et injecte le script JS.

**Device auto-detection pipeline:**
```
tailscale status --json → Self.DNSName → assets/infras.json lookup → skills/<k-*>/SKILL.md read
Fallback: os.hostname() if tailscale unavailable
```

**Source files:** `skills/k-opencode/scripts/hooks/` — tracked in `.agents` git repo, auto-deployed on push.
