---
name: k-tmux
description: >
  KπX tmux reference — sessions, windows, panes, copy-mode, mouse scroll, config reload,
  and practical CLI/key shortcuts. Load before any tmux workflow, shared interactive shell,
  or terminal multiplexing task on KπX workstations.
  ⚠️ SUDO GATE — tmux is the ONLY channel for sudo/SSH/password elevation.
  Never raw sudo in agent shells. Use ops pane <session>:agents.2.
metadata:
  version: 1.20.1
  author: KpihX
  scope: terminal-multiplexer
allowed-tools: Bash(tmux:*), Read, Write, Edit
---

# KπX — tmux

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-ubuntu` (shell / workstation context) · `k-codex` (shared interactive tmux panes with password polling)
> **OS references:** `references/windows.md` (WSL tmux setup and limitations)
> **Canonical config:** `assets/tmux.conf` (this skill) is the source of truth. `$HOME/.tmux.conf` is a **symlink** to it on every infra.

## When to Load

Load this skill for:

- creating, attaching to, switching, or killing tmux sessions
- splitting panes, resizing, zooming, or navigating layouts
- scrolling history / copy-mode / mouse wheel behavior
- editing or reloading tmux configuration
- agents running long commands in a shared tmux pane with KπX
- **`sudo`**, SSH passphrase, or any command that needs KπX approval (**`sui` is deprecated**)

## Shared interactive gate (mandatory for agents)

Normative short form: **`AGENTS.md` → Tool Discipline** · **`k-context`** header. This section is the **full** protocol.

### Triggers

Use this gate when a command may require **KπX** interaction:

- `sudo` / root elevation
- SSH host key or passphrase prompts
- Bitwarden / vault unlock in terminal
- `yes/no` or other blocking prompts

**`sui` is deprecated** — do not invoke it. Agents **never** run raw `sudo` in non-interactive tool shells; elevation happens in the shared pane.

### Standard session per equipment

Every KπX equipment gets a tmux session named after itself (`ubuntu`, `pve`, `pve-debian`, `dockerhost`, `blglaptop139`, `s25`, `deep-pc6`). Full equipment gets 3 windows (`agents` 3-pane layout, `default`, `tmp`); phones get 2 (`default`, `tmp`). Full layout diagram + setup commands → **`references/session-layout.md`**.

### Session hygiene (non-`ubuntu` sessions)

1. `tmux ls` — list sessions.
2. Prefer an existing **short, topic-named** session (e.g. `pve`, `fluid`, `apt`).
3. Prefer an existing **window/tab** for the same sub-task; create only when needed.
4. If none fits: `tmux new -ds <short-name>` (detached), then target a pane.
5. Naming: lowercase, ≤12 chars when possible (`pve-dns`, not `kpihx-pve-vm-debian-fix`).

### Run and get notified (stateful — NEVER manually poll `capture-pane`)

```bash
# Default long command — 300 seconds (NOT ms) timeout, 20 lines shown
TMUX_TIMEOUT=300 TMUX_LINES=20 tmux send-keys -t SESSION:WIN.PANE 'your command here' Enter

# Command that may need KπX action (sudo password, passphrase, 2FA) —
# SHORT timeout so you catch the prompt fast instead of sitting idle
TMUX_TIMEOUT=20 TMUX_LINES=15 tmux send-keys -t SESSION:WIN.PANE 'sudo apt update' Enter
```

`TMUX_TIMEOUT`/`TMUX_LINES` are parsed automatically by the `tmux-notify` OpenCode
plugin (see `## Stateful Integration` below) — **do not manually loop
`capture-pane` or `sleep` to wait for a command.** The plugin arms a timer on the
target pane the moment you `send-keys`, then delivers a synthetic
`<tmux-notify>` message into the conversation:

