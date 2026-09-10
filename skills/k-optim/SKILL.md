---
name: k-optim
description: >
  optimization state and action map — READ THIS FIRST when  talks
  about "nettoyer / purge / clean / optimiser / cleanup". Generic framework
  covering four optimization scopes: local machine, homelab server, agent
  runtimes, and kernel governance. OS-specific cleanup actions live in
  references/ (ubuntu.md, windows.md). Load before any cleanup/optim work.
license: private
metadata:
  author: 
  version: "1.0.0"
  scope: optimization
allowed-tools: Bash, Read, Write, Edit
---

#  — Optimization Framework

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

> **OS references:** `references/ubuntu.md` (Ubuntu cleanup: apt, snap, GNOME, ext4 recovery, services, home media) · `references/windows.md` (Windows cleanup: temp files, app caches, disk cleanup)
> **Static rules:** `rules/audit-commands.md` (make check) · `rules/k-context-hygiene.md` (session log, issues log) · `rules/tool-discipline.md` (shared tmux gate)
> **Last Known State limit:** each `### Last Known State` section holds **at most 7 items**.
> **Issues ledger sync (mandatory):** every optimization-related diagnostic/fix attempt must be appended to `$HOME/.agents/skills/k-context/references/issues.md` with full commands and outputs (no compaction, no deletion).

---

## Role

> **AFTER PERFORMING AN OPTIMIZATION, THIS FILE MUST BE UPDATED WITH EVENTUAL FIXES OF COMMANDS AND THE LAST KNOWN STATE.**
> **AUTO-UPDATE MANDATE:** do not wait for  confirmation to write the operational trace; update `k-optim` and `k-context/references/issues.md` automatically at the end of each relevant optimization/incident action.

> **🔴 GRAVÉ — MANDATORY EXHAUSTIVE LOG AFTER EVERY FULL K-OPTIM RUN:** AFTER EACH COMPLETE `k-optim` RUN (a full cleanup/purge/optimization pass), **`references/log.md` MUST BE UPDATED WITH EVERYTHING THAT WAS DONE — EXHAUSTIVELY** (every command, every purge, every dir/file touched, every skill edited, every version bumped, every problem found+fixed). NO SUMMARIES, NO OMISSIONS, NO "ETC.". Append the full run trace to `references/log.md` (append-only, GRAVÉ). THIS IS AN ABSOLUTE, NON-NEGOTIABLE OBLIGATION — the operational history must never be lost. Only after logging is the run considered complete.

`k-optim` is the compact operational map for  optimization work, organized in four scopes (executed in order):

- **Local machine scope** — storage cleanup, project artifact removal, cache management. See `references/ubuntu.md` (Ubuntu) or `references/windows.md` (Windows).
- **Homelab scope** — server-side maintenance, Docker hygiene, client-side backup verification.
- **Agents scope** — AI runtime specific cache and historical data purging (gemini, claude, codex, copilot, vibe).
- **Meta scope** — `.agents/` governance hygiene, QMD cleanliness, hook/skill alignment. (Final cleanup step)

In all scopes: **load this skill before starting any cleanup/optim work** — reuse existing standards and scripts instead of reinventing. Log new scripts, key actions, and notable results in the relevant `### Last Known State` section and `## Script & Action Log` so the state stays current.

---

## Purge Discipline (Absolute Obligation)

When  asks to **purge** or **uninstall** a package, application, or tool, the agent MUST perform a complete and exhaustive cleanup of all associated files and directories across the entire system. No debris must remain. This includes purging:
- **User home directories**: `~` root level, `~/.local/`, `~/.config/`, `~/.local/share/`, `~/.cache/`, etc.
- **Snaps / Flatpaks**: snap packages, snap cache, snap user/system directories.
- **Systemd units**: both user-level (`~/.config/systemd/user/`) and system-level (`/etc/systemd/system/`) services and timers (including configurations, drop-ins, sockets).
- **Global system paths**: `/opt/`, `/usr/bin/`, `/var/lib/`, etc. (using package manager purge options).
- **Environment & Shell files**: any exports, aliases, or paths added to configuration files (`.zshrc`, `.bashrc`, `.kshrc`).

### Post-Purge Verification (MANDATORY — plocate)
🔴 **AFTER ANY PURGE, ALWAYS RUN `plocate` for the purged name/path — even when you believe everything is removed.** A purge is never "done" on assumption: verify with `plocate <name>` (and targeted `ls`/`test` where needed) covering `~`, `~/.local`, `~/.config`, `~/.cache`, `/opt`, `/usr/bin`, systemd units and `.desktop` files. Catch residual debris that `apt purge` / `npm uninstall` / `rm -rf` miss. Only when `plocate` returns no relevant hit is the purge complete. Log the `plocate` command + output in the trace. This rule lives in `rules/skill-governance.md` → Post-Purge Verification and `AGENTS.md` → Skills.

### Debris Scan — Where & How to Dig (MANDATORY — learned 2026-08-14)
🔴 **A purge is complete only when the `share`/`config`/`bin` debris of the dead app is gone too.** Beyond the package/binary, sweep these user-level dirs for leftovers of apps no longer installed:

