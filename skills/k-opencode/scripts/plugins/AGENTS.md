# scripts/plugins/ — KπX Agent Plugins (Guardrail)

**⚠️ MANDATORY — READ THIS FILE BEFORE ADDING OR MODIFYING ANYTHING UNDER `scripts/plugins/` OR `assets/plugins/`.**

This directory holds the KπX OpenCode **plugins** (JS modules that subscribe to
OpenCode events), their **shared libs**, the **tmux integration**, and the
**prompt assets** that back them. Adding a plugin that is unaware of the
existing ecosystem creates **conflicts, duplicates, and regressions** — which
is strictly forbidden.

## 🔴 HARD RULE — "Hook" vs "Plugin" are NOT synonyms (never confuse them again)

**A "hook" is a specific, narrower category — NOT a generic word for
"anything under `scripts/plugins/`".** Real incident 2026-08-27: a new
notification plugin was written straight into `scripts/plugins/hooks/` and
called "the opencode-notify hook" throughout, purely out of habit — corrected
live by KπX. Fix this confusion for good:

| Category | Definition | Lives in | Declares `TARGET_AGENTS`? | Examples |
|---|---|---|---|---|
| **Hook** | Actively **shapes/influences agent behavior** — injects, transforms, or blocks a message/tool call the agent sees or executes (`experimental.chat.messages.transform`, `tool.execute.before` that can `throw`, etc.). | `scripts/plugins/hooks/` | **Yes — mandatory** (`references/hooks-standard.md` §2) | `startup-context.js`, `prompt-enforcer-*.js`, `stop-enforcer.js`, `make-check-guard.js`, `math-enforcer.js`, `suggestions-check.js` |
| **Plugin (non-hook)** | **Read-only / observational** — subscribes to `event`/`chat.message`/etc. purely as a SIDE EFFECT channel (notify, log, relay, expose a slash-command tool). **Never** injects a message into the conversation, **never** blocks/transforms agent input or output, **never** influences what the agent sees or does. | Its **own subdirectory** directly under `scripts/plugins/` (own name, e.g. `opencode-notify/`) — NOT `hooks/` | **No** — that mandate is hooks-only; an internal `SCOPE_*`/similar constant is fine but is NOT the hooks contract | `tmux-notify.js` (relays a signal, never rewrites agent output — its `tool.execute.after` reminder is appended to a tool's OWN result, not injected as a new message), `opencode-context/` (`/context` slash command — pure read/report), `opencode-voice/` (TUI STT/TTS — UI extension, not a behavior hook), `opencode-notify/` (system+Telegram notification — pure side effect) |

**The test to apply before placing a new file:** *"Does this change what the
agent sees, is told to do, or is allowed to do?"* — YES → hook → `hooks/`.
NO (it only observes and produces an external side effect) → plugin → its own
subdirectory, never `hooks/`.

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
6. **Every existing non-hook plugin** — `scripts/plugins/tmux-notify.js` (flattened
   out of the former `tmux/` subfolder 2026-08-16 — no more subfolder, lives directly
   in `scripts/plugins/`), `scripts/plugins/opencode-context/`, `scripts/plugins/opencode-voice/`,
   `scripts/plugins/opencode-notify/`.
7. **Every prompt asset in `assets/plugins/hooks/*.txt`** — the prose each hook
   loads, plus the `AGENTS.md` inventory table.
8. **The `"plugin"` array in `assets/opencode.jsonc`** — the registration order
   (which is NOT cosmetic; see the ordering rule).

> **The reflex is always: look before you build.** If a concern is already
> covered by an existing hook/lib/asset, extend it — never duplicate.

## 📂 Directory map

```
scripts/plugins/
├── hooks/                 # HOOKS ONLY (JS, actively shape/influence agent behavior)
│   ├── startup-context.js, lite-instructions-swap.js, prompt-enforcer-lite.js, prompt-enforcer-strict.js,
│   ├── stop-enforcer.js, math-enforcer.js, suggestions-check.js, make-check-guard.js, raw-exec-guard.js
├── libs/                  # shared helpers (reused, never re-implemented)
│   ├── agent-scope.js, message-utils.js, prompt-loader.js, device-info.js, tmux-patterns.js
├── tmux-notify.js         # NON-HOOK plugin — tmux ↔ agent stateful relay (2026-08-16: flattened out of
│                          #   the former tmux/ subfolder directly into plugins/, no more subfolder)
├── opencode-context/      # NON-HOOK plugin — /context slash-command (git submodule)
├── opencode-voice/        # NON-HOOK plugin — TUI STT/TTS (voice, sovereign fork)
├── opencode-notify/       # NON-HOOK plugin — system+Telegram lifecycle notification
│   ├── opencode-notify.js, opencode-notify.sh
├── opencode-advisor/      # NON-HOOK plugin — advisor() tool + auto-escalation (git submodule)
│   ├── dist/plugin.js (compiled)
│   └── src/plugin.ts
├── opencode-btw/          # NON-HOOK plugin — /btw slash command (git submodule, raw .ts)
│   ├── btw.ts, index.ts
│   └── assets/plugins/btw/btw.md (command definition, symlinked to ~/.config/opencode/commands/)
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
| `startup-context.js` | `experimental.chat.messages.transform` | `Colab, Live, Agent, Auto, Build, Plan` | `startup-context.txt` | Injects `<startup-context>` + `<device-context>` + `<tmux-context>` as first user message (`synthetic:true`). The k-context (TODOs/Projects/Log) sub-block only injects when the CALLING SESSION's `Session.directory` (resolved via `client.session.get`, never `process.cwd()` — see file header comment) is EXACTLY `$HOME/KpihX-Labs`; `device-context`/`tmux-context` always inject regardless. |
| `lite-instructions-swap.js` | `experimental.chat.system.transform` | `Lite` | — (none — Lite prompt is `agents/Lite/prompt.txt` via `opencode.jsonc`) | Strips the native big kernel `AGENTS.md` (`kpihx-agents` fingerprint) for Lite only — Lite now uses its standard `prompt.txt` (like Colab/Live). Detected via Lite prompt marker (`You are Lite`) present in `output.system[]`, race-free. |
| `prompt-enforcer-lite.js` | `experimental.chat.messages.transform` | `Agent` | `prompt-enforcer-lite.txt` | Injects the Agent carte-blanche enforcement after a real user message. |
| `prompt-enforcer-strict.js` | `experimental.chat.messages.transform` | `Colab, Auto` | `prompt-enforcer-strict.txt` | Injects the strict obedience/enforcement prompt. |
| `prompt-enforcer.js` | `experimental.chat.messages.transform` | `Live` | `prompt-enforcer.txt` | Injects the strict obedience/enforcement prompt LITE-style (only after a real new user message, not every turn) — Live's delta vs Colab's every-turn `prompt-enforcer-strict.js`. |
| `stop-enforcer.js` | `event` (`session.idle`) | `Agent` | `stop-enforcer.txt` | Post-tool completion check on session idle; injects `{{MISSION_CONTEXT}}`. |
| `make-check-guard.js` | `tool.execute.before` | `*` | — | Blocks any bash command where the FIRST `make check` is followed by a blank (enforces the GRAVÉ 2-token rule). |
| `raw-exec-guard.js` | `tool.execute.before` | `*` | — | **Technically enforces two long-standing PROSE-ONLY rules (KπX, 2026-08-29)**: blocks raw `sudo` (`rules/tool-discipline.md` → `## tmux sudo Gate`) and raw `sleep`/`wait`/`timeout` used as manual polling (`## Tmux Stateful Command Execution` self-backgrounding rule) whenever the bash command is NOT already a compliant `tmux send-keys -t <target> ...` call (checked via the shared `SEND_KEYS_REGEX`, see `libs/tmux-patterns.js`) — the quoted payload inside a compliant send-keys call is delivered to the pane, never executed by the agent's own shell, so it is explicitly exempt. Same `throw`-only pattern as `make-check-guard.js` (no `TARGET_AGENTS`, same reasoning: `tool.execute.before` has no `messages` to scope by — this is a GLOBAL kernel rule). **Scope explicitly limited to these 2 static pre-execution checks** — a 3rd idea ("kill any command after 30s and relaunch the agent") was proposed and REJECTED by KπX as out of scope: not achievable anyway with the current plugin API (no PID access, no reliable command rewriting — mutating `output.args` does not propagate, upstream opencode #31680), and KπX chose a simple, fully-verifiable hook over a reactive mechanism that could only ever be an after-the-fact reminder. 17/17 tests green (`tests/hooks/raw-exec-guard.test.mjs`, imports the real module). |
| `math-enforcer.js` | `experimental.chat.messages.transform` | `Explore` | `math-enforcer.txt` | Enforces OpenCode-web math rendering order. |
| `suggestions-check.js` | `experimental.chat.messages.transform` | `*` | `suggestions-check.txt` | Appends the universal "≥3 Suggestions" footer format (must be LAST). |

### Tmux integration (`scripts/plugins/tmux-notify.js`)

| File | Role |
|------|------|
| `tmux-notify.js` | **Stateful tmux command execution — 6 pieces.** (1) `tool.execute.before` intercepts any `bash` tool call containing `tmux send-keys -t <target> ...`, parses `TMUX_TIMEOUT=<seconds>` (SECONDS — NOT milliseconds; default `30`.) and `TMUX_LINES=<n>` / `TMUX_MAX_LINES=<n>` (default `50`) out of the command string — applying these defaults EVEN IF absent, so EVERY stateful send-keys is armed — resolves `<target>` to a pane id, and arms an in-memory registry (`Map<paneId,{agent,sessionID,timeoutTimer,timeoutSecs,maxLines,cmd,armedAt}>`) with a recurring unref'd `setTimeout`. `capture-pane` is NEVER intercepted or blocked here (KπX, 2026-08-16 — an earlier reactive `throw`-based block was tried then explicitly REMOVED: the agent may legitimately need a manual `capture-pane` if this very plugin malfunctions). (2) `tool.execute.after` appends a `<tmux-armed>` reminder DIRECTLY to that SAME `send-keys` call's own result (no round-trip through the conversation) — it directs a one-shot `tmux capture-pane -p -t <pane> -S -100` diagnostic fallback only when the final automatic capture is empty, incomplete, or insufficient; never a polling loop. (3) Relays tmux `prompt` events (written directly by `.kshrc` `precmd`/`PROMPT_COMMAND` return-to-prompt signal): polls `/tmp/tmux-pane-done.log`, and on a matching pane clears the timer, runs `tmux capture-pane`, slices the last `maxLines` lines, queues a `<tmux-notify>` whose label states the EXACT line count shown, and delivers via `client.session.prompt` (idle) + `chat.message` prepend — both delivery paths use a `Map<sessionID, string[]>` pending queue (fixed 2026-08-16, real bug: a flat/global queue could leak session A's notification into session B's conversation) so a notification is delivered ONLY to the session that armed it, never to "whichever session is active". (4) Every `TMUX_TIMEOUT` period while the pane has not returned to the shell, fires a recurring `<tmux-watchdog>` (`... has not returned to its shell after Xs.` + fresh capture) and re-arms until shell return; shell return remains the ONLY stop condition — no mode flag — simple rule documented in `rules/tool-discipline.md` → `## Tmux Stateful Command Execution` and `k-tmux/SKILL.md` → `### Run and get notified`. (5) **Busy-pane block — TWO cascading layers** (layer 1 added 2026-08-16, KπX directive — "on demande d'utiliser un autre pane vide si présent, ou en créer un si tous occupés"; layer 2 added same day, KπX follow-up "tu check juste busy par un autre agent ou vrai busy ?"). Layer 1 (tracked-busy): `tool.execute.before` now `throw`s BEFORE arming if `registry.get(paneId)` already has an unresolved entry (pane already busy, command not yet returned to prompt) — closes the earlier silent "last-arm-wins" gap (a second arm on the same pane used to overwrite the first with zero trace anywhere, even in debug logs). Layer 2 (untracked-busy): if layer 1 finds nothing, ALSO queries `tmux display-message -p -t <paneId> '#{pane_current_command}'` (pure metadata, no `capture-pane`/content read) and blocks if the result isn't one of `zsh`/`bash`/`sh`/`fish` — catches a pane busy for a reason our own registry never tracked (KπX typing directly in it, an agent bypassing our interception, a leftover foreground process), fails open on any tmux/pane error so a lookup failure never blocks arming. Either layer's thrown message tells the agent to use a different EMPTY pane (`tmux list-panes -a`) or create a new one if all are occupied — same `throw`-to-block pattern as `make-check-guard.js`, a DIFFERENT scope from the `capture-pane` block removed in (1): blocking `send-keys` into a busy pane protects against input cross-contamination, while blocking `capture-pane` would remove the agent's only diagnostic fallback. Uses `event`+`chat.message`+`tool.execute.before`+`tool.execute.after`, NOT `messages.transform` → exempt from the ordering rule §5. (6) **Timeout self-adjustment + escalating watchdog guidance (KπX, 2026-08-29):** a bare recurring watchdog with an identical message was unclear (agent didn't know whether to wait, work in parallel, or abort) and gave no way to widen the check interval without literally typing into the pane (risky: pollutes the stdin of whatever is actually running there). Fixed with a pure META marker `: TMUX_ADJUST <pane> <seconds>` (`:` = bash no-op builtin, always succeeds, zero side effects, NEVER a `send-keys` call — never touches the target pane at all) recognized by an anchored regex in `tool.execute.before` on the agent's OWN bash command; if the lease belongs to the calling session, updates `entry.timeoutSecs` in-memory, clears+re-arms the watchdog timer (countdown restarts from the new value) and resets `entry.watchdogCount`; ownership-gated exactly like send-keys (another session's lease → `status:"denied"`, no lease at all → `status:"noop"`) — never a hard `throw`, always a soft `<tmux-timeout-adjusted>` confirmation via `tool.execute.after`. `notificationFor()` now tracks `entry.watchdogCount` (incremented on every watchdog fire) and escalates: checks 1–2 say "still running normally → CONTINUE in parallel, or ADJUST if you expect it to take longer"; checks ≥3 say "genuinely long-running, not stuck → ADJUST to space out checks, or Ctrl+C to abort" — every watchdog message states the exact `: TMUX_ADJUST <pane> <bigger_seconds>` syntax so the agent never has to guess it. The `<tmux-armed>` reminder (2) also now advertises this syntax up front. |

