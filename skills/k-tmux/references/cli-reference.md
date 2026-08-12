# CLI Reference — Sessions, Windows, Panes

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
