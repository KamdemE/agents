---
name: k-25
description: >
  KπX Android phones over Tailscale — SSH (Termux sshd) and ADB (wireless debugging).
  Inventory: kpihx-s25 (active), kpihx-tablet (listed, not configured). Load before phone SSH/ADB work.
license: private
metadata:
  author: KpihX
  version: "2.0.0"
  scope: device-access
allowed-tools: Bash(ssh:*), Bash(adb:*), Read, Write, Edit
---

# KπX — Phones

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related:** `k-infras` (master infrastructure map + setup checklist) · `k-zsh` (shell setup) · `k-ssh` (SSH config — canonical fragment, keys, Include) · `k-tmux` (tmux config — canonical config to symlink) · `k-clis` (Tailscale) · `k-tg` (wireless-debug screenshot)

## Inventory (Tailscale)

| Host | Short name | MagicDNS | Tailscale IP | SSH | ADB | Notes |
|------|-----------|----------|--------------|-----|-----|-------|
| **kpihx-s25** | `s25` | `kpihx-s25.tail2527bd.ts.net` | `100.125.54.1` | ✅ Termux `:8022` | ✅ Wireless debug on TS IP | **Default focus** · hardware → `references/s25-hardware.md` |
| **kpihx-tablet** | — | `kpihx-tablet.tail2527bd.ts.net` | `100.89.79.87` | 🚧 TBD | 🚧 TBD | Node exists; no Termux/ADB runbook yet |

## When to Load

- SSH or ADB to **S25** (or future tablet setup)
- Fixing phone remote access, keys, ports, Termux `sshd`
- Agents need phone context after a capture-bot screenshot
- **S25 specs, compute limits, inference routing** → read `references/s25-hardware.md` first
- **Screen mirroring/control** → `scrcpy` (snap, v3.3.4) via ADB

## Quick commands (workstation)

| Goal | Command |
|------|---------|
| **SSH shell (PC → phone)** | `ssh s25` |
| **SSH + PC tmux (phone → PC)** | Termux: `ubuntu` — **`tmux attach -t default`** on PC — `references/phone-to-ubuntu.md` |
| **Termux local tmux** | `pkg install tmux termux-api` then read **`k-tmux`** for config |
| **ADB pair** | `adb-s25-pair PAIRING_PORT` — port from *Pair device with pairing code* dialog only |
| **ADB connect** | `adb-s25 DEBUG_PORT` — port from main *IP address & port* (≠ pairing port) |
| **ADB reconnect** | `adb-s25` — uses last saved debug port |
| **ADB status** | `adb-s25 status` |
| **Screen mirror** | `scrcpy -s 100.125.54.1:<DEBUG_PORT>` (or just `scrcpy` if one ADB device) |
| **Termux:Boot install** | `zsh $HOME/.agents/skills/k-25/scripts/termux-install-boot.sh` (needs `adb` device) |
| **Install PVE Finder** | `ln -sf ~/.agents/skills/k-25/scripts/pve_finder.sh $PREFIX/bin/pve_finder` |

CLI symlinks (one-time setup):
```bash
ln -sf ~/.agents/skills/k-25/scripts/adb-s25 ~/.local/bin/adb-s25
ln -sf ~/.agents/skills/k-25/scripts/adb-s25-pair ~/.local/bin/adb-s25-pair
```
`~/.local/bin/` is in PATH via `~/.kshrc` — commands available immediately.

## S25 Setup (simplified)

Done once, directly on the phone (from any SSH pane, e.g. `ubuntu:0.2` on the S25).

### Prerequisites — `~/.agents` cloned and up to date

```bash
test -d ~/.agents || git clone git@github.com:KpihX/agents.git ~/.agents
cd ~/.agents && git pull github master
```

### 1. Shell — 6 symlinks from .agents

```bash
# 5 shared files from k-zsh/assets/
ln -sf ~/.agents/skills/k-zsh/assets/zshrc    ~/.zshrc
ln -sf ~/.agents/skills/k-zsh/assets/zshenv   ~/.zshenv
ln -sf ~/.agents/skills/k-zsh/assets/zprofile ~/.zprofile
ln -sf ~/.agents/skills/k-zsh/assets/bashrc   ~/.bashrc
ln -sf ~/.agents/skills/k-zsh/assets/profile  ~/.profile

# kshrc from k-25 assets (infra-specific: s25 tmux + sshd autostart)
ln -sf ~/.agents/skills/k-25/assets/kshrc ~/.kshrc
```

