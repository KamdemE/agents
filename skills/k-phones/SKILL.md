---
name: k-phones
description: KπX Android phones over Tailscale — Termux SSH, raw wireless ADB, and screen control. Load before phone SSH, ADB, or Termux work.
license: private
metadata:
  author: KpihX
  version: "3.0.4"
  scope: device-access
allowed-tools: Bash(ssh:*), Bash(adb:*), Read, Write, Edit
---

# KπX — Phones

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related:** `k-infras` (inventory and setup checklist) · `k-zsh` (shell hub) · `k-ssh` (canonical SSH fragment) · `k-tmux` (Termux tmux) · `k-tailscale` (mesh connectivity).
> **MANDATORY — read `k-infras` → New Infra Setup Checklist FIRST** to understand the setup rule: everything lives in `.agents/` (single source of truth); `$HOME`/`/root` items are symlinks (`ln -sf`). Each infra has its own `assets/kshrc` (copied from `k-zsh/assets/kshrc.base` and customized).

## Role

This infrastructure skill covers Android phones connected through Tailscale. Keep phone-specific assets in this skill; use raw platform tools rather than wrapper CLIs.

## S25

| Host | Short name | Tailscale IP | Access |
|------|------------|--------------|--------|
| `kpihx-s25` | `s25` | `100.125.54.1` | Termux SSH `:8022`, wireless ADB, `scrcpy` |

- **SSH:** `ssh s25`; Termux `sshd` persistence is documented in `references/s25-termux-sshd.md`.
- **Shell asset:** `$HOME/.kshrc` on the S25 is registered to `assets/kshrc`; it sources `scripts/k_phones_sshd_autostart.sh`.
- **ADB:** use raw `adb`. Check the phone's live Wireless Debugging port and Tailscale address before connecting; do not persist ports or use ADB wrappers. See `references/adb.md`.
- **Screen control:** `scrcpy -s 100.125.54.1:<DEBUG_PORT>` after a raw ADB connection.
- **Hardware and capacity:** `references/s25-hardware.md`.

## Setup procedure

For any phone, follow `references/termux-boot.md` literally, substituting its
phone alias and Tailscale IP where indicated. It covers Termux OpenSSH,
shell-open SSHD autostart, Termux:Boot installation through F-Droid or raw ADB,
boot payload deployment, and verification.

**Deployment rule:** with `~/.agents/` present on the phone, deployed files
(`~/.kshrc`, `~/.termux/boot/sshd`) are **symlinks** into the kernel clone —
`ln -sf`, never `cp`. Registered in `assets/links.jsonc` under `k-phones`.

## Assets and references

| Path | Purpose |
|------|---------|
| `assets/kshrc` | S25 Termux `$HOME/.kshrc` source of truth |
| `scripts/k_phones_sshd_autostart.sh` | Start Termux `sshd` when a shell opens |
| `assets/termux-boot-sshd` | Termux:Boot `sshd` payload (symlinked to `~/.termux/boot/sshd` on the phone) |
| `assets/termux-boot.apk` | Preserved Termux:Boot installer package |
| `references/adb.md` | Raw wireless ADB procedure |
| `references/termux-boot.md` | Literal manual Termux SSHD and Termux:Boot setup |
| `references/termux-tmux.md` | Termux tmux installation and usage |
| `references/s25-termux-sshd.md` | SSH persistence |
| `references/phone-to-ubuntu.md` | S25-to-workstation SSH workflow |
| `references/s25-adb-vs-ssh.md` | ADB and Termux SSH capabilities |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-phones/references/insights.md` before non-trivial phone work.
- Update it with durable lessons at task end.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-24 | [COLAB] | v3.0.4 — Added the mandatory k-infras setup note and documented the existing Termux:Boot APK and Termux tmux reference to satisfy bundled-content provenance coverage. |
| 2026-08-23 | [COLAB] | v3.0.3 — Symlink deployment rule: with `~/.agents/` present on the phone, deployed files (`~/.kshrc`, `~/.termux/boot/sshd`) are `ln -sf` into the kernel clone, never `cp`; boot payload procedure switched to symlink + chmod on source; rule registered in `assets/links.jsonc`. |
| [SUMMARY] | — | v3.0.2 Termux:Boot manual setup (→ `references/log.md`) · v3.0.1 shell asset rename (→ `references/log.md`) · v1.3.0 and older in log.md |
