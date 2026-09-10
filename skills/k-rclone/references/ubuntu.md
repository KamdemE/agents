# k-rclone — Ubuntu

> **OS reference:** Ubuntu (native)
> **Applies to:** `k-ubuntu` (workstation workstation)

---

## Installation

```bash
sudo apt install rclone
```

## FUSE Mounts

Google Drive mounts use FUSE via systemd user services:

| Mount | Systemd service | Remote |
|-------|----------------|--------|
| `~/Gdrive/` | `rclone-gdrive.service` | `gdrive:` |
| `~/Gdrive/` | _(manual)_ | `gdrive-x:` |

Service templates: `assets/rclone-gdrive.service` in this skill.

## Config File

`$HOME/.config/rclone/rclone.conf` — source of truth for all remotes. Copy to other machines for the same setup.

## SFTP Remote

`pve:` connects to `personal@<github-user>` port 2222 via Tailscale. Requires SSH key access.
