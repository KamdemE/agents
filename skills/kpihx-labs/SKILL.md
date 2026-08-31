---
name: kpihx-labs
description: >
  KπX kernel top reference — the central entry point for understanding the
  KπX sovereign kernel ecosystem. References k-context (HOT context),
  k-infras (master infrastructure map → per-infra skills), k-clis (CLI
  registry), k-ai (AI hub + agent runtime registry), k-opencode (OpenCode-exclusive
  hook architecture), and all top skills. Also documents the cross-infra project directory
  ($HOME/Work/KpihX-Labs/Homelab/) and the presentation knowledge base.
  Load for kernel orientation, architecture overview, or project registry.
  NOT for generic project init (→ k-project). NOT for infra-specific tasks
  (→ k-infras → appropriate k-* infra skill).
license: private
metadata:
  author: KpihX
  version: "2.11.0"
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
│   └── k-phones      (Android phones)
│
├── k-ai         (AI hub + agent runtime registry — Colab, Explore, runtime configs)
├── k-opencode   (OpenCode-exclusive hook architecture — scripts/plugins/hooks/, hooks-standard.md)
├── k-clis       (CLI registry — routes to all k-* CLI skills)
├── k-final      (post-work closure checklist)
├── k-project    (project init templates)
├── k-skill-creator (skill creation & governance)
│
├── [top skills with OS-specific refs]
│   ├── k-tmux / k-optim / k-browser / k-code
│   ├── k-hermes / k-nvim / k-docker
│   ├── k-windows (Windows/WSL/MSYS2 platform hub — child infra skills: k-blglaptop139)
│   └── … (see references/ for full list)
│
├── [generic top skills]
│   ├── k-ai / k-classification / k-cloudflare / k-cloud-tools
│   ├── k-drive / k-git / k-git-pages / k-google / k-latex / k-linkedin
│   ├── k-mail / k-media / k-meta / k-microsoft / k-napkin / k-ollama
│   ├── k-openclaw / k-opencode / k-openvino / k-pptx / k-qmd / k-rclone / k-tailscale
│   ├── k-tg / k-tick / k-whatsapp / k-x
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
| `~/.agents/` | KpihX kernel — symlink to `~/KpihX-Labs/.agents`, clone of the private `git@github.com:kpihx-labs/agents.git` repo | Git clone (private) |
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
#    Canonical path is ~/KpihX-Labs/.agents — never ~/.agents alone
mkdir -p ~/KpihX-Labs
git clone git@github.com:kpihx-labs/agents.git ~/KpihX-Labs/.agents   # real repo
ln -sfn ~/KpihX-Labs/.agents ~/.agents                            # symlink

# 2. Switch to your infra branch — NEVER work on master
#    Sole exception: kpihx-ubuntu works directly on master (rules/git-branch-per-infra.md)
#    Windows machines in WSL mode append -wsl to their infra name (blglaptop139-wsl)
cd ~/KpihX-Labs/.agents
INFRA=$(hostname | tr '[:upper:]' '[:lower:]')   # or: source libs/jsonc/jsonc_lib.sh && INFRA=$(current_infra)
if [ "$INFRA" = "kpihx-ubuntu" ]; then git switch master   # ubuntu = the master infra
elif git show-ref --verify --quiet "refs/heads/$INFRA"; then git switch "$INFRA"
elif git ls-remote --heads github "$INFRA" | grep -q "$INFRA"; then git fetch github "$INFRA" && git switch "$INFRA"
else git switch -c "$INFRA" && git push -u github "$INFRA"
fi

# 3. Create an (empty) per-infra AGENTS.md if needed
touch ~/KpihX-Labs/AGENTS.md
```

> **Branch per infra (GRAVÉ):** every infra owns a branch named after itself (`deep-pc6`, `blglaptop139`; Windows machines in WSL mode append `-wsl`, e.g. `blglaptop139-wsl`). `master` is read-only for every infra EXCEPT `kpihx-ubuntu` — the sole infra authorized to commit on `master`. After clone, always `git switch <infra>` (ubuntu stays on `master`). Before every `commit`/`push`, `git fetch github` + check `git log HEAD..github/master` and `git rebase github/master` if `master` moved (other infras' PRs). Push only your infra branch (`make push` → `github`+`gitlab`, NEVER `origin`), then PR to `master`. See `rules/git-branch-per-infra.md` + `k-infras` → Git Branch per Infra.

### Current machines

| Machine | Has `~/.agents/`? | Has `~/KpihX-Labs/`? | Symlink? | AGENTS.md? |
|---------|-------------------|---------------------|----------|------------|
| **kpihx-ubuntu** | ✅ | ✅ | ✅ | ✅ (compact synthesis) |
| **kpihx-pve** | ✅ | ✅ | ❌ | ❌ |
| **kpihx-pve-debian** | ✅ | ✅ | ❌ | ❌ |
| **blglaptop139** | ✅ (WSL) | ✅ | ✅ | ✅ |
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
| **Config standard (JSONC)** | KπX config files are **JSONC** (JSON + `//` comments) for `.agents/` assets and non-code config (self-documenting, single source of truth). **Code projects** prefer plain `config.py`/`config.ts` (no import needed). **Secrets** always in `.env` (never committed). See `k-project` → Config Standard. Kernel assets: `assets/infras_skills.jsonc`, `assets/services.jsonc`, `assets/links.jsonc`. |

