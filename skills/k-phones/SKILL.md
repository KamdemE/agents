---
name: k-phones
description: >
  KπX Android phones over Tailscale — SSH (Termux sshd) and ADB (wireless debugging).
  Inventory: kpihx-s25 (active), kpihx-tablet (listed, not configured). Load before phone SSH/ADB work.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
  scope: device-access
allowed-tools: Bash(ssh:*), Bash(adb:*), Read, Write, Edit
---

# KπX — Phones

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related:** `k-infras` (master infrastructure map) · `k-clis` (Tailscale) · `k-tg` (wireless-debug screenshot to `@kpihx_general_capture_bot`)

## Inventory (Tailscale)

| Host | MagicDNS | Tailscale IP | SSH | ADB | Notes |
|------|----------|--------------|-----|-----|-------|
| **kpihx-s25** | `kpihx-s25.tail2527bd.ts.net` | `100.125.54.1` | ✅ Termux `:8022` | ✅ Wireless debug on TS IP | **Default focus** · hardware → `references/s25-hardware.md` |
| **kpihx-tablet** | `kpihx-tablet.tail2527bd.ts.net` | `100.89.79.87` | 🚧 TBD | 🚧 TBD | Node exists; no Termux/ADB runbook yet |

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
| **Termux local tmux** | `tmux` on phone — Ctrl-a, 5 min autosave — `assets/termux-tmux.conf` |
| **ADB pair** | `adb-s25-pair PAIRING_PORT` — port from *Pair device with pairing code* dialog only |
| **ADB connect** | `adb-s25 DEBUG_PORT` — port from main *IP address & port* (≠ pairing port) |
| **ADB reconnect** | `adb-s25` — uses last saved debug port |
| **ADB status** | `adb-s25 status` |
| **Screen mirror** | `scrcpy -s 100.125.54.1:<DEBUG_PORT>` (or just `scrcpy` if one ADB device) |
| **Termux:Boot install** | `zsh $HOME/.agents/skills/k-phones/scripts/termux-install-boot.sh` (needs `adb` device) |
| **Full phone deploy** | `termux-deploy-all.sh` (sshd + tmux) |

Shell wiring: `assets/phones.ksh` sourced from `$HOME/.kshrc` (idempotent guard — safe to `source ~/.kshrc` repeatedly).

## Documentation triad (read order)

| # | File | Scope |
|---|------|--------|
| 1 | `SKILL.md` (this file) | Inventory, quick commands, layout |
| 2 | `references/s25-hardware.md` | **S25 SoC, RAM, GPU, storage, Termux stack, compute / inference limits** |
| 3 | `references/phone-to-ubuntu.md` | Phone → PC SSH, **where tmux runs**, security |
| 4 | `references/termux-tmux.md` | Termux **local** tmux, clipboard, deploy |

## Tmux topology

| Command (Termux) | tmux on | Session |
|------------------|---------|---------|
| `ubuntu` | **kpihx-ubuntu** | attach **`default`** |
| `tmux` | **S25 Termux** | local only |

## SSH (S25)

- **Canonical config:** now centralized in `k-ssh/assets/ssh.conf` — see `k-ssh` skill.
- **Key:** `~/.ssh/id_ed25519_s25` → Termux `~/.ssh/authorized_keys`.
- **User:** `u0_a417` (fixed by Android — cannot become `kpihx`; use alias `s25` + optional Termux `PS1`) · **Port:** `8022`.
- **Termux `sshd`:** must be running on the phone — persistence: `references/s25-termux-sshd.md` · deploy: `scripts/termux-deploy-sshd.sh` · assets: `termux-sshd-autostart.sh`, `termux-boot-sshd`.
- **OpenSSH on PC only reads** `$HOME/.ssh/config` (+ Include fragments). Skill references are runbooks, not loaded by `ssh`.

## ADB (S25)

Full runbook: `references/s25-adb-wireless.md`.