See `k-tmux` → Stateful Integration for the full mechanism.

> **Current lease semantics (2026-08-28, simplified):** a registry entry is an exclusive
> completion watch, not a blanket input lock. Its owning session may continue
> the foreground TUI, correct input, or send `Ctrl+C` without re-arming or
> replacing the watch; another OpenCode session remains blocked. Prompt-event
> timestamps prevent a late completion from a prior command finalizing a rapid
> relaunch. A new watched command is armed only after the original
> `<tmux-notify>` releases its lease. Every `TMUX_TIMEOUT` period while the pane has not returned to the shell emits a recurring `<tmux-watchdog>`; only shell return emits definitive `<tmux-notify>` — simple rule, no mode flag. The owning session may widen (or narrow) that interval at any time with `: TMUX_ADJUST <pane> <seconds>` — a no-op meta marker, never sent to the pane — instead of being pinged repeatedly on a too-short timeout (2026-08-29, see piece 6 above).

### Notification plugin (`scripts/plugins/opencode-notify/`)

| File | Role |
|------|------|
| `opencode-notify.js` | **NOT a hook** (read-only/observational, see "Hooks vs Plugins" above). Fires KπX a notification (system + Telegram) the moment the agent finishes a turn (`event`/`session.idle`), hits an error (`event`/`session.error`), or is blocked waiting for an approval decision (`"permission.ask"` hook callback). Always fires, all agents, no focus-detection gate (replaces the purged third-party `opencode-notifications` npm plugin — see `references/plugin-watch.md` → Purged). Includes device hostname (`libs/device-info.js`), resolved agent (`libs/agent-scope.js`), and session title/directory (`client.session.get`) in every notification. |
| `opencode-notify.sh` | Sibling shell wrapper — sources the shared `$HOME/.agents/libs/notif/notifier.sh` and calls `notify_mixed` (system `notify-send` + Telegram, one call). Invoked by `opencode-notify.js` via `execFile` (argv array, no shell string interpolation). Prefers the dedicated `TELEGRAM_OPENCODE_TOKEN` (see `.env.example`) over the shared notifier fallback chain. |