---

## Config & Assets (JSONC)

All kernel-level config and registries live as **JSONC** under `~/.agents/assets/` (comments allowed — self-documenting, single source of truth). The current infra is resolved from tailscale via `infras_skills.jsonc`.

| Asset | Purpose | Consumed by |
|-------|---------|-------------|
| `assets/infras_skills.jsonc` | flat infra → k-* skill map | `startup-context.js` hook, `libs/jsonc/jsonc_lib.sh` `current_infra` |
| `assets/services.jsonc` | `.agents`-owned systemd services (direct list, `infras:[...]` or `*`) | `scripts/services/check-services.sh`, `reload-services.sh` |
| `assets/links.jsonc` | `.agents`-owned symlinks (direct list, `infras:[...]` or `*`) | `scripts/links/set-links.sh`, `check-links.sh` |

Shared libs (single source of truth, each has sh/py/js twins — see `libs/AGENTS.md`):
- JSONC helpers: `~/.agents/libs/jsonc/jsonc_lib.sh` (strip_jsonc / jsonc_valid / load_jsonc / current_infra / infra_matches) with Python (`jsonc_lib.py` — strip_jsonc / load_jsonc / load_jsonc_obj) and JS (`jsonc_lib.js` — stripJsonc / loadJsonc / loadJsoncObj). Python/JS callers import from `libs/jsonc/` instead of re-implementing comment-stripping (single source of truth; added 2026-08-15).
- Env helpers: `~/.agents/libs/env/env_lib.sh` (env_keys / env_has_value / env_validate_format / env_keys_not_in_example / env_load) with Python (`env_lib.py`) and JS (`env_lib.js`) twins. `.env` handling is centralized here — never re-implement `set -a; source` inline in a script. Secrets zero-touch: these helpers only expose key NAMES and present/empty status, never VALUES.

> **Libs-first reflex (MANDATORY):** before creating any helper/parser/loader inside `.agents`, **check `libs/` first** (especially `libs/jsonc/` and `libs/env/` for infra-skill scripts). If a fitting library exists, USE it; if not, add a new twin set there and expose it via a check in `scripts/`. Never duplicate logic inline.

> **Lint/type config single source of truth (2026-08-15):** `ruff.toml` centralizes rule ignores + `[lint.per-file-ignores]` (e.g. `E402` for scripts that `sys.path.insert` before importing local libs — no scattered `# noqa: E402` inline); `pyrightconfig.json` declares `extraPaths = ["libs", "scripts/check_skills"]` so pyright resolves shared sibling imports (no `reportMissingImports`). Both live at `.agents/` root — update there, never inline.

> **Update mandate (MANDATORY):** whenever you create or change a `.agents` service or symlink, **update the corresponding JSONC asset** (`services.jsonc` / `links.jsonc`) so `make check-services` / `make check-links` stay accurate. The `.agents/` asset is the source of truth; local paths are symlinks back to it.
>
> **External repo references convention (2026-08-15):** references to `.agents` files **from external repos** (techskills, 𝛱/TechSkills, Homelab, presentation, tutorials) use the **gitlab URL** of the real `.agents` file (`https://gitlab.com/kpihx/agents/-/blob/main/<path>`), **not a local template symlink**. `.agents` stays the single source of truth; no duplicate local symlinks into `.agents` from external repos.

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
- For agent kernel governance, load `k-ai` (AI hub + runtime registry) + `k-opencode` (hook architecture)
- For infrastructure-specific maintenance, load the relevant infra skill from `k-infras`

---

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/kpihx-labs/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/kpihx-labs/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-29 | [LIVE] | v2.11.0 — **`k-openvino` added to the kernel hierarchy** (new skill, generic top skills list) — OpenVINO GenAI local LLM serving, created after a session implementing its full OpenAI-compatible tool-calling/reasoning protocol. |
| 2026-08-25 | [CLAUDE] | v2.10.0 — **`k-windows` added to the kernel hierarchy** (new Windows/WSL/MSYS2 platform hub, migrated from an unversioned Windows-side `.agents`) under "top skills with OS-specific refs". *(Renumbered from v2.8.3 at PR merge.)* |
| [SUMMARY] | — | v2.9.1 setup block corrected at PR #1 integration (clone URL, ubuntu master exception, `-wsl` branch naming) · v2.9.0 Git branch per infra (GRAVÉ) — Infrastructure Directory Standard clone+switch flow (mirrors `rules/git-branch-per-infra.md` + `k-infras`) · v2.8.2 `blglaptop139` full WSL infra setup completed (`~/KpihX-Labs/AGENTS.md` created, `blglaptop139-wsl` node added to `assets/infras_skills.jsonc`) · v2.8.1 kernel hierarchy updated to renamed `k-phones` · v2.8.0 External repo refs convention · v2.7.0 Shared JSONC libs + lint/type single source · v2.6.0 Config Standard JSONC · v2.5.0 kernel tree cleanup · v2.4.0 k-ai reactivated · v2.3.0 Infrastructure Directory Standard (→ `references/log.md`) |
