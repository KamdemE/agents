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
  version: "1.20.0"
  scope: workstation
allowed-tools: Bash, Read, Write, Edit
---

# KpihX-Ubuntu — Workstation

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-infras` (master infrastructure map + setup checklist) · `k-zsh` (shell setup — .kshrc, .zshrc) · `k-ssh` (SSH config — canonical fragment, keys) · `k-nftables` (firewall — sub-skill) · `k-tailscale` (mesh VPN operations) · `k-optim` (Ubuntu optimization) · `k-docker` (generic container patterns) · `k-cloudflare` (flarectl DNS/API) · `k-bw` (bw-proxy) · `k-openclaw` (gateway service) · `k-rclone` (FUSE mounts) · `k-tmux` (shared interactive gate) · `kpihx-labs` (kernel top reference)
> **SSH config source of truth:** `$HOME/.ssh/config`
> **Tailscale live state:** `tailscale status --json`

> **MANDATORY — read `k-infras` → New Infra Setup Checklist FIRST** to understand the setup rule: everything lives in `.agents/` (single source of truth); `$HOME`/`/root` items are symlinks (`ln -sf`). Each infra has its own `assets/kshrc` (copied from `k-zsh/assets/kshrc.base` and customized).
> For `kpihx-ubuntu`, `k-ubuntu/assets/kshrc` is the source of truth for `~/.kshrc`.
>
> **Directory standard (1st op):** if absent, create `~/KpihX-Labs`; clone `git@github.com:KpihX/agents.git` → `~/KpihX-Labs/.agents`; create `~/.agents` as a **symlink** → `~/KpihX-Labs/.agents`. See `k-infras` → New Infra Setup Checklist → Step 0.

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

Ubuntu workstation firewall is managed via `k-nftables`. The canonical ruleset resides at `k-nftables/assets/nftables.conf`, is symlinked to `/etc/nftables.conf`, and is currently scoped in `links.jsonc` to `kpihx-ubuntu` + `kpihx-pve-debian` only.

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
| `scripts/clean/` | dir | System cleanup suite (17 scripts, systemd timer) |
| `scripts/backup_restore/` | dir | Workstation backup/restore (8 scripts, systemd timer) |
| `scripts/backup_restore_pve/` | dir | PVE backup/restore (rsync + cloud, systemd timer) |
| `scripts/CHANGELOG.md` | doc | Version history (current v2.1.4) |
| `scripts/TODO.md` | doc | Pending improvements (4 items) |

> **Migration note:** Sources moved from `$HOME/Work/sh/` into `.agents/`. `ksh.sh` is symlinked from `$HOME/.local/bin/ksh`.

Full `ksh` dispatcher usage and Clean/Backup/PVE-backup module commands → **`references/scripts-modules.md`**.

> **🔴 RULE — Scripts executed by systemd services that need `$HOME` resources (GRAVÉ):** system-level services do NOT export `$HOME` reliably — and units with an explicit `User=root` directive get `$HOME=/root` **preset by systemd**, so any bare `source "$HOME/.agents/..."` or path through `$HOME` silently misses the kernel (`/root/.agents` does not exist) or aborts under `set -u`. A `${HOME:-/home/kpihx}` fallback is NOT sufficient under `User=root` (the preset value is non-empty). **Every script that can be launched by a service must start with:**
>
> ```bash
> export HOME="${HOME:-/home/kpihx}"
> [ -d "$HOME/.agents" ] || export HOME="/home/kpihx"
> ```
>
> placed BEFORE any `source "$HOME/.agents/..."`. This is the validated pattern from `scripts/backup_restore_pve/backup_pve.sh` (2026-08-23 incident: `clean.service` ran fine but its Telegram notification was silently skipped for months because `/root/.agents/libs/notif/notifier.sh` did not exist; fixed in `auto_clean.sh` + `restore_pve.sh`, E2E delivery verified on @k_ubuntu_bot the same night). Note: `pve-backup.service` only ever worked because it has NO `User=` line — systemd then leaves `$HOME` unset, so its fallback fires. Secrets need no unit-level `EnvironmentFile`: `libs/notif/notifier.sh` self-loads `$HOME/.agents/.env` via `libs/env/env_lib.sh` (`env_load`) once `$HOME` is correct. Prefer loud ERROR logging over silent best-effort skips in service-run notification tails.

### Agent kernel

| Path | Role |
|------|------|
| `$HOME/.agents/` | Symlink → `$HOME/KpihX-Labs/.agents/` (git root for the global agent kernel) |

### MIME Type Associations

To ensure uniform file associations and avoid the priority hijacking by Nautilus for local file schemes, the user-level MIME type database is centralized:
- `$HOME/.config/mimeapps.list` → **symlink** to `assets/mimeapps.list` (this skill).
- Cleaned from legacy, missing applications (Slack, Brave, VLC, Rhythmbox, OnlyOffice, old Thunderbird) and linked to local system apps (`nvim.desktop`, `mpv.desktop`, `com.microsoft.Edge.desktop`, `libreoffice`).
- Removed `x-scheme-handler/file` to restore correct fallback behavior.

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

**Purge Obligation**: When performing a purge or uninstallation, you MUST exhaustively clean all debris across the system (configs/data in `~`, `~/.local/`, `~/.config/`, `~/.local/share/`, `~/.cache/`, snap packages/cache, system/user systemd units, `/opt/` files, and env vars). No leftovers are tolerated.

Machine-installed system CLIs (fd, asciinema, k-whisper / k-piper via k-ai), WaveTerm widgets config, and npm-global prefix detail → **`references/package-management.md`**. Full CLI registry with routing to dedicated k-* skills: **`k-clis`**.

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
| `references/scripts-modules.md` | `ksh` dispatcher usage, Clean/Backup/PVE-backup modules |
| `references/dell-battery-health.md` | Dell CCTK installation, battery charging threshold enforcement, and QWERTY/AZERTY trap |
| `references/apps.md` | Complete registry of all Ubuntu desktop applications (system `.desktop`, user `.desktop`, `/opt` heavy clients, GUI snaps, recently purged) |
| `references/gnome-extensions.md` | GNOME Shell extensions catalog, roles, and uv tool-based installation automation |
| `assets/command-configure_5.1.0-6.ubuntu24_amd64.tar.gz` | Preserved Dell Command Configure installer used by the battery-health runbook |
| `assets/mimeapps.list` | Centralized desktop file MIME type associations (symlinked to `~/.config/mimeapps.list`) |
| `scripts/notifier.sh` | Telegram notification wrapper — uses TELEGRAM_PVE_TOKEN from .env |
| `scripts/backup_restore` | Backup/restore automation script |
| `scripts/clean` | System cleanup script |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-ubuntu/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-ubuntu/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [CLAUDE] | v1.20.0 — Persistent SSH agent (gpg-agent ssh-emulation, socket-activated) added to `assets/kshrc` Section 1. See `k-zsh` v2.5.0 for the mechanism; mirrored here per the SYNC RULE. |
| 2026-08-24 | [COLAB] | v1.19.0 — **clean.timer rescheduled (KπX order)**: `assets/clean/clean.timer` changed from `OnCalendar=*-*-1/2 21:30:00` (odd days) to `OnCalendar=Sat *-*-* 04:00:00` (every Saturday at 04:00); `Persistent=true` kept (catch-up on boot if the PC was off/asleep at trigger time). Applied live via tmux sudo gate (`daemon-reload` + `restart clean.timer`) — verified: `list-timers` shows NEXT Sat 2026-08-29 04:00:00. Docs aligned: `references/system-services.md` row, `references/scripts-modules.md` ×2, `scripts/clean/README.md`. |
| [SUMMARY] | — | v1.18.0 root-run `$HOME` rule + clean notification fix · v1.17.0 clean-system rename (→ `references/log.md`) · v1.16.0 apps.md config-debris (→ `references/log.md`) · v1.15.0 and older in log.md |
