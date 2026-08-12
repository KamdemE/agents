---
name: kpihx-labs
description: >
  KπX kernel top reference — the central entry point for understanding the
  KπX sovereign kernel ecosystem. References k-context (HOT context),
  k-infras (master infrastructure map → per-infra skills), k-clis (CLI
  registry), k-agents (agent runtime registry), k-opencode (OpenCode-exclusive
  hook architecture), and all top skills. Also documents the cross-infra project directory
  ($HOME/Work/KpihX-Labs/Homelab/) and the presentation knowledge base.
  Load for kernel orientation, architecture overview, or project registry.
  NOT for generic project init (→ k-project). NOT for infra-specific tasks
  (→ k-infras → appropriate k-* infra skill).
license: private
metadata:
  author: KpihX
  version: "2.3.0"
  scope: kernel
allowed-tools: Bash(*), "*"
---

# KpihX-Labs — Kernel Top Reference

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **This skill is the kernel-level entry point.** It does not contain infra-specific details — those live in their dedicated skills (see structure below).

---

## KπX Kernel Structure

```
kpihx-labs (this skill — kernel top reference)
│
├── k-context    (HOT context — session log, active projects, current intent)
├── k-infras     (master infrastructure map)
│   ├── k-ubuntu          (Ubuntu workstation — this machine)
│   ├── k-blglaptop139       (Windows + WSL — internship)
│   ├── k-deep-pc6        (Linux server — internship)
│   ├── k-pve             (Proxmox VE hypervisor)
│   │   ├── k-pve-debian     (Debian VM)
│   │   └── k-pve-dockerhost (Docker host VM)
│   └── k-25          (Android phones)
│
├── k-agents     (agent runtime registry — Colab, Explore, runtime configs)
├── k-opencode   (OpenCode-exclusive hook architecture — scripts/hooks/, hooks-standard.md)
├── k-clis       (CLI registry — routes to all k-* CLI skills)
├── k-final      (post-work closure checklist)
├── k-project    (project init templates)
├── k-skill-creator (skill creation & governance)
│
├── [top skills with OS-specific refs]
│   ├── k-tmux / k-optim / k-browser / k-code / k-codex / k-copilot
│   ├── k-gemini / k-hermes / k-nvim / k-docker
│   └── … (see references/ for full list)
│
├── [generic top skills]
│   ├── k-bw / k-classification / k-cloudflare / k-cloud-tools
│   ├── k-drive / k-git / k-git-pages / k-google / k-latex / k-linkedin
│   ├── k-mail / k-media / k-meta / k-microsoft / k-napkin / k-ollama
│   ├── k-openclaw / k-opencode / k-pptx / k-qmd / k-rclone / k-tailscale
│   ├── k-tg / k-tick / k-vibe / k-whatsapp / k-x / k-zed
│   └── kpihx (identity hub)
│
└── k-context/references/refactor.md (skills refactoring plan)
```

Implicit hierarchy: documented in `k-infras`. Not reflected in filesystem — skills are flat under `skills/`.

---

## OS-Specific References Governance

Skills that have platform-specific behaviors use `refs/<os>.md` files to document them. This is the **single source of truth** for OS-specific variations.

### File naming convention

| File | OS | Scope |
|------|----|-------|
| `refs/ubuntu.md` | Ubuntu (native) | Local workstation paths, apt, systemd, GNOME, Intel Arc GPU |
| `refs/windows.md` | Windows | Native Windows paths + **WSL subsection** (WSL aliases, WSL-specific configs, winget install for editors/CLIs) |
| `refs/debian.md` | Debian Linux | Server-specific paths, apt, systemd differences from Ubuntu |
| `refs/pve.md` | Proxmox VE | PVE-specific CLI tools, storage, networking |

### Rules

