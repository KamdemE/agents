---
name: k-deep-pc6
description: >
  Deep-PC6 — Linux server at DxO internship. Accessed via DxO VPN from the
  Ubuntu workstation. Known SSH configuration and purpose. This skill serves
  as the entry point for Deep-PC6 operations as information is gathered.
license: private
metadata:
  author: KpihX
  version: "1.4.0"
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
[ -d ~/KpihX-Labs/.agents ] || git clone git@github.com:kpihx-labs/agents.git ~/KpihX-Labs/.agents
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

Deep-PC6 is DxO's GPU compute server — reference machine for the `framework-internship-culling` ML project (see `k-dxo`) and for running Ollama models too large/slow for local hardware (see `k-dxo` → Ollama via deep-pc6).

**Hardware:**

| Component | Value |
|---|---|
| CPU | AMD 3960X — 48 threads, 3.8 GHz, 128 MiB L3 |
| RAM | 64 GB DDR4 (~60 GB typically free) |
| GPU | 2× RTX 3090, 48 GB VRAM total, CUDA 8.6, driver 545 |
| NVMe data | `/mnt/data-nvme`, ~12 GB/s read |
| Bottleneck | PCIe Gen1×16 → CPU↔GPU transfer capped at ~3.9 GB/s |

Access is entirely DxO-internship-gated (VPN, domain account, internal IP) — see `k-dxo` for VPN/SSH/RDP/rclone-mount details from both Ubuntu and Windows; this skill stays the Linux-server-facing view (SSH access, host identity).

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-deep-pc6/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-deep-pc6/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [CLAUDE] | v1.4.0 — Persistent SSH agent (gpg-agent ssh-emulation, socket-activated) added to `assets/kshrc` Section 1 — verified live on this machine (`gpg-agent-ssh.socket` already active). See `k-zsh` v2.5.0 for the mechanism; mirrored here per the SYNC RULE. *(Renumbered from v1.3.0 at PR merge — collided with this skill's own v1.3.0 hardware-specs entry.)* |
| 2026-08-25 | [CLAUDE] | v1.3.0 — Filled in the "Purpose" stub (was TBD since creation): hardware specs (AMD 3960X, 64 GB RAM, 2× RTX 3090/48 GB VRAM, NVMe, PCIe Gen1×16 bottleneck) migrated from `framework-internship-culling`'s README §8.1 reference-machine table. Added Insights Discipline + `references/insights.md` (were missing). |
| [SUMMARY] | — | v1.2.0 setup rule added (kshrc symlink → k-deep-pc6/assets/kshrc, registered in assets/links.jsonc) · v1.1.0 VPN prerequisite reference updated (vpn-dxo CLI removed, now systemctl) · v1.0.0 created k-deep-pc6 (→ `references/log.md`) |
