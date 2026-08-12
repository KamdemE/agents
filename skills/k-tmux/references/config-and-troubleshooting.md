# Config Essentials, One-Liners, SSH Pattern & Troubleshooting

## Config Essentials

Edit `assets/tmux.conf` (the source of truth). `$HOME/.tmux.conf` is a symlink to it.

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
| After reboot: `tmux ls` → no server / no sessions | Follow **First tmux after reboot** (`references/boot-recovery.md`); do not expect persistence from `tmux.service` at login |
| After reboot: only empty `default` | `Ctrl-a Ctrl-r`; check `resurrect/last` size; restore older `tmux_resurrect_*.txt` if needed |
| Config ignored | Wrong file path; use `tmux show -g` to inspect active values |
| Broken symlink in skill assets | Recreate: `ln -sf ~/.agents/skills/k-tmux/assets/tmux.conf ~/.tmux.conf` |
