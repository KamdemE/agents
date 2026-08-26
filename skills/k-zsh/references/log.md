# k-zsh Changelog Archive

Append-only archive for durable skill changelog history. One single `##` section — rows are stacked underneath it in chronological order, oldest first, exactly like a real log. Never create a new `##` sub-header per rotation; always append new rows to the bottom of the section below.

## Archived Changelog Rows

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-24 | [OPENCODE] | v2.1.0 — **kshrc pattern redesigned**: `~/.kshrc` is now a symlink to infra skill `assets/kshrc` (not a direct copy). If infra skill absent, create it (k-skill-creator), seed with kshrc.base, customize. Setup order: tmux first, then zsh. OS notes updated for all infra types. |
| 2026-07-26 | [OPENCODE] | v2.2.0 — **with-env helper added**: Added the `with-env` function to `kshrc.base` and `k-ubuntu/assets/kshrc` to allow secure command execution with isolated `.env` loading. |
| 2026-08-16 | [COLAB] | v2.3.0 — **Documented the idempotency-guard gotcha (`source ~/.kshrc` no-op on already-loaded shells)**: found while debugging why 2 tmux panes (`ubuntu:1.0`, `ubuntu:3.0`) never signaled command completion to the `tmux-notify` reflex even after KπX manually ran `source ~/.kshrc` in one of them — the `__KSHRC_INTERACTIVE_LOADED` guard (set before the `precmd` hook was added) silently blocked the whole interactive section from re-running. Added a new `## Known Gotcha` section with the fix (`unset __KSHRC_LOADED __KSHRC_INTERACTIVE_LOADED; source ~/.kshrc`, or restart the shell) + an inline comment at the exact guard line in `kshrc.base`. Cross-referenced in `k-tmux/references/insights.md` and root `AGENTS.md` (new `k-zsh` entry, previously absent from the kernel-wide skills list). |
| 2026-08-16 | [COLAB] | v2.4.1 — **`references/` overflow: gotchas + changelog rotation (300-line skill body limit)**: `make check` flagged SKILL.md at 306 lines (limit 300) and 4 explicit changelog rows before `[SUMMARY]`. Moved both full `## Known Gotcha` write-ups verbatim to `references/gotchas.md`; rotated v2.2.0 + v2.1.0 changelog rows verbatim here. Zero information loss. |
| 2026-08-16 | [COLAB] | v2.4.0 — **Fixed OpenCode web terminal tmux hijack**: added `[ -z "$OPENCODE_TERMINAL" ]` to the auto-tmux guard in `kshrc.base` and all infra copies, preventing OpenCode embedded PTYs from attaching to the shared desktop tmux session. |
| 2026-08-20 | [COLAB] | v2.4.2 — Updated the Android infrastructure cross-references for `k-phones` and the explicit S25 shell asset. |
