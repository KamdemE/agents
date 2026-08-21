---
name: k-infras
description: >
  KπX master infrastructure map — lists all equipment, Tailscale identities,
  SSH access, and hierarchical relationships. Each infra entry maps to its
  dedicated k-* skill. Load this skill first when dealing with any
  infrastructure to get the full picture before diving into specifics.
  Also documents the required init skills for setting up a new infra.
license: private
metadata:
  author: KpihX
  version: "1.6.2"
  scope: infrastructure
allowed-tools: Bash, Read, Write, Edit
---

# KπX — Infrastructure Master Map

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related skills:** `k-ubuntu` (workstation) · `k-pve` (hypervisor) · `k-pve-debian` (Debian VM) · `k-dockerhost` (Docker host) · `k-blglaptop139` (Windows+WSL) · `k-deep-pc6` (Linux server) · `k-phones` (Android phones) · **`k-clis`** (CLI registry — routing to all per-CLI skills)
> **Scope also covers:** low-level hardware (disk partitioning, BIOS/UEFI, filesystem recovery, dual-boot, interrupted ntfsresize recovery) — see `references/ntfs-shrink-dual-boot.md`. Firewall: `k-nftables`. Mesh VPN: `k-tailscale`.
> **Init skills:** see **New Infra Setup Checklist** below — these apply to every infra skill.
> This skill is the **implicit hierarchy** — not reflected in filesystem sub-folders. Skills are flat under `skills/`.

---

## Equipment Inventory

Source of truth for live state: `tailscale status --json` or `tailscale status`.

| Tailscale name | Tailscale IP | OS | Status | Skill | Notes |
|---------------|-------------|----|--------|-------|-------|
| Tailscale name | Short name | Tailscale IP | OS | Status | Skill | Notes |
|---------------|-----------|-------------|----|--------|-------|-------|
| `kpihx-ubuntu` | `ubuntu` | `100.82.95.70` | Linux | online | **`k-ubuntu`** | Primary workstation. |
| `blglaptop139` | `blglaptop139` | `100.99.196.32` | Windows | online | **`k-blglaptop139`** | Internship PC (Grenoble). |
| `kpihx-pve` | `pve` | `100.123.81.21` | Linux (PVE) | idle | **`k-pve`** | Proxmox VE hypervisor. |
| `kpihx-pve-debian` | `pve-debian` | `100.117.171.4` | Linux (Debian) | offline | **`k-pve-debian`** | Debian VM on PVE. |
| `kpihx-pve-dockerhost` | `dockerhost` | — | Linux | — | **`k-dockerhost`** | Docker host VM on PVE. |
| `kpihx-s25` | `s25` | `100.125.54.1` | Android | offline | **`k-phones`** | Samsung S25 phone. |
| `kpihx-tablet` | — | `100.89.79.87` | Android | offline | **`k-phones`** | Tablet (not configured). |

---

## New Infra Setup Checklist

When setting up a **new infrastructure** (any equipment running a shell), an agent MUST load and follow these steps **in order** before writing any config:

### Step 0 — Infrastructure Directory Standard (MANDATORY, first)

**Before ANY other skill setup**, every new infra MUST bootstrap the KπX directory standard. Everything lives **exclusively and 100% inside `~/KpihX-Labs/`** by default — the kernel, all projects, all work. The only exception is transient/debug debris, which belongs in `/tmp` (never next to the original file, never in `~` root — see `rules/file-governance.md`):

```bash
mkdir -p ~/KpihX-Labs
git clone git@github.com:KpihX/agents.git ~/KpihX-Labs/.agents   # real repo lives HERE
ln -sfn ~/KpihX-Labs/.agents ~/.agents                            # ~/.agents is a symlink, never a standalone clone
```

Rules:
- `~/KpihX-Labs/.agents/` is the **real git clone** (source of truth, single canonical copy).
- `~/.agents/` is **always a symlink** → `~/KpihX-Labs/.agents/`. Never a real directory, never a second clone.
- All projects are created inside `~/KpihX-Labs/` (`~/KpihX-Labs/<project>/`), never outside it.
- Only `/tmp`-scoped debris may live outside `~/KpihX-Labs/`.
- **Verify before proceeding:** `readlink ~/.agents` must resolve to `~/KpihX-Labs/.agents`, and `git -C ~/.agents status` must work.

