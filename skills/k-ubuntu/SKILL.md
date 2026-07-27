---
name: k-ubuntu
description: >
  KpihX-Ubuntu workstation — the machine running this kernel session (Intel
  Core Ultra 7 155H, Ubuntu 26.04 LTS). Covers shell architecture, system
  services, directory layout, local MCP ecosystem, firewall, remote work
  VPN/RDP, and hardware. Load before any Ubuntu workstation-specific task.
license: private
metadata:
  author: KpihX
  version: "1.9.0"
  scope: workstation
allowed-tools: Bash, Read, Write, Edit
---

# KpihX-Ubuntu — Workstation

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-infras` (master infrastructure map + setup checklist) · `k-zsh` (shell setup — .kshrc, .zshrc) · `k-ssh` (SSH config — canonical fragment, keys) · `k-nftables` (firewall — sub-skill) · `k-tailscale` (mesh VPN operations) · `k-optim` (Ubuntu optimization) · `k-docker` (generic container patterns) · `k-cloudflare` (flarectl DNS/API) · `k-bw` (bw-mcp & bw-proxy) · `k-openclaw` (gateway service) · `k-rclone` (FUSE mounts) · `k-tmux` (shared interactive gate) · `kpihx-labs` (kernel top reference)
> **SSH config source of truth:** `$HOME/.ssh/config`
> **Tailscale live state:** `tailscale status --json`

---

## Host Identity

| Property | Value |
|----------|-------|
| Hostname | `KpihX-Ubuntu` |
| Short name (tmux) | `ubuntu` |
| Tailscale | `kpihx-ubuntu` (`100.82.95.70`) |
| OS | Ubuntu 26.04 LTS (Resolute Raccoon) |
| Kernel | Linux 7.0.0-28-generic x86_64 |
| CPU | Intel Core Ultra 7 155H |
| RAM | 30 GiB |
| Disk | KIOXIA 1024GB (nvme0n1) — see `k-infras` references/ntfs-shrink-dual-boot.md for partitioning |

### Tailscale Identity

| Property | Value |
|----------|-------|
| Tailscale hostname | `KpihX-Ubuntu` |
| DNS name | `kpihx-ubuntu.tail2527bd.ts.net.` |
| Tailscale IPv4 | `100.82.95.70` |
| Tailscale IPv6 | `fd7a:115c:a1e0::b801:5f48` |
| Physical IP | `129.104.235.226:41641` |
| Bridge IPs (Docker/libvirt) | `172.17.0.1`, `172.17.21.27`, `192.168.122.1` |
| Owner | `kapoivha@gmail.com` |
| Tailscale version | `1.96.4` |
| Node key expiry | `2026-12-22` |
| WireGuard port | `41641/udp` |
| Serve (OpenClaw) | `https://kpihx-ubuntu.tail2527bd.ts.net:443` → `127.0.0.1:18789` |
| Serve (OpenCode) | `https://kpihx-ubuntu.tail2527bd.ts.net:1443` → `127.0.0.1:4097` |
| accept-routes | ✅ `10.10.10.0/24` via `kpihx-pve` |
| accept-dns | ✅ |
| Operator | `kpihx` (no sudo for tailscale CLI) |

Full Tailscale operations reference: **`k-tailscale`** (generic patterns: install, serve, funnel, DERP, ACL, troubleshooting).

Hardware details (disk layout, BIOS/UEFI, dual-boot): **`k-infras`** (see `references/ntfs-shrink-dual-boot.md`)

---

## Firewall

Ubuntu workstation firewall is managed via `k-nftables`. The canonical ruleset resides at `k-nftables/assets/nftables.conf` and is symlinked to `/etc/nftables.conf`.

> **Sub-skill:** Load `k-nftables` for ruleset reference, interface inventory, service management, and troubleshooting.

Key facts:
- `/etc/nftables.conf` → symlink to `~/.agents/skills/k-nftables/assets/nftables.conf`
- systemd drop-in `/etc/systemd/system/nftables.service.d/protect-home.conf` overrides `ProtectHome=read-only` so systemd can follow the symlink
- `nftables.service` enabled at boot