| Event | What you get automatically |
|-------|------------------------------|
| Right after you `send-keys` (ALWAYS, even with no `TMUX_TIMEOUT`/`TMUX_LINES` added — defaults apply) | A `<tmux-armed>` reminder appended directly to that SAME tool call's own result: pane armed, do not `capture-pane`, continue a parallel task or stop, you'll be auto-notified. |
| Pane returns to its prompt before `TMUX_TIMEOUT` | `<tmux-notify>` — `... has returned to its prompt.` + exact last-N captured lines. |
| `TMUX_TIMEOUT` elapses, pane still busy | ONE `<tmux-notify>` — `... is still running after Xs.` + a fresh capture. The registry stays armed — the real completion notification still fires later, you don't need to re-send anything. |

**`capture-pane` is NEVER blocked (KπX, 2026-08-16, reversing an earlier reactive
block):** an agent may legitimately need a manual `capture-pane` if this very
plugin malfunctions (log not written, watcher stuck, registry desync). The
reflex above is now enforced PROACTIVELY (the `<tmux-armed>` reminder right
after `send-keys`), never by rejecting a later `capture-pane` call.

**KπX-approval flow (sudo/passphrase/2FA):** inspect the captured lines in the
notification. If they show a password/passphrase/2FA prompt, message KπX
directly (never type the secret yourself, never re-send the command) and wait
for KπX to act in the pane. If they show real work progressing, no human
action is needed — the real completion notification is already armed and will
arrive on its own.

The only case that still needs a manual chat handoff to KπX is a **visual**
human action the stateful system cannot detect from pane text (reading a QR
code, clicking an OAuth consent page, scanning a code) — for that, one chat
message with: (1) `tmux attach -t SESSION` (+ window if needed), (2) exact
command running, (3) what KπX must do.

### Cleanup

When the task is **fully done** for that pane:

- idle pane + no future reuse → `tmux kill-pane -t SESSION:WIN.PANE`
- whole session obsolete → `tmux kill-session -t SESSION`

Kill only when sure — not mid-command, not while KπX may still attach.

### Session vs window (quick)

| Need | Action |
|------|--------|
| New project / SSH target / isolated stack | **New session** `tmux new -ds NAME` |
| Same project, another tab (logs, second shell) | **New window** `tmux new-window -t NAME -n tab` |
| Side-by-side in one tab | **Pane split** (`Ctrl-a` `%` / `"`) |

## Mental Model

```
server
 └── session   (named workspace, e.g. "dev", "homelab")
      └── window   (tab — index + optional name)
           └── pane   (split terminal region)
```

Default prefix: **`Ctrl-a`** (press prefix, release, then the command key) - customized in workspace config.

## Bundled Config

| Asset | Role |
|-------|------|
| `assets/tmux.conf` | Source of truth — `$HOME/.tmux.conf` symlinks to this |
| `assets/tmux-resurrect-save.sh` | Source of truth — `save.sh` in plugin dir symlinks to this |
| `assets/tmux-resurrect-restore.sh` | Source of truth — `restore.sh` in plugin dir symlinks to this |
| `assets/tmux-continuum-save.sh` | Source of truth — `continuum_save.sh` in plugin dir symlinks to this |
| `assets/setup-session.sh` | Creates standard session per equipment (3 windows or 2 for phones) |

Current KπX settings: `mouse on`, `focus-events on`, wheel → copy-mode scroll, `history-limit 50000`, `tmux-resurrect`/`tmux-continuum` auto-save every 5 min + auto-restore on boot (`@continuum-boot on` generates the systemd unit). Full plugin behavior/scope → **`references/plugins.md`**. Reboot recovery workflow (mandatory, `@continuum-boot` is OFF) → **`references/boot-recovery.md`**.

Apply after edits:

```bash
tmux source-file $HOME/.tmux.conf
```

## Stateful Integration (agent → tmux → agent notifications)

An agent (e.g. an OpenCode plugin) can be **notified** when a **persistent pane**
returns to its shell prompt (a command the agent launched finished) — instead of
the agent polling `capture-pane`. Panes PERSIST: nothing is killed or detached,
no `remain-on-exit` needed, and no tmux-side silence heuristics are used. Three
pieces cooperate:

1. **Shell prompt hook** (in `.kshrc`, propagated to all infras): a `precmd` (zsh)
   or `PROMPT_COMMAND` (bash) hook writes a JSON `{"event":"prompt","pane","ts"}`
   line directly to `/tmp/tmux-pane-done.log` whenever the shell prompt redraws.
   This avoids false positives during silent waits (e.g. `sudo` password prompts).