### Advisor plugin (`scripts/plugins/opencode-advisor/`)

| File | Role |
|------|------|
| `plugin.js` (compiled from `src/plugin.ts`) | **Advisor tool + auto-escalation.** Registers `advisor()` tool (model decides when to consult a stronger model) and monitors `message.part.updated` for consecutive tool errors — after `failureThreshold` (default 3, configured 5), aborts session, consults advisor, resumes with guidance. Hidden agent with read-only permissions. Non-hook plugin (event + tool, not messages.transform). |

### /btw plugin (`scripts/plugins/opencode-btw/`)

| File | Role |
|------|------|
| `btw.ts` (raw .ts, no build — opencode-context pattern) | **`/btw` command.** `command.execute.before` intercepts `/btw <query>`, creates ephemeral sub-session via SDK, appends answer as card. Default model: `opencode-go/mimo-v2.5`. Command definition in `assets/plugins/btw/btw.md` (symlinked to `~/.config/opencode/commands/btw.md`). |

### Shared libs (`scripts/plugins/libs/`)

| Lib | Exports | Purpose |
|-----|---------|---------|
| `agent-scope.js` | `currentAgent(messages)`, `currentAgentIs(messages, targets)` | Resolve the **active** agent (last message with `info.agent`), gate hook on `TARGET_AGENTS`. |
| `message-utils.js` | `messageRole`, `messageParts`, `messageText`, `isToolPart`, `hasToolPart`, `appendMessage` (sets `synthetic:true`), `hasPriorUserText`, `missionContext` | Message inspection + safe injection. |
| `prompt-loader.js` | `loadPrompt(name)`, `renderPrompt(name, vars)`, `promptMarker(name)` | Load/render prompts from `assets/plugins/hooks/`, extract the first marker line. |
| `device-info.js` | `detectDevice()` | Resolve Tailscale hostname + owning `k-*` infra skill (`assets/infras_skills.jsonc`). Extracted 2026-08-27 out of `startup-context.js` (was a private local function) — single source of truth for any hook/plugin needing device identity. |
| `tmux-patterns.js` | `SEND_KEYS_REGEX` | Detects a compliant `tmux send-keys -t <target> ...` call. Extracted 2026-08-29 — was duplicated 3 times (`tmux-notify.js` `.before`+`.after`, and would have been a 3rd copy in `raw-exec-guard.js`); single source of truth shared by both files. |