---

## Shell

Shell setup follows the **`.kshrc` Universal Hub** pattern — see **`k-zsh`** for full documentation, installation guide, and template assets.

**Ubuntu workstation specifics:**
- `$HOME/.kshrc` → **symlink** to `assets/kshrc` (this skill). Source of truth.
- Shell files: `$HOME/.zshrc`, `$HOME/.zprofile`, `$HOME/.zshenv`, `$HOME/.bashrc`
- `$EDITOR` is set to `nvim` (see `.kshrc`)

**Critical shell — shared tmux (replaces `sui`)**
- `sui` is deprecated. For `sudo`, SSH passphrase, or any interactive approval → `rules/tool-discipline.md` · `k-tmux/SKILL.md` → Shared interactive gate.

---

## Directory Layout

### $HOME/Work/ — Dev & Prod

| Path | Purpose |
|------|---------|
| `$HOME/Work/AI/MCPs/` | All MCP servers source code |
| `$HOME/Work/AI/gemini_mcps/` | Gemini Extension wrappers |
| `$HOME/Work/Homelab/` | Infrastructure (Traefik, Vaultwarden, Portainer, Ollama) — remote access |
| `$HOME/Work/Homelab/` | Infrastructure (Traefik, Vaultwarden, Portainer, Ollama) — remote access |
| `$HOME/Work/techskills/` | Ubuntu living KB — real fixes documented as they happen |
| `$HOME/Work/Others/` | Miscellaneous / Non-project files / Transit zone |
| `$HOME/Gdrive/` | Personal Google Drive via rclone (kapoivha@gmail.com) |
| `$HOME/Gdrive_X/` | Pro/Academic Google Drive via rclone (ivann.kamdem-pouokam.2024@polytechnique.org) |
| `$HOME/go/` | Go workspace (GOPATH) |

### Centralized Scripts — `scripts/`

All workstation scripts are centralized in `scripts/` (this skill). Each is a standalone executable symlinked from `$HOME/.local/bin/` for PATH access.

| Path | Type | Purpose |
|------|------|---------|
| `scripts/ksh.sh` | shell | Universal Dispatcher — central entrypoint (see below) |
| `assets/cinema-mode.conf` | config | Centralized defaults for Gamescope cinema viewport geometry |
| `scripts/gamescope-cinema.sh` | shell | Scale-compensated Wayland Gamescope launcher (AZERTY synced) |
| `scripts/inject-cinema-actions.py` | python | Desktop Action Injector for "Launch in Cinema Mode" context menus |
| `scripts/tg-bot.py` | python | Telegram bot daemon — listens for `/clean`, `/status`, `/backup` |
| `assets/tg-bot.service` | systemd | User service for tg-bot.py (symlink target) |
| `scripts/clean/` | dir | System cleanup suite (17 scripts, systemd timer) |
| `scripts/backup_restore/` | dir | Workstation backup/restore (8 scripts, systemd timer) |
| `scripts/backup_restore_pve/` | dir | PVE backup/restore (rsync + cloud, systemd timer) |
| `scripts/CHANGELOG.md` | doc | Version history (current v2.1.4) |
| `scripts/TODO.md` | doc | Pending improvements (4 items) |

> **Migration note:** Sources moved from `$HOME/Work/sh/` into `.agents/`. `ksh.sh` is symlinked from `$HOME/.local/bin/ksh`.

### ksh — Universal Dispatcher

`ksh` is the central CLI entrypoint for all workstation modules. It delegates to `make` targets in each module directory.

**Install (once per machine):**
```bash
ln -sfn "$HOME/.agents/skills/k-ubuntu/scripts/ksh.sh" "$HOME/.local/bin/ksh"
chmod +x "$HOME/.agents/skills/k-ubuntu/scripts/ksh.sh"
```

