---
name: k-tmux
description: >
  KπX tmux reference — sessions, windows, panes, copy-mode, mouse scroll, config reload,
  and practical CLI/key shortcuts. Load before any tmux workflow, shared interactive shell,
  or terminal multiplexing task on KπX workstations.
  ⚠️ SUDO GATE — tmux is the ONLY channel for sudo/SSH/password elevation.
  Never raw sudo in agent shells. Use tmux pane ubuntu:0.2 (ops).
metadata:
  version: 1.9.0
  author: KpihX
  scope: terminal-multiplexer
allowed-tools: Bash(tmux:*), Read, Write, Edit
---

# KπX — tmux

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-ubuntu` (shell / workstation context) · `k-codex` (shared interactive tmux panes with password polling)
> **OS references:** `references/windows.md` (WSL tmux setup and limitations)
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

### Fixed session: `ubuntu`

**KπX workstation always has a running `ubuntu` tmux session** (attached, 3 windows minimum).

Window 0 ("agents") has 3 panes:

| Pane | App | Rules |
|------|-----|-------|
| `ubuntu:0.0` | opencode | Never send keys here |
| `ubuntu:0.1` | nvim | Never send keys here |
| `ubuntu:0.2` | **zsh** | **Designated sudo/ops pane** — all elevation here |

**Always prefer `ubuntu` for sudo/ops.** Do not create separate sessions for workstation tasks unless the scope is clearly different (e.g. SSH to homelab → new session).

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
| `assets/tmux.conf` | Symlink → `$HOME/.tmux.conf` |
| `assets/tmux-resurrect-save.sh` | Symlink → `$HOME/.tmux/plugins/tmux-resurrect/scripts/save.sh` |
| `assets/tmux-resurrect-restore.sh` | Symlink → `$HOME/.tmux/plugins/tmux-resurrect/scripts/restore.sh` |
| `assets/tmux-continuum-save.sh` | Symlink → `$HOME/.tmux/plugins/tmux-continuum/scripts/continuum_save.sh` |

Current KπX settings:

- `mouse on` — click to focus panes, resize splits, select windows
- `focus-events on` — sends focus gained/lost to Neovim for `autoread` (reload files when switching back to tmux window)
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

## Plugins — TPM

| Plugin | Prefix key | Purpose |
|--------|-----------|---------|
| `tmux-resurrect` | `Ctrl-a Ctrl-s` save / `Ctrl-a Ctrl-r` restore | Session/window/pane/layout/cwd save & restore |
| `tmux-continuum` | — (auto 5min) | Auto-save + auto-restore on first tmux |
| `tmux-yank` | `Ctrl-a Ctrl-y` (vi copy-mode) | System clipboard integration (xclip/wl-copy) |
| `tmux-copycat` | `Ctrl-a /` in copy-mode | Regex file/pattern search in scrollback |
| `tmux-prefix-highlight` | — | Shows prefix indicator in status bar |

Install commands:

```bash
# Add to ~/.tmux.conf, then:
tmux new -s tpm-install && ~/.tmux/plugins/tpm/scripts/install_plugins.sh
# Or from existing tmux: prefix + I (capital I)
```

Plugin install paths:

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
| Automatic restore | first tmux start after reboot (`@continuum-restore on`) — run `tmux` from a terminal post-login |
| Login systemd boot | **off** (`@continuum-boot off`; `tmux.service` disabled — avoids login server dying before restore) |
| Last pane display | captured via `@resurrect-capture-pane-contents on` |

Scope:

- Restores tmux sessions, windows/tabs, panes, layouts, current directories, and captured pane text.
- Does **not** restore terminal emulator tabs outside tmux.
- Does **not** restore shell command history for arrow-key navigation; shell history remains owned by zsh (`$HOME/.zsh_history` or any future zsh history split).
- Captured pane text can include sensitive terminal output; avoid displaying secrets before a save.
- On Linux, `@continuum-boot on` would create `$HOME/.config/systemd/user/tmux.service`; **KπX keeps it off** (see **First tmux after reboot**).

### First tmux after reboot (post-login) — mandatory workflow

> **Do not trust an immediate `tmux ls` right after login.** `@continuum-boot` is **off** and `tmux.service` is **disabled** — there is no login-time server. **`no server running`** until you run step 2 (`tmux` from a real terminal).

**After every reboot, in order:**

1. **Check server (optional)** — `tmux ls`  
   - `no server running` → normal; go to step 2.  
   - Only `default` or wrong layout → step 4 after attach.

2. **Start tmux once from a real terminal** (Cursor, GNOME Terminal, etc.) — not via the user `tmux.service` unit:
   ```bash
   tmux
   ```
   Auto-restore (`@continuum-restore on`) runs **only on this new server start** (first client loads plugins → `continuum_restore.sh` after ~1s).

3. **Verify sessions** — `tmux ls` inside or outside tmux. Expect your named sessions (`live`, `pve`, …) if the last save was good.

4. **If empty or only a bare `default`** — manual restore:
   ```bash
   # inside tmux: Ctrl-a Ctrl-r
   ```
   If `last` points at a tiny/empty save (reboot loop), pick an older file:
   ```bash
   ls -lt $HOME/.tmux/resurrect/tmux_resurrect_*.txt | head
   wc -c $HOME/.tmux/resurrect/$(readlink -f $HOME/.tmux/resurrect/last)
   ```
   See tmux-resurrect docs for restoring a specific timestamped file.

5. **Before the next reboot** — inside tmux: `Ctrl-a Ctrl-s`, then confirm `last` is non-trivial:
   ```bash
   wc -c $HOME/.tmux/resurrect/$(readlink -f $HOME/.tmux/resurrect/last)
   ```
   Do **not** rely on shutdown `ExecStop` save — journals show `save.sh: no server running` when the unit stops.

**Diagnose boot/shutdown (optional):**

```bash
journalctl --user -u tmux.service -b 0 --no-pager | tail -30
```

**Config (2026-05-25):** `@continuum-boot off` + `systemctl --user disable tmux.service`. Restore happens when KπX runs step 2. Forensics: `references/insights.md`.

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

> **Why Shift+drag “does nothing”:** With `mouse on`, tmux owns the mouse. **Cursor, Zed, and most integrated terminals do not pass Shift+drag to the OS** — there is no highlight, no copy. Use the workflows below (wheel or drag-in-copy-mode), not desktop-style Shift+select.

| Keys | Action |
|------|--------|
| `[` | Enter copy-mode |
| `q` / `Esc` | Cancel copy-mode (no copy) |
| `PgUp` / wheel up | Scroll up (wheel enters copy-mode via KπX config) |
| `PgDn` / wheel down | Scroll down |
| `/` / `?` | Search (vi copy-mode) |
| `v` | Begin keyboard selection (vi) |
| `y` | Copy selection to system clipboard + exit |
| `Enter` | Same as `y` (copy + exit) |
| `]` | Paste tmux buffer |

### Mouse copy (KπX default — `mode-keys vi`)

| Action | Result |
|--------|--------|
| **Drag** (no Shift) on text | Enters copy-mode, highlights selection |
| **Release** after drag | Copies to clipboard, exits copy-mode |
| **Wheel up** | Scroll history in copy-mode (unchanged) |
| **Right-click** | Copy-mode (scroll/select) — not the tmux popup menu |
| **Shift+drag** | Ignored by design in integrated terminals — use drag without Shift |

Clipboard pipe: `xclip` (XWayland) with `wl-copy` fallback — on pure Wayland install `wl-clipboard` (`apt install wl-clipboard`) if copy is empty.

Reload after config change: `tmux source-file $HOME/.tmux.conf`

## Mouse (KπX Config)

With `mouse on` and wheel bindings:

- **Wheel up** → enter copy-mode and scroll history
- **Wheel down** → scroll down; exits copy-mode at bottom (`-e`)
- **Click pane** → focus
- **Click window name** → switch window
- **Drag border** → resize pane
- **Drag on text** → copy-mode selection + copy on release (see above)

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
| After reboot: `tmux ls` → no server / no sessions | Follow **First tmux after reboot** above; do not expect persistence from `tmux.service` at login |
| After reboot: only empty `default` | `Ctrl-a Ctrl-r`; check `resurrect/last` size; restore older `tmux_resurrect_*.txt` if needed |
| Config ignored | Wrong file path; use `tmux show -g` to inspect active values |
| Broken symlink in skill assets | Recreate: `ln -sf $HOME/.tmux.conf assets/tmux.conf` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-tmux/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-tmux/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.9.0 — Added **SUDO GATE** warning to description: tmux is the ONLY channel for sudo/SSH elevation. Never raw sudo in agent shells. |
| [SUMMARY] | — | v1.8.0 fixed ubuntu session + sudo pane; v1.6.0 focus-events on, Neovim autoread; v1.3.x–v1.5.0: tmux-yank/copycat plugins, mouse copy, continuum boot fix, prefix and shared interactive gate. |