### Prompt assets (`assets/plugins/hooks/`)

See `assets/plugins/hooks/AGENTS.md` for the full inventory and rules.

## Registration contract

- Every hook/plugin is loaded via the `"plugin"` array in `assets/opencode.jsonc`
  using an explicit `file://` path — a hook at `scripts/plugins/hooks/<name>.js`,
  a non-hook plugin at its own `scripts/plugins/<plugin-name>/<plugin-name>.js`
  (or a flat file directly under `scripts/plugins/` for a single-file plugin
  like `tmux-notify.js`).
- **Ordering rule** (`references/hooks-standard.md` §5) — **HOOKS ONLY**: hooks
  that inspect `messages.at(-1)` must come BEFORE any hook that unconditionally
  appends a message. `suggestions-check.js` (unconditional `system` append)
  must be LAST. Non-hook plugins (`tmux-notify.js`, `opencode-notify/`, …) use
  `event`/`chat.message`/`"permission.ask"` (not `messages.transform`), so they
  are exempt from this ordering constraint — place them anywhere sensible,
  grouped near related plugins for readability.
- **`synthetic:true` rule** (`references/hooks-standard.md` §6) — **HOOKS
  ONLY** (only relevant to code that injects a message into the conversation,
  which by definition makes it a hook, not a plugin): ANY injected message
  part MUST carry `synthetic: true` (via `appendMessage` or manually). Never
  inject a `user` part without it (breaks session title generation).