**Usage:**
```bash
ksh -h                    # show full usage

# Clean module
ksh clean --safe -y       # safe cleanup, auto-confirm
ksh clean --purge         # deep purge
ksh clean-admin status    # systemd status
ksh clean-admin log       # last 50 journal lines
ksh clean-admin install   # symlink systemd + enable timer (sudo)
ksh clean-admin purge     # remove symlinks (sudo)

# Backup module
ksh backup --preview      # dry-run estimate
ksh backup                # full backup to default HDD
ksh backup-admin status   # systemd status
ksh backup-admin log      # last 50 journal lines
ksh backup-admin install  # symlink systemd + enable timer (sudo)
ksh backup-admin purge    # remove symlinks (sudo)

# Restore (bare-metal)
ksh restore <backup.tar.zst>

# Global audit
ksh status                # clean + backup + QMD health
```

### Clean — Automated System Cleanup

Modular cleanup suite with systemd timer (every 2 days at 21:30).

**Via ksh:**
```bash
ksh clean -s -y              # safe + auto-confirm
ksh clean -p --system        # deep purge + system (sudo)
ksh clean --help             # all flags
ksh clean-admin status       # systemd status
ksh clean-admin log          # journal output
ksh clean-admin install      # symlink units + enable timer (sudo)
ksh clean-admin purge        # remove symlinks (sudo)
```

**6 stages:** snap → cache → editors → work → docker → AI.

**Permissions:** scripts must be executable (`chmod +x *.sh` in each module dir) or services fail silently with `exit-code`/`203/EXEC`.

**Systemd units** in `.agents/skills/k-ubuntu/assets/clean/` (symlinked to `/etc/systemd/system/`): `clean-system.service` (root, oneshot) · `clean-system.timer` (every 2d @21:30, Persistent)

### Backup & Restore — Phoenix Protocol

Archives `$HOME` + `/etc` to external HDD via tar+zstd. Timer: every 2 days at 22:00.

**Via ksh:**
```bash
ksh backup --preview         # dry-run estimate
ksh backup                   # full backup
ksh backup-admin status/log  # systemd monitoring
ksh backup-admin install     # symlink units + enable timer (sudo)
ksh backup-admin purge       # remove symlinks (sudo)
ksh restore <archive>        # bare-metal restore
```

**Phases:** metadata export → size estimate → tar+zstd → keep 2.

**Systemd units** in `.agents/skills/k-ubuntu/assets/backup_restore/` (symlinked to `/etc/systemd/system/`): `backup-restore.service` (root, oneshot) · `backup-restore.timer` (every 2d @22:00, Persistent)

### PVE Backup — Phoenix Protocol

Pulls Proxmox backups from PVE via rsync, stores on HDD + Google Drive.  
Smart restore: auto-selects HDD or Cloud (newer archive wins).

**Via ksh:**
```bash
ksh backup-pve                  # full backup: rsync → HDD → Cloud
ksh restore-pve                 # restore (auto-select newest source)
ksh backup-pve-admin status/log # systemd monitoring
ksh backup-pve-admin install    # symlink units + enable timer (sudo)
ksh backup-pve-admin purge      # remove symlinks (sudo)
```

**Paths:** HDD `/media/kpihx/KpihX-Backup/Backups/PVE/` (keep 3) · Cloud `gdrive-x:Backups/PVE/` (keep 1)

**Systemd units** in `.agents/skills/k-ubuntu/assets/backup_restore_pve/`

### tg-bot — Telegram Listener

User systemd service. Polls Telegram, dispatches via ksh.

| Command | Action |
|---------|--------|
| `/clean` | Run cleanup (safe) |
| `/backup` | Preview backup |
| `/status` | Full audit |
| `/help` | Help |

**Secrets:** `TELEGRAM_UBUNTU_TOKEN` + `TELEGRAM_CHAT_ID` from `~/.agents/.env`.

**Service in:** `.agents/skills/k-ubuntu/assets/tg-bot.service` → symlink → `~/.config/systemd/user/tg-bot.service`.

**Install:** `make -C scripts install` or manual symlink. **Logs:** `journalctl --user -u tg-bot.service -f`

### Agent kernel

| Path | Role |
|------|------|
| `$HOME/.agents/` | Symlink → `$HOME/KpihX-Labs/.agents/` (git root for the global agent kernel) |

