---
name: k-optim
description: >
  KπX optimization state and action map. Load before any cleanup/optim work
  to reuse existing standards and scripts, inspect last known states, and log
  key results for perennial reference. Covers .agents/ governance, QMD hygiene,
  Ubuntu local cleanup, and Homelab maintenance.
license: private
metadata:
  author: KpihX
  version: "1.4.0"
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
- **Ubuntu scope** — local machine storage cleanup, project artifact removal, cache management. Covers KπX's Ubuntu workstation and its projects.
- **Homelab scope** — server-side maintenance, Docker hygiene, client-side backup verification.

In all scopes: **load this skill before starting any cleanup/optim work** — reuse existing standards and scripts instead of reinventing. Log new scripts, key actions, and notable results in the relevant `### Last Known State` section so the state stays current.

## Source Of Truth

| Topic | Where to look |
|------|----------------|
| Agent governance and response contract | `$HOME/.agents/AGENTS.md` |
| Current hot session state and TODOs | `$HOME/.agents/skills/k-context/SKILL.md` |
| Shared hook and skill audits | `$HOME/.agents/hooks/audit.py` |
| QMD declarative config | `$HOME/.config/qmd/index.yml` |
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
- QMD collections are clean; `codex`, `gemini`, `copilot`, `vibe` tightened in `index.yml`; `tutos_live` and `presentation` clean; `openclaw` intentionally broad — watch for stale renamed skill copies
- agents should proactively suggest reviewing stale AI session-history stores when noisy/costly, but wait for KπX approval before any prune/delete
- `AGENTS.md` cleaned 2026-04-03 [CLAUDE]: skills table paths removed, duplicate rules removed (proactivity, TODOs reminder, QMD when-to-query verbosity), changelog limits deduped; k-optim description updated to load-before-optim standard

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
   - inspect `qmd collection list`
   - inspect `qmd ls <collection>` for suspected noisy collections
   - if patterns drift, edit `$HOME/.config/qmd/index.yml`, then run `qmd update <collection>`
   - run `qmd embed <collection>` only when content changed materially and embeddings are actually needed
4. Suggest AI history cleanup when relevant:
   - point to the runtime history roots exposed by `k-claude`, `k-gemini`, `k-codex`, `k-copilot`, `k-vibe`, `k-openclaw`, or `k-ai`
   - propose the cleanup proactively when history size or noise is part of the optimization problem
   - wait for KπX approval before any prune, delete, archive, or reset action

## Ubuntu

> Scope: KπX Ubuntu workstation — local storage, project artifacts, caches.

### Last Known State

- the active cleanup suite lives in `$HOME/Work/sh/clean/`
- `clean_all.sh` is the orchestrator for `clean_snap.sh`, `clean_cache.sh`, `clean_vscode.sh`, `clean_work.sh`, `clean_docker.sh`, and `clean_ai.sh`
- `auto_clean.sh` is the weekly automation wrapper: logs to `$HOME/Work/sh/clean/logs/`, runs `clean_all.sh -s -y`, measures reclaimed space, sends a Telegram report
- the cleanup model distinguishes analysis, safe cleanup, deeper purge, and privileged/system cleanup — respect that progression instead of jumping to aggressive removal

### Actions

1. Start with analysis:
   - run `<script> --infos` before cleanup when the goal is diagnosis rather than blind deletion
2. Prefer safe cleanup first:
   - use `clean_all.sh -s` for a broad low-risk sweep
   - use module-specific `-s` modes when the pressure is localized
3. Use purge or system modes only intentionally:
   - `-p` removes heavier caches, dependency folders, or unused Docker assets
   - `-y` is privileged/system cleanup and should be treated as an explicit maintenance step
4. Re-read the relevant script before running it if the target scope matters:
   - these scripts are the real behavior contract, not this summary

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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CLAUDE] | v1.4.0 — added max-7 Last Known State rule; clarified Meta/Ubuntu/Homelab scope descriptions; updated Meta LKS with 2026-04-03 AGENTS.md cleanup state; updated description for load-before-optim standard |
| 2026-04-03 | [CODEX] | v1.3.1 — added proactive AI session-history cleanup suggestion rule with KπX approval gate |
| [SUMMARY] | — | v1.3.1–v1.0.0: initial `.agents/`, QMD, Ubuntu, Homelab optimization map; path normalization; AGENTS↔hooks sync reminder; low-token doc compaction rule |
