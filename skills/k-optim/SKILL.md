---
name: k-optim
description: >
  KπX optimization state and action map. Generic framework covering
  four optimization scopes: local machine, homelab server, agent runtimes,
  and kernel governance. OS-specific cleanup actions live in references/
  (ubuntu.md, windows.md). Load before any cleanup/optim work.
license: private
metadata:
  author: KpihX
  version: "3.0.0"
  scope: optimization
allowed-tools: Bash, Read, Write, Edit
---

# KπX — Optimization Framework

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **OS references:** `references/ubuntu.md` (Ubuntu cleanup: apt, snap, GNOME, ext4 recovery, services, home media) · `references/windows.md` (Windows cleanup: temp files, app caches, disk cleanup)
> **Static rules:** `rules/audit-commands.md` (make audit, make check) · `rules/k-context-hygiene.md` (session log, issues log) · `rules/tool-discipline.md` (shared tmux gate)
> **Last Known State limit:** each `### Last Known State` section holds **at most 7 items**.
> **Issues ledger sync (mandatory):** every optimization-related diagnostic/fix attempt must be appended to `$HOME/.agents/skills/k-context/references/issues.md` with full commands and outputs (no compaction, no deletion).

---

## Role

> **AFTER PERFORMING AN OPTIMIZATION, THIS FILE MUST BE UPDATED WITH EVENTUAL FIXES OF COMMANDS AND THE LAST KNOWN STATE.**
> **AUTO-UPDATE MANDATE:** do not wait for KπX confirmation to write the operational trace; update `k-optim` and `k-context/references/issues.md` automatically at the end of each relevant optimization/incident action.

`k-optim` is the compact operational map for KπX optimization work, organized in four scopes (executed in order):

- **Local machine scope** — storage cleanup, project artifact removal, cache management. See `references/ubuntu.md` (Ubuntu) or `references/windows.md` (Windows).
- **Homelab scope** — server-side maintenance, Docker hygiene, client-side backup verification.
- **Agents scope** — AI runtime specific cache and historical data purging (gemini, claude, codex, copilot, vibe).
- **Meta scope** — `.agents/` governance hygiene, QMD cleanliness, hook/skill alignment. (Final cleanup step)

In all scopes: **load this skill before starting any cleanup/optim work** — reuse existing standards and scripts instead of reinventing. Log new scripts, key actions, and notable results in the relevant `### Last Known State` section and `## Script & Action Log` so the state stays current.

---

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
| Homelab Orchestrator (hsh) | `$HOME/Work/KpihX-Labs/Homelab/sh/` |
| Ubuntu cleanup scripts | `$HOME/Work/sh/clean/` |
| Deleted-file recovery | `references/ubuntu.md` → Deleted-file recovery section |
| Deleted-file recovery (full runbook) | `references/ubuntu-deleted-files-recovery.md` |
| Homelab maintenance scripts | `$HOME/Work/KpihX-Labs/Homelab/sh/` |

---

## Local Machine Scope

See OS-specific reference:
- **Ubuntu:** `references/ubuntu.md` — apt/snap cleanup, GNOME thumbnails, ext4/PhotoRec recovery, home media directories, service analysis, script map
- **Windows:** `references/windows.md` — Disk Cleanup, temp files, app caches, WSL-side cleanup

---

## Homelab Scope

> Scope: Proxmox server, Docker-Host LXC, backups.

### Last Known State

- The operational homelab scripts live in `$HOME/Work/KpihX-Labs/Homelab/sh/` (Phoenix v3.1 modular architecture) — `hsh` is **not** guaranteed on non-login PATH; prefer `"$HOME/Work/KpihX-Labs/Homelab/sh/hsh"`
- `hsh` is the local dispatcher: `hsh status` (audit), `hsh backup host` (PVE), `hsh backup vault` (DKD), `hsh maintenance` (Server)
- Backups follow the **3-2-1 rule**: 3 copies (SSD, HDD, Cloud), 2 supports, 1 off-site; Vault uses Deterministic Key Derivation (DKD)

### Actions

