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
  version: "1.2.0"
  scope: workstation
allowed-tools: Bash, Read, Write, Edit
---

# KpihX-Ubuntu — Workstation

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-infras` (master infrastructure map) · `k-nftables` (firewall — sub-skill) · `k-tailscale` (mesh VPN operations) · `k-optim` (Ubuntu optimization) · `k-docker` (generic container patterns) · `k-cloudflare` (flarectl DNS/API) · `k-bw` (bw-env secret injection) · `k-openclaw` (gateway service) · `k-rclone` (FUSE mounts) · `k-tmux` (shared interactive gate) · `kpihx-labs` (kernel top reference)
> **SSH config source of truth:** `$HOME/.ssh/config`
> **Tailscale live state:** `tailscale status --json`

---

## Host Identity

| Property | Value |
|----------|-------|
| Hostname | `KpihX-Ubuntu` |
| Tailscale | `kpihx-ubuntu` (`100.82.95.70`) |
| OS | Ubuntu 26.04 LTS (Resolute Raccoon) |
| Kernel | Linux 7.0.0-28-generic x86_64 |
| CPU | Intel Core Ultra 7 155H |
| RAM | 30 GiB |
| Disk | KIOXIA 1024GB (nvme0n1) — see `k-infra` for partitioning |

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

Hardware details (disk layout, BIOS/UEFI, dual-boot): **`k-infra`**

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
- Shell files live at `$HOME/.kshrc`, `$HOME/.zshrc`, `$HOME/.zprofile`, `$HOME/.zshenv`, `$HOME/.bashrc`
- `$EDITOR` is set to `micro` (see `.kshrc` line 39)
- bw-env idempotency guard: `BW_ENV_LOADED=$$` (PID-scoped — child processes always reload secrets)
- Ollama backend orchestration lives in `$HOME/Work/AI/ollama/ipex`, not in `$HOME/Work/sh/`

**Critical shell — shared tmux (replaces `sui`)**
- `sui` is deprecated. For `sudo`, SSH passphrase, or any interactive approval → `rules/tool-discipline.md` · `k-tmux/SKILL.md` → Shared interactive gate.
- If `git push` hits `Permission denied` on `.git/refs/remotes/*.lock`, fix via shared tmux: `chown -R $USER:$USER` on affected `$HOME/Work/sh/<module>/.git` trees.

---

## Directory Layout

### $HOME/Work/ — Dev & Prod

| Path | Purpose |
|------|---------|
| `$HOME/Work/AI/MCPs/` | All MCP servers source code |
| `$HOME/Work/AI/gemini_mcps/` | Gemini Extension wrappers |
| `$HOME/Work/sh/bw_env/` | Bitwarden env manager — secrets in RAM via /dev/shm |
| `$HOME/Work/sh/` | Universal Orchestrator (Phoenix Protocol v2.1.3) |
| `$HOME/Work/sh/clean/` | System Cleanup (systemd, every 2 days starting Sun at 21:30) |
| `$HOME/Work/sh/backup_restore/` | Workstation Backup (systemd, every 2 days starting Sun at 22:00) |
| `$HOME/Work/Homelab/` | Infrastructure (Traefik, Vaultwarden, Portainer, Ollama) — remote access |
| `$HOME/Work/techskills/` | Ubuntu living KB — real fixes documented as they happen |
| `$HOME/Work/Others/` | Miscellaneous / Non-project files / Transit zone |
| `$HOME/Gdrive/` | Personal Google Drive via rclone (kapoivha@gmail.com) |
| `$HOME/Gdrive_X/` | Pro/Academic Google Drive via rclone (ivann.kamdem-pouokam.2024@polytechnique.org) |
| `$HOME/go/` | Go workspace (GOPATH) |

### Agent kernel

| Path | Role |
|------|------|
| `$HOME/.agents/` | Symlink → `$HOME/KpihX-Labs/.agents/` (git root for the global agent kernel) |

---

## System Services (enabled at boot)

Key services managed on this workstation. For full list: `systemctl list-unit-files --state=enabled`.

| Service | Role | Notes |
|---------|------|-------|
| `tor@default.service` | Anonymizing overlay network (SOCKS5 proxy on 127.0.0.1:9050) | ~112 MB RAM. Disable if not actively using Tor. |
| `docker.service` | Container runtime | Core infra |
| `tailscaled.service` | Tailscale mesh VPN | Persistent connectivity to homelab and peers |
| `rclone-gdrive.service` | Google Drive FUSE mount (kapoivha@gmail.com) | `~/Gdrive` mount point |
| `rclone-gdrive-x.service` | Google Drive FUSE mount (Poly X account) | `~/Gdrive_X` mount point |
| `nftables.service` | Firewall | Managed via `k-nftables` |
| `ssh.service` | SSH daemon | Local SSH access |
| `NetworkManager.service` | Network management | Default Ubuntu |
| `systemd-resolved.service` | DNS resolver | Default Ubuntu |
| `snapd.service` | Snap package daemon | Pre-installed |

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
| Node.js | nvm v22.22.1 | Per-project versions only |

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

Config: `$HOME/.config/waveterm/widgets.json` — all widgets use `zsh -l -c '...'` wrapper to load the login environment.

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

Secrets wrap pattern for MCPs needing bw-env: `{ "command": "zsh", "args": ["-l", "-c", "<binary> serve"] }`

---

## Remote Work — DxO VPN + RDP

> **Asset:** `assets/vpn-dxo` — symlinked to `$HOME/Work/sh/vpn-dxo` (in PATH)

### VPN (GlobalProtect via OpenConnect)

| Command | Effect |
|---------|--------|
| `vpn-dxo` | Launch VPN in tmux session `vpn-dxo` + attach (enter sudo password) |
| `vpn-dxo` (if already running) | Re-attach to session |
| `vpn-dxo status` | Check if VPN is running |
| `vpn-dxo stop` | Kill the tmux session |

**Connection:** WebKit popup → Microsoft auth (email + MFA). Tunnel stays active in background.

**Params:** `--ignore-tls-errors --fix-openssl` (self-signed DxO cert + OpenSSL 3+ legacy renegotiation)

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

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-ubuntu/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-ubuntu/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.2.0 — Shell section trimmed: .kshrc hub pattern moved to k-zsh. Reference to k-zsh. |
| 2026-07-22 | [OPENCODE] | v1.1.0 — Tailscale identity, Ollama Intel Arc HW, WaveTerm + npm prefix from k-workspace. |
| [SUMMARY] | — | — |
