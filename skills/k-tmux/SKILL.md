---
name: k-tmux
description: >
  KπX tmux reference — sessions, windows, panes, copy-mode, mouse scroll, config reload,
  and practical CLI/key shortcuts. Load before any tmux workflow, shared interactive shell,
  or terminal multiplexing task on KπX workstations.
  ⚠️ SUDO GATE — tmux is the ONLY channel for sudo/SSH/password elevation.
  Never raw sudo in agent shells. Use ops pane <session>:agents.2.
metadata:
  version: 1.30.0
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

🔴 **TECHNICALLY ENFORCED, not just documented (2026-08-29):** `k-opencode`'s
`raw-exec-guard.js` hook `throw`s (blocks the tool call before it runs) on any
raw `sudo` — and separately on raw `sleep`/`wait`/`timeout` (manual polling
anti-pattern) — unless the command is already a compliant
`tmux send-keys -t <target> '...' Enter` call. If you hit this block, do not
retry the same raw command: send the exact same payload through
`tmux send-keys` on the ops pane instead (see `### Run and get notified`
below). Scope deliberately limited to these 2 static checks — no attempt to
kill a command mid-execution past some duration (not achievable with the
current OpenCode plugin API, and out of scope per KπX).

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
# Default long command — 30 seconds (NOT ms) timeout, 50 lines shown
TMUX_TIMEOUT=30 TMUX_LINES=50 tmux send-keys -t SESSION:WIN.PANE 'your command here' Enter

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
| Right after you `send-keys` (ALWAYS, even with no `TMUX_TIMEOUT`/`TMUX_LINES` added — defaults apply) | A `<tmux-armed>` reminder appended directly to that SAME tool call's own result: pane armed, continue a parallel task or stop, you'll be auto-notified. If its final capture is empty, incomplete, or insufficient, immediately run the one larger diagnostic capture it names (`tmux capture-pane -p -t <pane> -S -100`), never a polling loop. |
| Pane returns to its prompt before `TMUX_TIMEOUT` | `<tmux-notify>` — command FINISHED, lease released, exact last-N captured lines. |
| `TMUX_TIMEOUT` elapses, pane still not at shell | `<tmux-watchdog>` — explicit `STATUS:` (has NOT returned yet) + check counter + a lettered **decision tree**: **A** interactive → keep driving it or `C-c` when done; **B** normal-but-slow, expect much longer → `: TMUX_ADJUST` now; **C** normal, current interval fine → do nothing; **D** stuck/crashed/forgotten → `C-c` now or be woken forever. Checks ≥3 add an explicit push toward B/D. Recurring every `TMUX_TIMEOUT` until shell return. |

**Adjust the timeout without ever touching the pane (2026-08-29):** if a watchdog fires and you judge the pane needs more (or less) time before the next check, run this — it is a pure no-op meta command, it is NEVER sent to the pane's actual input:

```bash
: TMUX_ADJUST SESSION:WIN.PANE 180   # or the pane id, e.g. %3
```

The lease's countdown restarts from the new value; you get a `<tmux-timeout-adjusted>`
confirmation. Only the session that armed the pane may adjust it (another
session's lease → refused, no lease at all → informational no-op, never an
error). This is the ONLY sanctioned way to widen/narrow the check interval —
never `send-keys` an env var into the pane itself (would pollute the stdin of
whatever is actually running there).

**`capture-pane` is NEVER blocked:** it remains a diagnostic fallback when the
watcher is suspect, and an explicit snapshot is legitimate for an interactive
TUI. For a normal command, never turn it into a polling loop: the shell-return
notification is authoritative. The reflex is enforced PROACTIVELY — a reminder
appended directly to the `send-keys` call's own result right after you send it
(see `<tmux-armed>` above) — never by reactively rejecting a later
`capture-pane` call.

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
| `assets/tmux-init.sh` | Creates standard session per equipment (3 windows or 2 for phones) |

Current KπX settings: `mouse on`, `focus-events on`, wheel → copy-mode scroll, `history-limit 50000`, `tmux-resurrect`/`tmux-continuum` auto-save every 5 min + auto-restore on boot (`@continuum-boot on` generates the systemd unit). Full plugin behavior/scope → **`references/plugins.md`**. Reboot recovery workflow (mandatory, `@continuum-boot` is OFF) → **`references/boot-recovery.md`**.