2. **`k-opencode` `tmux-notify.js` — arming (`tool.execute.before`) + proactive
   reminder (`tool.execute.after`):**
   - `tool.execute.before` intercepts any `bash` tool call containing
      `tmux send-keys -t <target> ...`, parses `TMUX_TIMEOUT=<seconds>` (SECONDS
      — NOT milliseconds; default `300` = 5 min.) and `TMUX_LINES=<n>` /
      `TMUX_MAX_LINES=<n>` (default `20`) from the
     command string — applying these defaults EVEN IF the agent didn't add the
     vars, so EVERY stateful send-keys gets armed — resolves `<target>` to a
     pane id, and arms an in-memory registry entry with an unref'd `setTimeout`.
   - `tool.execute.after` runs right after that SAME send-keys command has
     actually executed, and appends a `<tmux-armed>` reminder DIRECTLY to the
     tool call's own result text (no round-trip through the conversation):
     "pane armed, do not capture-pane, continue a parallel task or stop, you
     will be auto-notified." **This is the reflex enforcement mechanism** — it
     replaces an earlier REACTIVE `throw`-based block on `capture-pane` itself,
     which was explicitly REMOVED (KπX, 2026-08-16): `capture-pane` is NEVER
     intercepted, because the agent may legitimately need it as a manual
     fallback if this very plugin malfunctions (log not written, watcher
     stuck, registry desync) — blocking the one diagnostic tool available in
     that failure mode would be worse than the anti-pattern being prevented.
   - The log watcher polls `/tmp/tmux-pane-done.log`; on a matching `prompt`
     event it clears the timer, runs `tmux capture-pane`, slices the last
     `TMUX_LINES` lines, and injects a `<tmux-notify>` message into the
     OpenCode session (`client.session.prompt`) whose label states the EXACT
     number of lines shown (e.g. `Last 20 output lines:`) — never a vague
     placeholder. If `TMUX_TIMEOUT` elapses first, ONE "still running"
     notification fires with a fresh capture, but the registry entry is kept
     alive (only its timer is cleared) so the real completion notification
     still fires automatically later.
3. **Session isolation** (fixed 2026-08-16, real bug found): pending
   notifications are queued in a `Map<sessionID, string[]>`, NEVER a flat
   global array. Delivery via `chat.message`/`session.idle` ONLY ever drains
   the bucket owned by the exact session receiving the event — a notification
   armed by agent/session A can never leak into agent/session B's
   conversation, even if A's immediate flush was delayed or failed.
4. **Busy-pane block — TWO cascading layers** (layer 1 added 2026-08-16, KπX
   directive — "on demande d'utiliser un autre pane vide si présent, ou en
   créer un si tous occupés"; layer 2 added same day, KπX follow-up question
   "tu check juste busy par un autre agent ou vrai busy ?"):
   - **Layer 1 — tracked-busy**: `tool.execute.before` REJECTS a `tmux
     send-keys` targeting a pane that already has an unresolved registry
     entry (a previously armed command that hasn't returned to its prompt
     yet). Before this layer existed, a second arm on the SAME pane silently
     overwrote the first ("last-arm-wins") — the first session would never
     be notified, with zero trace anywhere, even in debug logs (a real gap
     found the same day via a direct KπX question about session isolation).
   - **Layer 2 — untracked-busy**: layer 1 alone only catches panes WE
     armed via our own `tmux send-keys` interception — a pane busy for any
     OTHER reason (KπX typing directly in it, an agent bypassing our
     interception, a leftover foreground process) was invisible to it. If
     layer 1 finds nothing, `tool.execute.before` now ALSO queries `tmux
     display-message -p -t <paneId> '#{pane_current_command}'` (pure
     metadata, no `capture-pane`/content read needed) and blocks if the
     result isn't one of `zsh`/`bash`/`sh`/`fish` — a real, independent
     ground-truth signal that catches genuine busyness regardless of
     whether our system ever tracked it.
   - Either layer's `throw`d message tells the agent EXACTLY what to do:
     **never send-keys into an occupied pane — use a different EMPTY pane
     if one exists (`tmux list-panes -a`), or create a new pane/window if all
     are occupied.** Same `throw`-to-block pattern as `make-check-guard.js`
     (the only other hook in this kernel that blocks a tool call outright) —
     this is a DIFFERENT scope from the `capture-pane` block that was removed
     in point 2: blocking `send-keys` into a busy pane protects against input
     cross-contamination; blocking `capture-pane` would have removed the
     agent's only diagnostic fallback, which is why that one stays unblocked.

