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
  version: "1.11.0"
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
| `$HOME/Work/techskills/` | Ubuntu living KB — real fixes documented as they happen |
| `$HOME/Work/Others/` | Miscellaneous / Non-project files / Transit zone |
| `$HOME/Gdrive/` | Personal Google Drive via rclone (kapoivha@gmail.com) |
| `$HOME/Gdrive_X/` | Pro/Academic Google Drive via rclone (ivann.kamdem-pouokam.2024@polytechnique.org) |
| `$HOME/go/` | Go workspace (GOPATH) |

### Centralized Scripts — `scripts/`

All workstation scripts are centralized in `scripts/` (this skill). Each is a standalone executable symlinked from `$HOME/.local/bin/` for PATH access.

| Path | Type | Purpose |
|------|------|---------|
| `scripts/ksh.sh` | shell | Universal Dispatcher — central entrypoint |
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

Full `ksh` dispatcher usage, Clean/Backup/PVE-backup module commands, and the tg-bot Telegram listener setup/purge → **`references/scripts-modules.md`**.

### Agent kernel

| Path | Role |
|------|------|
| `$HOME/.agents/` | Symlink → `$HOME/KpihX-Labs/.agents/` (git root for the global agent kernel) |

---

## System Services

Full inventory of all active system/user services, timers, and config symlinks (18+ entries, verified) → **`references/system-services.md`**.

---

## Ollama (Intel Arc iGPU)

This workstation has Intel Core Ultra 7 155H with Arc Graphics iGPU. Ollama is tuned for this hardware (IPEX vs native backend control plane, performance tuning env vars, group prerequisites) → **`references/ollama-igpu.md`**. Generic Ollama operations (install, model management, API): **`k-ollama`**.

---

## Package Management

| Language | Toolchain | Install pattern |
|----------|-----------|-----------------|
| Python | `uv` (`$HOME/.local/bin/uv`) | CLIs: `uv tool install --editable .` · Scripts: `uv run --with` |
| JS/TS (owned projects / MCP servers) | **Bun** when runtime-compatible | `bun add/run/build/test/publish` · `bun link / bun install -g` |
| JS tools (3rd party) | npm-global (`$HOME/.npm-global/`) | `npm install -g` for daily-driver CLIs |
| Node.js | fnm v24.18.0 | via `fnm install 24` — dynamic multishell, `--use-on-cd` |

**Never:** `pip install` globally · `npm install -g <local-path>` · hatchling/poetry/setuptools

Machine-installed system CLIs (fd, asciinema, whisper-ctranslate2), WaveTerm widgets config, and npm-global prefix detail → **`references/package-management.md`**. Full CLI registry with routing to dedicated k-* skills: **`k-clis`**.

---

## MCP Ecosystem (on this workstation)

> **Source of truth — do not hardcode lists here:**
> - Source code: `$HOME/Work/AI/MCPs/`
> - HTTP endpoints: `<name>.kpihx-labs.com/mcp`
> - Installed stdio binaries: `uv tool list` · `npm list -g` · `bun pm ls -g`
> - Agent configs: read config files directly

**Ownership rule:** JS/TS MCP servers you own → use Bun when verified; Python MCPs → uv; npm-global → third-party daily-driver CLIs only.

---

## Remote Work — DxO VPN + RDP

> **DxO VPN:** see **`k-dxo`** skill for full setup — VPN (GlobalProtect via openconnect), RDP via Remmina, accounts, and Windows procedure.

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

## Battery Health / Dell Charging Thresholds

On Dell laptops (like the 7640), standard Linux ACPI tools and WMI sysfs are often hardware-locked. The GNOME GUI toggle for battery health will silently revert to "Maximize charge" upon reboot/unplug.

To correctly enforce a persistent battery charge limit (e.g., 75-80%), you must bypass the standard tools and use the permanently preserved Dell CCTK installer from this skill's assets.

→ **Full resolution runbook:** [`references/dell-battery-health.md`](references/dell-battery-health.md) (covers CCTK installation, BIOS password AZERTY/QWERTY trap, and execution).

---

## Bundled references

| File / Script | Content |
|---------------|---------|
| `references/insights.md` | Durable lessons, mistakes, validated fixes |
| `references/log.md` | Operation log — significant system changes (pip purges, tool migrations, apt removals) |
| `references/system-services.md` | Full systemd services/timers/symlinks inventory |
| `references/ollama-igpu.md` | Ollama Intel Arc iGPU tuning: IPEX/native backend, env vars, prerequisites |
| `references/package-management.md` | System CLIs, WaveTerm widgets, npm-global detail |
| `references/scripts-modules.md` | `ksh` dispatcher usage, Clean/Backup/PVE-backup modules, tg-bot listener setup |
| `references/dell-battery-health.md` | Dell CCTK installation, battery charging threshold enforcement, and QWERTY/AZERTY trap |
| `assets/command-configure_5.1.0-6.ubuntu24_amd64.tar.gz` | Preserved Dell Command Configure installer used by the battery-health runbook |
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
| 2026-08-09 | [COLAB] | v1.11.0 — **SKILL.md size reduction (300-line rule)**: Extracted System Services inventory, Ollama iGPU tuning, Package Management CLI details, and the ksh/Clean/Backup/PVE-backup/tg-bot module docs into 4 new `references/*.md` files. **Fixed a pre-existing duplication**: the "tg-bot — Telegram Listener" section was documented twice (once under Directory Layout, once under a separate "User Services" heading) — consolidated into a single copy in `references/scripts-modules.md`, no information lost (both versions were textually identical). |
| 2026-08-03 | [OPENCODE] | v1.10.0 — **Dell Battery Charging Limits**: Documented hard BIOS/sysfs lock on Dell 7640, deprecation of `libsmbios-bin` on Ubuntu 26.04, required use of CCTK, and the critical QWERTY/AZERTY BIOS terminal password trap for setting thresholds. |
| [SUMMARY] | — | Older changelog entries were copied to `references/log.md`; the live table keeps only the two newest entries. |