- **Two ports:** *Pair device with pairing code* → `adb-s25-pair PAIRING_PORT` · main screen → `adb-s25 DEBUG_PORT`. **Never** `adb pair` on the debug port (`protocol fault`).
- **Paired devices** lists hosts already paired (`kpihx@KpihX-Ubuntu`) — still re-pair if connect fails after eduroam/Tailscale changes.
- **Eduroam:** campus Wi‑Fi isolates clients; Tailscale IP can work after correct pair, else **phone hotspot** + Wi‑Fi IP on screen.
- **CLI helpers (assets):** `adb-s25` · `adb-s25-pair` · `phones.ksh`.
- **ADB vs SSH:** `adb shell` ≠ Termux — full app/Linux work via **`ssh s25`**; ADB scope: `references/s25-adb-vs-ssh.md`.

## Layout

| Path | Role |
|------|------|
| `assets/adb-s25` | Connect to wireless-debug **debug port** |
| `assets/adb-s25-pair` | `adb pair` on **pairing port** only |
| `assets/phones.ksh` | `PATH` + alias `s25` — sourced from `$HOME/.kshrc` |
| `assets/termux-tmux.conf` | Termux `~/.tmux.conf` template (Ctrl-a, resurrect, continuum) |
| `assets/termux-zshrc-snippet.sh` | Reference snippet for `alias ubuntu=…` |
| `assets/termux-sshd-autostart.sh` | Start `sshd` on each Termux shell open (`pgrep`, not `ss`) |
| `assets/termux-boot-sshd` | Termux:Boot (F-Droid) script → `~/.termux/boot/sshd` |
| **SSH canonical config** | now in `k-ssh/assets/ssh.conf` |
| `scripts/termux-deploy-tmux.sh` | Push tmux + TPM + zsh alias to S25 via `ssh s25` |
| `scripts/termux-deploy-sshd.sh` | Push sshd autostart + ubuntu SSH + boot script |
| `scripts/termux-deploy-all.sh` | `termux-deploy-sshd.sh` then `termux-deploy-tmux.sh` |
| `scripts/termux-install-boot.sh` | Install Termux:Boot (ADB silent or SSH + Install tap) |
| `references/s25-adb-wireless.md` | Two-port ADB, Tailscale, eduroam |
| `references/phone-to-ubuntu.md` | **Phone → PC** — `ubuntu` alias, PC tmux, security |
| `references/termux-tmux.md` | Termux local tmux, termux-api clipboard, deploy |
| `references/s25-adb-vs-ssh.md` | Termux username, ADB capabilities vs SSH |
| `references/s25-termux-sshd.md` | Termux `sshd` persistence |
| `references/s25-hardware.md` | S25 hardware profile + agent compute routing |
| `references/insights.md` | Runtime lessons |

State file (not in git): `$HOME/.config/kpihx/phones/s25-adb-port`.

## Troubleshooting (S25)

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Successfully paired` but **`adb devices` empty** | **Pair ≠ connect** — `41183` was the **pairing** port | Main screen → **IP address & port** → `adb-s25 DEBUG_PORT` (different port) |
| `ssh s25` → **Connection refused :8022** | Termux **`sshd` not running** (normal after app close/reboot) | Termux: `sshd` or deploy persistence — `references/s25-termux-sshd.md` · `scripts/termux-deploy-sshd.sh` |
| `source ~/.kshrc` → **read-only KPHONES_ASSETS** | Old `phones.ksh` used `readonly` | Fixed v1.0.8 — idempotent `_KPHONES_PHONES_KSH_SOURCED` guard |
| `adb connect` fails, TCP open | Stale debug port or missing pair | Fresh pair code + `adb-s25-pair` then `adb-s25` with **live** debug port |

**Pair success example:** `adb pair 100.125.54.1:41183` + code → then **`adb-s25 <debug_port>`** (not `41183` unless main screen shows the same port for connect).

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-phones/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-phones/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v1.1.0 — SSH canonical config migrated to `k-ssh/assets/ssh.conf`. Removed `ssh-kpihx-phones.conf`, `termux-ssh-ubuntu.conf`, `ssh-config` symlink from assets. SSH section now points to `k-ssh`. |
| 2026-05-26 | [CURSOR] | v1.0.17 — Added `references/s25-hardware.md` (S25 specs + compute/inference routing); doc triad + When to Load. |
| [SUMMARY] | — | v1.0.15 Termux:Boot + bidirectional SSH; v1.0.8–v1.0.0 sshd autostart, IP Host blocks, tmux/ADB runbooks, tablet TBD. |