1. **`refs/` files are always OS/Platform-oriented.** Never machine-oriented (use infra skills for that). A `refs/windows.md` documents Windows-specific editor paths or WSL tmux aliases — not that `blglaptop139` has a specific Chrome profile.
2. **The main `SKILL.md` stays generic.** It should work on any supported OS without modification. OS-specific details live exclusively in `refs/`.
3. **Infra-specific vs OS-specific**: If a detail changes between machines running the same OS (e.g., different Chrome profiles on two Windows machines), it belongs in the **infra skill** (`k-blglaptop139`), not in `refs/windows.md`.
4. **Each `refs/` file is self-contained** — readable on its own without cross-referencing the main skill.
5. **WSL is documented under `refs/windows.md`** with a clear `### WSL` subsection, not in a separate file. WSL is Windows subsystem — one file per OS.

---

## Infrastructure Directory Standard

Every KpihX infrastructure machine MUST have the following directory layout:

| Path | Purpose | Source |
|------|---------|--------|
| `~/.agents/` | KpihX kernel — clone of the private `git@github.com:KpihX/agents.git` repo | Git clone (private) |
| `~/KpihX-Labs/` | Work directory — all projects, code, experiments live here | Created on each machine |
| `~/KpihX-Labs/.agents/` | Symlink → `~/.agents/` | `ln -sf ~/.agents ~/KpihX-Labs/.agents` |
| `~/KpihX-Labs/AGENTS.md` | Per-infra AGENTS.md — empty by default, can contain infra-specific agent instructions | Created empty if absent |

### Rationale

- `~/.agents/` is the **canonical kernel location** — the git repo root. Everything (skills, rules, hooks, agents, assets) lives here.
- `~/KpihX-Labs/` is the **work directory** — not a git repo itself, but contains all projects as subdirectories or repos.
- `~/KpihX-Labs/.agents/` is a **symlink** so that paths like `~/KpihX-Labs/.agents/skills/...` work consistently across all machines, even when code references the kernel from within the workspace.
- `~/KpihX-Labs/AGENTS.md` exists per-infra so that machine-specific agent instructions can be added without modifying the shared kernel.

### Setup on a new machine

```bash
# 1. Clone the kernel (private repo — SSH key required)
git clone git@github.com:KpihX/agents.git ~/.agents

# 2. Create the work directory
mkdir -p ~/KpihX-Labs

# 3. Symlink .agents/ into it
ln -sf ~/.agents ~/KpihX-Labs/.agents

# 4. Create an (empty) per-infra AGENTS.md if needed
touch ~/KpihX-Labs/AGENTS.md
```

### Current machines

| Machine | Has `~/.agents/`? | Has `~/KpihX-Labs/`? | Symlink? | AGENTS.md? |
|---------|-------------------|---------------------|----------|------------|
| **kpihx-ubuntu** | ✅ | ✅ | ✅ | ✅ (compact synthesis) |
| **kpihx-pve** | ✅ | ✅ | ❌ | ❌ |
| **kpihx-pve-debian** | ✅ | ✅ | ❌ | ❌ |
| **blglaptop139** | ✅ (WSL) | ✅ | ❌ | ❌ |
| **kpihx-s25** | ❌ (Termux) | ❌ | ❌ | ❌ |

---

## Workspace Conventions

### Non-code file routing

For content that is not code or infrastructure, use the standard XDG directories under `$HOME`:

| Directory | Purpose |
|-----------|---------|
| `$HOME/Pictures/` | Generated visuals (Napkin, Excalidraw exports), screenshots |
| `$HOME/Documents/` | Docs, PDFs, notes, text exports |
| `$HOME/Downloads/` | Temporary downloaded files |
| `$HOME/Videos/` | Recordings, screencasts |

> Code and infra → `$HOME/Work/` only. Non-code files never live in `$HOME/Work/`.

### Engineering Standards

| Standard | Rule |
|----------|------|
| Build backend | `uv_build` for Python · Bun for JS/TS |
| Architecture | Independent packages in `src/<pkg>/` — no monoliths |
| Pattern | Directive-Sequential (Executor logic ↔ Orchestrator lifecycle) |
| Python naming | `snake_case` for local/import · dashes for PyPI/CLI/repo name |
| Makefile | Every project — `make push` pushes to ALL remotes simultaneously |
| Docker base | Python → `python:3.12-slim` · JS/TS → `oven/bun:1-slim` |
| GitLab MCPs | All MCPs in `kpihx-labs` GitLab group namespace |
| PyPI name ≠ module | Use `[tool.uv.build-backend] module-name = "<import_name>"` to decouple |

