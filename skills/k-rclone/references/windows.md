# k-rclone — Windows / WSL

> **OS reference:** Microsoft Windows (with WSL subsystem)
> **Applies to:** `k-blglaptop139` (blglaptop139)

---

## rclone in WSL

rclone installs inside WSL identically to Linux:

```bash
# Inside WSL
sudo apt install rclone
# Or download from https://rclone.org/downloads/
```

## rclone Natively on Windows

rclone also has a native Windows build:

```powershell
winget install Rclone.Rclone
```

Windows paths use `%USERPROFILE%\.config\rclone\rclone.conf` instead of `~/.config/rclone/rclone.conf`.

## FUSE Mounts on Windows

FUSE mounts (`rclone mount`) are **Linux-only** via FUSE kernel module. On Windows:
- **Native Windows**: Use `rclone mount` with WinFSP (install separately) or use `rclone sync` instead
- **WSL**: Full FUSE support inside WSL2 — mount commands work identically to Linux

## Google Drive Remotes

The same remote names (`gdrive:`, `gdrive-x:`) work on all platforms — the rclone config is portable. Copy the config file to each machine.

## SFTP Remote

The `homelab-sftp:` remote requires Tailscale connectivity and SSH key access to `ivann@kpihx-labs` — works from any OS with Tailscale connected.