Then continue with the ordered checklist below.

| Order | Skill | Purpose |
|-------|-------|---------|
| 1 | **`k-zsh`** | Shell setup: 5 shared files (zshrc, zshenv, zprofile, bashrc, profile) symlinked from `k-zsh/assets/`. PATH, env vars, hub pattern. |
| 1b | **Infra skill** | **`~/.kshrc`** source of truth = `assets/kshrc` in the infra skill (e.g. `k-ubuntu/assets/kshrc`). Infra skills have ONLY `kshrc` — the 5 other files are shared from `k-zsh`. If infra skill has no `assets/kshrc`, copy `kshrc.base`, customize, then symlink. |
| 2 | **`k-tailscale`** | Mesh VPN: install, authenticate, verify connectivity. |
| 3 | **`k-tmux`** | Tmux session per equipment: standard 3-window layout (agents/default/tmp), shared interactive gate. |
| 4 | **`k-ssh`** | SSH config: canonical `assets/ssh.conf`, key generation, Bitwarden agent, passphrase rules. |
| 5 | **`k-clis`** | CLI registry: which CLIs to install on this infra type. |
| 6 | **`k-nvim`** | Neovim config (when applicable — skip if Termux/headless). |
| 7 | **`k-opencode`** | OpenCode runtime (when applicable — does not run on Termux). |

**Exception:** Termux/Android phones (`k-phones`) skip `k-nvim` and `k-opencode` — they do not run on Termux.

### Tmux session name — short name convention

Every infra skill MUST document both the **Tailscale name** (e.g. `kpihx-ubuntu`) and the **short name** (e.g. `ubuntu`) in its `## Host Identity` table. The short name is the tmux session name (see `k-tmux` → Standard session per equipment).

| Equipment | Tailscale name | Short name (tmux session) |
|-----------|---------------|--------------------------|
| Workstation | `kpihx-ubuntu` | `ubuntu` |
| Internship laptop | `blglaptop139` | `blglaptop139` |
| DxO server | — | `deep-pc6` |
| PVE hypervisor | `kpihx-pve` | `pve` |
| Debian VM | `kpihx-pve-debian` | `pve-debian` |
| Docker host | — | `dockerhost` |
| S25 phone | `kpihx-s25` | `s25` |

When setting up `kshrc.base` → `~/.kshrc`, the agent reads the infra skill to find the **short name** and replaces `<INFRA_SESSION>` in the auto-tmux block with that value.

---

## Implicit Hierarchy

```
kpihx-labs (kernel top reference)
│
├── k-context    (HOT context — session log, active projects)
├── k-infras     (this skill — master map)
│   ├── k-ubuntu          (Ubuntu workstation)
│   ├── k-blglaptop139       (Windows + WSL — internship)
│   ├── k-deep-pc6        (Linux server — internship)
│   ├── k-pve             (Proxmox VE hypervisor)
│   │   ├── k-pve-debian     (Debian VM)
│   │   └── k-dockerhost (Docker host VM)
│   └── k-phones      (Android phones)
│
├── k-clis       (CLI registry — routes to all skills)
└── [all other top skills]
```

---

## SSH Access Map

Source of truth: `$HOME/.ssh/config`. Each infra skill documents its own SSH specifics.

