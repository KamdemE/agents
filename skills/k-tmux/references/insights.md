# k-tmux Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created with skill v1.0.0.
- KπX tmux config lives at `$HOME/.tmux.conf` (canonical). Skill asset `assets/tmux.conf` is a symlink — edit the real file, then `tmux source-file ~/.tmux.conf`.
- Without explicit wheel bindings, mouse scroll at the shell prompt can reach zsh as ↑/↓ and browse command history instead of scrolling the tmux buffer. The bundled config forces copy-mode scroll on wheel up.
- `copy-mode -e` auto-exits copy mode when scrolling back to the bottom — preferred over plain `copy-mode` for daily use.
- **`sui` deprecated (2026-05-18):** critical shell = shared tmux only; full gate in `k-tmux/SKILL.md` → Shared interactive gate.
- Poll **≥30s** after `send-keys` before chat handoff; give full attach + command + what KπX must type only after that. Earlier versions (pre-2026-05-29) caused a **chat handoff too early** — agent stopped mid-turn instead of looping until >=30s or command completion. Fix: loop every 3-5s, check for shell prompt (done) vs password prompt (keep polling). Only chat after >=30s without progress.
- **Cleanup is mandatory (2026-05-29):** every temp session/window created for a sudo/SSH gate MUST be killed after the command finishes and verification passes. `tmux kill-session -t NAME`. No mess, no dangling windows. If KπX detaches without finishing, the session stays available — but once the task is verified complete, the agent must auto-clean.
- **NEVER split panes for sudo (2026-05-29):** creating a pane split in the user's current window destroys their layout and can kill their active editor (micro, vim, etc). Always use `tmux new-window -t <SESSION> -n <name>` — a full new window. After the command finishes, kill the window and select-window back to the previous one.
- **15s password poll rule (2026-05-29, updated to 15s):** after sending a sudo command, poll every 3-5s for ≥15s before any chat handoff about the password. If KπX enters the password within that window, keep polling until the full command finishes. Only ask if ≥15s pass with no password input. After the command finishes (shell prompt visible), kill the window and return to previous window.
- Reuse short-named sessions/windows; create/kill only when necessary for clarity.
- `tmux-resurrect` owns save/restore contents; `tmux-continuum` schedules auto-save/auto-restore and can also provision a user-login `systemd` tmux service via `@continuum-boot on`.
- Resurrect shell-history restoration is removed upstream; arrow-key history remains a zsh concern, not a tmux persistence feature.
- **`𝛱/live` dev session (2026-05-24):** use tmux session `live` — window `ops` for `make check`/git; `brain` for `make dev-brain` (:8000); `web` for `make dev-web` (:5173). Map: `$HOME/KpihX-Labs/𝛱/live/docs/DEV_WORKFLOW.md`.
- **Mouse copy (2026-05-25, v1.4.4):** with `mouse on`, OS/terminal selection does not work on drag; **Shift+drag does nothing** in Cursor/Zed integrated terminals (tmux keeps the mouse). KπX fix: `mode-keys vi` + `MouseDrag1Pane` → `copy-mode -M` + release → `copy-pipe` (`xclip` / `wl-copy`). **Wheel up** still scrolls buffer. Right-click → copy-mode (no popup menu). Wayland: install `wl-clipboard` if clipboard empty. Keyboard fallback: `Ctrl-a [` → `v`/`y` or `Ctrl-a ]` paste tmux buffer.
- **Persistence reboot (2026-05-25):** saves under `$HOME/.tmux/resurrect/` are working (autosave + manual). Auto-restore runs **only once per new tmux server** (`@continuum-restore on`). `@continuum-boot` + `tmux.service` starts server at login with `new-session -d`; **ExecStop save.sh often fails** (`no server running`) because server is already gone before stop — do not rely on shutdown save. If login boot starts server before restore window, or user starts a second server, restore is skipped. Last-good workflow before reboot: `Ctrl-a Ctrl-s`, check `ls -l ~/.tmux/resurrect/last`. After reboot if empty: `Ctrl-a Ctrl-r`.
- **Reboot forensics (2026-05-25):** `journalctl --user -u tmux.service` showed **ExecStop save.sh → `no server running`** and login server dying in ~2s. **Fix applied:** `@continuum-boot off` in `$HOME/.tmux.conf`, `systemctl --user disable --now tmux.service`. Post-login: run `tmux` once from a real terminal → `@continuum-restore` runs. Runbook: `k-tmux/SKILL.md` → **First tmux after reboot (post-login)**. Good historical save example: `tmux_resurrect_20260524T185451.txt` (`live` + `default`).
- **CRITICAL — Always identify pane before send-keys (2026-06-05):** sent `:qa!` to wrong pane (opencode default session) instead of actual nvim pane. Must run `tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}'` first to confirm exact target. Rule added to SKILL.md under "Send Keys & Capture Output".
- **Sudo gate with `sudo systemctl` + `apt purge` via `ubuntu:0.2` (2026-07-21):**
  - Pane `ubuntu:0.2` (zsh) is the designated sudo/ops pane — works well.
  - `sudo apt purge` can stall if the apt solver hangs on unresolvable dependencies. Always pre-check reverse-depends before `apt purge -y "libvirt-*"`: `apt-cache rdepends --installed <pkg> | grep -v libvirt`.
  - For complex purges, send the full command as one `send-keys` (no split between disable + purge) to avoid KπX seeing an intermediate prompt.
  - `tmux capture-pane -t SESSION:WIN.PANE -p -S -` to capture full scrollback when output is long (polling with `tail -10` is sufficient for progress).
