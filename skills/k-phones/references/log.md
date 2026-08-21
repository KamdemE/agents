# Phones — Historical Log

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-20 | [COLAB] | Transition record: `k-25` was renamed to `k-phones`; the old ADB wrappers, saved-port state, and PVE discovery interface were purged. Raw ADB became the supported interface. Historical details remain in prior kernel session/changelog logs. |
| 2026-08-20 | [COLAB] | v3.0.0 — Renamed the skill to `k-phones`; generalized Android coverage while retaining the S25 subsection. Removed legacy ADB helper and PVE discovery interfaces, replaced the volatile-port workflow with raw ADB documentation, and initially named the S25 shell asset `kshrc-s25`. Superseded immediately by v3.0.1, which normalized it to `assets/kshrc` and moved the SSHD autostart code to `scripts/`. |
| 2026-07-24 | [OPENCODE] | v2.0.0 — **Historical:** simplified Termux deployment and introduced the former S25 shell assets. |