| # | Dir | What to hunt | Example finds (2026-08-14) |
|---|-----|--------------|----------------------------|
| 0 | `~/` root level (**incl. hidden `.*`**) | dotdirs/dotfiles of dead apps, stale backups (`*~`) | `.zoom`, `.windsurf`, `.cline`, `.sui`, `.codeium`, `.qwen`, `.roo`, `.securecoder`, `.mistralcode`, `.n8n`, `.dotnet`, `.grip`, `.deno` — all purged 2026-08-14 |
| 1 | `~/.local/bin/` | stale binaries + **broken symlinks** | `k-desktop-mcp.py`, `bw-admin`, `bw-mcp` (symlinks → absent `/opt/bw-mcp`) |
| 2 | `~/.config/` | config dirs of uninstalled apps | `asciinema`, `BraveSoftware`, `Slack`, `Termius`, `Wave`, `Windsurf`, `browseruse`, `chromium`, `devin`, `vibe`, `kaggle`, `obs-studio`, `onedrive`, `opera`, `vivaldi`, `viperx`, `xarchiver`, `jupyterlab-desktop`, `google-chrome-{beta,unstable,for-testing}`, `microsoft-edge-{beta,dev}`, `eog`, `gogcli`, `ggs`, `vercel-plugin`, `zoom.conf`, `zoomus.conf` |
| 3 | `~/.local/share/` | data dirs of uninstalled apps | `devin`, `qalculate`, `totem`, `vlc`, `hyprland`, `opentui`, `rhythmbox`, `meld`, `tirith`, `nemo`, `nemo-python`, `onedriver` |
| 4 | `~/.cache/` | caches of purged apps | any `*zoom*`, `*signal*`, `*wine*`, `*asciinema*` |
| 5 | `/opt/` | heavy-client dirs | `/opt/Signal`, `/opt/zoom` |
| 6 | `/etc/apparmor.d/` | AppArmor profiles (root) | `opt.bw-mcp.bin.bw-mcp` (needs tmux sudo) |
| 7 | `apt sources` + `/usr/share/applications/*.desktop` | stale `*.sources` + launchers | `signal-desktop.sources`, `Zoom.desktop` |
| 8 | **Skills** (`~/.agents/skills/`) | doc/registry/skill referencing the purged tool as active | `bw-mcp`/`bw-admin` in `k-bw`, `k-clis`, `k-google`, `k-cloudflare`, `k-final`, `deactive/*` |

> **🔴 Always check `~` root level AND `~/.cache` when cleaning local configs or purging anything** (added 2026-08-14): many tools leave top-level dotdirs (`~/.zoom`, `~/.windsurf`, `~/.cline`, …) and caches (`~/.cache/*`) that `apt purge` / `npm uninstall` never touch. Sweep them with the same debris check below.

**How to confirm a config dir is debris (never delete live-app config):**
```bash
# candidate dir name = D
command -v D        # empty = no binary (use command -v, NOT which which echoes "not found")
dpkg -l | grep -E "^ii\s+D"
snap list | grep -w D
uv tool list | grep -w D
npm ls -g --depth=0 | grep -w D
ls /usr/share/applications/*.desktop | grep -i D
# all empty → debris → remove (trash-safe rm), then plocate <name> to confirm no residual
```
This methodology lives in `rules/skill-governance.md` → Full Debris Scan Methodology.

---

## Source Of Truth

| Topic | Where to look |
|------|----------------|
| Agent governance and response contract | `$HOME/.agents/AGENTS.md` |
| Current hot session state and TODOs | `$HOME/.agents/skills/k-context/SKILL.md` |
| Shared skill audits | `$HOME/.agents/scripts/check_skills/check_skills.py` (via `make check-skills`) |
| QMD declarative config | `$HOME/.config/qmd/index.yml` |
| QMD optimization guide | `$HOME/.agents/skills/k-qmd/references/qmd-optimization.md` |
| QMD live runtime state | `qmd status`, `qmd collection list`, `qmd ls <collection>` |
| Workstation Orchestrator (ksh) | `$HOME/.agents/skills/k-ubuntu/scripts/` |
| Homelab Orchestrator (hsh) | `$HOME/Work/Labs/Homelab/sh/` |
| Ubuntu cleanup scripts | `$HOME/.agents/skills/k-ubuntu/scripts/clean/` |
| Deleted-file recovery | `references/ubuntu.md` → Deleted-file recovery section |
| Deleted-file recovery (full runbook) | `references/ubuntu-deleted-files-recovery.md` |
| Homelab maintenance scripts | `$HOME/Work/Labs/Homelab/sh/` |

---

## Local Machine Scope

See OS-specific reference:
- **Ubuntu:** `references/ubuntu.md` — apt/snap cleanup, GNOME thumbnails, ext4/PhotoRec recovery, home media directories, service analysis, script map
- **Windows:** `references/windows.md` — Disk Cleanup, temp files, app caches, WSL-side cleanup

---

## Homelab Scope

> Scope: Proxmox server, Docker-Host LXC, backups.