Apply after edits:

```bash
tmux source-file $HOME/.tmux.conf
```

## Stateful Integration (agent → tmux → agent notifications)

An agent (e.g. an OpenCode plugin) can be **notified** when a **persistent pane** returns to its shell prompt (a command the agent launched finished) — instead of the agent polling `capture-pane`. Panes PERSIST: nothing is killed or detached, no `remain-on-exit` needed, and no tmux-side silence heuristics are used.

Brief summary of the mechanism:
- **Shell prompt hook** in `.kshrc` writes JSON prompt events to `/tmp/tmux-pane-done.log`.
- **`k-opencode` `tmux-notify.js` plugin** handles arming (`tool.execute.before`) and proactive reminder (`tool.execute.after`).
- **Session isolation** scopes notifications to the exact session that launched the command.
- **Pane leases** preserve exclusive cross-session ownership while letting the owner continue an interactive program.
- **Timeout self-adjustment** (`: TMUX_ADJUST <pane> <seconds>`) lets the owning session widen/narrow its own watchdog interval at any time — a no-op meta command, never sent to the pane.

For detailed architecture, cooperative pieces, and rules, see **`references/stateful-integration.md`**.

Apply after edits: `tmux source-file $HOME/.tmux.conf`.

## Sessions, Windows & Panes — CLI + Keys

Full CLI/keybind tables for creating/entering/switching/deleting **sessions**, tabs (**windows**), and split/move/resize/kill (**panes**) → **`references/cli-reference.md`**.

## Copy-Mode, Scrolling & Mouse

Copy-mode keys, KπX mouse-drag-to-copy behavior, wheel bindings, and synchronised panes → **`references/copy-mode-mouse.md`**.

## Send Keys & Capture Output