1. Start with local audit: run `"$HOME/Work/KpihX-Labs/Homelab/sh/hsh" status`
2. Prefer local-first orchestration: `hsh backup host` (hypervisor snapshot), `hsh backup vault` (encrypted Vaultwarden)
3. Server-Side Maintenance: `hsh maintenance` for the weekly loop on the homelab server
4. Manual Fallback: shared tmux — `ssh kpihx-labs` and run `/root/proxmox/maintenance.sh`

### Automated Tasks & Logs

| Task | Frequency | Script (Server Path) | Log Path |
| :--- | :--- | :--- | :--- |
| Vault Cloud Backup | Sun 02:00 | `/root/docker_host/backup_vault/backup_vault_server.sh` | `/var/log/vault-backup.log` |
| PVE Snapshot | Sat 03:00 | (Proxmox VZDump) | `/var/log/vzdump-*.log` |
| PVE Cloud Sync | After Backup | `/root/proxmox/backup_docker_host/vzdump-hook.sh` | `/var/log/vzdump-rclone.log` |
| System Maint | Sat 04:00 | `/root/proxmox/maintenance.sh` | `/var/log/maintenance.log` |
| Network Watchdog | Every 4 min | `/root/proxmox/network/network_watchdog.sh` | `/var/log/network_watchdog.log` |
| Boot Notifier | @reboot | `/root/proxmox/network/boot_notify.sh` | `/var/log/boot_notify_debug.log` |

---

## Agents Scope

> Scope: AI runtime specific cache and historical data purging. Covers gemini, claude, codex, copilot, vibe.

### Last Known State

- **2026-05-22**: Cursor archived purge (119) + Zed archived purge (20); Antigravity `brain/*` mass prune (0 sessions kept); Codex Apr 2026 sessions deleted; `.gemini/tmp` cleared; HF cache cleared via `clean_ai -p`.
- Agents store chat history in transparent local files (JSONL, SQLite, UUID folders).

### Actions

**Rule of thumb:** Inspect storage paths before any deletion. Identify the latest active conversation thread and safely isolate it. Only delete files that are 100% conclusively tied to old, stale discussions. If there is any doubt about a file's relevance, **do not delete it**.

1. **Antigravity (Agentic backend):** Inspect `$HOME/.gemini/antigravity/brain/`. Remove older UUID session folders only if you are certain they are dead history.
2. **Gemini CLI:** Run `gemini --list-sessions` to review history. Use `gemini --delete-session <index>` to remove all sessions except the most recent one.
3. **Claude Code:** Inspect `$HOME/.claude/` for `sessions/`, `history.jsonl`, `shell-snapshots/`, `debug/`, `paste-cache/`. Never blindly delete `projects/` subfolders (contain Claude's long-term memory).
4. **Codex CLI:** Inspect `$HOME/.codex/` for `sessions/`, `archived_sessions/`, `history.jsonl`, `log/`, `.sqlite` caches, `tmp/`.
5. **GitHub Copilot CLI:** Inspect `$HOME/.copilot/` for `logs/`, `session-state/`, `command-history-state.json`.
6. **Mistral Vibe:** Inspect `$HOME/.vibe/logs/` and `$HOME/.vibe/vibehistory`.
7. **Issue trace synchronization (required):** append every diagnosis/remediation attempt to `$HOME/.agents/skills/k-context/references/issues.md`.

---

## Meta Scope

> Scope: `.agents/` governance, QMD, hooks, shared agent configs (Final cleanup step).

### Last Known State

_(To be documented per optimization pass.)_

### Actions

1. Run `make audit` and fix any warnings
2. Check QMD health: `qmd status`, `qmd collection list`
3. Verify hook alignment: `python3 $HOME/.agents/hooks/audit.py`
4. Update `k-context/SKILL.md` session log if needed
5. Check for orphaned references in `skills/` and `references/`

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-optim/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-optim/references/insights.md` at the end of the task with durable lessons.
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v3.0.0 — Rewritten as generic optimization framework. Ubuntu cleanup content (apt, snap, GNOME, ext4, services, scripts) extracted to references/ubuntu.md. Homelab scope stays as cross-infra reference. |
| [SUMMARY] | — | v2.x: full Ubuntu runbook with ext4 recovery, service audit, script maps. Full details now in references/ubuntu.md. |
