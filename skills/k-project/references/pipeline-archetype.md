# k-project — Pipeline R&D Archetype

**⚠️ WHEN EDITING THIS FILE, ALSO UPDATE THE HEADER (VERSION).**

Distilled (form only, zero business content) from a real, mature multi-month R&D/ML pipeline project — both its Windows-side early snapshot and its much more advanced server copy were audited (2026-08-25) to extract this. Use this archetype instead of the default Service/Lib one (`SKILL.md`) when the project is a **multi-stage R&D/ML pipeline**: uv workspace, CPU/GPU hardware variants, heavy local non-code assets, several loosely-coupled processing stages.

Templates: `assets/pyproject.pipeline.toml`, `assets/Makefile.pipeline`.

## Directory layout

```
<project-name>/
├── AGENTS.md              ← from assets/AGENTS.md (root, gitignored by name — see k-git global excludes)
├── pyproject.toml         ← from assets/pyproject.pipeline.toml
├── Makefile               ← from assets/Makefile.pipeline
├── src/<package_name>/    ← thin CLI shell (Typer) + decisional/model code
│   ├── step_00_<name>.py
│   ├── step_01_<name>.py
│   └── ...
├── libs/                  ← uv workspace members, grouped by domain
│   └── <domain>/<member>/
│       ├── pyproject.toml
│       ├── src/
│       └── tests/
├── tests/
├── scripts/               ← human-owned META tooling, unrelated to the pipeline's own substance
│   └── mnt-sync/          ← e.g. k-rclone's mount-sync templates, if this project needs one
├── assets/                ← gitignored, project-local data — see below
├── tmp/                   ← gitignored scratch — see below
└── nbs/                   ← gitignored notebooks, optional
```

**`scripts/` vs `src/`/`libs/`**: `src/`/`libs/` hold the pipeline's own substance (the `step_NN_` stages, the reusable domain code). `scripts/` holds **meta** tooling that has nothing to do with what the pipeline computes — git hook installers (if any project-specific ones are needed beyond `k-git`'s global gates), mount-sync scripts, one-off maintenance scripts. Keep the two separated: a reader grepping `src/`/`libs/` for "what does this pipeline actually do" should never have to skip over sync/tooling code to find it.

**Dependency direction is one-way: `libs/` never imports `src/`.** `libs/` members hold zero business/dataset-specific constants — they're the reusable, portable part; `src/` is the thin, project-specific shell that wires them together. This is why splitting into `libs/` early (as soon as a second consumer of some code appears) beats letting `src/` grow into a single monolithic package — the lesson that motivated writing this archetype down.

Each `libs/<domain>/<member>/` is a real, independent uv workspace member: its own `README.md` + `pyproject.toml` + `src/` + `tests/`, registered in the root `[tool.uv.workspace] members` list (see `assets/pyproject.pipeline.toml`).

## `assets/` — no fixed structure by default, but a real convention in pipeline mode

There is **no predefined `assets/` structure in general** — a Service/Lib project's `assets/` (if any) is whatever that project needs. **In pipeline mode specifically**, the convention is:

```
assets/
├── inputs/
├── results/
│   ├── 00_<stage>/
│   ├── 01_<stage>/
│   └── ...
└── weights/        ← only if the pipeline trains/stores a model
```

- `inputs/` and `weights/` are flat (or per-stage, as needed) — no numbering.
- `results/` subfolders are **ordinal-numbered** (`00_`, `01_`, ...) in pipeline stage order, so their sort order always matches execution order. This differs deliberately from a ticket-ID-rooted layout (`<TICKET>_<slug>/`): that pattern only makes sense when a laptop/repo is shared across several unrelated work units at once. A  pipeline project is normally scoped to **one** self-contained repo per pipeline — so `assets/` numbering tracks **stage order within that one pipeline**, not a ticket registry.
- Each numbered `results/NN_<stage>/` folder should carry its own local `README.md` when its content isn't self-explanatory from filenames alone — link to it from a project-level synthesis doc rather than duplicating its content there (see Anti-patterns below).

## Scripts — `step_NN_<name>` naming

Python (and most languages') module names can't start with a digit — `00_preprocess.py` isn't importable. Hence the `step_` prefix: `step_00_preprocess.py`, `step_01_train.py`, etc. Keep the pipeline order encoded in **three places that must always agree**:
1. The module filename (`step_NN_<name>`)
2. The `[project.scripts]` CLI alias in `pyproject.toml`
3. A comment legend directly above `[project.scripts]` listing stage → name

`uv run <alias> --help` and "read the filename" should never disagree.

## `tmp/` — scratch discipline

Fixed, small root — never let it sprawl. A workable baseline (adapt subfolder names to the project, keep the count small):

```
tmp/
├── assets/    ← image/data scratch outputs
├── scripts/   ← agent's own working scripts (promotion to scripts/ is a manual human copy)
├── logs/
├── trash/     ← dated subfolders: trash/<YYYYMMDD>_<what>/
└── docs/      ← loose planning notes
```

Rules:
1. A new scratch thing goes into one of the fixed subfolders, never beside them at `tmp/` root.
2. No duplication between `tmp/` and the tracked tree — work either graduates fully (human copies it into `scripts/`/`libs/`) or stays fully in scratch.
3. **`tmp/` must never be named in any tracked file** (path, comment, docstring) — from the tracked tree's point of view it does not exist. This makes the scratch area safe to reorganize/wipe without breaking anything real.

## Git hooks — none needed locally

`k-git`'s global `core.hooksPath` passthrough already (a) blocks a commit if `make check` fails, and (b) strips AI-agent attribution trailers (`Co-authored-by:`, `Signed-off-by:`, `Author:`) from every commit message, for **every** repo automatically. **Never set `core.hooksPath` locally in a project** — it would silently opt that repo out of the global gates (submodule hygiene, Loom sync) instead of adding to them. If a project genuinely needs an extra project-specific hook, drop it at `.git/hooks/<name>` (untracked, machine-local) — the global passthrough re-chains to it automatically; there is no need for a custom installer script or a repo-local `core.hooksPath`.

## Heavy asset sync

When `assets/` needs syncing against a network drive, an NVMe mirror, or a Windows↔Linux boundary, don't write bespoke rsync scripts per project — see `k-rclone` → `references/mnt-sync.md` for the generic, customizable template (single `dirs.txt` source-of-truth manifest, one script per source/destination/OS combination, Makefile targets, live progress UI).

## Anti-patterns observed (avoid these)

- **Doc/Makefile drift** — a project's `AGENTS.md` documented Makefile targets that no longer existed in the real `Makefile`. At closure (`k-final`), diff the documented target list against real `make help` output.
- **Hook/check duplication** — don't reimplement `make check`'s steps inside a hook; a hook should call `make check`, never re-list its steps separately (now moot for the two globalized gates, but applies to any other project-specific hook).
- **Synthesis README polluted with results** — a project-wide "here's what we found" README filled with actual result tables/metrics instead of staying a pure pointer to per-stage/per-run READMEs. Keep synthesis docs free of content; link down instead of duplicating up.
- **Two independently-maintained membership lists** — if using a standalone `pyrightconfig.json` instead of `[tool.pyright]` in `pyproject.toml`, its `include`/`extraPaths` must be kept in sync by hand with `[tool.uv.workspace] members` — don't forget a new `libs/` member in both places.

