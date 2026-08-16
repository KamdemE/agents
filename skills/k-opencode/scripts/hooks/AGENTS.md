# scripts/hooks/ — Agent Guardrail

**⚠️ MANDATORY — READ THIS FILE BEFORE ADDING OR MODIFYING ANY HOOK/PLUGIN.**

This directory holds the KπX OpenCode **lifecycle hooks** (JS plugins that
subscribe to OpenCode events). Every hook here shapes agent behavior at
runtime. Adding a hook that is unaware of the existing ecosystem creates
**conflicts, duplicates, and regressions** — which is strictly forbidden.

## 🔴 HARD RULE — FULL READ before ANY hook/plugin change

Before you **create, edit, register, or delete** any hook (or its prompt asset,
or its `"plugin"` registration in `assets/opencode.jsonc`), you **MUST** fully
read — in order — all of the following, **totally**, not partially:

1. **This file** (`AGENTS.md`) — the guardrails you are currently reading.
2. **`references/hooks-standard.md`** (in `k-opencode/`) — the authoritative
   coding standard: file structure, `TARGET_AGENTS`, prompt-name matching,
   the `libs/` helpers, the **ordering rule**, and the **`synthetic:true` rule**.
3. **`assets/hooks/AGENTS.md`** — the canonical prompt-asset rules and inventory.
4. **`scripts/hooks/libs/`** — every helper (`agent-scope.js`,
   `message-utils.js`, `prompt-loader.js`). Reuse them; never re-implement.
5. **Every existing hook in `scripts/hooks/*.js`** — `startup-context.js`,
   `prompt-enforcer-lite.js`, `prompt-enforcer-strict.js`, `stop-enforcer.js`,
   `math-enforcer.js`, `suggestions-check.js`, `tmux-notify.js`.
6. **Every prompt asset in `assets/hooks/*.txt`** — the prose each hook loads,
   plus the `AGENTS.md` inventory table.
7. **The `"plugin"` array in `assets/opencode.jsonc`** — the registration order
   (which is NOT cosmetic; see the ordering rule).

### Why

Each existing hook has a precise role, a `TARGET_AGENTS` scope, an event it
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

### Hooks (`scripts/hooks/`)

| Hook | Event | `TARGET_AGENTS` | Prompt asset | Role |
|------|-------|-----------------|--------------|------|
| `startup-context.js` | `experimental.chat.messages.transform` | `Colab, Agent, Auto, Build, Plan` | `startup-context.txt` | Injects `<startup-context>` + `<device-context>` as first user message (`synthetic:true`). |
| `prompt-enforcer-lite.js` | `experimental.chat.messages.transform` | `Agent` | `prompt-enforcer-lite.txt` | Injects the Agent carte-blanche enforcement after a real user message. |
| `prompt-enforcer-strict.js` | `experimental.chat.messages.transform` | `Colab, Auto` | `prompt-enforcer-strict.txt` | Injects the strict obedience/enforcement prompt. |
| `stop-enforcer.js` | `event` (`session.idle`) | `Agent` | `stop-enforcer.txt` | Post-tool completion check on session idle; injects `{{MISSION_CONTEXT}}`. |
| `tmux-notify.js` | `event` (`session.*`) + `chat.message` | `Colab, Agent` | — | Relays tmux `pane-died` events to the agent: polls `/tmp/tmux-pane-done.log` (written by `tmux-pane-done.sh` via a global tmux hook), queues `<tmux-notify>`, delivers via `client.session.prompt` (idle) + `chat.message` prepend (fallback). No prompt asset (dynamic text). Uses `event`+`chat.message`, NOT `messages.transform` → exempt from the ordering rule §5. |
| `math-enforcer.js` | `experimental.chat.messages.transform` | `Explore` | `math-enforcer.txt` | Enforces OpenCode-web math rendering order. |
| `suggestions-check.js` | `experimental.chat.messages.transform` | `*` | `suggestions-check.txt` | Appends the universal "≥3 Suggestions" footer format (must be LAST). |

### Shared libs (`scripts/hooks/libs/`)

| Lib | Exports | Purpose |
|-----|---------|---------|
| `agent-scope.js` | `currentAgent(messages)`, `currentAgentIs(messages, targets)` | Resolve the **active** agent (last message with `info.agent`), gate hook on `TARGET_AGENTS`. |
| `message-utils.js` | `messageRole`, `messageParts`, `messageText`, `isToolPart`, `hasToolPart`, `appendMessage` (sets `synthetic:true`), `hasPriorUserText`, `missionContext` | Message inspection + safe injection. |
| `prompt-loader.js` | `loadPrompt(name)`, `renderPrompt(name, vars)`, `promptMarker(name)` | Load/render prompts from `assets/hooks/`, extract the first marker line. |

## Registration contract

- Every hook is loaded via the `"plugin"` array in `assets/opencode.jsonc`
  using an explicit `file://` path to `scripts/hooks/<name>.js`.
- **Ordering rule** (`references/hooks-standard.md` §5): hooks that inspect
  `messages.at(-1)` must come BEFORE any hook that unconditionally appends a
  message. `suggestions-check.js` (unconditional `system` append) must be LAST.
  `stop-enforcer.js` uses `event` + `client` (not `messages.transform`), so it
  is exempt from that ordering constraint.
- **`synthetic:true` rule** (`references/hooks-standard.md` §6): ANY injected
  message part MUST carry `synthetic: true` (via `appendMessage` or manually).
  Never inject a `user` part without it (breaks session title generation).
- **Prompt-name matching** (`references/hooks-standard.md` §3): a hook that
  loads a prompt via `loadPrompt("<name>")` MUST have a same-named
  `assets/hooks/<name>.txt`.

## Adding a NEW hook — checklist

1. **FULL READ** everything listed above (mandatory).
2. Confirm the concern is **not already covered** by an existing hook. If it
   is, extend the existing hook — never duplicate.
3. Place the file at `scripts/hooks/<name>.js`, declare `TARGET_AGENTS` at top,
   use the `libs/` helpers (never inline logic), and follow the language/pattern
   of the existing hooks.
4. If it loads a prompt → create `assets/hooks/<name>.txt` (same name) and add
   it to the `assets/hooks/AGENTS.md` inventory table.
5. Register it in the `"plugin"` array of `assets/opencode.jsonc` at the
   **correct position** (respecting the ordering rule).
6. Test it in a real session; verify no regression to the other hooks.
7. Update `k-opencode/SKILL.md` (version + changelog) and this inventory table.
