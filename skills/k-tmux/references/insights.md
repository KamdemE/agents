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
- Poll **≥30s** after `send-keys` before chat handoff; give full attach + command + what KπX must type only after that.
- Reuse short-named sessions/windows; create/kill only when necessary for clarity.
