---
name: k-blglaptop139
description: >
  BLGLAPTOP139 — Windows + WSL laptop at DxO internship (Grenoble).
  Primary development workstation on Windows with WSL for Linux tooling.
  Known Tailscale identity and RDP access from Ubuntu workstation.
  This skill documents the Windows-specific environment, WSL setup,
  and cross-platform access patterns.
license: private
metadata:
  author: KpihX
  version: "1.3.0"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# BLGLAPTOP139 — Windows + WSL

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-infras` (master infrastructure map + setup checklist) · `k-zsh` (shell setup — .kshrc, .zshrc) · `k-ssh` (SSH config — canonical fragment, keys) · `k-ubuntu` (SSH client — RDP from this machine)
> **SSH config source of truth:** `$HOME/.ssh/config`

---

## Setup (WSL — once)

> **MANDATORY — read `k-infras` → New Infra Setup Checklist FIRST** to understand the setup rule: everything lives in `.agents/` (single source of truth); `$HOME`/`/root` items are symlinks (`ln -sf`). Each infra has its own `assets/kshrc` (copied from `k-zsh/assets/kshrc.base` and customized).

```bash
# 1. Clone .agents repo inside WSL distro (canonical location; ~/.agents is only a symlink)
mkdir -p ~/KpihX-Labs
[ -d ~/KpihX-Labs/.agents ] || git clone git@github.com:kpihx-labs/agents.git ~/KpihX-Labs/.agents
[ -e ~/.agents ] || ln -sfn ~/KpihX-Labs/.agents ~/.agents
# 1b. Branch per infra: cd ~/KpihX-Labs/.agents && git switch <infra>-wsl  (Windows/WSL naming)

# 2. kshrc — symlink ($HOME item), source of truth is k-blglaptop139/assets/kshrc
ln -sf ~/.agents/skills/k-blglaptop139/assets/kshrc ~/.kshrc

# 3. SSH config — Include canonical
echo "Include ~/.agents/skills/k-ssh/assets/ssh.conf" > ~/.ssh/config

# 4. Secrets
cp ~/.agents/.env.example ~/.agents/.env
```

> **Windows Terminal** → zsh by default. Requires `chsh -s $(which zsh)` inside WSL (see `k-zsh`).

---

## Host Identity

| Property | Value |
|----------|-------|
| Hostname | `BLGLAPTOP139` |
| Short name (tmux) | `blglaptop139` |
| Tailscale | `blglaptop139` (`100.99.196.32`) |
| OS | Windows (with WSL) |
| Location | DxO internship, Grenoble |
| Tailscale connection | Direct (`172.16.142.143:41641`) |

---

## Access from Ubuntu Workstation

### RDP (via Remmina)

| Field | Value |
|-------|-------|
| Server | `BLGLAPTOP139.corp.dxo.com` |
| Username | `ikamdem` (no domain) |
| Password | DxO password |
| Domain | `corp.dxo.com` |

**Profile file:** `~/.local/share/remmina/group_rdp_dxo_blglaptop139-corp-dxo-com.remmina` (on the Ubuntu workstation)

### Tailscale SSH

When WSL is running with `sshd`, direct SSH via Tailscale is possible:
```bash
ssh kapoivha@blglaptop139
```

---

## OS-Specific Notes (cross-reference)

- **Browser:** Windows Chrome/Edge paths differ from Ubuntu. See `k-browser/refs/windows.md` when complete.
- **tmux in WSL:** requires `alias tmux='wsl tmux'` or equivalent. See `k-tmux/refs/windows.md` when complete.
- **Code:** VS Code user data directory differs on Windows. See `k-code/refs/windows.md` when complete.
- **Dotfiles:** WSL environment uses `$HOME/.kshrc` via the KπX kernel clone.

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [CLAUDE] | v1.3.0 — Persistent SSH agent block added to `assets/kshrc` Section 1 (gpg-agent ssh-emulation, guarded no-op) — WSL needs its own systemd verification (`systemctl --user status gpg-agent-ssh.socket`; WSL2 only runs systemd if enabled in `/etc/wsl.conf`) before this activates; native Windows-side git is unaffected (Windows has its own `ssh-agent` service, out of scope here). See `k-zsh` v2.5.0 for the mechanism; mirrored here per the SYNC RULE. |
| 2026-08-14 | [COLAB] | v1.2.0 — **Setup rule added (per KπX infra setup standard)**: added Setup (WSL) section (read `k-infras` → New Infra Setup Checklist first); `kshrc` symlink → `k-blglaptop139/assets/kshrc` (created from `kshrc.base`); registered `kshrc-blglaptop139` in `assets/links.jsonc`. |
| [SUMMARY] | — | v1.1.0 renamed from k-alienware to k-blglaptop139 · v1.0.0 created as k-alienware (→ `references/log.md`) |
