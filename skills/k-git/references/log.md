# k-git — Changelog Archive

Older changelog entries condensed out of `SKILL.md` (max 2 explicit rows before `[SUMMARY]`). **Zero-information-loss: copied, never deleted.**

> Note: this file did not exist before 2026-08-25 even though the `SKILL.md` `[SUMMARY]` row referenced it for v2.7.0/v2.6.4 — those two entries' full text was never captured here and predates this archive; recover via `git log -- skills/k-git/SKILL.md` if the full text is ever needed.

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-24 | [COLAB] | v2.9.0 — **Hook plumbing ownership (Prop A)**: NEW `assets/git-hook-passthrough.sh` moved from k-loom — one generic asset + 9 symlinks (`pre-commit`, `commit-msg`, `prepare-commit-msg`, `pre-push`, `pre-rebase`, `post-checkout`, `post-merge`, `post-rewrite`, `pre-applypatch`) in `$HOME/.config/git/hooks/` re-chaining repo-local hooks under `core.hooksPath`. NEW section documenting ownership rule: **k-git owns ALL git hook plumbing; the ONLY behavior-adding hook is the post-commit Loom dispatcher owned by `k-loom`.** Redundant dedicated `k-loom/assets/git-pre-commit.sh` deleted per explicit KπX order. links.jsonc: 9 entries under k-git block. E2E verified: real commit chains local commit-msg + post-commit (`CM_RAN`,`CM_RAN`,`PC_RAN`). |
