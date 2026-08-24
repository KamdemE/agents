# scripts/plugins/ — KπX Agent Plugins (Guardrail)

**⚠️ MANDATORY — READ THIS FILE BEFORE ADDING OR MODIFYING ANYTHING UNDER `scripts/plugins/` OR `assets/plugins/`.**

This directory holds the KπX OpenCode **plugins** (JS modules that subscribe to
OpenCode events), their **shared libs**, the **tmux integration**, and the
**prompt assets** that back them. Every plugin here shapes agent behavior at
runtime. Adding a plugin that is unaware of the existing ecosystem creates
**conflicts, duplicates, and regressions** — which is strictly forbidden.

## 🔴 HARD RULE — CHECK THE EXISTING FIRST (never create blind)

Before you **create, edit, register, or delete** ANY file under
`scripts/plugins/` or `assets/plugins/` (a hook, a lib, a tmux helper, a prompt
asset, or a `"plugin"` registration in `assets/opencode.jsonc`), you **MUST**
first **check what already exists** and **read the standards** — totally, in
order, not partially:

1. **This file** (`plugins/AGENTS.md`) — the guardrails you are currently reading.
2. **`references/hooks-standard.md`** (in `k-opencode/`) — the authoritative
   coding standard: file structure, `TARGET_AGENTS`, prompt-name matching,
   the `libs/` helpers, the **ordering rule**, and the **`synthetic:true` rule**.
3. **`assets/plugins/hooks/AGENTS.md`** — the canonical prompt-asset rules and inventory.
4. **`scripts/plugins/libs/`** — every shared helper (`agent-scope.js`,
   `message-utils.js`, `prompt-loader.js`). **Reuse them; never re-implement.**
   (Moved here 2026-08-16: `scripts/hooks/libs` → `scripts/plugins/libs/`.)
5. **Every existing hook in `scripts/plugins/hooks/*.js`** — `startup-context.js`,
   `prompt-enforcer-lite.js`, `prompt-enforcer-strict.js`, `stop-enforcer.js`,
   `math-enforcer.js`, `suggestions-check.js`, `make-check-guard.js`.
6. **The tmux helper `scripts/plugins/tmux-notify.js`** (flattened out of the former `tmux/` subfolder 2026-08-16 — no more subfolder, lives directly in `scripts/plugins/`).
7. **Every prompt asset in `assets/plugins/hooks/*.txt`** — the prose each hook
   loads, plus the `AGENTS.md` inventory table.
8. **The `"plugin"` array in `assets/opencode.jsonc`** — the registration order
   (which is NOT cosmetic; see the ordering rule).

> **The reflex is always: look before you build.** If a concern is already
> covered by an existing hook/lib/asset, extend it — never duplicate.

## 📂 Directory map

```
scripts/plugins/
├── hooks/                 # lifecycle hooks (JS, subscribe to OpenCode events)
│   ├── startup-context.js, prompt-enforcer-lite.js, prompt-enforcer-strict.js,
│   ├── stop-enforcer.js, math-enforcer.js, suggestions-check.js, make-check-guard.js
├── libs/                  # shared helpers (reused, never re-implemented)
│   ├── agent-scope.js, message-utils.js, prompt-loader.js
├── tmux-notify.js         # tmux ↔ agent stateful integration (2026-08-16: flattened out of
│                          #   the former tmux/ subfolder directly into plugins/, no more subfolder)
├── opencode-context/      # /context slash-command plugin (git submodule)
└── web/                   # web plugins (opencode-lens, opencode-web-voice)

assets/plugins/
├── hooks/                 # prompt .txt assets (same name as the hook JS that loads them)
└── context/               # /context command markdown asset
```

## Why

Each existing plugin has a precise role, a `TARGET_AGENTS` scope, an event it
subscribes to, and a message it may append. Without full awareness of all of
them you will:

- **duplicate** an existing responsibility (forbidden by `libs/AGENTS.md`), or
- **break the ordering rule** (a hook inspecting `messages.at(-1)` placed after
  an unconditional appender), or
- **break title generation** (an injected `user` message without
  `synthetic:true`), or
- **mis-scope** `TARGET_AGENTS` and gate/allow the wrong agents.

You must create **in continuity with the existing ecosystem** — same patterns,
same helpers, same naming — never as an isolated bolt-on that ignores its
neighbors.

## Current inventory (source of truth)