---

## System Services — Full Inventory (enabled, verified)

All services listed below are **active and running** (verified 2026-07-25). Source of truth is within `.agents/` with a symlink to the OS location. For custom services, the `Source (.agents/)` column shows the canonical file path; for KπX-managed configs, the symlink target is listed.

| Service | Role | Statut | Source (.agents/) | Symlink |
|---------|------|--------|-------------------|---------|
| `nftables.service` | Firewall | ✅ enabled + active | `k-nftables/assets/nftables.conf` (config) | ✅ `/etc/nftables.conf` |
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
| `tg-bot.service` | Telegram bot (clean/status/backup) | ✅ enabled + active | `k-ubuntu/assets/tg-bot.service` | ✅ `~/.config/systemd/user/tg-bot.service` |
| `opencode-web.service` | OpenCode Web server | ✅ enabled + active | `k-opencode/assets/opencode-web.service` | ✅ `~/.config/systemd/user/opencode-web.service` |
| `rclone-gdrive.service` | Gdrive (kapoivha@gmail.com → ~/Gdrive) | ✅ enabled + active | `k-rclone/assets/rclone-gdrive.service` | ✅ `~/.config/systemd/user/rclone-gdrive.service` |
| `rclone-gdrive-x.service` | Gdrive_X (X account → ~/Gdrive_X) | ✅ enabled + active | `k-rclone/assets/rclone-gdrive-x.service` | ✅ `~/.config/systemd/user/rclone-gdrive-x.service` |
| `rclone-deep-pc6.service` | Deep-PC6 (via k-dxo → ~/Deep-PC6) | ✅ enabled + active | `k-dxo/assets/rclone-deep-pc6.service` | ✅ `~/.config/systemd/user/rclone-deep-pc6.service` |
| | | | | |
| **Timers** (system) | | | | |
| `clean-system.timer` | Weekly system cleanup (21:30) | ✅ enabled + active | `k-ubuntu/assets/clean/clean-system.service` + `.timer` | ✅ `/etc/systemd/system/clean-system.*` |
| `backup-restore.timer` | Daily workstation backup (22:00) | ✅ enabled + active | `k-ubuntu/assets/backup_restore/backup-restore.service` + `.timer` | ✅ `/etc/systemd/system/backup-restore.*` |
| `pve-backup.timer` | PVE weekly backup (Sat 03:30) | ✅ enabled + active | `k-ubuntu/assets/backup_restore_pve/pve-backup.service` + `.timer` | ✅ `/etc/systemd/system/pve-backup.*` |
| | | | | |
| **Config symlinks** | | | | |
| `~/.kshrc` | Shell config (zsh) | ✅ valide | `k-ubuntu/assets/kshrc` | ✅ symlink |
| `~/.local/bin/ksh` | Universal dispatcher | ✅ valide | `k-ubuntu/scripts/ksh.sh` | ✅ symlink |
| `~/.config/rclone/rclone.conf` | rclone config (4 remotes) | ✅ valide | `k-rclone/assets/rclone.conf` | ✅ symlink |
| `~/.local/bin/rm` | Trash-safe rm wrapper | ✅ valide | `k-clis/assets/rm` | ✅ symlink |
| `openclaw-gateway.service` | OpenClaw Gateway runtime (user service) | ✅ enabled + active | `k-openclaw/assets/openclaw-gateway.service` + `assets/exec-override.conf` | ✅ `~/.config/systemd/user/openclaw-gateway.service` |

---

## Ollama (Intel Arc iGPU)

This workstation has Intel Core Ultra 7 155H with Arc Graphics iGPU. Ollama is tuned for this hardware.

### Hardware

| Component | Detail |
|-----------|--------|
| CPU | Intel Core Ultra 7 155H (6P + 8E + 2LP cores) |
| GPU | Arc Graphics iGPU — shared RAM, no discrete VRAM, max 2250 MHz |
| NPU | `/dev/accel/accel0` — available but not used by Ollama directly |
| RAM | 30 GiB total |

### Control Plane

