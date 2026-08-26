# k-skill-creator — changelog archive (append-only, GRAVÉ)

## Changelog rotation from `k-skill-creator/SKILL.md` (2026-08-25)

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-16 | [COLAB] | v2.5.0 — **`tests/` dir added to Structural Contract**: skills may ship a `tests/` folder (e.g. `tests/hooks/<hook>.test.mjs`) mirroring the structure of the `scripts/`/`assets/` they validate — durable source of truth for non-regression proof. Reference example: `k-opencode/tests/hooks/make-check-guard.test.mjs`. Tests are NOT deployed/symlinked (unlike `scripts/`). |
