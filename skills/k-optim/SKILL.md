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
  version: "1.9.0"
  scope: optimization
allowed-tools: Bash, Read, Write, Edit
---

# KπX - Optimization

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Last Known State limit:** each `### Last Known State` section holds **at most 7 items**.
> When the limit is reached, condense the oldest into a single `[SUMMARY]` item.

## Role

`k-optim` is the compact operational map for KπX optimization work, organized in three scopes:

- **Meta scope** — `.agents/` governance hygiene, QMD cleanliness, hook/skill alignment. Covers general configs shared across all agents.
- **Ubuntu scope** — local machine storage cleanup, project artifact removal, cache management, home media directories. Covers KπX's Ubuntu workstation and its projects.
- **Homelab scope** — server-side maintenance, Docker hygiene, client-side backup verification.

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
| Ubuntu cleanup scripts | `$HOME/Work/sh/clean/` |
| Homelab maintenance scripts | `$HOME/Work/Homelab/sh/` |

## Meta

> Scope: `.agents/` governance, QMD, hooks, shared agent configs.

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
4. Suggest AI history cleanup when relevant:
   - point to the runtime history roots exposed by `k-claude`, `k-gemini`, `k-codex`, `k-copilot`, `k-vibe`, or `k-ai`
   - propose the cleanup proactively when history size or noise is part of the optimization problem
   - wait for KπX approval before any prune, delete, archive, or reset action

## Ubuntu

> Scope: KπX Ubuntu workstation — local storage, project artifacts, caches, home media dirs.

### Last Known State

- the active cleanup suite lives in `$HOME/Work/sh/clean/`
- `clean_all.sh` orchestrates `clean_snap.sh`, `clean_cache.sh`, `clean_vscode.sh`, `clean_work.sh`, `clean_docker.sh`, `clean_ai.sh`; `auto_clean.sh` is the weekly automation wrapper
- the cleanup model distinguishes analysis, safe cleanup, deeper purge, and privileged/system cleanup — respect that progression
- **home cleanup 2026-04-03**: removed 22 debris entries (~1.3GB): `.conda`, `.gradle` (786MB), `.node-llama-cpp` (314MB), `.net` (120MB), `.continue`, `.ai-cli`, `.redhat`, `.overgrive.log`, `.minikube`, `.android`, `.aitk`, `.dbclient`, `.azure`, and others
- **home media cleanup 2026-04-04**: `Downloads/`, `Pictures/`, `Documents/` all emptied; `wine_mastery.md` migrated to `tutos_live/wine.md` (EN, reformatted)
- **pending review**: `.agent/` (old kernel git repo, predecessor to `.agents/`); `backup/` (root-owned, Jul 2025)
- `_dg_backup_check` zsh hook intercepts `rm -rf` — always verify deletions explicitly

### Actions

1. Start with analysis:
   - run `<script> --infos` before cleanup when the goal is diagnosis rather than blind deletion
2. Prefer safe cleanup first:
   - use `clean_all.sh -s` for a broad low-risk sweep
   - use module-specific `-s` modes when the pressure is localized
3. Use purge or system modes only intentionally:
   - `-p` removes heavier caches, dependency folders, or unused Docker assets
   - `-y` is privileged/system cleanup and should be treated as an explicit maintenance step
4. Re-read the relevant script before running it if the target scope matters

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

### Home Media Directories

> Policy: these dirs are **transit zones**, not storage. Keep them empty or near-empty at all times.
> Permanent files belong in `$HOME/Work/`, `Gdrive/`, or `Gdrive_X/`.

| Dir | Policy |
|-----|--------|
| `Downloads/` | Install artifacts (.deb, .tar.gz) → install immediately then delete. Backup CSVs → move to Gdrive. Keep empty after each session. |
| `Documents/` | No permanent storage here. Docs → `Gdrive_X/` (academic/pro) or `Gdrive/` (personal). Keep empty. |
| `Pictures/` | Screenshots → review and clear. Profile assets → `Gdrive/`. Napkin exports → only if referenced. Keep empty. |
| `Videos/` | Keep empty — recordings go to `Gdrive/` directly. |
| `Music/` | Keep empty. |
| `Desktop/` | Keep empty — no file dumping here. |

**Cleanup check:**
```bash
du -sh ~/Downloads ~/Documents ~/Pictures ~/Videos ~/Music ~/Desktop
ls ~/Downloads ~/Documents ~/Pictures ~/Videos ~/Music ~/Desktop
```

## Homelab

> Scope: Proxmox server, Docker-Host LXC, backups.

### Last Known State

- the operational homelab maintenance scripts live in `$HOME/Work/Homelab/sh/`
- `maintenance.sh` is the weekly server-side routine: apt update/upgrade/autoremove/autoclean, Docker prune inside container `100`, Telegram notifications, then reboot
- `backup_homelab.sh` is the client-side backup routine: SSH pull from `/var/lib/vz/dump`, local HDD mirror and rotation, then upload only the latest archive to `gdrive-x:Backup_Homelab`
- broader maintenance rationale and schedule documented in `$HOME/Work/Homelab/presentation/tutos_live/security/1-sauvegarde-maintenance-321.md` and `…/2-automatisation-watchtower.md`

### Actions

1. Re-read the real scripts before acting:
   - `maintenance.sh` for server cleanup/reboot behavior
   - `backup_homelab.sh` for backup destinations, retention, and notification flow
2. For documentation or architectural context:
   - use the `presentation` QMD collection or read the two security guides directly
3. Treat homelab optimization as two separate lanes:
   - server-side maintenance and Docker hygiene
   - client-side backup verification and storage rotation
4. If you change the maintenance rhythm or backup workflow:
   - update `k-homelab` and `k-optim`
   - recheck whether the presentation docs have drifted from the scripts

## Script & Action Log

> Log new scripts, key optimization actions, or notable results here for perennial reference.
> Newest first. Keep entries concise — one line per item. No limit enforced.

| Date | Scope | Script / Action | Notes |
|------|-------|-----------------|-------|
| 2026-04-04 | Meta/QMD | Shared `post-commit` hook symlink model + Vulkan check | repo-name-derived hook template now symlinked from `tutos_live` and `presentation`; `glslc` presence confirmed before retesting embeds |
| 2026-04-04 | Meta/QMD | Hot-only QMD cleanup + `qmd-optimization.md` | raw runtime histories removed from active index; guide added for inspection, SQLite checks, and cleanup flow |
| 2026-04-04 | Ubuntu/Media | Emptied Downloads/, Documents/, Pictures/ | wine_mastery.md migrated to tutos_live/wine.md |
| 2026-04-03 | Ubuntu | Manual home debris cleanup — 22 entries removed | ~1.3GB freed; see Ubuntu LKS for full list |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CODEX] | v1.8.0 — added the static-template provenance rule, noted the shared QMD hook symlink model, and recorded the Vulkan `glslc` check as part of the QMD optimization workflow |
| 2026-04-04 | [CLAUDE] | v1.6.0 — added Home Media Directories section (policy + cleanup check); updated Ubuntu LKS and Script Log with 2026-04-04 media cleanup |
| [SUMMARY] | — | v1.7.0–v1.0.0: QMD guide and cleanup state, Ubuntu cleanup state, max-7 LKS rule, Meta/Ubuntu/Homelab scopes, load-before-optim standard, initial map and path normalization |