Ollama backend orchestration: `$HOME/Work/AI/ollama/ipex/`

```bash
ollama-ipex start      # Switch to IPEX (Intel Arc GPU) backend
ollama-ipex native     # Switch to native (CPU) backend
ollama-ipex status     # Check current backend
ollama-ipex preload <model>
```

### Performance Tuning

| Variable | Value | Reason |
|----------|-------|--------|
| `OLLAMA_KEEP_ALIVE` | `10m` | Warm cache without pinning RAM |
| `OLLAMA_NUM_GPU` | `999` | Offload all layers to iGPU |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Avoid RAM split (shared VRAM) |
| `OLLAMA_FLASH_ATTENTION` | `1` | Faster attention for long contexts |
| `OMP_NUM_THREADS` | `6` | P-cores only for CPU fallback |
| `mem_limit` | `24g` | Headroom for desktop + editors on 30 GiB |

### Prerequisites

- User in `video` + `render` groups: `sudo usermod -aG video,render $USER`
- Native service management: `sudo systemctl stop ollama && sudo systemctl disable ollama` (stop before switching to IPEX)
- Single endpoint: both backends expose `http://127.0.0.1:11434`

Generic Ollama operations (install, model management, API): **`k-ollama`**

---

## Package Management

| Language | Toolchain | Install pattern |
|----------|-----------|-----------------|
| Python | `uv` (`$HOME/.local/bin/uv`) | CLIs: `uv tool install --editable .` · Scripts: `uv run --with` |
| JS/TS (owned projects / MCP servers) | **Bun** when runtime-compatible | `bun add/run/build/test/publish` · `bun link / bun install -g` |
| JS tools (3rd party) | npm-global (`$HOME/.npm-global/`) | `npm install -g` for daily-driver CLIs |
| Node.js | fnm v24.18.0 | via `fnm install 24` — dynamic multishell, `--use-on-cd` |

**Never:** `pip install` globally · `npm install -g <local-path>` · hatchling/poetry/setuptools

npm global prefix: `$HOME/.npmrc → prefix=$HOME/.npm-global` (no EACCES, no sudo needed).

### System CLIs installed on this machine

**npm-global:**
| CLI | Install | Purpose |
|-----|---------|---------|
| `fd` | `npm i -g fd-find` | Telescope file-search backend |

**uv tool:**
| CLI | Install | Purpose |
|-----|---------|---------|
| `asciinema` | `uv tool install asciinema` | Terminal session recorder |

**Speech-to-text (whisper-ctranslate2):**
- Installed CLI: `whisper-ctranslate2` (0.5.7)
- Intel Arc note: exposes `cpu`/`cuda`; no Arc backend flag yet — use optimized CPU settings
- Default model: `distil-large-v3` with `--device cpu --compute_type int8 --vad_filter true`

Full CLI registry with routing to dedicated k-* skills: **`k-clis`**

### WaveTerm widgets

Config: `$HOME/.config/waveterm/widgets.json` — all widgets load their own environment.

### npm-global prefix

`$HOME/.npmrc` → `prefix=$HOME/.npm-global` — no EACCES, no sudo needed for global installs.

---

## MCP Ecosystem (on this workstation)

> **Source of truth — do not hardcode lists here:**
> - Source code: `$HOME/Work/AI/MCPs/`
> - HTTP endpoints: `<name>.kpihx-labs.com/mcp`
> - Installed stdio binaries: `uv tool list` · `npm list -g` · `bun pm ls -g`
> - Agent configs: read config files directly

**Ownership rule:** JS/TS MCP servers you own → use Bun when verified; Python MCPs → uv; npm-global → third-party daily-driver CLIs only.



---

## User Services (systemd — user level)

### tg-bot — Telegram Ubuntu Bot

Listens for Telegram commands and dispatches them via `ksh`.

| Command | Action |
|---------|--------|
| `/clean [flags]` | Run cleaner (safe mode default) |
| `/backup` | Preview backup |
| `/status` | Global system audit |
| `/help` | List commands |

