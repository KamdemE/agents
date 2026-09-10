# k-rclone — Mount Sync (rsync/robocopy, across mounts/disks)

Distilled (form only, zero business content) from a real, mature R&D pipeline project's asset-mirroring tooling. Distinct from the rest of `k-rclone` (Google Drive remotes/FUSE mounts): this is generic **mount-to-mount sync** — two separate mounted disks/paths (a network drive, an NVMe mirror, a Windows↔Linux boundary), not the same disk — plain `rsync`/`robocopy`, no rclone remote involved. The most common use is mirroring a project's heavy `assets/` (large data/model files), but the pattern is generic: any two mount points. Documented here anyway (not in `k-project`) so it's discoverable alongside the rest of the user's sync tooling whenever a project needs it — `k-project` → Pipeline R&D archetype just points here.

Templates: `assets/mnt-sync/{dirs.txt.example,load_dirs.sh,sync-pull.sh,sync-push.sh,sync-pull.ps1,sync-push.ps1}`.

## Topology

```
                    REMOTE_ROOT (network drive / NVMe mirror — source of truth)
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
        Linux (rsync)                   Windows (robocopy)
     sync-pull.sh / sync-push.sh   sync-pull.ps1 / sync-push.ps1
```

- **Pull** = remote mount → local mount (no delete — never destroys local-only work).
- **Push** = local mount → remote mount (mirrors exactly — `--delete`/`/MIR` removes orphans on the remote side; use deliberately).

## Single source of truth: `dirs.txt`

Every script reads the same `dirs.txt` (one folder name per line, `#` comments and blank lines ignored) via `load_dirs.sh` (Linux) or inline parsing (PowerShell). Adding a new synced folder is a **one-line edit to `dirs.txt`**, never a change to every script. Copy `dirs.txt.example` to `dirs.txt` in your project and adjust.

## Wiring into a project's Makefile

```makefile
sync-pull: ## Pull from the remote mount (no delete)
	@bash scripts/mnt-sync/sync-pull.sh

sync-push: ## Push to the remote mount (mirror, deletes orphans)
	@bash scripts/mnt-sync/sync-push.sh
```

Set `MNT_SYNC_REMOTE_ROOT` / `MNT_SYNC_LOCAL_ROOT` (env vars, both scripts default to sane placeholders — `LOCAL_ROOT` defaults to the project's `assets/`, the common case, but either root can point at any mounted path) rather than hardcoding paths inside the scripts — machine-specific paths belong in the environment or a gitignored `.env`, never committed inline.

## Design notes worth keeping

- **One script per direction, not per direction×OS×folder** — the folder list is data (`dirs.txt`), not code. Don't generate N nearly-identical scripts as folders grow.
- **Pull never deletes, push always mirrors** — this asymmetry is deliberate: an accidental `push` before a `pull` can't silently erase remote-only files you never fetched, but a `push` that *should* mirror (e.g. after deleting a stale run locally) does so completely rather than leaving orphans to accumulate.
- **Live progress for large transfers**: for very large/slow mounts, the source project used a hand-rolled progress UI (background `rsync` jobs polled via `kill -0` + `du -sb`, `trap ... EXIT` cleanup) instead of a third-party dependency — consistent with the "no extra dependency for local tooling" philosophy. The templates here use `rsync --info=progress2` instead (built into rsync, simpler); reach for the hand-rolled version only if you need per-folder parallel progress bars specifically.
- **Keep a push error log outside any cleanup trap** — if you add error logging, write it outside the repo and outside any `trap ... EXIT` cleanup, so a partial/failed push is still diagnosable afterward.