Agents: the reminder is a **reflex**, not an opt-in — every `tmux send-keys`
gets armed AND reminded, whether or not you added `TMUX_TIMEOUT`/`TMUX_LINES`
(defaults apply). You never manually `capture-pane` in a loop to check
progress — but `capture-pane` itself is always available to you as a
diagnostic fallback if you suspect the plugin isn't working. Full usage
pattern → `### Run and get notified` above and `AGENTS.md` →
`rules/tool-discipline.md` → `## Tmux Stateful Command Execution`.

Apply after edits: `tmux source-file $HOME/.tmux.conf`.

## Sessions, Windows & Panes — CLI + Keys

Full CLI/keybind tables for creating/entering/switching/deleting **sessions**, tabs (**windows**), and split/move/resize/kill (**panes**) → **`references/cli-reference.md`**.

## Copy-Mode, Scrolling & Mouse

Copy-mode keys, KπX mouse-drag-to-copy behavior, wheel bindings, and synchronised panes → **`references/copy-mode-mouse.md`**.

## Send Keys & Capture Output

```bash
# Send keys to a pane — DEFAULT pattern: always carry TMUX_TIMEOUT/TMUX_LINES
# (see ### Run and get notified above) so completion is reported automatically.
TMUX_TIMEOUT=300 TMUX_LINES=20 tmux send-keys -t SESSION:WIN.PANE 'ls -la' Enter

# Manual capture-pane — NEVER blocked (KπX, 2026-08-16: an earlier reactive
# block was tried, then explicitly REMOVED — the agent may legitimately need
# this if the tmux-notify plugin itself malfunctions). Preferred practice:
# rely on the automatic <tmux-armed>/<tmux-notify> messages instead of
# checking yourself, but this command always remains available as a fallback.
tmux capture-pane -t SESSION:WIN.PANE -p

# Capture scrollback (-S = start line, -E = end line)
tmux capture-pane -t SESSION:WIN.PANE -p -S -3000

# Save scrollback to file
tmux capture-pane -t SESSION:WIN.PANE -p -S - > /tmp/pane.log
```

Agent rule: rely on the automatic `<tmux-notify>` message for command
completion (see `## Stateful Integration` + `TMUX_TIMEOUT`/`TMUX_LINES`). **Do
NOT "check just in case" with a manual `capture-pane` right after sending a
stateful command** — even framed as a one-off/one-shot look, this defeats the
entire point of the reflex and is now blocked at the tool level for any pane
still in the registry. Only fall back to a manual chat handoff for a
**visual** KπX action the stateful system cannot detect from pane text (QR
code, OAuth consent click) — never for a command that will return to its own
prompt.

### ⚠️ CRITICAL — Always identify pane before send-keys

**NEVER** use `tmux send-keys` without first confirming the exact target session, window, and pane index via `tmux list-panes`. Blindly sending keys to the wrong pane can:

- Send commands into an opencode agent session (breaking it)
- Type into a running editor (nvim, micro) — injecting garbage
- Send keystrokes to a sudo prompt or SSH session unintentionally

**Mandatory checklist before every `send-keys`:**

1. `tmux list-sessions` — identify the right session
2. `tmux list-windows -t <SESSION>` — identify the right window name and index
3. `tmux list-panes -t <SESSION:WIN>` — identify the right pane index (0, 1, 2...)
   - Also check `pane_current_command` to confirm what's running in that pane
4. Only then target with `-t SESSION:WIN.PANE`

```bash
# Full identification query:
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}'
```

This shows every pane across all sessions with the running command — no guessing.