### Hooks (`scripts/plugins/hooks/`)

| Hook | Event | `TARGET_AGENTS` | Prompt asset | Role |
|------|-------|-----------------|--------------|------|
| `startup-context.js` | `experimental.chat.messages.transform` | `Colab, Agent, Auto, Build, Plan` | `startup-context.txt` | Injects `<startup-context>` + `<device-context>` + `<tmux-context>` as first user message (`synthetic:true`). |
| `prompt-enforcer-lite.js` | `experimental.chat.messages.transform` | `Agent` | `prompt-enforcer-lite.txt` | Injects the Agent carte-blanche enforcement after a real user message. |
| `prompt-enforcer-strict.js` | `experimental.chat.messages.transform` | `Colab, Auto` | `prompt-enforcer-strict.txt` | Injects the strict obedience/enforcement prompt. |
| `stop-enforcer.js` | `event` (`session.idle`) | `Agent` | `stop-enforcer.txt` | Post-tool completion check on session idle; injects `{{MISSION_CONTEXT}}`. |
| `make-check-guard.js` | `tool.execute.before` | `*` | — | Blocks any bash command where the FIRST `make check` is followed by a blank (enforces the GRAVÉ 2-token rule). |
| `math-enforcer.js` | `experimental.chat.messages.transform` | `Explore` | `math-enforcer.txt` | Enforces OpenCode-web math rendering order. |
| `suggestions-check.js` | `experimental.chat.messages.transform` | `*` | `suggestions-check.txt` | Appends the universal "≥3 Suggestions" footer format (must be LAST). |

### Tmux integration (`scripts/plugins/tmux-notify.js`)

| File | Role |
|------|------|
| `tmux-notify.js` | **Stateful tmux command execution — 5 pieces.** (1) `tool.execute.before` intercepts any `bash` tool call containing `tmux send-keys -t <target> ...`, parses `TMUX_TIMEOUT=<seconds>` (SECONDS — NOT milliseconds; default `300` = 5 min.) and `TMUX_LINES=<n>` / `TMUX_MAX_LINES=<n>` (default `20`) out of the command string — applying these defaults EVEN IF absent, so EVERY stateful send-keys is armed — resolves `<target>` to a pane id, and arms an in-memory registry (`Map<paneId,{agent,sessionID,timeoutTimer,timeoutSecs,maxLines,cmd,armedAt}>`) with an unref'd `setTimeout`. `capture-pane` is NEVER intercepted or blocked here (KπX, 2026-08-16 — an earlier reactive `throw`-based block was tried then explicitly REMOVED: the agent may legitimately need a manual `capture-pane` if this very plugin malfunctions). (2) `tool.execute.after` appends a `<tmux-armed>` reminder DIRECTLY to that SAME `send-keys` call's own result (no round-trip through the conversation) — "pane armed, do not capture-pane, do not sleep/wait/timeout-poll — continue other parallel work or stop your turn, notified in BOTH cases." This is the CURRENT proactive reflex-enforcement mechanism. (3) Relays tmux `prompt` events (written directly by `.kshrc` `precmd`/`PROMPT_COMMAND` return-to-prompt signal): polls `/tmp/tmux-pane-done.log`, and on a matching pane clears the timer, runs `tmux capture-pane`, slices the last `maxLines` lines, queues a `<tmux-notify>` whose label states the EXACT line count shown (e.g. `Last 20 output lines:`, never a vague placeholder), and delivers via `client.session.prompt` (idle) + `chat.message` prepend — both delivery paths use a `Map<sessionID, string[]>` pending queue (fixed 2026-08-16, real bug: a flat/global queue could leak session A's notification into session B's conversation) so a notification is delivered ONLY to the session that armed it, never to "whichever session is active". (4) If `TMUX_TIMEOUT` elapses first, fires ONE "still running" notification with a fresh capture but KEEPS the registry entry alive (only the timer is cleared) so the real completion notification still fires automatically later — this is the agent-facing reflex documented in `rules/tool-discipline.md` → `## Tmux Stateful Command Execution` and `k-tmux/SKILL.md` → `### Run and get notified`. (5) **Busy-pane block — TWO cascading layers** (layer 1 added 2026-08-16, KπX directive — "on demande d'utiliser un autre pane vide si présent, ou en créer un si tous occupés"; layer 2 added same day, KπX follow-up "tu check juste busy par un autre agent ou vrai busy ?"). Layer 1 (tracked-busy): `tool.execute.before` now `throw`s BEFORE arming if `registry.get(paneId)` already has an unresolved entry (pane already busy, command not yet returned to prompt) — closes the earlier silent "last-arm-wins" gap (a second arm on the same pane used to overwrite the first with zero trace anywhere, even in debug logs). Layer 2 (untracked-busy): if layer 1 finds nothing, ALSO queries `tmux display-message -p -t <paneId> '#{pane_current_command}'` (pure metadata, no `capture-pane`/content read) and blocks if the result isn't one of `zsh`/`bash`/`sh`/`fish` — catches a pane busy for a reason our own registry never tracked (KπX typing directly in it, an agent bypassing our interception, a leftover foreground process), fails open on any tmux/pane error so a lookup failure never blocks arming. Either layer's thrown message tells the agent to use a different EMPTY pane (`tmux list-panes -a`) or create a new one if all are occupied — same `throw`-to-block pattern as `make-check-guard.js`, a DIFFERENT scope from the `capture-pane` block removed in (1): blocking `send-keys` into a busy pane protects against input cross-contamination, while blocking `capture-pane` would remove the agent's only diagnostic fallback. Uses `event`+`chat.message`+`tool.execute.before`+`tool.execute.after`, NOT `messages.transform` → exempt from the ordering rule §5. |

