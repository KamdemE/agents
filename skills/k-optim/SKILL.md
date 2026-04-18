---
name: k-optim
description: >
  KπX optimization state and action map. Load before any cleanup/optim work
  to reuse existing standards and scripts, inspect last known states, and log
  key results for perennial reference. Covers .agents/ governance, QMD hygiene,
  Ubuntu local cleanup, home media dirs, and Homelab maintenance.
license: private
metadata:
   author: KpihX
   version: "2.9.2"
   scope: optimization
allowed-tools: Bash, Read, Write, Edit
---

# KπX - Optimization

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Last Known State limit:** each `### Last Known State` section holds **at most 7 items**.
> When the limit is reached, condense the oldest into a single `[SUMMARY]` item.

## Role

> **AFTER PERFORMING AN OPTIMIZATION, THIS FILE (k-optim) MUST BE UPDATED WITH EVENTUAL FIXES OF COMMANDS AND THE LAST KNOWN STATE.**

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
| Homelab maintenance scripts | `$HOME/Work/Homelab/sh/` |

## Ubuntu

> Scope: KπX Ubuntu workstation — local storage, project artifacts, caches, home media dirs.

### Last Known State

- the active cleanup suite lives in `$HOME/Work/sh/clean/`
- `clean_all.sh` orchestrates `clean_snap.sh`, `clean_cache.sh`, `clean_vscode.sh`, `clean_work.sh`, `clean_docker.sh`, `clean_ai.sh`; `auto_clean.sh` is the weekly automation wrapper
- the cleanup model distinguishes analysis, safe cleanup, deeper purge, and privileged/system cleanup — respect that progression
- **[SUMMARY]** Spring 2026 context: 1.3GB debris and redundant media emptied; legacy `.agent/` & `backup/` pending review; `_dg` safe-rm hook active
- **phoenix optim 2026-04-06**: Executed full automated loop (`ksh clean run` → `ksh backup run`). 27GiB compressed to 15GiB (zstd). Safe-cleanup rotated workspace caches and AI models automatically.
- **Auto-mount active**: KpihX-Backup is structurally guaranteed via `fstab` and `x-systemd.automount` on a permanent mount point. No manual click required. [GEMINI] 2026-04-07.

### Actions

1. Start with analysis:
   - run `ksh status` for a global health audit (Clean/Backup/Vault)
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

- the operational homelab scripts live in `$HOME/Work/Homelab/sh/` (Phoenix v3.1 modular architecture)
- `hsh` is the local dispatcher: `hsh status` (audit), `hsh backup host` (PVE), `hsh backup vault` (DKD), `hsh maintenance` (Server)
- `maintenance.sh` is the weekly server routine: apt update/upgrade/autoremove, Docker prune, Telegram notify, and REBOOT
- backups follow the **3-2-1 rule**: 3 copies (SSD, HDD, Cloud), 2 supports, 1 off-site; Vault uses Deterministic Key Derivation (DKD)

### Actions

1. Start with local audit:
   - run `hsh status` to check node connectivity and latest log entries
2. Prefer local-first orchestration:
   - use `hsh backup host` for hypervisor snapshot pull to local HDD mirror
   - use `hsh backup vault` for encrypted Vaultwarden backup (Master Password required)
3. Server-Side Maintenance:
   - run `hsh maintenance` to trigger the weekly loop on `kpihx-labs`
   - manual fallback: `sui -r "Run the Proxmox maintenance routine on kpihx-labs" @kpihx-labs /root/proxmox/maintenance.sh`
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

- Agents store chat history in transparent local files (JSONL, SQLite, UUID folders).
- **Phoenix v3.1 finalization (2026-04-06)**: Purged ~412MB of Codex history; Antigravity history preserved for current context.
- Claude Code leverages a `projects/` structure reflecting absolute paths with `-home-kpihx-...` identifiers.

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

## Meta

> Scope: `.agents/` governance, QMD, hooks, shared agent configs (Final cleanup step).

### Last Known State

- `.agents/` governance is stable: hooks, shared guards, `AGENTS.md`, and key `k-*` skills aligned and validated with `make -C $HOME/.agents audit`
- `AGENTS.md` must stay synchronized with the actual hook contract under `$HOME/.agents/hooks/`; wording/behavior divergence = governance drift
- operational Markdown must stay low-token and source-of-truth first; compact and point back when a skill starts duplicating detail owned elsewhere
- `make -C $HOME/.agents help` and `make -C $HOME/.agents audit` are the compact operational entrypoints
- QMD is now hot-only: raw `codex`, `gemini`, and `k-ai` histories were removed from the active index; use the dedicated optimization guide for checks and cleanup
- static reusable templates should live in `.agents`; external consumers should point back via symlink instead of drifting copies whenever the file is meant to be used as-is
- agents should proactively suggest reviewing stale AI session-history stores when noisy/costly, but wait for KπX approval before any prune/delete
- `AGENTS.md` cleaned 2026-04-03 [CLAUDE]: skills table paths removed, duplicate rules removed; k-optim updated to load-before-optim standard

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
   - inspect `qmd collection list`
   - inspect `qmd ls <collection>` for suspected noisy collections
   - if patterns drift, edit `$HOME/.config/qmd/index.yml`, then run `qmd update <collection>`
   - run `qmd cleanup` after structural changes
   - run `qmd embed <collection>` only when content changed materially and embeddings are actually needed
   - if embed performance regresses, verify the local Vulkan toolchain first (`which glslc`) before assuming index/config drift
5. **Telegram Reporting Mandatory**:
    - At the very end of any k-optim cycle (after Meta scope), a concise synthesis MUST be sent via Telegram.
    - **Homelab Bot (@sentinel_homelab_bot)**: Send the synthesis of Homelab status and backups.
    - **Ubuntu Bot (@k_ubuntu_bot)**: Send the synthesis of Ubuntu workstation cleanup and Meta/Governance state.
    - Usage: `tg user send <bot_id> "SENSY: (content)"`
4. Suggest AI history cleanup when relevant:
   - point to the runtime history roots exposed by `k-claude`, `k-gemini`, `k-codex`, `k-copilot`, `k-vibe`, or `k-ai`
   - propose the cleanup proactively when history size or noise is part of the optimization problem
   - wait for KπX approval before any prune, delete, archive, or reset action

## Script & Action Log

> Log new scripts, key optimization actions, or notable results here for perennial reference.
> Newest first. Keep entries concise — one line per item. No limit enforced.

| Date | Scope | Script / Action | Notes |
|------|-------|-----------------|-------|
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
| 2026-04-18 | [CODEX] | v2.9.2 — Replaced the raw remote-`sudo` maintenance fallback with the audited `sui -r` pattern and cleaned the duplicated changelog block. |
| 2026-04-13 | [CODEX] | v2.9.1 — Standardized insights discipline and autonomous maintenance hooks for this skill. |
| [SUMMARY] | — | v2.9.0 KpihX-Backup automount guarantee; v2.8.2 `$HOME` cleanup generalization; v2.8.1 screenshot policy; v2.8.0 Ubuntu frequency; older in git history |
