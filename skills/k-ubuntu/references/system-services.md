# System Services — Full Inventory (enabled, verified)

All services listed below are **active and running** (verified 2026-07-25). Source of truth is within `.agents/` with a symlink to the OS location. For custom services, the `Source (.agents/)` column shows the canonical file path; for KπX-managed configs, the symlink target is listed.

| Service | Role | Statut | Source (.agents/) | Symlink |
|---------|------|--------|-------------------|---------|
| `nftables.service` | Firewall | ✅ enabled + active | `k-nftables/assets/nftables.conf` (shared canonical config; scoped to `kpihx-ubuntu` + `kpihx-pve-debian`) | ✅ `/etc/nftables.conf` |
| `docker.service` | Container runtime | ✅ enabled + active | — (system default) | — |
| `tailscaled.service` | Tailscale mesh VPN | ✅ enabled + active | — (system default) | — |
| `ssh.service` | SSH daemon | ✅ enabled + active | — (system default) | — |
| `tor@default.service` | Tor SOCKS5 proxy | ✅ enabled-runtime + active | — (system default) | — |
| `NetworkManager.service` | Network management | ✅ enabled + active | — (system default) | — |
| `systemd-resolved.service` | DNS resolver | ✅ enabled + active | — (system default) | — |
| `snapd.service` | Snap daemon | ✅ enabled + active | — (system default) | — |
| `ollama.service` | LLM runtime (Intel Arc iGPU) | ✅ linked + active | `k-ollama/assets/ollama.service` + `override.conf` | ✅ symlink via `k-ollama` |
| | | | | |
| **User services** (systemctl --user) | | | | |
| `opencode-web.service` | OpenCode Web server | ✅ enabled + active | `k-opencode/assets/opencode-web.service` | ✅ `~/.config/systemd/user/opencode-web.service` |
| `rclone-gdrive.service` | Gdrive (kapoivha@gmail.com → ~/Gdrive) | ✅ enabled + active | `k-rclone/assets/rclone-gdrive.service` | ✅ `~/.config/systemd/user/rclone-gdrive.service` |
| `rclone-gdrive-x.service` | Gdrive_X (X account → ~/Gdrive_X) | ✅ enabled + active | `k-rclone/assets/rclone-gdrive-x.service` | ✅ `~/.config/systemd/user/rclone-gdrive-x.service` |
| `rclone-deep-pc6.service` | Deep-PC6 (via k-dxo → ~/Deep-PC6) | ✅ enabled + active | `k-dxo/assets/rclone-deep-pc6.service` | ✅ `~/.config/systemd/user/rclone-deep-pc6.service` |
| | | | | |
| **Timers** (system) | | | | |
| `clean.timer` | System cleanup (Sat 04:00) | ✅ enabled + active | `k-ubuntu/assets/clean/clean.service` + `.timer` | ✅ `/etc/systemd/system/clean.*` |
| `backup-restore.timer` | Daily workstation backup (22:00) | ✅ enabled + active | `k-ubuntu/assets/backup_restore/backup-restore.service` + `.timer` | ✅ `/etc/systemd/system/backup-restore.*` |
| `pve-backup.timer` | PVE weekly backup (Sat 03:30) | ✅ enabled + active | `k-ubuntu/assets/backup_restore_pve/pve-backup.service` + `.timer` | ✅ `/etc/systemd/system/pve-backup.*` |
| | | | | |
| **Config symlinks** | | | | |
| `~/.kshrc` | Shell config (zsh) | ✅ valide | `k-ubuntu/assets/kshrc` | ✅ symlink |
| `~/.local/bin/ksh` | Universal dispatcher | ✅ valide | `k-ubuntu/scripts/ksh.sh` | ✅ symlink |
| `~/.config/rclone/rclone.conf` | rclone config (4 remotes) | ✅ valide | `k-rclone/assets/rclone.conf` | ✅ symlink |
| `~/.local/bin/rm` | Trash-safe rm wrapper | ✅ valide | `k-clis/assets/rm` | ✅ symlink |
| `openclaw-gateway.service` | OpenClaw Gateway runtime (user service) | ✅ enabled + active | `k-openclaw/assets/openclaw-gateway.service` + `assets/openclaw-override.conf` | ✅ `~/.config/systemd/user/openclaw-gateway.service` |
