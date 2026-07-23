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
  version: "1.1.0"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# BLGLAPTOP139 — Windows + WSL

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-infras` (master infrastructure map + setup checklist) · `k-zsh` (shell setup — .kshrc, .zshrc) · `k-ssh` (SSH config — canonical fragment, keys) · `k-ubuntu` (SSH client — RDP from this machine)
> **SSH config source of truth:** `$HOME/.ssh/config`

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
| 2026-07-22 | [OPENCODE] | v1.1.0 — Renamed from k-alienware to k-blglaptop139. Updated metadata to match hostname-based naming. |
| 2026-07-22 | [OPENCODE] | v1.0.0 — Created as k-alienware. Windows+WSL internship PC. Tailscale identity, RDP access. |
| [SUMMARY] | — | — |
