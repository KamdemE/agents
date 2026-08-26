---
name: k-deep-pc6
description: >
  Deep-PC6 — Linux server at DxO internship. Accessed via DxO VPN from the
  Ubuntu workstation. Known SSH configuration and purpose. This skill serves
  as the entry point for Deep-PC6 operations as information is gathered.
license: private
metadata:
  author: KpihX
  version: "1.3.0"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# Deep-PC6 — Linux Server (DxO Internship)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-infras` (master infrastructure map + setup checklist) · `k-zsh` (shell setup — .kshrc, .zshrc) · `k-ssh` (SSH config — canonical fragment, keys) · `k-ubuntu` (SSH client — VPN access required first)
> **SSH config source of truth:** `$HOME/.ssh/config`

---

## Setup (once per machine)

> **MANDATORY — read `k-infras` → New Infra Setup Checklist FIRST** to understand the setup rule: everything lives in `.agents/` (single source of truth); `$HOME`/`/root` items are symlinks (`ln -sf`). Each infra has its own `assets/kshrc` (copied from `k-zsh/assets/kshrc.base` and customized).

```bash
# 1. Directory standard — 1st op: create ~/KpihX-Labs (if absent), clone agents
#    into ~/KpihX-Labs/.agents (if absent), then symlink ~/.agents -> ~/KpihX-Labs/.agents
mkdir -p ~/KpihX-Labs
[ -d ~/KpihX-Labs/.agents ] || git clone git@github.com:KpihX/agents.git ~/KpihX-Labs/.agents
[ -e ~/.agents ] || ln -sf ~/KpihX-Labs/.agents ~/.agents

# 2. kshrc — symlink ($HOME item), source of truth is k-deep-pc6/assets/kshrc
ln -sf ~/.agents/skills/k-deep-pc6/assets/kshrc ~/.kshrc

# 3. SSH config — Include canonical
echo "Include ~/.agents/skills/k-ssh/assets/ssh.conf" > ~/.ssh/config

# 4. Secrets
cp ~/.agents/.env.example ~/.agents/.env
```

---

## Host Identity

| Property | Value |
|----------|-------|
| Hostname | `deep-pc6` |
| Short name (tmux) | `deep-pc6` |
| LAN IP | `172.16.150.163` |
| OS | Linux |
| Location | DxO network (Grenoble) |
| Access | Via DxO VPN only (not on Tailscale) |

---

## SSH Access

| Alias | Target | Key | Notes |
|-------|--------|-----|-------|
| `deep-pc6` | `172.16.150.163` | `id_ed25519_deep_pc6` | Requires DxO VPN active first |

**User:** `ikamdem@corp.dxo.com`  
**Connection:** SSH over DxO VPN (GlobalProtect via OpenConnect on Ubuntu workstation)

**Prerequisite:** DxO VPN must be connected first (`sudo systemctl start vpn-dxo` on Ubuntu). See `k-ubuntu` → Remote Work.

---

## Purpose

Deep-PC6 is a Linux development/server machine at the DxO internship. Its exact role, services, and configuration are to be documented as discovered.

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [CLAUDE] | v1.3.0 — Persistent SSH agent (gpg-agent ssh-emulation, socket-activated) added to `assets/kshrc` Section 1 — verified live on this machine (`gpg-agent-ssh.socket` already active). See `k-zsh` v2.5.0 for the mechanism; mirrored here per the SYNC RULE. |
| 2026-08-14 | [COLAB] | v1.2.0 — **Setup rule added (per KπX infra setup standard)**: added Setup section (read `k-infras` → New Infra Setup Checklist first); `kshrc` symlink → `k-deep-pc6/assets/kshrc` (created from `kshrc.base`); registered `kshrc-deep-pc6` in `assets/links.jsonc`. |
| [SUMMARY] | — | v1.1.0 VPN prerequisite reference update (`vpn-dxo` CLI removed) · v1.0.0 created k-deep-pc6 (→ `references/log.md`) |