```bash
# Send keys to a pane — DEFAULT pattern: always carry TMUX_TIMEOUT/TMUX_LINES
# (see ### Run and get notified above) so completion is reported automatically.
TMUX_TIMEOUT=30 TMUX_LINES=20 tmux send-keys -t SESSION:WIN.PANE 'ls -la' Enter

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
- `references/stateful-integration.md` — Detailed stateful agent-notification mechanism, hooks, and pane leases
- `references/config-and-troubleshooting.md` — Config essentials, useful one-liners, SSH+tmux pattern, troubleshooting table
- `references/windows.md` — WSL tmux setup and limitations

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-tmux/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-tmux/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-30 | [LIVE] | v1.30.0 — **Default `TMUX_LINES` raised 20→50 and empty-result fallback made explicit (KπX request):** `<tmux-armed>` now tells the agent to make one immediate `tmux capture-pane -p -t <pane> -S -100` diagnostic capture whenever the eventual automatic capture is empty, incomplete, or insufficient. It remains a one-shot diagnosis, never a polling loop. |
| 2026-08-29 | [LIVE] | v1.29.0 — **`## tmux sudo Gate` and self-backgrounding rules now TECHNICALLY ENFORCED (KπX request)**: both were prose-only for 3+ days despite documented incidents. `k-opencode`'s new `raw-exec-guard.js` hook blocks raw `sudo`/`sleep`/`wait`/`timeout` unless the command is already a compliant `tmux send-keys` call. `## Shared interactive gate` and `## tmux sudo Gate` updated to state the block explicitly. Scope deliberately limited (KπX): no attempt at a runtime >30s kill-and-relaunch (not achievable with the current plugin API, rejected as out of scope). |
| 2026-08-29 | [LIVE] | v1.28.1 — **Orphan sentence fragment fixed in `## Send Keys & Capture Output`** (KπX-flagged in a prior turn's Remarks, then explicitly requested "fix ceci aussi"): a dangling leftover fragment from a previous edit ("after `send-keys`), never by rejecting a later `capture-pane` call.") sat disconnected right after a complete sentence, with zero connecting context. Merged into one coherent sentence — preserves the original point (proactive reminder mechanism vs a reactive block) instead of just deleting it. |
| 2026-08-29 | [LIVE] | v1.28.0 — **Watchdog/armed/control messages rewritten as an explicit A/B/C/D decision tree (KπX 2nd-pass correction — a real transcript showed an agent stuck looping acknowledgements, never deciding)**: every notification now states an unambiguous STATUS ("has NOT returned to its shell yet") + infinite-loop warning + 4 lettered options with exact commands: interactive→keep driving or `C-c`, slow-but-normal→`: TMUX_ADJUST`, normal-just-wait→do nothing, stuck/forgotten→`C-c` now. `## Run and get notified` table updated. |
| 2026-08-29 | [LIVE] | v1.27.0 — **Timeout self-adjustment + escalating watchdog guidance (KπX: watchdog loop was unclear, and adjusting via `send-keys` risked polluting a running process's stdin)**: new no-op meta marker `: TMUX_ADJUST <pane> <seconds>` — never a `send-keys` call, never delivered to the pane — lets the owning session widen/narrow its own watchdog interval at any time; countdown restarts from the new value, ownership-gated (another session's lease → refused; no lease → informational no-op, never a hard error). Watchdog messages now carry an explicit check counter and escalate: checks 1–2 offer "continue in parallel, or adjust if you expect longer"; checks ≥3 read "genuinely long-running, not stuck" and push adjusting the interval or `Ctrl+C` to abort — every message states the exact adjust syntax. `## Run and get notified`, `## Stateful Integration`, `references/stateful-integration.md` updated (5 pieces, was 4). |
| 2026-08-28 | [LIVE] | v1.26.0 — **Owner-aware tmux leases + interactive mode:** the session that armed a pane retains input control (follow-ups, corrections, `Ctrl+C`) without replacing its watch; another OpenCode session stays blocked. `TMUX_MODE=interactive` marks a persistent TUI: timeout becomes `<tmux-watchdog>` (open, no conclusion), while return to shell is the definitive `<tmux-notify>`. Prompt timestamps prevent an old completion event from finalizing a rapid relaunch. `capture-pane` is explicitly available for diagnosis or an interactive snapshot, never a headless polling loop. |
| 2026-08-27 | [COLAB] | v1.25.0 — **Default `TMUX_TIMEOUT` reduced from 300s (5 min) to 30s** (KπX directive). Updated in `tmux-notify.js` (the actual default), `k-tmux/SKILL.md` (examples), `rules/tool-discipline.md` (doc), `k-tmux/references/stateful-integration.md` (doc), and `plugins/AGENTS.md` (inventory table). The old 5-minute default was too long for most agent workflows — 30s catches completion (or prompts) much faster while still allowing explicit override for genuinely long builds. |
| 2026-08-26 | [COLAB] | v1.24.0 — **Copy-mode mouse bindings FULLY REVERTED to the historical pre-saga state (3rd pass, same day) — the real fix is Shift+drag, not a tmux-side config** (KπX: "enfin la solution était juste ce shift ! tout ce qui a été ajouté [...] revient juste à ce qui était depuis toujours"). Root cause of the v1.23.0 "stuck pane"/"tmux menu after selection" complaints: dropping `-and-cancel` (both v1.21.0 and v1.23.0 kept the pane in copy-mode after a copy) left the pane in the `copy-mode-vi` key table, where right-click falls through to tmux's own popup-menu bindings instead of the `root` table's intended `select-pane \; copy-mode`. Reverted `Enter`/`y`/`MouseDragEnd1Pane` to `copy-pipe-and-cancel "xclip -in -selection clipboard -quiet 2>/dev/null \|\| wl-copy -n 2>/dev/null \|\| true"` — byte-identical to the config from before the ENTIRE clipboard saga (v1.20.x and earlier) — auto-exits copy-mode immediately after copy, exactly as it always did. Removed the `@yank_action` override entirely (plugin default `copy-pipe-and-cancel` applies). **Live-reload gotcha hit AGAIN**: `tmux source-file` after removing `set -g @yank_action "copy-pipe"` from the file did NOT clear the option from the running server (same class of bug as the documented `remain-on-exit` incident) — required an explicit `tmux set-option -gu @yank_action` before tmux-yank's `yank.tmux` would regenerate the correct default binding. **Kept**: the `allow-passthrough` version-guard (legitimate deep-pc6-3.2a-vs-ubuntu-3.6 compatibility fix, harmless no-op either way) and the `tmux-copycat` plugin removal (unrelated, already KπX-validated, not implicated in the stuck-pane/menu symptoms). **Real, durable fix documented instead**: Shift+drag mouse selection bypasses tmux's mouse reporting entirely (standard xterm/VTE convention) — the TERMINAL does native selection + OS clipboard write, zero dependency on tmux/OSC52/copy-pipe/tmux-yank, and — critically — works for the deep-pc6 nested-SSH-tmux case too since the terminal only cares about on-screen character cells, not their origin; confirmed via research, documented as the PRIMARY method in this file's header comment, with the mouse-drag/`y`/`Enter` copy-mode path kept as SECONDARY (scrollback-only) fallback. Makes the `RemoteForward`-bridge-to-deep-pc6 idea (raised, deferred in v1.23.0) moot — no longer needed for clipboard. `references/insights.md` +1 entry. |
| 2026-08-26 | [COLAB] | v1.23.0 — **Remote clipboard fix REVERTED (2nd pass, same day) — the v1.21.0 native-OSC52-only approach was wrong**: found live on kpihx-ubuntu right after merging PR #3, via KπX report "je peux pas faire de clic droit .. et c'est auto copié, actu quels sont tous les mécanismes liés au cp ?". Two compounding bugs: (1) GNOME Terminal/VTE (AND Ptyxis, Ubuntu 26.04's new default terminal — same VTE engine, purple icon) has ZERO OSC52 support by deliberate, still-current upstream policy (tracked since 2018) — `copy-selection` relying purely on `set-clipboard on` can never reach the OS clipboard on either terminal, local or over nested SSH/tmux; VS Code/Cursor (xterm.js) DO support OSC52 locally but are known-unreliable over the Remote-SSH extension specifically. (2) `tmux-yank`'s `yank.tmux` unconditionally appends the detected copy command as a trailing arg to `@yank_action` (`send-keys -X "$(yank_action)" "$copy_command"`), assuming a `copy-pipe*` family action — setting it to `"copy-selection"` (not a pipe variant) produced an invalid `copy-selection wl-copy` binding, confirmed live via `tmux list-keys`. Fix: `@yank_action "copy-pipe"` (NOT `-and-cancel` — keeps KπX's preferred "selection stays highlighted" UX) + explicit `Enter` binding restored to `copy-pipe "wl-copy 2>/dev/null \|\| xclip -selection clipboard 2>/dev/null \|\| true"` (byte-identical fallback chain to the pre-v1.21.0 working mechanism). `set-clipboard on` kept as a zero-cost OSC52 bonus for compatible terminals. Investigated (declined for now, KπX arbitrage): bridging deep-pc6's nested-tmux copy back to the local clipboard via the new `RemoteForward 2222` tunnel (G5, k-ssh v1.5.0) — tunnel confirmed LIVE and reachable, but requires provisioning an inbound SSH key FROM deep-pc6 TO kpihx-ubuntu (a real security trade-off, not just a config change) — deferred. `references/insights.md` +1 entry (VTE/Ptyxis OSC52 absence + tmux-yank pipe-arg assumption, cross-ref `k-ssh` RemoteForward). |
| [SUMMARY] | — | v1.22.0 5th tmux-notify root cause (self-backgrounding nohup+sleep never covered) · v1.21.0 remote clipboard native-OSC52-only attempt, superseded same-day by v1.23.0/v1.24.0 · v1.20.2 split-window WINDOW-vs-PANE hazard doc · v1.20.1 S25→k-phones ref · v1.20.0 busy-pane block layer 2 (ground-truth `pane_current_command` check) · v1.19.0 dead-pane & terminal hijack fixes (→ `references/log.md`) · v1.18.0 capture-pane block REMOVED + proactive reminder + session isolation fix (→ `references/log.md`) · v1.17.0 technical block on manual capture-pane, later reversed (→ `references/log.md`) · v1.16.0 TMUX_TIMEOUT/TMUX_LINES reflex generalized + exact line-count label (→ `references/log.md`) · v1.14.0 Stateful Integration + remain-on-exit (→ `references/log.md`) · v1.13.0 SKILL size reduction (→ `references/log.md`) · v1.12.0 symlink direction reversed (→ `references/log.md`) · v1.11.0 phone exception · v1.9.0 SUDO GATE · v1.8.0 ubuntu session + sudo pane · v1.6.0 focus-events · v1.3.x–v1.5.0 plugins, mouse, continuum. |
