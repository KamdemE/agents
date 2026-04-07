---
name: k-rclone
description: KπX rclone — Google Drive remote setup (OAuth flow), systemd user service template for FUSE mounts, mount flags, and post-setup agent checklist. Load when adding a new cloud remote, setting up a mount, or troubleshooting rclone.
license: private
metadata:
  author: KpihX
  version: "1.0.3"
allowed-tools: Bash(rclone:*), Bash(systemctl:*), Bash(ls:*), Bash(cat:*)
---

# KπX — rclone

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

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
| `--dir-cache-time 1m` | Refresh directory listing every 1 min — balance freshness vs API quota |

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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v1.0.3 — normalized the bundled systemd service template away from hardcoded home paths by using user-home-safe path specifiers |
| 2026-04-03 | [CODEX] | v1.0.2 — normalized remaining paths to `$HOME` and condensed the changelog to the standard footer format |
| [SUMMARY] | — | v1.0.1 moved `templates/` to `assets/`; v1.0.0 created the remotes table, Google Drive OAuth flow, mount flags, systemd template ref, and post-setup checklist |
