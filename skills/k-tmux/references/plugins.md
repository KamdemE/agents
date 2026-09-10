# Plugins — TPM

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
- On Linux, `@continuum-boot on` would create `$HOME/.config/systemd/user/tmux.service`; ** keeps it off** (see `references/boot-recovery.md`).
