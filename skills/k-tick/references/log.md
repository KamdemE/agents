# k-tick — Changelog Archive

Frozen append-only archive for changelog rows rotated from `SKILL.md`.

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-12 | [COLAB] | v1.0.2 — Documented the `access_forbidden` V2 refresh recovery rule: canonical `X-Device` headers for every refresh request, reference-compatible MFA shape, and one HITL-gated email device-approval retry. See `ISS-20260812-001`; mocked coverage and project `make check` passed 27 tests, with no live authentication request. |
| 2026-08-09 | [AGENT] | v1.0.1 — Renamed `TICK_USERNAME` → `TICK_EMAIL` in env vars and docs per KπX directive, while keeping refresh logic flow as-is. |
