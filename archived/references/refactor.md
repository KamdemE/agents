# KπX Skills Refactoring — Architecture Vision & Analysis

> **Author:** KπX
> **Date:** 2026-07-22
> **Status:** Brainstorm — awaiting validation before execution
> **Location:** This file → `k-context/references/refactor.md` (durable brainstorm before promotion)

---

## Core Principle

All equipment runs `.agents/` cloned everywhere. Skills must reflect this:

- **TOP skills** = common kernel logic that applies across ALL equipment
- **INFRA skills** = machine-specific (one per physical/virtual host)
- **OS-specific refs** = per-OS detail files inside top skills (`refs/ubuntu.md`, `refs/debian.md`, `refs/windows.md`)
- **No info loss, no compression, no deletion** — content is always copied/moved, never reduced
- **No deactivation of existing skills** — generic and specific skills coexist
- **Hierarchy is implicit** — documented in `k-infras`, NOT reflected in filesystem sub-folders (skills are flat under `skills/`)

---

## Equipment Inventory (from Tailscale)

| Tailscale name | Host | Type | Skill | Notes |
|---------------|------|------|-------|-------|
| `kpihx-ubuntu` | KpihX-Ubuntu (this machine) | Linux | `k-ubuntu` | Ubuntu workstation. Content from `k-workspace`. |
| `blglaptop139` | Alienware | Windows + WSL | `k-alienware` | Internship PC (Grenoble). |
| `kpihx-pve` | Proxmox VE | Linux (PVE) | `k-pve` | Hypervisor. Content from `kpihx-labs` PVE parts. |
| `kpihx-pve-debian` | Debian VM on PVE | Linux (Debian) | `k-pve-debian` | Sub-infra of k-pve. Content from `kpihx-labs` Docker parts + `k-docker` Ubuntu specifics. |
| `kpihx-pve-dockerhost` | Docker host VM on PVE | Linux | `k-pve-dockerhost` | Sub-infra of k-pve. Skill reflects actual state. |
| `kpihx-s25` | Samsung S25 | Android | `k-phones` | Phone. |
| `kpihx-tablet` | Tablet | Android | `k-phones` | Tablet. |

### Implicit Hierarchy (documented in k-infras only)

```
kpihx-labs (kernel top reference)
│
├── k-context
├── k-infras (this skill — master map)
│   ├── k-ubuntu          (Ubuntu workstation)
│   ├── k-alienware       (Windows + WSL — internship)
│   ├── k-deep-pc6        (Linux server — internship)
│   ├── k-pve             (Proxmox VE hypervisor)
│   │   ├── k-pve-debian     (Debian VM)
│   │   └── k-pve-dockerhost (Docker host VM)
│   └── k-phones          (Android phones)
│
├── k-clis
└── [all other top skills]
```

---

## Full Skill Inventory — Classification

### KERNEL-LEVEL TOP Skills (core kernel, apply to every machine)

Loaded at session start or required by the kernel itself. No infrastructure mapping needed.

| Skill | Current status | Notes |
|-------|---------------|-------|
| `k-context` | ✅ Already clean | HOT context, session log |
| `kpihx` | ✅ Already clean | Identity hub |
| `k-agents` | ✅ Already clean | Agent runtime registry |
| `k-hook` | ✅ Already clean | Hook architecture |
| `k-clis` | ✅ Already clean | CLI registry |
| `k-final` | ✅ Already clean | Post-work checklist |
| `k-project` | ✅ Already clean | Project init |
| `k-skill-creator` | ✅ Already clean | Skill creation |

### GENERAL TOP Skills (apply everywhere, may need OS refs)

