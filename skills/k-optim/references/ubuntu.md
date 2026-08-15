# k-optim — Ubuntu

> **OS reference:** Ubuntu (native)
> **Applies to:** `k-ubuntu` (kpihx-ubuntu workstation)

---

## Scope

Ubuntu workstation optimization — local storage, project artifacts, caches, home media directories, systemd services, deleted-file recovery.

---

## Last Known State

- **2026-05-26 deleted-image recovery**: Tier A (no sudo) → 103 GNOME thumbnail previews from `recently-used.xbel` → `~/Recovery_candidates_2026-05-26/from_thumbnails/`. Tier B PhotoRec → ~1534 carved images in `~/Recovery_PhotoRec_2026-05-26/`. extundelete failed (mounted `/`).
- **2026-05-22 (post-kernel)**: `timeshift` purged. `ISS-20260516-001` RESOLVED (16G backup SUCCESS).
- **2026-05-22 full pass**: `$HOME` ~165G→~147G; `/` 72% (74G free). Transit emptied. `clean_all.sh -s -p -y` + UV cache (~15G).
- **2026-05-31 full session**: disk 204G→182G (81G free, 70%). Purged: brew 5.9G, waydroid, Windsurf 966MB, open-webui 811MB Docker, 6 snaps, 35 unit files disabled.
- Cleanup stack: `.agents/skills/k-ubuntu/scripts/clean/` — `clean_editors.sh` wraps Code/Cursor/AGY.

---

## Actions

1. Start with analysis:
   - `ksh status` for global health audit (Clean/Backup/Vault/QMD)
   - `systemctl list-timers` for scheduled task status
   - `make -C $HOME/.agents/skills/k-ubuntu/scripts/clean log-scan` for last workspace scan
   - `ksh backup status` for safety window
2. Prefer safe cleanup first: `ksh clean run` for broad low-risk sweep
3. Use purge/system modes intentionally: `-p` for heavy caches, `-y` for privileged cleanup
4. Finalize: `ksh backup run` after cleanup

---

## Script Map

| Script | Primary use |
|--------|-------------|
| `.agents/skills/k-ubuntu/scripts/clean/clean_all.sh` | Orchestrate full Ubuntu cleanup suite |
| `.agents/skills/k-ubuntu/scripts/clean/auto_clean.sh` | Weekly automated cleanup with Telegram report |
| `.agents/skills/k-ubuntu/scripts/clean/clean_snap.sh` | Snap revisions, caches, snapshots |
| `.agents/skills/k-ubuntu/scripts/clean/clean_cache.sh` | Trash, package caches, browser cache |
| `.agents/skills/k-ubuntu/scripts/clean/clean_vscode.sh` | VSCode cache and extension-state |
| `.agents/skills/k-ubuntu/scripts/clean/clean_work.sh` | `$HOME/Work` analysis, git GC, temp artifacts |
| `.agents/skills/k-ubuntu/scripts/clean/clean_docker.sh` | Docker space analysis and cleanup |
| `.agents/skills/k-ubuntu/scripts/clean/clean_ai.sh` | Ollama and HuggingFace storage cleanup |

---

## Automated Tasks

| Task | Frequency | Script | Log Path |
| :--- | :--- | :--- | :--- |
| System Cleanup | Every 2 days (starting Sun) | `.agents/skills/k-ubuntu/scripts/clean/auto_clean.sh` | `/var/log/clean/workspace_scan.log` |
| Workstation Backup | Every 2 days (starting Sun) | `.agents/skills/k-ubuntu/scripts/backup_restore/backup_workstation.sh` | (systemd journal) |

---

## Deleted-file Recovery (images, ext4)

> **Full runbook:** `$HOME/.agents/skills/k-optim/references/ubuntu-deleted-files-recovery.md` — load before any undelete work.

1. **Tier A (no sudo):** `recently-used.xbel` + `~/.cache/thumbnails/` — fast previews with original names.
2. **Tier B (sudo):** PhotoRec `freespace` — full resolution; run in shared tmux (`default:0.0`), no split panes.
3. **Tier C:** extundelete — only if partition unmounted (live USB); fails on mounted `/`.
4. Stop writing to disk; cross-match carved `f*` files against xbel name list after scan.

---

## Home Media Directories

> Policy: transit zones, not storage. Keep empty or near-empty.

| Dir | Policy |
|-----|--------|
| `Downloads/` | Install artifacts immediately → delete. Backups → Gdrive. |
| `Documents/` | No permanent storage. Docs → Gdrive_X/ or Gdrive/. |
| `Pictures/` | Screenshots are transit → review → keepers to Gdrive/ or $HOME/Work/ → empty. |
| `Videos/` | Keep empty — recordings go to Gdrive/ directly. |
| `Music/` | Keep empty. |
| `Desktop/` | Keep empty. |

**Check:** `du -sh "$HOME/Downloads" "$HOME/Documents" "$HOME/Pictures" "$HOME/Videos" "$HOME/Music" "$HOME/Desktop"`

---

## Services Analysis

1. **Diagnostic:**
   ```bash
   systemctl list-units --type=service --state=failed --no-pager
   systemctl list-units --type=service --state=not-found --no-pager
   systemctl list-unit-files --type=service --state=enabled --no-pager --no-legend | awk '{print $1}' | sort
   ```
2. **Broken (not-found)** → `systemctl mask` (no purge)
3. **Useless but enabled**: categorize as Replaced / No hardware / Orphaned / Condition never met
4. **Validate with KπX** before disable/purge
5. **Final report**: running count before/after, RAM freed, units eliminated