- **Prompt-name matching** (`references/hooks-standard.md` §3) — **HOOKS
  ONLY**: a hook that loads a prompt via `loadPrompt("<name>")` MUST have a
  same-named `assets/plugins/hooks/<name>.txt`. Non-hook plugins do not load
  prompts (they don't talk to the conversation at all).

## Adding a NEW plugin/hook — checklist

1. **CHECK THE EXISTING FIRST + FULL READ** everything listed above (mandatory).
2. Confirm the concern is **not already covered** by an existing plugin/hook/lib.
   If it is, extend the existing one — never duplicate.
3. **Classify it first** using the "Hooks vs Plugins" test above (does it
   change what the agent sees/is told/is allowed to do?):
   - **Hook** → `scripts/plugins/hooks/<name>.js`, declare `TARGET_AGENTS` at
     top (mandatory), use the `libs/` helpers, follow the existing hook pattern.
   - **Non-hook plugin** → its OWN subdirectory `scripts/plugins/<plugin-name>/`
     (or a flat single file directly under `scripts/plugins/` if truly
     single-file, like `tmux-notify.js`) — **never** `hooks/`. No
     `TARGET_AGENTS` mandate; use the `libs/` helpers anyway (never inline
     logic already covered by `agent-scope.js`/`device-info.js`/etc.).
4. If it loads a prompt (hooks only — see above) → create
   `assets/plugins/hooks/<name>.txt` (same name) and add it to the
   `assets/plugins/hooks/AGENTS.md` inventory table.
5. Register it in the `"plugin"` array of `assets/opencode.jsonc` at the
   **correct position** (respecting the ordering rule for hooks; anywhere
   sensible for non-hook plugins).
6. Test it in a real session; verify no regression to the other plugins.
7. Update `k-opencode/SKILL.md` (version + changelog) and this inventory table.