The `kshrc` sources `assets/k25-remote.sh` directly, which auto-starts `sshd` on every Termux shell.

### 2. SSH — Include k-ssh canonical config

```bash
echo "Include ~/.agents/skills/k-ssh/assets/ssh.conf" > ~/.ssh/config
```

All Host blocks (s25, ubuntu, pve, etc.) come from the central `k-ssh/assets/ssh.conf` — no duplication.

### 3. Tmux — install + follow k-tmux

```bash
pkg install tmux termux-api
```

Then load **`k-tmux`** skill and follow its setup: symlink the canonical config, install TPM, install plugins (resurrect, continuum, yank, copycat). The config alone is not enough — the plugins are required for the full experience (session save/restore, clipboard, search).

```bash
ln -sf ~/.agents/skills/k-tmux/assets/tmux.conf ~/.tmux.conf
# Then follow k-tmux → Plugin install section for TPM + plugins
```

### 4. Termux:Boot — sshd at boot

See Termux:Boot section below (requires ADB from workstation or F-Droid).

## Reference docs

| # | File | Scope |
|---|------|--------|
| 1 | `SKILL.md` (this file) | Inventory, quick commands, setup, layout |
| 2 | `references/s25-hardware.md` | S25 SoC, RAM, GPU, Termux stack, compute / inference limits |
| 3 | `references/phone-to-ubuntu.md` | Phone → PC SSH, where tmux runs, security |
| 4 | `references/s25-termux-sshd.md` | Termux sshd persistence details |
| 5 | `references/s25-adb-wireless.md` | Two-port ADB, Tailscale, eduroam |
| 6 | `references/s25-adb-vs-ssh.md` | Termux vs ADB capabilities |
| 7 | `references/termux-tmux.md` | Termux local tmux notes (see k-tmux for canonical config) |


## Termux:Boot (`assets/termux-boot.apk`)

**Role:** Starts `sshd` automatically when the phone boots — otherwise you need to open Termux and tap after every reboot.

Two-step install on S25 (once per phone boot cycle):

1. **Install APK** (via ADB from workstation):
   ```bash
   adb install -r ~/.agents/skills/k-25/assets/termux-boot.apk
   ```
   If `INSTALL_FAILED_VERIFICATION_FAILURE`, run first:
   ```bash
   adb shell settings put global verifier_verify_adb_installs 0
   ```

2. **Place boot script** (runs `sshd` at boot):
   ```bash
   mkdir -p ~/.termux/boot/
   cp ~/.agents/skills/k-25/assets/termux-boot-sshd ~/.termux/boot/sshd
   chmod +x ~/.termux/boot/sshd
   ```

3. **Open Termux:Boot** once after install (Android requires manual launch to grant permissions).

## PVE Finder (`pve_finder`)

**Purpose:** Locate the Proxmox homelab server when its IP changes on eduroam.
**Source:** `scripts/pve_finder.sh`

Install on S25 (one-time):
```bash
ln -sf ~/.agents/skills/k-25/scripts/pve_finder.sh $PREFIX/bin/pve_finder
```

Requires `TELEGRAM_S25_TOKEN` and `CHAT_ID` in `~/.agents/.env` for Telegram alerts. Runs standalone: `pve_finder`.

## Tmux

| Command (Termux) | tmux on | Session |
|------------------|---------|---------|
| `tmux` | **S25 Termux** | local |

For general tmux config, canonical keybindings, and plugin setup → load **`k-tmux`** skill. The canonical `assets/tmux.conf` in `k-tmux` works on Termux (symlink it).

## SSH (S25)

- **Config:** `Include ~/.agents/skills/k-ssh/assets/ssh.conf` in `~/.ssh/config` — all Host blocks centralized in `k-ssh`.
- **Key:** `~/.ssh/id_ed25519_s25` → Termux `~/.ssh/authorized_keys`.
- **User:** `u0_a417` (fixed by Android — cannot become `kpihx`; use alias `s25` + optional Termux `PS1`) · **Port:** `8022`.
- **Termux `sshd`:** must be running on the phone — persistence: `assets/k25-remote.sh` (sourced via `kshrc`) + `assets/termux-boot-sshd` (boot).
- **OpenSSH on PC only reads** `$HOME/.ssh/config` (+ Include fragments). Skill references are runbooks, not loaded by `ssh`.