### Last Known State

- The operational homelab scripts live in `$HOME/Work/Labs/Homelab/sh/` (Phoenix v3.1 modular architecture) — `hsh` is **not** guaranteed on non-login PATH; prefer `"$HOME/Work/Labs/Homelab/sh/hsh"`
- `hsh` is the local dispatcher: `hsh status` (audit), `hsh backup host` (PVE), `hsh backup vault` (DKD), `hsh maintenance` (Server)
- Backups follow the **3-2-1 rule**: 3 copies (SSD, HDD, Cloud), 2 supports, 1 off-site; Vault uses Deterministic Key Derivation (DKD)

### Actions

1. Start with local audit: run `"$HOME/Work/Labs/Homelab/sh/hsh" status`
2. Prefer local-first orchestration: `hsh backup host` (hypervisor snapshot), `hsh backup vault` (encrypted Vaultwarden)
3. Server-Side Maintenance: `hsh maintenance` for the weekly loop on the homelab server
4. Manual Fallback: shared tmux — `ssh <github-user>` and run `/root/proxmox/maintenance.sh`

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

### Systemd service symlink audit (mandatory before cleanup)

- **Check ALL systemd symlinks to `.agents/` are valid:**
  ```bash
  # System services
  find /etc/systemd/system/ -xtype l -lname '$HOME/.agents/*' -o -lname '$HOME/.config/opencode/skills/*'
  # User services
  find ~/.config/systemd/user/ -xtype l
  ```
- For each broken symlink: identify the canonical asset in `.agents/skills/<skill>/assets/` and re-symlink
- Log all fixes to `k-context/references/issues.md`
- **Zero-tolerance:** no broken `.agents/` symlinks in systemd should remain after an optimization pass
- **Automated checks:** `make check-services` (`scripts/services/check-services.sh`, joined into the `check:` chain) verifies every applicable `.agents`-owned unit's canonical asset, deployment, selected internal paths, and expected active state. Symlinks (non-systemd) are verified by `make check-links` (`scripts/links/check-links.sh`, using `assets/links.jsonc` as the single source of truth) — see below.

### Actions

1. Run `make check` and fix any warnings
2. Check QMD health: `qmd status`, `qmd collection list`
3. Verify skill alignment: `make check-skills` (or `python3 $HOME/.agents/scripts/check_skills/check_skills.py`)
4. Update `k-context/SKILL.md` session log if needed
5. Check for orphaned references in `skills/` and `references/`
6. **Check + run correct script permissions**: after any purge/optimization, verify and normalize execute bits on all kernel scripts with `make chmod` (default 755; stricter 744/700 via `scripts/chmod.sh <XYZ>`) — always check that installed scripts/entry points remain executable.
7. **Broken-link sweep (`~` whole home + `/etc`)**: dig the ENTIRE `$HOME` (`find ~ -type l` — recursive, ALL of `~`, not just `~/.local/bin`, `~/.config`, `~/.local/share`; those are examples, not a limit) and the whole system config `/etc` (covers `/etc/systemd/system` and everything else). For each broken link whose canonical asset exists in `.agents` (`~/.agents/skills/<skill>/assets|scripts/...`), **re-create the symlink** to that source of truth (`ln -sf`; elevation via tmux for `/etc`). If the source of truth is NOT localizable (asset missing/uninstalled), **signal/report it** (do not silently leave it) and log to `k-context/references/issues.md`. Zero-tolerance: no broken `.agents`-related symlink should remain after an optimization pass. Fast detection (whole home + `/etc`): `find ~ /etc -type l ! -exec test -e {} \; -print 2>/dev/null`. **Speed note (PRUNE_DIRS — never scan into these noise dirs):** when sweeping the whole home, prune `Trash`, `.venv`, `node_modules`, and `models` (large model stores) — they are noise / not `.agents`-owned symlinks. Mirror of `scripts/links/check-links.sh` `PRUNE_DIRS`.
8. **`.loom` index debris analysis (MANDATORY during any optimization pass)**: analyze `$HOME/.loom/projects/*.db` and clean Loom debris — (a) **stub DBs**: 0-node DBs created lazily whenever an agent merely started a session in a folder (only `meta`/FTS tables) → purge; (b) **rename ghosts**: DBs whose project directory was renamed/no longer exists (e.g. `tg_proxy.db` vs `tg-proxy.db`, cleaned 2026-08-24) → purge after confirming the new-name index exists or re-indexing; (c) **stale real indexes**: check freshness via `loom stats` + DB mtime (`stat`) on ACTIVE projects → flag for `loom sync`/`loom analyze .`, do not delete (loom CLI only — no MCP since 2026-08-24). Detection: `uv run --no-project python` sqlite read-only count over `nodes` per DB (`sqlite3` CLI may be absent); cross-check each DB name against existing directories under `$HOME/Labs/`, `$HOME/Work/`, etc. Use trash-safe `rm`. Methodology details: `k-loom/SKILL.md` → `.loom` Hygiene.

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-optim/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-optim/references/insights.md` at the end of the task with durable lessons.
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

