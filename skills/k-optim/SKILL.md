---
name: k-optim
description: >
  KπX optimization state and action map. Load before any cleanup/optim work
  or Ubuntu deleted-file recovery (Trash empty, ext4 carve). Reuse existing
  standards and scripts, inspect last known states, and log key results.
  Covers .agents/ governance, QMD hygiene, Ubuntu local cleanup/recovery,
  home media dirs, and Homelab maintenance.
license: private
metadata:
  author: KpihX
  version: "2.12.0"
  scope: optimization
allowed-tools: Bash, Read, Write, Edit
---

# KπX - Optimization

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Last Known State limit:** each `### Last Known State` section holds **at most 7 items**.
> When the limit is reached, condense the oldest into a single `[SUMMARY]` item.
> **Issues ledger sync (mandatory):** every optimization-related diagnostic/fix attempt must be appended to `$HOME/.agents/skills/k-context/references/issues.md` with full commands and outputs (no compaction, no deletion), and k-context Session Log should only keep the concise cross-referenced summary.

## Role

> **AFTER PERFORMING AN OPTIMIZATION, THIS FILE (k-optim) MUST BE UPDATED WITH EVENTUAL FIXES OF COMMANDS AND THE LAST KNOWN STATE.**
> **AUTO-UPDATE MANDATE:** do not wait for KπX confirmation to write the operational trace; update `k-optim` and `k-context/references/issues.md` automatically at the end of each relevant optimization/incident action.

`k-optim` is the compact operational map for KπX optimization work, organized in four scopes (executed in order):

- **Ubuntu scope** — local machine storage cleanup, project artifact removal, cache management, home media directories.
- **Homelab scope** — server-side maintenance, Docker hygiene, client-side backup verification.
- **Agents scope** — AI runtime specific cache and historical data purging (gemini, claude, codex, copilot, vibe).
- **Meta scope** — `.agents/` governance hygiene, QMD cleanliness, hook/skill alignment. (Final cleanup step)

In all scopes: **load this skill before starting any cleanup/optim work** — reuse existing standards and scripts instead of reinventing. Log new scripts, key actions, and notable results in the relevant `### Last Known State` section and `## Script & Action Log` so the state stays current.

## Source Of Truth

| Topic | Where to look |
|------|----------------|
| Agent governance and response contract | `$HOME/.agents/AGENTS.md` |
| Current hot session state and TODOs | `$HOME/.agents/skills/k-context/SKILL.md` |
| Shared hook and skill audits | `$HOME/.agents/hooks/audit.py` |
| QMD declarative config | `$HOME/.config/qmd/index.yml` |
| QMD optimization guide | `$HOME/.agents/skills/k-qmd/references/qmd-optimization.md` |
| QMD live runtime state | `qmd status`, `qmd collection list`, `qmd ls <collection>` |
| Workstation Orchestrator (ksh) | `$HOME/Work/sh/` |
| Homelab Orchestrator (hsh) | `$HOME/Work/Homelab/sh/` |
| Ubuntu cleanup scripts | `$HOME/Work/sh/clean/` |
| **Deleted-file recovery (ext4, GNOME)** | `$HOME/.agents/skills/k-optim/references/ubuntu-deleted-files-recovery.md` |
| TechSkills mirror (Docsify) | `$HOME/Work/techskills/ubuntu-deleted-files-recovery.md` |
| Homelab maintenance scripts | `$HOME/Work/KpihX-Labs/Homelab/sh/` |

## Ubuntu

> Scope: KπX Ubuntu workstation — local storage, project artifacts, caches, home media dirs.

### Last Known State