## ADB (S25)

Full runbook: `references/s25-adb-wireless.md`.

- **Two ports:** *Pair device with pairing code* → `adb-s25-pair PAIRING_PORT` · main screen → `adb-s25 DEBUG_PORT`. **Never** `adb pair` on the debug port (`protocol fault`).
- **Paired devices** lists hosts already paired (`kpihx@KpihX-Ubuntu`) — still re-pair if connect fails after eduroam/Tailscale changes.
- **Eduroam:** campus Wi‑Fi isolates clients; Tailscale IP can work after correct pair, else **phone hotspot** + Wi‑Fi IP on screen.
- **CLI helpers (symlinks → `~/.local/bin/`):** `adb-s25` · `adb-s25-pair`.
- **ADB vs SSH:** `adb shell` ≠ Termux — full app/Linux work via **`ssh s25`**; ADB scope: `references/s25-adb-vs-ssh.md`.

## Layout

| Path | Role |
|------|------|
| `scripts/adb-s25` | Connect ADB to wireless-debug **debug port** |
| `scripts/adb-s25-pair` | `adb pair` on **pairing port** only |
| `scripts/pve_finder.sh` | PVE server IP discovery (scans subnets via SSH fingerprint) |
| `scripts/termux-install-boot.sh` | Install Termux:Boot (ADB or SSH) |
| `assets/kshrc` | **S25 `~/.kshrc`** source of truth — symlink target |
| `assets/k25-remote.sh` | sshd autostart for Termux — sourced directly from `kshrc` |
| `assets/termux-boot.apk` | Termux:Boot APK (F-Droid, 26K) — install via `adb install` |
| `assets/termux-boot-sshd` | Termux:Boot script → `~/.termux/boot/sshd` |
| `references/s25-adb-wireless.md` | Two-port ADB, Tailscale, eduroam |
| `references/phone-to-ubuntu.md` | Phone → PC SSH, PC tmux, security |
| `references/s25-adb-vs-ssh.md` | Termux username, ADB vs SSH capabilities |
| `references/s25-termux-sshd.md` | Termux sshd persistence details |
| `references/s25-hardware.md` | S25 hardware profile + agent compute routing |
| `references/insights.md` | Runtime lessons |

**External (cross-infra):**
| Skill asset | Role on S25 |
|-------------|-------------|
| `k-ssh/assets/ssh.conf` | Included via `~/.ssh/config` — all Host blocks |
| `k-tmux/assets/tmux.conf` | Symlinked to `~/.tmux.conf` — canonical tmux config |

State file (not in git): `$HOME/.config/kpihx/phones/s25-adb-port`.

## Troubleshooting (S25)

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Successfully paired` but **`adb devices` empty** | **Pair ≠ connect** — `41183` was the **pairing** port | Main screen → **IP address & port** → `adb-s25 DEBUG_PORT` (different port) |
| `ssh s25` → **Connection refused :8022** | Termux **`sshd` not running** (normal after app close/reboot) | Termux: `sshd` or setup persistence — `references/s25-termux-sshd.md` |

| `adb connect` fails, TCP open | Stale debug port or missing pair | Fresh pair code + `adb-s25-pair` then `adb-s25` with **live** debug port |

**Pair success example:** `adb pair 100.125.54.1:41183` + code → then **`adb-s25 <debug_port>`** (not `41183` unless main screen shows the same port for connect).

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-25/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-25/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-24 | [OPENCODE] | v2.0.0 — **Major simplification**: deleted 3 deploy scripts, deleted termux-tmux.conf, renamed k25-remote.zsh → k25-remote.sh. New `assets/kshrc` as S25 kshrc source of truth. Setup is now: symlink kshrc, Include k-ssh, read k-tmux, `pkg install tmux termux-api`. Only `termux-install-boot.sh` remains. |
| 2026-07-24 | [OPENCODE] | v1.3.0 — Deleted `phones.ksh`; `adb-s25` + `adb-s25-pair` symlinked to `~/.local/bin/`. |
| [SUMMARY] | — | v1.2.2 termux-boot.apk; v1.2.0 pve_finder; v1.1.0 SSH → k-ssh; earlier → references/log.md |