**Setup (symlink from `.agents`):**
```bash
systemctl --user stop tg-ubuntu.service    # stop old if exists
rm -f ~/.config/systemd/user/tg-ubuntu.service
ln -sf ~/.agents/skills/k-ubuntu/assets/tg-bot.service ~/.config/systemd/user/tg-bot.service
systemctl --user daemon-reload
systemctl --user enable --now tg-bot.service
```

**Source of truth:** `k-ubuntu/scripts/tg-bot.py` + `k-ubuntu/assets/tg-bot.service` in `.agents/`.

**Purge:**
```bash
systemctl --user stop tg-bot.service
systemctl --user disable tg-bot.service
rm -f ~/.config/systemd/user/tg-bot.service
systemctl --user daemon-reload
```

**Secrets:** sourced from `~/.agents/.env` — needs `TELEGRAM_UBUNTU_TOKEN` + `TELEGRAM_CHAT_ID`.

**Logs:** `journalctl --user -u tg-bot.service -f`

---

## Remote Work — DxO VPN + RDP

> **DxO VPN:** see **`k-dxo`** skill — VPN, RDP, accounts, and remote access setup.

### DxO VPN + RDP

See **`k-dxo`** skill for full setup: VPN (GlobalProtect via openconnect), RDP via Remmina, accounts, and Windows procedure.

### RDP (Remmina → BLGLAPTOP139 / deep-pc6)

| Field | Value |
|-------|-------|
| Server (BLGLAPTOP139) | `BLGLAPTOP139.corp.dxo.com` |
| Server (Deep PC6) | `deep-pc6.corp.dxo.com` |
| Username | `ikamdem` (no domain) |
| Domain | `corp.dxo.com` |

**Profile file:** `~/.local/share/remmina/group_rdp_dxo_blglaptop139-corp-dxo-com.remmina`

**Audio:** `sound=local` + `microphone=local`

**Multi-monitor:** Edit → Advanced → "Span screen over multiple monitors" + Resolution "Use client resolution"

---

## Display — ASUS VE228 Stretch Fix

The ASUS VE228 monitor's internal scaler stretches non-standard resolutions vertically. The software-native solution is the **Tiling Shell** GNOME extension (installable via Extension Manager GUI). It creates a custom 1920x880 snap zone, leaving 200px black at the bottom when combined with `xwayland-native-scaling` and a solid black wallpaper.

→ **Full engineering journey:** [`techskills/ubuntu-asus-ve228-stretch-fix.md`](https://github.com/kpihx/techskills/blob/master/ubuntu-asus-ve228-stretch-fix.md) — Paths A–G, Gamescope detour, final resolution.
→ **Issues:** [`k-context/references/issues.md#ISS-20260727-001`](../k-context/references/issues.md)

## Bundled references

| File / Script | Content |
|---------------|---------|
| `references/insights.md` | Durable lessons, mistakes, validated fixes |
| `references/log.md` | Operation log — significant system changes (pip purges, tool migrations, apt removals) |
| `scripts/notifier.sh` | Telegram notification wrapper — uses TELEGRAM_PVE_TOKEN from .env |
| `scripts/tg-bot.py` | Telegram bot bridge script |
| `scripts/backup_restore` | Backup/restore automation script |
| `scripts/clean` | System cleanup script |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-ubuntu/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-ubuntu/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-27 | [OPENCODE] | v1.9.0 — **Cinema Mode (Gamescope) Integration**: Added scale-compensated launcher wrapper `gamescope-cinema.sh` with AZERTY layout sync, `cinema-mode.conf` config, and `inject-cinema-actions.py` crawler. |
| 2026-07-26 | [OPENCODE] | v1.8.0 — **with-env helper added**: Added the `with-env` function and Zsh autocompletion to `assets/kshrc` for secure command execution with isolated `.env` loading. |
| [SUMMARY] | — | v1.5.0–v1.7.0 clean docs + secrets + kshrc symlink + idempotency guard; v1.4.0 backup_restore; v1.3.0 scripts/ centralization; v1.2.0 shell → k-zsh; v1.1.0 Tailscale/Ollama/WaveTerm |