- **2026-05-26 deleted-image recovery (`ISS` session)**: Tier A (no sudo) → **103** GNOME thumbnail previews from `recently-used.xbel` → `~/Recovery_candidates_2026-05-26/from_thumbnails/` (13/13 RAS `VeniceAI_*.png`, ~90 Telegram `photo_*.jpg`). Tier B PhotoRec via tmux `default:0.0` → **~1534** carved images in `~/Recovery_PhotoRec_2026-05-26/photorec.{1,2,3}`; extundelete failed (mounted `/`). Canonical runbook: `references/ubuntu-deleted-files-recovery.md`.
- **2026-05-22 (post-kernel)**: `timeshift` **purged** (no snapshots on `nvme0n1p4` nor `sda1`; package removed; `/etc/timeshift` cleaned). `ISS-20260516-001` **RESOLVED** (16G backup SUCCESS). `Optim_2A_P3` `uv sync` **OK** after `libpangocairo` + `libpango1.0-dev` + `libcairo2-dev`. Homelab `sh/` pushed `189d3e2` → `gitlab:kpihx-labs/scripts`.
- **2026-05-22 full pass (`ISS-20260522-001`)**: `$HOME` ~165G→~147G; `/` **72%** (**74G** free). Transit emptied; debris/Cursor/Zed/ai_dispatcher tmp; `clean_all.sh -s -p -y` + UV cache (~15G). Work `.venv` purged then re-synced.
- **[SUMMARY]** Spring 2026: phoenix loop, automount KpihX-Backup, `_dg` safe-rm; older debris cycles in Script Log
- cleanup stack: `$HOME/Work/sh/clean/` — `clean_editors.sh` wraps Code/Cursor/AGY; non-interactive: pipe `y` + `-y` on `clean_all.sh`

### Actions

