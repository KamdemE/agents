# Copy-Mode & Scrolling / Mouse Config

Enter copy-mode to scroll the tmux buffer (not the shell prompt history).

> **Why Shift+drag "does nothing":** With `mouse on`, tmux owns the mouse. **Cursor, Zed, and most integrated terminals do not pass Shift+drag to the OS** — there is no highlight, no copy. Use the workflows below (wheel or drag-in-copy-mode), not desktop-style Shift+select.

| Keys | Action |
|------|--------|
| `[` | Enter copy-mode |
| `q` / `Esc` | Cancel copy-mode (no copy) |
| `PgUp` / wheel up | Scroll up (wheel enters copy-mode via  config) |
| `PgDn` / wheel down | Scroll down |
| `/` / `?` | Search (vi copy-mode) |
| `v` | Begin keyboard selection (vi) |
| `y` | Copy selection to system clipboard + exit |
| `Enter` | Same as `y` (copy + exit) |
| `]` | Paste tmux buffer |

## Mouse copy ( default — `mode-keys vi`)

| Action | Result |
|--------|--------|
| **Drag** (no Shift) on text | Enters copy-mode, highlights selection |
| **Release** after drag | Copies to clipboard, exits copy-mode |
| **Wheel up** | Scroll history in copy-mode (unchanged) |
| **Right-click** | Copy-mode (scroll/select) — not the tmux popup menu |
| **Shift+drag** | Ignored by design in integrated terminals — use drag without Shift |

Clipboard pipe: `xclip` (XWayland) with `wl-copy` fallback — on pure Wayland install `wl-clipboard` (`apt install wl-clipboard`) if copy is empty.

Reload after config change: `tmux source-file $HOME/.tmux.conf`

## Mouse ( Config)

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
