# Optimization Framework — Operation Log

> **Purpose:** Append-only record of significant system optimization operations and changelog archives.

| 2026-08-20 | [COLAB] | Full interface purge: inspected `k-25` assets/registries and all active references; renamed the skill to `k-phones`; moved S25 shell assets to `kshrc-s25` and `k_phones_sshd_autostart.sh`; rewrote wireless ADB documentation for raw `adb`; removed the two host wrapper symlinks, saved `s25-adb-port` state, stale Neovim swap, three obsolete source scripts, and their link-registry entries; a legacy finder runtime record remained pending later cleanup. Planned verification: `plocate` and targeted `rg`, JSON parse, shell syntax checks. |


---

## Archived changelog rows from `k-optim/SKILL.md` (2026-08-14 rotation)

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v3.0.0 — Rewritten as generic optimization framework. Ubuntu cleanup content (apt, snap, GNOME, ext4, services, scripts) extracted to references/ubuntu.md. Homelab scope stays as cross-infra reference. |
| [SUMMARY] | — | v2.x: full Ubuntu runbook with ext4 recovery, service audit, script maps. Full details now in references/ubuntu.md. |

## Changelog rotation from `k-optim/SKILL.md` (2026-08-15)

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-14 | [COLAB] | v3.7.0 — **Link infrastructure (links.sh / set_links.sh / check_links.sh)**: symlink audit/creation centralized in `scripts/links/` — `make link` (creates) + `make check-links` (verifies, joined into `make check`) both use `scripts/links/links.sh` as single source of truth (one entry per `.agents`-owned symlink, grouped by owning skill). `check-systemd.sh` renamed to `check_systemd.sh`. Red-emoji RED RULE added in `AGENTS.md`, `rules/skill-governance.md`, `k-context` (symlink to skill/agents always centralized via `.agents` + registered in links.sh). |
| 2026-08-14 | [COLAB] | v3.6.0 — **`~` root + `~/.cache` debris sweep added + GRAVE exhaustive-log obligation**: Debris Scan now includes row 0 `~/` root-level dotdirs (`.zoom`, `.windsurf`, `.cline`, …) + note "always check `~` root AND `~/.cache`"; Role section adds a GRAVE caps obligation to update `references/log.md` EXHAUSTIVELY after every full k-optim run. |
| 2026-08-14 | [COLAB] | v3.5.0 — **Read-First designation + mutual reference**: description now states `k-optim` is READ FIRST when KπX says "nettoyer / purge / clean / optimiser"; cross-referenced with `rules/skill-governance.md` → Full Debris Scan Methodology (mutual, update both). |
| 2026-08-14 | [COLAB] | v3.4.0 — **Debris Scan methodology**: documented where/how to dig for post-purge debris in `share`/`config`/`bin` (`~/.local/bin` broken symlinks, `~/.config` + `~/.local/share` dead-app dirs, `/opt`, `/etc/apparmor.d`, apt sources, skills) + the confirm-debris-vs-live-app check. Mirrors `rules/skill-governance.md` → Full Debris Scan Methodology. |
| 2026-08-14 | [COLAB] | v3.3.0 — **Temporary-storage emptying added** during optimization passes. |
| 2026-08-14 | [COLAB] | v3.2.0 — **Purge Discipline**: Documented absolute system-wide purge obligation (cleaning all configs/cache/services/snaps/opt). |
| 2026-08-14 | [COLAB] | v3.8.0 — **chmod guidance + `.agents/hooks` purge**: Meta Scope Actions step 8 — after any purge/optimization, always check + normalize script execute bits with `make chmod` (default 755; stricter via `scripts/chmod.sh <XYZ>`). `chmod.sh` cleaned: removed the obsolete `hooks/` scope (`.agents/hooks` no longer exists) and the `assets/install.sh|purge.sh` scope (matches no real assets — real ones live under `scripts/`). Added `make chmod` target. |

## Changelog Rotation — 2026-08-24 (check-skills cleanup)

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-20 | [COLAB] | v3.11.0 — Recorded the complete `k-phones` interface purge and the reusable wrapper/state/registry cleanup lesson. |
| 2026-08-15 | [COLAB] | v3.10.0 — **Broken-link sweep (Meta Scope Actions step 9)**: check ALL broken/dangling symlinks in `$HOME` (whole home: `find ~ -type l` — recursive, not just `~/.local/bin`, `~/.config`, `~/.local/share`) and systemd dirs (`/etc/systemd/system`, `~/.config/systemd/user`); re-create each from its `.agents` source of truth when localizable (`ln -sf`; tmux for `/etc`), else **signal/report** it (log to `k-context/references/issues.md`). Zero-tolerance: no broken `.agents`-related symlink after a pass. |
| 2026-08-14 | [COLAB] | v3.9.0 — **`clean-system`→`clean` + JSONC infra refs**: `references/ubuntu.md` updated to `/var/log/clean/workspace_scan.log` (service renamed to `clean` per the services-key restructure). Cross-refs: `assets/services.jsonc` (key `clean-service-ubuntu`, unit `clean.service`), `scripts/services/{check_services,reload_services}.sh` (use `unit` param; reload_services also reloads user+system daemons). |
