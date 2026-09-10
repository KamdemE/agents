# plocate — Much Faster Search

**Asset:** `k-clis/references/plocate.md`
**Scope:** Ubuntu / Debian

## Why

`find` and `grep` scan the filesystem in real time — slow on large trees.
`plocate` uses a pre-built index (`/var/lib/plocate/plocate.db`) updated periodically.
Typical speedup: **~100×** on a full disk search.

## Install

```bash
sudo apt install plocate
```

This replaces `mlocate` if installed. The `plocate` command is the primary tool.

## Database Setup

`plocate` ships with a systemd timer that runs `updatedb` daily. On a fresh install, the DB is empty until the first run.

### Immediate build

```bash
sudo updatedb
```

This indexes all mounted filesystems (respects `PRUNEPATHS` in `/etc/updatedb.conf`).

### Timer check

```bash
systemctl status plocate-updatedb.timer
systemctl list-timers plocate-updatedb.timer
```

Default: daily at ~6:00 AM local time.

### Manual refresh

```bash
sudo updatedb        # full reindex
# or for a specific path:
sudo updatedb -l 0 -U $HOME
```

## Agent Usage Mandate

**Always prefer `plocate <pattern>` (never `locate` — plocate's DB is auto-updated daily) over `find / -name <pattern>` or recursive `grep`/Glob operations.**

### Good — fast (milliseconds):

```bash
plocate SOME_FILE
plocate -i CASE_INSENSITIVE        # case-insensitive
plocate -l 20 PATTERN              # limit to 20 results
plocate --regex 'PATTERN'          # regex search (basic regex)
plocate -b BASENAME                # match basename only (not full path)
```

### Bad — slow (seconds to minutes):

```bash
find / -name SOME_FILE             # slow — full tree scan
grep -r PATTERN /some/dir         # slow — reads every file
```

### When NOT to use plocate

- **Real-time search**: files created/renamed since last `updatedb` won't appear.
- **Permissions**: `plocate` respects visibility — no results for paths the user cannot read.
- **Network/remote filesystems**: excluded by default (`PRUNEFS` in `/etc/updatedb.conf`).

For these cases, fall back to `find` with narrow scope or `fd` (if installed).

## Configuration

`/etc/updatedb.conf` — controls what is indexed:

```conf
PRUNE_BIND_MOUNTS="yes"
PRUNEFS="9p afs anon_inodefs auto autofs bdev binfmt_misc cgroup2 cifs coda configfs cpusys debugfs devpts devtmpfs ecryptfs exfat fuse.encfs fuse.sshfs fuseblk fusectl gfs gfs2 gpfs hugetlbfs inotifyfs iso9660 jffs2 lustre mqueue ncpfs nfs nfs4 nfsd ocfs pipefs proc ramfs rootfs rpc_pipefs securityfs sELinux smbfs squashfs sysfs tmpfs tracefs ubifs udf usbfs vboxsf vfat"
PRUNENAMES=".git .hg .svn __pycache__ node_modules .tox .venv .direnv build dist target .cache .m2 .npm .cargo"
PRUNEPATHS="/home/*/.cache /media /mnt /tmp /var/cache /var/lib/apt /var/lib/docker /var/lib/flatpak /var/lib/snapd /var/log /var/spool /var/tmp /snap /proc /sys /dev"
```

Adjust `PRUNENAMES` / `PRUNEPATHS` to exclude directories that don't need indexing.