1. Start with analysis:
   - run `ksh status` for a global health audit (Clean/Backup/Vault/**QMD**)
   - run `systemctl list-timers` to see next/last runs and their concrete frequency
   - run `make -C $HOME/Work/sh/clean log-scan` for the last workspace scan report
   - run `ksh backup status` to check the current safety window
2. Prefer safe cleanup first:
   - use `auto_clean.sh` via `ksh clean run` for a broad low-risk sweep without manual prompts
   - use module-specific `-s` modes when the pressure is localized
3. Use purge or system modes only intentionally:
   - `-p` removes heavier caches, dependency folders, or unused Docker assets
   - `-y` is privileged/system cleanup and should be treated as an explicit maintenance step
4. Finalize and Secure:
   - **run `ksh backup run`** only after cleanup is done to archive the stabilized, clean state of the workstation.
5. Re-read the relevant script before running it if the target scope matters.

### Deleted-file recovery (images, ext4)

> Load **`references/ubuntu-deleted-files-recovery.md`** before any undelete work.

1. **Tier A (no sudo):** `recently-used.xbel` + `~/.cache/thumbnails/` — fast previews with original names.
2. **Tier B (sudo):** PhotoRec `freespace` — full resolution; run only in **shared tmux** (`default:0.0`), **no split panes**.
3. **Tier C:** extundelete — only if partition unmounted (live USB); fails on mounted `/`.
4. Stop writing to disk; cross-match carved `f*` files against xbel name list after scan.

### Script Map

| Script | Primary use |
|-------|-------------|
| `$HOME/Work/sh/clean/clean_all.sh` | orchestrate the full Ubuntu cleanup suite |
| `$HOME/Work/sh/clean/auto_clean.sh` | weekly automated cleanup with logging and Telegram report |
| `$HOME/Work/sh/clean/clean_snap.sh` | Snap revisions, caches, snapshots, and app-specific Snap cleanup |
| `$HOME/Work/sh/clean/clean_cache.sh` | trash, package-manager caches, browser cache, and privileged system cache cleanup |
| `$HOME/Work/sh/clean/clean_vscode.sh` | VSCode cache and extension-state cleanup under `$HOME/.config/Code/` |
| `$HOME/Work/sh/clean/clean_work.sh` | `$HOME/Work` analysis, git GC, temp artifacts, and optional env/dependency purge |
| `$HOME/Work/sh/clean/clean_docker.sh` | Docker space analysis and unused image/container/volume cleanup |
| `$HOME/Work/sh/clean/clean_ai.sh` | Ollama and HuggingFace storage cleanup |

### Automated Tasks & Logs

| Task | Frequency | Script Path | Log Path |
| :--- | :--- | :--- | :--- |
| System Cleanup | Every 2 days (starting Sun) + Persistent | `$HOME/Work/sh/clean/auto_clean.sh` | `/var/log/clean-system/workspace_scan.log` |
| Workstation Backup | Every 2 days (starting Sun) + Persistent | `$HOME/Work/sh/backup_restore/backup_workstation.sh` | (Journal systemd) |

### Home Media Directories

> Policy: these dirs are **transit zones**, not storage. Keep them empty or near-empty at all times.
> Permanent files belong in `$HOME/Work/`, `Gdrive/`, or `Gdrive_X/`.

| Dir | Policy |
|-----|--------|
| `Downloads/` | Install artifacts (.deb, .tar.gz) → install immediately then delete. Backup CSVs → move to Gdrive. Keep empty after each session. |
| `Documents/` | No permanent storage here. Docs → `Gdrive_X/` (academic/pro) or `Gdrive/` (personal). Keep empty. |
| `Pictures/` | **Screenshots are transit**: during every optim cycle, review → move the keepers to `Gdrive/` or the relevant `$HOME/Work/` project → **empty `Pictures/`**. Profile assets → `Gdrive/`. Napkin exports → only if referenced. |
| `Videos/` | Keep empty — recordings go to `Gdrive/` directly. |
| `Music/` | Keep empty. |
| `Desktop/` | Keep empty — no file dumping here. |

**Cleanup check:**
```bash
du -sh "$HOME/Downloads" "$HOME/Documents" "$HOME/Pictures" "$HOME/Videos" "$HOME/Music" "$HOME/Desktop"
ls "$HOME/Downloads" "$HOME/Documents" "$HOME/Pictures" "$HOME/Videos" "$HOME/Music" "$HOME/Desktop"
```

## Homelab

> Scope: Proxmox server, Docker-Host LXC, backups.

### Last Known State

- the operational homelab scripts live in `$HOME/Work/KpihX-Labs/Homelab/sh/` (Phoenix v3.1 modular architecture) — `hsh` is **not** guaranteed on non-login PATH; prefer `"$HOME/Work/KpihX-Labs/Homelab/sh/hsh"`
- `hsh` is the local dispatcher: `hsh status` (audit), `hsh backup host` (PVE), `hsh backup vault` (DKD), `hsh maintenance` (Server)
- **2026-05-16 workstation audit**: `hsh status` from Ubuntu reported PVE (`kpihx-labs`) and Docker-host LXC **offline** (expected when mesh/VPN/server unreachable)
- `maintenance.sh` is the weekly server routine: apt update/upgrade/autoremove, Docker prune, Telegram notify, and REBOOT
- backups follow the **3-2-1 rule**: 3 copies (SSD, HDD, Cloud), 2 supports, 1 off-site; Vault uses Deterministic Key Derivation (DKD)

### Actions

1. Start with local audit:
   - run `"$HOME/Work/KpihX-Labs/Homelab/sh/hsh" status` (or ensure `hsh` is on PATH) to check node connectivity and latest log entries
2. Prefer local-first orchestration:
   - use `hsh backup host` for hypervisor snapshot pull to local HDD mirror
   - use `hsh backup vault` for encrypted Vaultwarden backup (Master Password required)
3. Server-Side Maintenance:
   - run `hsh maintenance` to trigger the weekly loop on `kpihx-labs`
   - manual fallback: shared tmux on homelab — `tmux new -As pve-maint` then `ssh kpihx-labs` and run `/root/proxmox/maintenance.sh` with KπX `sudo` approval in pane (`k-tmux`; **`sui` deprecated**)
4. Manual Fallback (Backups):
   - if `hsh` fails, run `backup_docker_host_server.sh` directly on `kpihx-labs` for cloud exfiltration

### Automated Tasks & Logs

| Task | Frequency | Script (Server Path) | Log Path |
| :--- | :--- | :--- | :--- |
| Vault Cloud Backup | Sun 02:00 | `/root/docker_host/backup_vault/backup_vault_server.sh` | `/var/log/vault-backup.log` |
| PVE Snapshot | Sat 03:00 | (Proxmox VZDump) | `/var/log/vzdump-*.log` |
| PVE Cloud Sync | After Backup | `/root/proxmox/backup_docker_host/vzdump-hook.sh` | `/var/log/vzdump-rclone.log` |
| System Maint | Sat 04:00 | `/root/proxmox/maintenance.sh` | `/var/log/maintenance.log` |
| Network Watchdog | Every 4 min | `/root/proxmox/network/network_watchdog.sh` | `/var/log/network_watchdog.log` |
| Boot Notifier | @reboot | `/root/proxmox/network/boot_notify.sh` | `/var/log/boot_notify_debug.log` |

## Agents

> Scope: AI runtime specific cache and historical data purging. Covers gemini, claude, codex, copilot, vibe.

### Last Known State

- **2026-05-22**: Cursor archived purge (119) + Zed archived purge (20) earlier same session; then Antigravity `brain/*` mass prune (kept 0 sessions — user asked full fresh), Codex Apr 2026 sessions deleted, `.gemini/tmp` cleared, HF cache cleared via `clean_ai -p`.
- Agents store chat history in transparent local files (JSONL, SQLite, UUID folders).
- **[SUMMARY]** Phoenix 2026-04-06 Codex ~412MB purge; Claude `projects/` path-keyed memory — do not delete blindly

### Actions

**Rule of thumb:** Inspect storage paths before any deletion. Identify the latest active conversation thread and safely isolate it. Only delete files that are 100% conclusively tied to old, stale discussions. If there is any doubt about a file's relevance, **do not delete it**. Do not use blind or brute-force `rm` commands.

1. **Antigravity (Agentic backend)**:
   - Inspect `$HOME/.gemini/antigravity/brain/`
   - Identify the most recent UUID session folders. Remove older UUID folders only if you are certain they are dead history.
2. **Gemini CLI**:
   - Avoid manual file deletion; rely on the CLI tool.
   - Run `gemini --list-sessions` to review history.
   - Use `gemini --delete-session <index>` thoughtfully to remove all sessions except the most recent one.
3. **Claude Code**:
   - Inspect `$HOME/.claude/` for `sessions/`, `history.jsonl`, `shell-snapshots/`, `debug/`, `paste-cache/`.
   - Before clearing `history.jsonl` or sessions, ensure no active context relies on them.
   - *Caution:* Never blindly delete `projects/` subfolders; they contain Claude's long-term memory (`memory/*.md`).
4. **Codex CLI**:
   - Inspect `$HOME/.codex/` for `sessions/`, `archived_sessions/`, `history.jsonl`, `log/`, `.sqlite` caches, and `tmp/`.
   - Remove stale SQLite artifacts and jsonl logs only when they accumulate heavily and are not tied to the active run.
5. **GitHub Copilot CLI**:
   - Inspect `$HOME/.copilot/` for `logs/`, `session-state/`, and `command-history-state.json`.
   - Clear only the definitively old logs and orphaned states.
6. **Mistral Vibe**:
   - Inspect `$HOME/.vibe/logs/` and `$HOME/.vibe/vibehistory`.
   - Clear log debris only when confirmed stale.
7. **Issue trace synchronization (required):**
   - append every diagnosis/remediation attempt to `$HOME/.agents/skills/k-context/references/issues.md`
   - keep exact commands and outputs in that issue entry (append-only)
   - add only a short, issue-ID-linked summary in `k-context` Session Log

## Meta

> Scope: `.agents/` governance, QMD, hooks, shared agent configs (Final cleanup step).

### Last Known State

- **2026-05-25 (Edge finalize)**: `k-browser` v1.3.0 Leave no trace; Edge agent **STABLE** (tabs cleaned, favorites `fake`/`agent-sandbox-bookmarks` removed by KπX); `make audit` after changelog/session-log cap fixes; QMD `check_collections.sh` → 1× `MISSING_PATH` `claude-memory` (path absent — known drift).
- **2026-05-25**: `.agents/` governance pass — social skills unified; `make audit` **ALL_OK**; JSON creds outside git (`$HOME/.config/kpihx/`).
- **2026-05-24**: QMD drift gate live — `check_collections.sh` in `k-qmd/scripts/`; wired to `auto_clean.sh` (Telegram block) + `ksh status`. Catches `MISSING_PATH` and `EMPTY_INDEX` (e.g. presentation `KpihX_Labs` typo → 0 files).
- **2026-05-22**: `make -C $HOME/.agents audit` => **ALL_OK** after changelog/session-log cap fixes. QMD presentation re-indexed after path fix.
- **2026-05-16**: `make -C $HOME/.agents audit` => `ALL_OK` after k-optim read cycle [CURSOR]
- governance stack is stable: hooks, shared guards, `AGENTS.md`, and key `k-*` skills stay aligned with `make -C $HOME/.agents audit` / `make -C $HOME/.agents help` as the operational entrypoints
- `AGENTS.md` must stay synchronized with the actual hook contract under `$HOME/.agents/hooks/`; wording/behavior divergence = governance drift
- operational Markdown must stay low-token and source-of-truth first; compact and point back when a skill starts duplicating detail owned elsewhere
- QMD is now hot-only: raw `codex`, `gemini`, and `k-ai` histories were removed from the active index; use the dedicated optimization guide for checks and cleanup
- static reusable templates should live in `.agents`; external consumers should point back via symlink instead of drifting copies whenever the file is meant to be used as-is
- agents should proactively suggest reviewing stale AI session-history stores when noisy/costly, but wait for KπX approval before any prune/delete; **[SUMMARY]** `AGENTS.md` hygiene pass 2026-04-03 [CLAUDE]: skills table paths removed, duplicate rules removed; k-optim updated to load-before-optim standard

### Actions

1. Recheck `.agents/` integrity:
   - `make -C $HOME/.agents audit`
   - `git -C $HOME/.agents status --short`
   - `git -C $HOME/.agents log --oneline -5`
   - re-read `$HOME/.agents/AGENTS.md` against the active hook behavior whenever response rules, path rules, or session-finalization behavior changed
2. If hooks or skills changed:
   - update the touched `SKILL.md`
   - check that `$HOME/.agents/AGENTS.md` still matches the real reminder text and enforced hook behavior
   - propagate any rename/add/remove to `$HOME/.agents/AGENTS.md`, `$HOME/.agents/.skill-lock.json`, and `$HOME/.agents/skills/k-context/SKILL.md`
   - commit and `make -C $HOME/.agents push`
3. Recheck QMD cleanliness:
   - start with `$HOME/.agents/skills/k-qmd/references/qmd-optimization.md`
   - run `$HOME/.agents/skills/k-qmd/scripts/check_collections.sh` (also runs in `auto_clean.sh` + `ksh status`)
   - inspect `qmd collection list`
   - inspect `qmd ls <collection>` for suspected noisy collections
   - if patterns drift, edit `$HOME/.config/qmd/index.yml`, then run `qmd update <collection>`
   - run `qmd cleanup` after structural changes
   - run `qmd embed <collection>` only when content changed materially and embeddings are actually needed
   - if embed performance regresses, verify the local Vulkan toolchain first (`which glslc`) before assuming index/config drift
4. **Telegram Reporting Mandatory**:
    - At the very end of any k-optim cycle (after Meta scope), a concise synthesis MUST be sent via Telegram.
    - **Homelab Bot (@sentinel_homelab_bot)**: Send the synthesis of Homelab status and backups.
    - **Ubuntu Bot (@k_ubuntu_bot)**: Send the synthesis of Ubuntu workstation cleanup and Meta/Governance state.
    - Preferred CLI (when `TELEGRAM_*_TOKEN` vars are loaded): `tg send --bot homelab "SENSY: (content)"` and `tg send --bot ubuntu "SENSY: (content)"` (`tg bots` must list aliases — if missing, load shell secrets / see `k-tg`).
5. Suggest AI history cleanup when relevant:
   - point to the runtime history roots exposed by `k-claude`, `k-gemini`, `k-codex`, `k-copilot`, `k-vibe`, or `k-ai`
   - propose the cleanup proactively when history size or noise is part of the optimization problem
   - wait for KπX approval before any prune, delete, archive, or reset action

## Script & Action Log

> Log new scripts, key optimization actions, or notable results here for perennial reference.
> Newest first. Keep entries concise — one line per item. No limit enforced.

| Date | Scope | Script / Action | Notes |
|------|-------|-----------------|-------|
| 2026-05-27 | Meta/Governance | `.agents` governance audit (make audit) | Missing Provenance & Quality reference: `references/sexemodel-insights.md` not in SKILL.md |
| 2026-05-26 | Ubuntu | Deleted-image recovery runbook | `references/ubuntu-deleted-files-recovery.md` + techskills mirror; Tier A thumbnails + Tier B PhotoRec |
| 2026-05-25 | Meta | `.agents` social+email skill audit fix | ALL_OK; no secrets in commit; JSON smoke Meta core + X me |
| 2026-05-24 | Meta/QMD | `check_collections.sh` + auto_clean/ksh wiring | Path-drift gate: MISSING_PATH + EMPTY_INDEX; Telegram alert on weekly cleanup |
| 2026-05-22 | Ubuntu/Agents/Meta | Full k-optim (`ISS-20260522-001`) | ~18G `$HOME` reclaim; transit empty; `clean_all -s -p -y`; venvs purged; governance ALL_OK; homelab offline |
| 2026-05-16 | Meta/Ubuntu/Homelab | k-optim audit (read-only) | `make -C $HOME/.agents audit` ALL_OK; `ksh status` shows clean OK / backup FAILED (`ISS-20260516-001`); `hsh` path corrected in skill SOT; PVE+LXC offline from workstation; home transit dirs still over policy on Downloads/Documents/Pictures |
| 2026-04-06 | Agents | AI History Purge | Pruned ~412MB of Codex and Vibe history |
| 2026-04-06 | Homelab | Phoenix v3.1 | Modular architecture stabilized; `hsh` dispatcher introduced; server log map finalized |
| 2026-04-06 | Homelab | Maintenance | Executed `hsh maintenance` on kpihx-labs (PVE upgrade, docker prune, reboot) |
| 2026-04-06 | Meta | QMD Hygiene | `qmd cleanup` run successfully (DB vacuumed); AI histories flagged for manual prune when needed |
| 2026-04-06 | Ubuntu | Full Phoenix Loop | Executed `ksh clean run` and `ksh backup run`; 27GiB compressed to 15GiB archive; old backup rotated |
| 2026-04-06 | Meta/Ubuntu | Unified Phoenix Orchestration | Integrated ksh status audits, clean -s routines, and backup checks into the core workflow; moved backup SOT to Ubuntu |
| 2026-04-04 | Meta/QMD | Shared `post-commit` hook symlink model + Vulkan check | repo-name-derived hook template now symlinked from `techskills` and `presentation`; `glslc` presence confirmed before retesting embeds |
| 2026-04-04 | Meta/QMD | Hot-only QMD cleanup + `qmd-optimization.md` | raw runtime histories removed from active index; guide added for inspection, SQLite checks, and cleanup flow |
| 2026-04-04 | Ubuntu/Media | Emptied Downloads/, Documents/, Pictures/ | wine_mastery.md migrated to techskills/wine.md |
| 2026-04-03 | Ubuntu | Manual home debris cleanup — 22 entries removed | ~1.3GB freed; see Ubuntu LKS for full list |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-optim/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-optim/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-26 | [CURSOR] | v2.11.0 — Ubuntu: `ubuntu-deleted-files-recovery.md` runbook (Tier A thumbnails + Tier B PhotoRec + extundelete limits); techskills mirror; LKS recovery session. |
|| 2026-05-27 | [CURSOR] | v2.12.0 — Meta: Governance audit detects bundled `references/sexemodel-insights.md` missing from SKILL.md Provenance & Quality section.
| 2026-05-25 | [CURSOR] | v2.10.1 — Meta: Edge agent STABLE finalize; audit cap fixes; QMD check (claude-memory path drift). |
| [SUMMARY] | — | v2.10.0 social skills audit; v2.9.9 QMD health gate; v2.9.8 Timeshift; v2.9.6 full k-optim (`ISS-20260522-001`); older in git |
