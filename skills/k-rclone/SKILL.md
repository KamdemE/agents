---
name: k-rclone
description: >
  KπX rclone — Google Drive remotes, FUSE mounts, systemd templates. Part of Google file layer
  (k-google → k-rclone → k-drive). Load for new remotes, mounts, or rclone troubleshooting.
license: private
metadata:
  author: KpihX
  version: "1.2.2"
allowed-tools: Bash(rclone:*), Bash(systemctl:*), Bash(ls:*), Bash(cat:*)
---

# KπX — rclone

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Cloud hub

Google **file layer** (not Gmail API): **`k-google`** → **this skill** → **`k-drive`** · map: `$HOME/.agents/skills/k-cloud-tools/references/cloud-hub.md`

> **Config file:** `$HOME/.config/rclone/rclone.conf` — source of truth for all remotes.
> **Templates:** `assets/rclone-gdrive.service` — systemd user service for FUSE mounts.

## Existing Remotes

| Remote name | Type | Account | Mount path | Systemd service |
|-------------|------|---------|------------|-----------------|
| `gdrive-x:` | Google Drive | `ivann.kamdem-pouokam.2024@polytechnique.org` | `$HOME/Gdrive_X/` | *(direct / manual)* |
| `gdrive:` | Google Drive | `kapoivha@gmail.com` | `$HOME/Gdrive/` | `rclone-gdrive.service` |
| `homelab-sftp:` | SFTP | `ivann@kpihx-labs` (port 2222) | *(on-demand)* | — |

## Adding a New Google Drive Remote

### Step-by-step (interactive)

```bash
rclone config
```

Then follow:

```
n) New remote
name> <remote-name>          # e.g. gdrive-work
Storage> drive               # Google Drive
client_id>                   # leave empty (use rclone's shared app)
client_secret>               # leave empty
scope> 1                     # drive (full access)
root_folder_id>              # leave empty
service_account_file>        # leave empty
Edit advanced config? n
Use auto config? y           # opens browser → sign in → grants access
Configure this as a Shared Drive (Team Drive)? n
y) Yes this is OK
```

> **After**: verify with `rclone lsd <remote-name>: | head -5`

### Non-interactive / headless (copy token from another machine)

1. Run `rclone config` on desktop → complete OAuth → copy token JSON from `rclone.conf`
2. On headless host: manually add section to `$HOME/.config/rclone/rclone.conf`:

```ini
[<remote-name>]
type = drive
scope = drive
token = {"access_token":"...","token_type":"Bearer","refresh_token":"...","expiry":"..."}
team_drive =
```

## Mount Flags

Standard KπX mount command:

```bash
rclone mount <remote>: <mountpoint> \
  --config=$HOME/.config/rclone/rclone.conf \
  --vfs-cache-mode full \
  --allow-other \
  --dir-cache-time 1m
```

| Flag | Why |
|------|-----|
| `--vfs-cache-mode full` | Full local cache — reads/writes go through cache; needed for most apps |
| `--allow-other` | Other users (root) can access the mountpoint |
| `--dir-cache-time 1000h` | **Sovereign Profile**: Keeps directory structure in RAM for 1000 hours. Prevents costly API re-scans on every `ls`/`find`. |
| `--poll-interval 10s` | **Sovereign Profile**: Listens for Google Drive "Notify" signals. If a file changes on another device, rclone updates the cache within 10s. |
| `--vfs-read-ahead 128M` | **Sovereign Profile**: Prefetches 128MB of data. Makes opening large PDFs or documents feel local. |

### The "Sovereign Mount" Strategy (2026-05-02)

For a high-performance, CLI-friendly Google Drive mount on Linux, standard defaults (`1m` cache) are insufficient. The "Sovereign Mount" configuration optimizes for **CLI search speed** and **document access latency**:

1. **Persistent Metadata Cache (`--dir-cache-time 1000h`)**:
   - **Why**: Standard mounts treat the cloud as a volatile disk. By setting a very long cache time, `rclone` builds a full local index of the Drive in memory.
   - **Benefit**: `find`, `rg`, and recursive `ls` operations run at near-SSD speeds because they never hit the network.

2. **Reactive Synchronization (`--poll-interval 10s`)**:
   - **Why**: Long cache times normally mean you won't see new files added via the web/phone. Polling solves this by asking Google for "changes since last sync" every 10 seconds.
   - **Benefit**: Real-time feel without the performance penalty of frequent full re-scans.

3. **Intelligent Prefetching (`--vfs-read-ahead 128M`)**:
   - **Why**: Sequential reads are the main bottleneck. Prefetching data into the VFS cache before the application asks for it hides the network latency.
   - **Benefit**: Documents open instantly as if they were stored locally.

Optional additional flags:

| Flag | Use case |
|------|----------|
| `--read-only` | Read-only mount (backup, audit) |
| `--transfers 8` | Parallel transfers (default 4) |
| `--buffer-size 256M` | Read-ahead buffer (streaming) |

## Systemd User Service

Template: `assets/rclone-gdrive.service`

Copy + adapt for each new mount:

```bash
cp $HOME/.agents/skills/k-rclone/assets/rclone-gdrive.service \
   $HOME/.config/systemd/user/rclone-<name>.service
# Edit: Description, ExecStart remote/mountpoint
systemctl --user daemon-reload
systemctl --user enable --now rclone-<name>.service
systemctl --user status rclone-<name>.service
```

## Post-Setup Agent Checklist

After any new rclone remote + mount is confirmed working (`rclone lsd <remote>:` returns content):

1. **Verify mount** — `ls $HOME/MountPoint/ | head -5` (check content is visible)
2. **Update `$HOME/.agents/AGENTS.md`** — add row to Storage table in Identity section
3. **Update k-context** — add session log entry, bump version
4. **Update `.skill-lock.json`** — only if a new skill was created, not for remotes
5. **Propose `techskills` entry** — document any non-obvious steps or fixes encountered
6. **Commit + push** — `cd $HOME/.agents && git add -A && git commit -m "..." && make push`

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Mount not accessible after reboot | `systemctl --user status rclone-<name>.service` — check logs |
| `fusermount: entry for ... not found in /etc/mtab` | Mount already gone — `fusermount -u <mountpoint>` to clean |
| Token expired / 401 | Run `rclone config reconnect <remote>:` to re-auth |
| `--allow-other` denied | Ensure `user_allow_other` in `/etc/fuse.conf` (or use without `--allow-other`) |
| High API quota usage | Increase `--dir-cache-time` (e.g. `10m`) |
| Large Google Drive metadata moves stall | Use Drive API moves by file ID for the bulk operation; keep `rclone` for root checks, size checks, and small independent verification counts |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-rclone/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-rclone/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-25 | [CURSOR] | v1.2.2 — Cloud-hub routing block; YAML description aligned with k-google stack. |
| [SUMMARY] | — | v1.2.0–v1.2.1 Sovereign Mount profile; bulk moves via Drive API when FUSE stalls; insights discipline. |