| Skill | Current clean? | OS refs needed? | Notes |
|-------|---------------|-----------------|-------|
| `k-ai` | ✅ Clean | No | AI gateway — pure config |
| `k-bw` | ✅ Clean | No | Bitwarden — self-hosted, same everywhere |
| `k-classification` | ✅ Clean | No | File/knowledge classification |
| `k-cloudflare` | ✅ Clean | No | Cloudflare API — same everywhere |
| `k-cloud-tools` | ✅ Keep as is | No | Already merged into k-clis, redirect skill, stays |
| `k-drive` | ✅ Clean | No | Google Drive — rclone, same everywhere |
| `k-git` | ✅ Clean | No | Git workflow — SSH, same everywhere |
| `k-git-pages` | ✅ Clean | No | GitHub Pages — same everywhere |
| `k-google` | ✅ Clean | No | Google Cloud + Workspace — same everywhere |
| `k-latex` | ✅ Clean | No | LaTeX — same everywhere |
| `k-linkedin` | ✅ Clean | No | LinkedIn — cloud hub |
| `k-mail` | ✅ Clean | No | Mail — cloud hub |
| `k-media` | ✅ Clean | No | Media publishing — cloud hub |
| `k-meta` | ✅ Clean | No | Meta — cloud hub |
| `k-microsoft` | ✅ Clean | No | Microsoft 365 — cloud hub |
| `k-napkin` | ✅ Clean | No | Napkin AI — API-based |
| `k-nvim` | ✅ Clean | No | Neovim — config is in `~/.config/nvim/` |
| `k-ollama` | ✅ Clean | No | Ollama — same everywhere |
| `k-openclaw` | ✅ Clean | No | OpenClaw — same everywhere |
| `k-opencode` | ✅ Clean | No | OpenCode — same everywhere |
| `k-phones` | ✅ Clean | No | Android phones — already generic |
| `k-pptx` | ✅ Clean | No | PPTX — MCP-based, same everywhere |
| `k-qmd` | ✅ Clean | No | QMD search — local CLI, same everywhere |
| `k-rclone` | ✅ Clean | No | rclone — same everywhere |
| `k-tailscale` | ✅ Clean | No | Tailscale — same everywhere |
| `k-tg` | ✅ Clean | No | Telegram — cloud hub |
| `k-ticktick` | ✅ Clean | No | TickTick — cloud hub |
| `k-vibe` | ✅ Clean | No | VIBE CLI — same everywhere |
| `k-whatsapp` | ✅ Clean | No | WhatsApp — cloud hub |
| `k-x` | ✅ Clean | No | X/Twitter — cloud hub |
| `k-zed` | ✅ Clean | No | Zed — same everywhere |

### GENERIC Skills with OS-specific notes (not infra-specific, keep as top)

These skills apply everywhere. Their Ubuntu-specific details are documented as sections or refs within the skill itself, NOT moved to another skill.

| Skill | What to do | Notes |
|-------|-----------|-------|
| `k-docker` | Keep generic. Add a section documenting Ubuntu-specific Docker paths/config if needed. | Docker patterns are cross-platform. Deployment destination is `k-pve-debian` for the actual server, but the skill stays generic. |
| `k-nftables` | Keep as own skill. Referenced from `k-ubuntu` as a sub-skill. | Firewall is Ubuntu-specific, but the skill stays self-contained. `k-ubuntu` references it. |
| `k-infra` | Keep as is (disk, BIOS, filesystem recovery). | Low-level hardware skill for this machine. Content is not replaced by `k-infras`. |

### TOP Skills with OS-specific considerations (need refs/)

| Skill | Current state | OS refs needed | What needs refactoring |
|-------|--------------|---------------|----------------------|
| `k-browser` | Ubuntu Chrome config | `refs/windows.md` | Alienware uses Windows Chrome + different profile paths |
| `k-code` | Code user dir on Ubuntu | `refs/windows.md` | VS Code/Cursor paths differ on Windows |
| `k-codex` | `~/.codex` config | `refs/windows.md` | Codex paths on Windows |
| `k-copilot` | Copilot config | `refs/windows.md` | Copilot-instructions.md paths |
| `k-gemini` | Gemini config | `refs/windows.md` | Extension paths |
| `k-hermes` | Cron-based daemon | `refs/windows.md`, `refs/debian.md` | PVE-debian has different systemd |
| `k-optim` | Ubuntu + homelab focus | `refs/ubuntu.md`, `refs/debian.md`, `refs/windows.md` | Currently Linux-oriented, needs platform refs + generic core |
| `k-tmux` | tmux on Linux | `refs/windows.md` | WSL needs `alias tmux='wsl tmux'` |

### NEW Infra Skills (one per machine, created from existing content)

