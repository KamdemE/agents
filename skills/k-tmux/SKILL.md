---
name: k-tmux
description: >
  KπX tmux reference — sessions, windows, panes, copy-mode, mouse scroll, config reload,
  and practical CLI/key shortcuts. Load before any tmux workflow, shared interactive shell,
  or terminal multiplexing task on KπX workstations.
  ⚠️ SUDO GATE — tmux is the ONLY channel for sudo/SSH/password elevation.
  Never raw sudo in agent shells. Use ops pane <session>:agents.2.
metadata:
  version: 1.14.0
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

### Run and poll

```bash
tmux send-keys -t SESSION:WIN.PANE 'your command here' Enter
tmux capture-pane -t SESSION:WIN.PANE -p | tail -20
```

Loop until:

- command finished (shell prompt back), or
- **≥30 seconds** elapsed since last `send-keys` with no progress and KπX has not completed auth

| Phase | Rule |
|-------|------|
| **Before 30s** | Keep polling `capture-pane`. **Do not** stop the agent turn for chat handoff. |
| **After ≥30s without validation** | One chat message with: (1) `tmux attach -t SESSION` (+ window if needed), (2) exact command running or to run, (3) what KπX must type/approve. |
| **Prompt cleared** | Resume automation (next command or verify output). |

Password / auth prompts are **not** stop conditions before 30s — keep polling.

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

tmux can **notify** an agent (e.g. an OpenCode plugin) when a pane's process
finishes — instead of the agent polling `capture-pane`. Three pieces cooperate:

1. **`remain-on-exit on`** (global, in `assets/tmux.conf`): a pane whose process
   exits STAYS visible with its output readable via `capture-pane`, instead of
   being destroyed. This is required for reliable detection (see #2).
2. **Global `pane-died` hook** → `scripts/hooks/tmux-pane-done.sh` (in
   `k-opencode/scripts/hooks/`): appends `{"pane","exit","ts"}` as one JSON line
   to `/tmp/tmux-pane-done.log`.
   ```tmux
   set-hook -g pane-died 'run-shell "$HOME/.agents/skills/k-opencode/scripts/hooks/tmux-pane-done.sh #{pane_id} #{pane_dead_status}"'
   ```
   ⚠️ Must be **GLOBAL**: per-pane `pane-exited`/`pane-died` is broken upstream
   (tmux issues #2882/#3736) — by the time the hook fires, the pane is destroyed
   and `#{pane_id}`/`#{pane_dead_status}` resolve to garbage.
3. **`k-opencode` `tmux-notify.js` hook** polls that log and injects a
   `<tmux-notify>` message into the OpenCode session (`client.session.prompt`),
   bringing the agent back to work. Full mechanics in `k-opencode` changelog.

Because `remain-on-exit` leaves dead panes visible, `Ctrl-a K` (`bind K
kill-pane`) closes a dead/selected pane cleanly.

Apply after edits: `tmux source-file $HOME/.tmux.conf`.

## Sessions, Windows & Panes — CLI + Keys

Full CLI/keybind tables for creating/entering/switching/deleting **sessions**, tabs (**windows**), and split/move/resize/kill (**panes**) → **`references/cli-reference.md`**.

## Copy-Mode, Scrolling & Mouse

Copy-mode keys, KπX mouse-drag-to-copy behavior, wheel bindings, and synchronised panes → **`references/copy-mode-mouse.md`**.

## Send Keys & Capture Output

```bash
# Send keys to a pane (agents / automation)
tmux send-keys -t SESSION:WIN.PANE 'ls -la' Enter

# Capture visible pane content
tmux capture-pane -t SESSION:WIN.PANE -p

# Capture scrollback (-S = start line, -E = end line)
tmux capture-pane -t SESSION:WIN.PANE -p -S -3000

# Save scrollback to file
tmux capture-pane -t SESSION:WIN.PANE -p -S - > /tmp/pane.log
```

Agent rule: follow **Shared interactive gate** — poll ≥30s before any chat handoff on auth prompts.

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
| 2026-08-16 | [COLAB] | v1.14.0 — **Stateful Integration (agent→tmux→agent) + `remain-on-exit`**: `assets/tmux.conf` now sets `remain-on-exit on` (dead panes stay visible/readable via capture-pane) + a GLOBAL `pane-died` hook relaying to `k-opencode/scripts/hooks/tmux-pane-done.sh` (JSON line to `/tmp/tmux-pane-done.log`) + `bind K kill-pane` to close dead panes. Added `## Stateful Integration` section documenting the 3-piece mechanism (remain-on-exit + global pane-died hook + `k-opencode` tmux-notify.js). E2E validated live (see k-opencode v2.34.0). |
| [SUMMARY] | — | v1.13.0 SKILL size reduction (→ `references/log.md`) · v1.12.0 symlink direction reversed (→ `references/log.md`) · v1.11.0 phone exception · v1.9.0 SUDO GATE · v1.8.0 ubuntu session + sudo pane · v1.6.0 focus-events · v1.3.x–v1.5.0 plugins, mouse, continuum. |