| Alias | Target | Route | Skill |
|-------|--------|-------|-------|
| `pve` | `pve.local:2222` | LAN (mDNS) | `k-pve` |
| `kpihx-pve` | `kpihx-pve:2222` | Tailscale | `k-pve` |
| `pve-ui` | `pve.local:2222` + port forwards | LAN | `k-pve` |
| `kpihx-pve-ui` | `kpihx-pve:2222` + port forwards | Tailscale | `k-pve` |
| `homelab` | `10.10.10.10` via `kpihx-pve` | LAN jump | `k-pve-debian` |
| `kpihx-cloud` | `10.10.10.10` via `kpihx-pve` | Tailscale jump | `k-pve-debian` |
| `pve-debian` | `10.10.10.101` via `pve` | LAN jump | `k-pve-debian` |
| `kpihx-pve-debian` | `10.10.10.101` via `kpihx-pve` | Tailscale jump | `k-pve-debian` |
| `deep-pc6` | `172.16.150.163` | Direct (DxO VPN) | `k-deep-pc6` |
| `kpihx-s25` | `kpihx-s25:8022` | Tailscale | `k-phones` |

---

## PVE Network Topology

Defined in `k-pve` (this is a summary reference). Full details in `kpihx-labs` (current) and `k-pve`.

| Interface | Subnet | Role |
|-----------|--------|------|
| `vmbr0` | DHCP (WAN) | Public, campus network |
| `vmbr1` | `10.10.10.1/24` | Private LAN, NAT (masquerade) |
| Port forwards | TCP 80, 443, 9443 → `10.10.10.10` | Traefik/Portainer ingress |

| PVE internal host | LAN IP | SSH alias |
|-------------------|--------|-----------|
| Docker host (CT 100) | `10.10.10.10` | `homelab` / `kpihx-cloud` |
| Debian VM | `10.10.10.101` | `pve-debian` / `kpihx-pve-debian` |

---

## Servies Exposure

| Service | Domain | Access |
|---------|--------|--------|
| Vaultwarden | `vault.kpihx-labs.com` | Tailscale only |
| Traefik dashboard | Via port forward | LAN / Tailscale tunnel |
| Portainer | Via port forward | LAN / Tailscale tunnel |

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-infras/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-infras/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Shared Libs Reflex (MANDATORY)

When writing or editing **any infra-skill script** (check, service, link, notifier, config) — **check `$HOME/.agents/libs/` first** before creating a local helper:

- `.env` handling → source `libs/env/env_lib.sh`
- JSONC config parsing → source `libs/jsonc/jsonc_lib.sh`
- Notifications (Telegram/system) → source `libs/notif/notifier.sh` (define `NOTIFY_TG_TOKEN` in the skill's `.env`)

Never inline a private copy of these helpers in an infra skill. If a concern is missing from `libs/`, add the twin set there and expose it via a check in `scripts/`. See `libs/AGENTS.md` → Reflex for the full rule.

**Full function index + guard mapping:** see `references/libs.md` — the single
orientation point for the three shared libs (`env`/`jsonc`/`notif`), their
functions, and the checks/guards that consume them.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-20 | [COLAB] | v1.6.2 — Renamed the Android infrastructure skill to `k-phones`; updated the S25/tablet inventory, Termux exception, hierarchy, and SSH access map. |
| 2026-08-16 | [COLAB] | v1.6.1 — **`references/libs.md` added (single orientation point)**: full index of the three shared libs (`libs/env`, `libs/jsonc`, `libs/notif`) — function signatures + purposes — plus the guards/checks that consume them and a "adding a new shared concern" workflow. Linked from the Shared Libs Reflex section. |
| 2026-08-16 | [COLAB] | v1.6.0 — **Shared Libs Reflex (MANDATORY)**: added section directing all infra-skill scripts to source `libs/env/env_lib.sh`, `libs/jsonc/jsonc_lib.sh`, `libs/notif/notifier.sh` from `$HOME/.agents/libs/` instead of inlining private helpers (env/jsonc/notifier centralization). |
| [SUMMARY] | — | v1.5.0 New Infra Setup: Step 0 Infrastructure Directory Standard (`~/KpihX-Labs/.agents/` real clone + `~/.agents` symlink; everything 100% inside `~/KpihX-Labs/`); v1.4.0 k-infra merged into k-infras (ntfs-shrink-dual-boot.md + insights.md moved; k-infra purged); v1.1.0–v1.3.0 New Infra Setup Checklist + dockerhost rename + kshrc pattern; v1.0.1–v1.0.0 master map created. |
