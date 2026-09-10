---
name: k-infras
description: Single-machine infrastructure template — directory standard, setup checklist, platform skills map.
metadata:
  author:
  version: "1.0.0"
---

# k-infras — Infrastructure (Single Machine)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

> **Related skills:** `k-ubuntu` (Linux workstation) · `k-windows` (Windows/WSL, dormant) · `k-phones` (Android, dormant) · **`k-clis`** (CLI registry)
> **Scope also covers:** low-level hardware (disk partitioning, BIOS/UEFI, filesystem recovery, dual-boot — see `references/ntfs-shrink-dual-boot.md`) — firewall: `k-nftables`. Optional mesh VPN: `k-tailscale`.
> This skill is the **setup template** for the one machine this fork lives on. No fleet, no branches, no tailscale backbone required.

---

## Machine Identity

| Property | Value / Rule |
|----------|--------------|
| Identity source | `$AGENTS_INFRA` when exported, else lowercased `hostname` (see `libs/jsonc/jsonc_lib.sh:current_infra`) |
| Platform skill | `k-ubuntu` (this machine) — `k-windows` / `k-phones` stay dormant unless needed |
| Tmux session | `ubuntu` (see `k-tmux` → standard session) |
| Work dir | `~/Labs/` (kernel at `~/Labs/.agents/`, symlinked as `~/.agents`) |

---

## Setup Checklist (new machine)

Clone + wire, in order. Steps marked optional are genuinely optional.

| Order | Skill | Purpose |
|-------|-------|---------|
| 0 | **(this checklist)** | Directory standard below — first, always |
| 1 | **`k-zsh`** | Shell hub: rc files symlinked from `k-zsh/assets/`, PATH, env vars |
| 2 | **Platform skill** | `~/.kshrc` source of truth = `assets/kshrc` in the platform skill |
| 3 | **`k-tmux`** | Tmux session: standard layout, shared interactive gate |
| 4 | **`k-ssh`** | SSH config, key generation, agent setup |
| 5 | **`k-clis`** | CLI registry: which CLIs to install |
| 6 | **`k-nvim`** | Editor config (when applicable) |
| 7 | **`k-opencode`** | Agent runtime (when applicable) |
| 8 | `k-tailscale` | *(optional)* mesh VPN for multi-machine reachability |

### Step 0 — Directory Standard (MANDATORY, first)

```bash
mkdir -p ~/Labs
git clone git@github.com:KamdemE/agents.git ~/Labs/.agents   # real repo lives HERE
ln -sfn ~/Labs/.agents ~/.agents                            # ~/.agents is a symlink, never a standalone clone
cd ~/Labs/.agents
```

Rules:
- `~/Labs/.agents/` is the **real git clone** (source of truth, single canonical copy).
- `~/.agents/` is **always a symlink** → `~/Labs/.agents/`. Never a real directory, never a second clone.
- All projects live inside `~/Labs/` (`~/Labs/<project>/`), never outside it.
- Only `/tmp`-scoped debris may live outside `~/Labs/`.
- **Workspace shortcuts:** `~k`, `$KLABS`, `$KHOME`, `$LABS` → `~/Labs/` (defined in every `.kshrc`).
- **Verify:** `readlink ~/.agents` must resolve to `~/Labs/.agents`.

Then continue with `make set-links && make check-links`, then the checklist above.

---

## Platform Skills Map

```
k-infras (this skill — setup template)
├── k-ubuntu     (Linux workstation — active here)
├── k-windows    (Windows/WSL — dormant)
└── k-phones     (Android — dormant)
```

Shared components: `k-tailscale` (optional mesh) · `k-nftables` (firewall reference).

---

## SSH Access Map

Source of truth: `$HOME/.ssh/config`. Document machine-specific SSH access in the platform skill.

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-infras/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-infras/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Shared Libs Reflex (MANDATORY)

When writing or editing **any skill script** (check, service, link, notifier, config) — **check `$HOME/.agents/libs/` first** before creating a local helper:

- `.env` handling → source `libs/env/env_lib.sh`
- JSONC config parsing → source `libs/jsonc/jsonc_lib.sh`
- Notifications (Telegram/system) → source `libs/notif/notifier.sh`

Never inline a private copy of these helpers in a skill. If a concern is missing from `libs/`, add the twin set there and expose it via a check in `scripts/`. See `libs/AGENTS.md` → Reflex for the full rule.

**Full function index + guard mapping:** see `references/libs.md` — the single
orientation point for the three shared libs (`env`/`jsonc`/`notif`), their
functions, and the checks/guards that consume them.