## References

- `references/session-layout.md` — Standard session layout per equipment: 3-pane `agents` window diagram, setup commands
- `references/plugins.md` — TPM plugins (resurrect, continuum, yank, copycat, prefix-highlight): install, paths, behavior, scope
- `references/boot-recovery.md` — First-tmux-after-reboot mandatory workflow (continuum-boot off, manual restore steps)
- `references/cli-reference.md` — Full CLI + keybind tables: sessions, windows, panes, layouts
- `references/copy-mode-mouse.md` — Copy-mode keys, mouse-drag-to-copy, wheel bindings, synchronised panes
- `references/config-and-troubleshooting.md` — Config essentials, useful one-liners, SSH+tmux pattern, troubleshooting table
- `references/windows.md` — WSL tmux setup and limitations

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-tmux/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-tmux/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-20 | [COLAB] | v1.20.1 — Updated the S25 session-layout cross-reference to `k-phones`. |
| 2026-08-16 | [COLAB] | v1.19.0 — **Fixed 2 real bugs found via KπX diagnostic questions (Q1: dead pane stays visible on `exit`, no layout reflow; Q2: opencode web terminal hijacked into shared tmux session)**: (Q1) `tmux show-window-options -g` revealed the LIVE server still carried `remain-on-exit on` even though `assets/tmux.conf` has had no `remain-on-exit` line since the precmd/prompt-event redesign — a config-file-vs-live-server drift (sourcing a config never unsets an option removed from it) dating back to the v1.14.0 pass. Fixed live: `tmux set-window-option -g remain-on-exit off` + cleared `remain-on-exit-format`. (Q2) opencode web's embedded terminal (confirmed via its own source, `packages/opencode/src/pty/index.ts`) sets `OPENCODE_TERMINAL=1` unconditionally on every PTY it spawns for its terminal panel — the Auto-tmux block in `kshrc.base`/7 infra copies was hijacking that isolated PTY into the shared desktop tmux session (multi-client resize glitches, input cross-contamination, non-`exec`'d leaked idle shells). Fixed in `k-zsh` (see its changelog) by adding `[ -z "$OPENCODE_TERMINAL" ]` to the guard. Both findings documented in `references/insights.md` (config/runtime drift + PTY-hijack anti-repeat lessons). Changelog rotated: v1.16.0 and v1.14.0 moved to `references/log.md` (new file). |
| 2026-08-16 | [COLAB] | v1.20.0 — **Busy-pane block extended to a 2nd layer (KπX follow-up question — "tu check juste busy par un autre agent ou vrai busy ?")**: layer 1 (v1.19.0-era `registry.get(paneId)` check) only catches panes armed by OUR OWN system — a pane busy for any other reason (KπX typing directly, an agent bypassing interception, a leftover foreground process) was invisible to it. Added layer 2 in `tmux-notify.js` `tool.execute.before`: if layer 1 finds nothing, queries `tmux display-message -p -t <paneId> '#{pane_current_command}'` (pure metadata, no `capture-pane`/content read) and blocks if the result isn't one of `zsh`/`bash`/`sh`/`fish` — a real, independent ground-truth signal, fails open on any tmux/pane error. `## Stateful Integration` point 4 rewritten to document both layers explicitly. `node --check` OK. Cross-ref: `k-opencode` v2.43.0. |
| [SUMMARY] | — | v1.18.0 capture-pane block REMOVED + proactive reminder + session isolation fix (→ `references/log.md`) · v1.17.0 technical block on manual capture-pane, later reversed (→ `references/log.md`) · v1.16.0 TMUX_TIMEOUT/TMUX_LINES reflex generalized + exact line-count label (→ `references/log.md`) · v1.14.0 Stateful Integration + remain-on-exit (→ `references/log.md`) · v1.13.0 SKILL size reduction (→ `references/log.md`) · v1.12.0 symlink direction reversed (→ `references/log.md`) · v1.11.0 phone exception · v1.9.0 SUDO GATE · v1.8.0 ubuntu session + sudo pane · v1.6.0 focus-events · v1.3.x–v1.5.0 plugins, mouse, continuum. |