See `k-tmux` → Stateful Integration for the full mechanism.

### Shared libs (`scripts/plugins/libs/`)

| Lib | Exports | Purpose |
|-----|---------|---------|
| `agent-scope.js` | `currentAgent(messages)`, `currentAgentIs(messages, targets)` | Resolve the **active** agent (last message with `info.agent`), gate hook on `TARGET_AGENTS`. |
| `message-utils.js` | `messageRole`, `messageParts`, `messageText`, `isToolPart`, `hasToolPart`, `appendMessage` (sets `synthetic:true`), `hasPriorUserText`, `missionContext` | Message inspection + safe injection. |
| `prompt-loader.js` | `loadPrompt(name)`, `renderPrompt(name, vars)`, `promptMarker(name)` | Load/render prompts from `assets/plugins/hooks/`, extract the first marker line. |

### Prompt assets (`assets/plugins/hooks/`)

See `assets/plugins/hooks/AGENTS.md` for the full inventory and rules.

## Registration contract

- Every hook is loaded via the `"plugin"` array in `assets/opencode.jsonc`
  using an explicit `file://` path to `scripts/plugins/hooks/<name>.js` (or
  `scripts/plugins/tmux-notify.js` for the tmux helper).
- **Ordering rule** (`references/hooks-standard.md` §5): hooks that inspect
  `messages.at(-1)` must come BEFORE any hook that unconditionally appends a
  message. `suggestions-check.js` (unconditional `system` append) must be LAST.
  `stop-enforcer.js` and `tmux-notify.js` use `event` + `client` (not
  `messages.transform`), so they are exempt from that ordering constraint.
- **`synthetic:true` rule** (`references/hooks-standard.md` §6): ANY injected
  message part MUST carry `synthetic: true` (via `appendMessage` or manually).
  Never inject a `user` part without it (breaks session title generation).
- **Prompt-name matching** (`references/hooks-standard.md` §3): a hook that
  loads a prompt via `loadPrompt("<name>")` MUST have a same-named
  `assets/plugins/hooks/<name>.txt`.

## Adding a NEW plugin/hook — checklist

1. **CHECK THE EXISTING FIRST + FULL READ** everything listed above (mandatory).
2. Confirm the concern is **not already covered** by an existing plugin/hook/lib.
   If it is, extend the existing one — never duplicate.
3. Place the file under `scripts/plugins/` (a hook in `hooks/`, a tmux helper in
   `tmux/`, a shared helper in `libs/`), declare `TARGET_AGENTS` at top for
   hooks, use the `libs/` helpers (never inline logic), and follow the
   language/pattern of the existing plugins.
4. If it loads a prompt → create `assets/plugins/hooks/<name>.txt` (same name)
   and add it to the `assets/plugins/hooks/AGENTS.md` inventory table.
5. Register it in the `"plugin"` array of `assets/opencode.jsonc` at the
   **correct position** (respecting the ordering rule).
6. Test it in a real session; verify no regression to the other plugins.
7. Update `k-opencode/SKILL.md` (version + changelog) and this inventory table.
