---
name: k-tmux
description: >
  KπX tmux reference — sessions, windows, panes, copy-mode, mouse scroll, config reload,
  and practical CLI/key shortcuts. Load before any tmux workflow, shared interactive shell,
  or terminal multiplexing task on KπX workstations.
license: private
metadata:
  author: KpihX
  version: "1.4.0"
  scope: terminal-multiplexer
allowed-tools: Bash(tmux:*), Read, Write, Edit
---

# KπX — tmux

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-workspace` (shell / workstation context) · `k-codex` (shared interactive tmux panes with password polling)
> **Canonical config:** `$HOME/.tmux.conf` — skill asset `assets/tmux.conf` is a symlink to it.

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

### Session hygiene

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
| `assets/tmux.conf` | Symlink → `$HOME/.tmux.conf` |
| `assets/tmux-resurrect-save.sh` | Symlink → `$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh` |
| `assets/tmux-resurrect-restore.sh` | Symlink → `$HOME/.tmux/plugins/tmux-resurrect/scripts/restore.sh` |
| `assets/tmux-continuum-save.sh` | Symlink → `$HOME/.tmux/plugins/tmux-continuum/scripts/continuum_save.sh` |

Current KπX settings:

- `mouse on` — click to focus panes, resize splits, select windows
- wheel up → copy-mode scroll (not shell history)
- wheel down → scroll down; `-e` exits copy-mode at bottom
- `history-limit 50000` — large scrollback buffer
- `tmux-resurrect` — saves/restores sessions, windows, panes, layouts, cwd, and pane text
- `tmux-continuum` — auto-saves every 5 minutes and auto-restores when tmux starts
- `@continuum-boot on` — tmux-continuum generates `$HOME/.config/systemd/user/tmux.service` for user-session startup on Linux

Apply after edits:

```bash
tmux source-file $HOME/.tmux.conf
```

## Persistence — resurrect + continuum

Installed plugin paths:

| Plugin | Path |
|--------|------|
| TPM | `$HOME/.tmux/plugins/tpm/` |
| tmux-resurrect | `$HOME/.tmux/plugins/tmux-resurrect/` |
| tmux-continuum | `$HOME/.tmux/plugins/tmux-continuum/` |

Behavior:

| Need | Mechanism |
|------|-----------|
| Manual save | `Ctrl-a Ctrl-s` (`tmux-resurrect`) |
| Manual restore | `Ctrl-a Ctrl-r` (`tmux-resurrect`) |
| Automatic save | every 5 minutes (`tmux-continuum`) |
| Automatic restore | first tmux start after reboot (`@continuum-restore on`) |
| Automatic tmux server boot | enabled at user login via `systemd --user` (`@continuum-boot on`) |
| Last pane display | captured via `@resurrect-capture-pane-contents on` |

Scope:

- Restores tmux sessions, windows/tabs, panes, layouts, current directories, and captured pane text.
- Does **not** restore terminal emulator tabs outside tmux.
- Does **not** restore shell command history for arrow-key navigation; shell history remains owned by zsh (`$HOME/.zsh_history` or any future zsh history split).
- Captured pane text can include sensitive terminal output; avoid displaying secrets before a save.
- On Linux, `@continuum-boot on` creates `$HOME/.config/systemd/user/tmux.service` and starts the tmux server when the user session starts. This is user-login startup, not pre-login system boot.

First restore after reboot:

```bash
tmux
# Continuum auto-restore should run at startup if a previous save exists.
# If needed: Ctrl-a Ctrl-r
```

## Sessions — Create, Enter, Switch, Delete

### CLI (outside tmux)

| Goal | Command |
|------|---------|
| New detached session | `tmux new -s NAME` |
| New session, run command | `tmux new -s NAME -d 'cmd'` |
| List sessions | `tmux ls` / `tmux list-sessions` |
| Attach | `tmux attach -t NAME` / `tmux a -t NAME` |
| Attach or create | `tmux new -A -s NAME` |
| Kill session | `tmux kill-session -t NAME` |
| Kill all except current | `tmux kill-session -a` |
| Kill every session | `tmux kill-server` |
| Rename session | `tmux rename-session -t OLD NEW` |

### Inside tmux (prefix = `Ctrl-a`)

| Keys | Action |
|------|--------|
| `d` | Detach (session keeps running) |
| `s` | Interactive session picker |
| `$` | Rename current session |
| `(` | Previous session |
| `)` | Next session |

### Quick patterns

```bash
# Dev session that survives disconnect
tmux new -As dev

# One-shot remote command in named session
tmux new -s deploy -d 'ssh homelab "docker compose up -d"' && tmux attach -t deploy

# Find which session owns a pane running a process
tmux list-panes -a -F '#{session_name} #{pane_id} #{pane_current_command}'
```

## Windows — Tabs Inside a Session

### CLI

```bash
tmux new-window -t SESSION: -n NAME      # new window
tmux kill-window -t SESSION:INDEX        # kill window by index
tmux rename-window -t SESSION:INDEX NAME
tmux select-window -t SESSION:INDEX
tmux list-windows -t SESSION
```

### Keys (after prefix)

| Keys | Action |
|------|--------|
| `c` | New window |
| `,` | Rename window |
| `&` | Kill window (confirm) |
| `w` | Window picker |
| `n` | Next window |
| `p` | Previous window |
| `0`–`9` | Jump to window index |
| `l` | Last active window |

Window target syntax: `session:window` or `session:window.pane` (e.g. `dev:2.1`).

## Panes — Split, Move, Resize, Kill

### Keys (after prefix)

| Keys | Action |
|------|--------|
| `%` | Split vertical (side by side) |
| `"` | Split horizontal (top/bottom) |
| `o` | Cycle panes |
| `;` | Last active pane |
| `q` | Show pane numbers (press number to jump) |
| `x` | Kill pane (confirm) |
| `z` | Toggle pane zoom (fullscreen toggle) |
| `{` | Move pane left |
| `}` | Move pane right |
| `Ctrl-o` | Rotate panes |
| `Alt-↑/↓/←/→` | Resize pane (with mouse off, or default bindings) |