---

## SSH & Tailscale — Quick Reference

Detailed maps live in:
- **Full infrastructure SSH map:** `k-infras` (master map with all aliases, routes, targets)
- **Per-infra SSH details:** each infra skill documents its own SSH specifics
- **Tailscale config:** `k-tailscale` (installation, serve, funnel, DERP)
- **SSH config source of truth:** `$HOME/.ssh/config` (aliases, jump hosts, port forwards)

> **Authentication Guard:** SSH keys are managed by the Bitwarden Desktop App (not `Vaultwarden`). When connecting, the Bitwarden Desktop App will spawn an **explicit authorization popup** that MUST be manually approved for `ssh` to succeed (otherwise it fails instantly with `Permission denied (publickey)`).

---

## Projects (`$HOME/Work/KpihX-Labs/Homelab/`)

Source code for all KpihX-Labs projects lives here. When a KπX project is mentioned, check this directory first.

| Project | Purpose | Deployed on |
|---------|---------|-------------|
| `kpihx_labs/` | Main infra stack (Docker Compose) | `k-pve-debian` (Debian VM) |
| `imhotep/` | — | — |
| `polytask/` | — | — |
| `sentinel/` | — | — |
| `wa-bot/` | WhatsApp bot | — |
| `sh/` | Homelab shell scripts (backup, boot notify, etc.) | — |
| `presentation/` | Knowledge / docs project (see below) | GitHub Pages |

---

## Knowledge Base — `$HOME/Work/KpihX-Labs/Homelab/presentation/`

Living knowledge/research project. Key `.md` at root: `README`, `VISION`, `IDEAS`, `STATE_OF_THE_ART`, `EVOLUTION`, `PORTABILITY`. Docsify site published at `kpihx-labs.github.io/presentation/` (`_sidebar.md`, `index.html`). Sub-structure:

- **`techskills/`** — Step-by-step homelab implementation series, Problem-first approach. Sections:
  - Root: 6 core infra guides (Proxmox/802.1X → Docker host → DevOps/CI → Tailscale/AdGuard → Cloudflare/Zero Trust → Vaultwarden/DNS-01)
  - `n8n/` — n8n deployment (private cerveau, PostgreSQL reuse)
  - `security/` — backup 3-2-1, Watchtower, SSH hardening
  - `annexes/` — Network watchdog, Termux toolkit
  - **`templates/`** — Ready-to-use config files for all homelab services: Docker Compose YAMLs + `.env` examples (Traefik, Vaultwarden, Ollama, Tailscale, AdGuard, n8n, Postgres, Watchtower, wa-bot…), GitLab CI deploy pipelines, SSH config template
- **`scripts/`** — utility scripts: `check_links.sh`, `check_templates.sh`, `check_tutos.sh`

---

## Maintenance Reflex

- For homelab optimization posture, weekly maintenance state, backup rotation, and cross-cutting cleanup guidance, load `k-optim`
- For agent kernel governance, load `k-agents` + `k-opencode` (hook architecture)
- For infrastructure-specific maintenance, load the relevant infra skill from `k-infras`

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/kpihx-labs/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/kpihx-labs/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-22 | [OPENCODE] | v2.2.0 — Added Workspace Conventions (XDG routing + Engineering Standards ported from k-workspace). |
| 2026-07-22 | [OPENCODE] | v2.3.0 — Added Infrastructure Directory Standard: every machine must have ~/.agents/ (kernel clone), ~/KpihX-Labs/ (work dir), symlink, and per-infra AGENTS.md. Current machine compliance table. |
| 2026-07-22 | [OPENCODE] | v2.1.0 — Added OS-Specific References Governance section. Rules: refs/ are always OS-oriented (ubuntu.md, windows.md, debian.md, pve.md). WSL under windows.md. Main SKILL.md stays generic. |
| 2026-07-22 | [OPENCODE] | v2.0.0 — Rewritten as kernel top reference. Full kernel structure tree, project registry, knowledge base, OS refs governance. |
| [SUMMARY] | — | v1.x: PVE content (CT-vs-VM DNS, network topology, prefix nomenclature) migrated to k-pve. Full history in git. |
