# Google Drive (gdrive) — Corbeille & Manipulation

Operational knowledge for manipulating KπX Google Drive remotes via rclone,
with a focus on finding and emptying the Drive trash and avoiding quota errors.

> Applies to `gdrive:` and `gdrive-x:` remotes. Configuration: `$HOME/.config/rclone/rclone.conf`
> (source of truth: `k-rclone/assets/rclone.conf`).

## 1. Inspect a remote — quota & trash at a glance

`rclone about` reports the account quota AND how much is sitting in the trash.

```bash
rclone about gdrive-x:
```

Output fields (Google Drive backend):

| Field | Meaning |
|-------|---------|
| `Total` | Total quota of the account |
| `Used` | Space used by live (non-trashed) files |
| `Free` | Remaining usable space |
| **`Trashed`** | Space occupied by **trashed** files — **counts against the quota** |
| `Other` | Other usage (apps data, etc.) |

> **Key insight (learned 2026-08-16):** Google Drive **counts trashed files toward
> the quota**. A `storageQuotaExceeded` error on backup upload can be caused by a
> full **trash**, not by live files. Always check `Trashed` before assuming the
> account itself is full.

## 2. Find / list the trash

rclone's flag to list only trashed files is **`--drive-trashed-only`** (NOT
`--trashed-only`, which does not exist and produces a flag error).

```bash
# List trashed files (shows original directory structure)
rclone lsl gdrive-x: --drive-trashed-only

# Recursive, with sizes, most-useful form
rclone lsl gdrive-x: --drive-trashed-only --fast-list

# Top-level view
rclone lsf gdrive-x: --drive-trashed-only
```

> `--drive-trashed-only` is a backend flag (see `rclone backend help gdrive-x:`).
> It also works via config `trashed_only = true` or env `RCLONE_DRIVE_TRASHED_ONLY`.

## 3. Empty the trash

```bash
rclone cleanup gdrive-x:
```

- **`rclone cleanup <remote>:`** permanently deletes **all** trashed files.
- No path argument — it clears the whole remote's trash.
- **Google empties the trash in the background** (minutes → days). The command
  returns within seconds and echoes no confirmation — this is expected, do not
  re-run repeatedly.

> `rclone cleanup` is the canonical way (calls Drive `emptyTrash`). If it seems
> not to work, `rclone delete gdrive-x: --drive-trashed-only --drive-use-trash=false --fast-list`
> is a manual fallback (enumerate + permanent-delete), though much slower.

## 4. Delete files & control the trash

By default rclone sends deleted files to the Drive **trash**. To delete
permanently (bypass the trash), use `--drive-use-trash=false`:

```bash
# Delete a single file permanently (does NOT fill the trash)
rclone deletefile gdrive-x:Backups/PVE/old.tar.zst --drive-use-trash=false

# Delete all files in a dir permanently
rclone delete gdrive-x:Backups/PVE --drive-use-trash=false
```

**Anti-quota rule for backup scripts:** when rotating/purging old backups on
Drive, ALWAYS use `--drive-use-trash=false` so old backups are permanently
removed instead of accumulating in the trash. Then call `rclone cleanup` after
the push to empty any residual trash. This is the fix applied to
`k-ubuntu/scripts/backup_restore_pve/backup_pve.sh` and
`k-pve/scripts/backup/backup` (2026-08-16).

## 5. Copy / upload

```bash
# Upload a local file to a Drive path
rclone copy /path/to/file.tar.zst gdrive-x:Backups/PVE --transfers=4 --drive-chunk-size=32M

# Download
rclone copy gdrive-x:Backups/PVE/latest.tar.zst /local/dir
```

## 6. Common gotchas

- **`--trashed-only` is invalid** (v1.74+). Use `--drive-trashed-only`.
- **Glob expansion vs sudo:** running `sudo grep ... /root/.../*.sh` on a remote
  host fails with `zsh: no matches found` because the glob is expanded by the
  shell BEFORE sudo, while `/root` is not readable by the user. Wrap the glob
  inside `sudo bash -c '...'` so it is resolved as root.
- **Shared client_id notice:** `rclone about` prints a NOTICE that rclone's
  shared Google client_id is being retired in 2026. This is informational — do
  not confuse it with an error.