| New skill | Source | Content |
|-----------|--------|---------|
| `k-infras` | New | Master infrastructure map. Lists all equipment, Tailscale identities, SSH access, hierarchy. Replaces current `k-infra` for the mapping role only — `k-infra` stays for its hardware content. |
| `k-ubuntu` | From `k-workspace` | Shell architecture (.kshrc), systemd services, DxO VPN, apt packages, `~/Work/` layout, `~/.config/` specifics. References `k-nftables` as sub-skill. |
| `k-pve` | From `kpihx-labs` PVE content | PVE config, VMs, vmbr0/vmbr1 networking, storage, CT management. |
| `k-pve-debian` | From `kpihx-labs` Docker parts + `k-docker` Ubuntu specifics | Debian-specific paths, Docker deployment, GitLab CI, Traefik. |
| `k-pve-dockerhost` | New | Docker host VM. Reflects actual state. |
| `k-alienware` | New | Windows + WSL paths, Chrome, different `$HOME`, Windows-specific env. |
| `k-deep-pc6` | New | Server-specific paths, services, env, headless Linux. |

---

## Proposed Phased Execution

### Phase 1 — Create `k-infras` (master infrastructure map) ✅ DONE
- New skill, lists all equipment, Tailscale names, SSH access, implicit hierarchy
- Maps each infra to its skill (`k-ubuntu`, `k-pve`, etc.)
- `k-infra` stays untouched (its disk/BIOS content is unrelated)

### Phase 2 — Create `k-ubuntu` from `k-workspace`
- Extract all Ubuntu-specific content from `k-workspace`
- Shell architecture (.kshrc, .zshrc, .zshenv)
- System services (docker, tailscale, rclone, nftables, tor, vpn-dxo)
- Package management (uv, bun, npm-global)
- Directory layout (~/Work/, ~/Gdrive/, etc.)
- DxO Remote Work (VPN + RDP)
- Engineering standards (non-infra-specific) → ported to `kpihx-labs`
- MCP ecosystem (stdio MCPs on this machine)
- **Reference** `k-nftables` as a sub-skill of k-ubuntu

### Phase 3 — Rework `kpihx-labs` as pure top kernel reference
- Extract PVE/Docker content as copy into `k-pve` / `k-pve-debian`
- Keep in `kpihx-labs`: cross-infra project registry, knowledge base (presentation/), high-level architecture
- Rewrite to become the "kernel-level top reference" — connects k-context, k-infras, k-clis
- No info removed from `kpihx-labs`

### Phase 4 — Create `k-pve` and `k-pve-debian`
- `k-pve`: PVE hypervisor config, networking, storage, CT management (copied from current `kpihx-labs`)
- `k-pve-debian`: Debian VM, Docker deployment, Traefik, GitLab CI (copied from `kpihx-labs` Docker parts)

### Phase 5 — Create `k-pve-dockerhost`, `k-alienware`, `k-deep-pc6`
- `k-pve-dockerhost`: Reflects actual Docker host VM state
- `k-alienware`: WSL+Windows specific config
- `k-deep-pc6`: Internship Linux server

### Phase 6 — Add OS-specific refs to top skills
- `k-tmux/refs/windows.md` — WSL alias
- `k-optim/refs/ubuntu.md`, `refs/debian.md` — platform-specific cleanup
- `k-browser/refs/windows.md` — Windows Chrome paths
- `k-docker/refs/ubuntu.md` (if needed for Ubuntu-specific notes)
- etc.

---

## Non-Negotiable Rules (from KπX)

- ~~**No deactivation of any existing skill** — keep generic and specific skills~~ → Overridden: k-workspace deactivated 2026-07-22 (content ported to k-ubuntu, kpihx-labs, k-agents)
- **No info loss, no compression, no deletion** — content is always copied, never removed from source
- **Structure is implicit** — hierarchy documented in `k-infras`, not reflected in filesystem
- **English only** in all files, code, comments
- **Existing skills that grow new sections or refs**: `k-docker` stays generic, `k-nftables` stays as referenced sub-skill, `k-cloud-tools` stays as redirect
- ~~**k-workspace** stays but its content serves as input for `k-ubuntu`~~ → Deactivated 2026-07-22. Content ported to k-ubuntu, kpihx-labs, k-agents.
- **k-infra** stays for its disk/BIOS content; `k-infras` adds the mapping layer

---

_This document is the durable brainstorm. Updated 2026-07-22 to reflect corrections: no deactivation, k-docker generic, k-nftables stays, k-cloud-tools stays, implicit hierarchy only._