### CLI

```bash
tmux split-window -h              # vertical split in current window
tmux split-window -v              # horizontal split
tmux kill-pane -t SESSION:WIN.PANE
tmux select-pane -t SESSION:WIN.PANE
tmux swap-pane -s SRC -t DST
tmux display-panes                # show pane indices
```

### Layouts

| Keys | Action |
|------|--------|
| `Space` | Cycle preset layouts |
| `Alt-1` … `Alt-5` | Layout: even-horizontal, even-vertical, main-horizontal, main-vertical, tiled |

## Copy-Mode & Scrolling

Enter copy-mode to scroll the tmux buffer (not the shell prompt history).

| Keys | Action |
|------|--------|
| `[` | Enter copy-mode |
| `q` | Exit copy-mode |
| `PgUp` / wheel up | Scroll up (with KπX config, wheel always scrolls buffer) |
| `PgDn` / wheel down | Scroll down |
| `/` | Search forward |
| `?` | Search backward |
| `Enter` | Copy selection (default mode) |
| `]` | Paste buffer |

Vi mode (optional — add to config if preferred):

```bash
setw -g mode-keys vi
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-selection-and-cancel
```

## Mouse (KπX Config)

With `mouse on` and wheel bindings:

- **Wheel up** → enter copy-mode and scroll history
- **Wheel down** → scroll down; exits copy-mode at bottom (`-e`)
- **Click pane** → focus
- **Click window name** → switch window
- **Drag border** → resize pane

If wheel still changes shell history: confirm config is loaded (`tmux show -g mouse`), reload with `tmux source-file ~/.tmux.conf`, and check the terminal emulator forwards wheel events to tmux.

## Synchronised Panes

Type the same input in all panes of the current window:

```bash
setw synchronize-panes on    # or prefix + toggle if bound
setw synchronize-panes off
```

Useful for running the same command on multiple SSH hosts — turn off immediately after.

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

## Config Essentials

Edit `$HOME/.tmux.conf` (or follow symlink from `assets/tmux.conf`).

| Setting | Example | Purpose |
|---------|---------|---------|
| Prefix | `set -g prefix C-a` | Change prefix from Ctrl-b (enabled in workspace) |
| Index from 1 | `set -g base-index 1` / `setw -g pane-base-index 1` | Windows/panes start at 1 |
| True color | `set -g default-terminal "tmux-256color"` | Better colors |
| Activity alert | `setw -g monitor-activity on` | Highlight idle windows with activity |
| Reattach | `set -g detach-on-destroy off` | Stay in tmux when a pane exits (tmux 3.2+) |

Reload without restart:

```bash
tmux source-file ~/.tmux.conf
```

## Useful One-Liners

```bash
# Is tmux running?
tmux has-session 2>/dev/null && echo yes || echo no

# Current session/window/pane (inside tmux)
echo "$TMUX"

# Kill all sessions except named
tmux kill-session -a -t dev

# New window in another session from outside
tmux new-window -t dev -n logs

# Run command in existing pane
tmux send-keys -t dev:0.0 C-c 'npm run dev' Enter

# Popup (tmux 3.2+)
tmux display-popup -E -w 80% -h 60% 'htop'
```

## SSH + tmux Pattern

On remote host, always prefer tmux for long jobs:

```bash
ssh homelab -t 'tmux new -As main'
# detach with prefix+d — job survives disconnect
```

Local persistence across laptop sleep:

```bash
tmux new -As local
# reattach after wake
tmux attach -t local
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Wheel browses shell history | Reload KπX config; verify wheel bindings in `~/.tmux.conf` |
| Colors broken in neovim/htop | Set `default-terminal "tmux-256color"`, ensure `TERM` in shell |
| `sessions should be nested` warning | Already inside tmux — use `tmux switch-client` or nested intentionally |
| Cannot attach | `tmux ls` — session may be dead; check `tmux info` |
| Config ignored | Wrong file path; use `tmux show -g` to inspect active values |
| Broken symlink in skill assets | Recreate: `ln -sf $HOME/.tmux.conf assets/tmux.conf` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-tmux/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-tmux/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-22 | [CODEX] | v1.4.0 — Enabled `@continuum-boot on`; verified generated `systemd --user` tmux service and Linux login-start behavior. |
| 2026-05-22 | [CODEX] | v1.3.1 — Changed tmux-continuum auto-save interval from 15 minutes to 5 minutes. |
| [SUMMARY] | — | v1.3.0 installed resurrect+continuum and script symlinks; v1.2.0 Ctrl-a prefix documented; v1.1.1 full shared interactive gate inlined; v1.1.0 shared interactive gate replaces `sui`; v1.0.0 baseline tmux skill. |
