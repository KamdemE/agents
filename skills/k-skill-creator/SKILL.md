---
name: k-skill-creator
description: >
  Create, standardize, audit, and improve KπX skills. This is the KπX fork and governance
  overlay of the upstream skill-creator baseline. Use when creating a new skill, restructuring
  an existing one, enforcing the KπX skill standard, or running eval/benchmark loops on skill
  quality.
license: private
metadata:
  author: KpihX
  version: "2.6.0"
  scope: agent-governance
allowed-tools: Bash, Read, Write, Edit
---

# KπX — Skill Creator

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Role

`k-skill-creator` is the structural baseline for KπX skills.

- It is a KπX-owned fork of the upstream skill-creator workflow.
- It remains the reference for how KπX creates, audits, and evolves skills.
- Other `k-*` skills should stay compact and source-of-truth first, but they inherit their creation standard from here.

## KπX Overlay

Apply these KπX rules on top of the inherited baseline:

- Follow `$HOME/.agents/AGENTS.md` as the normative contract for response format, changelog limits, provenance tags, and `$HOME` generalization.
- For standard KπX skills, use `SKILL.md` at root and add `scripts/`, `references/`, and `assets/` only when they materially help.
- Keep downstream `k-*` skills concise: present the minimum runtime/workflow map, then point to the source files or dirs to inspect for detail.
- Keep `k-skill-creator` itself as the allowed exception that also ships upstream support dirs when needed, notably `agents/` and `eval-viewer/`.
- When a skill is renamed, moved, or added, propagate the change to `$HOME/.agents/AGENTS.md`, `$HOME/.agents/.skill-lock.json`, and any impacted `k-*` references.

## Infrastructure Scope

All skills must be designed **cross-infrastructure first**. Follow `rules/skill-infra-scope.md`.

### Infra Skill Checklist

When creating or editing an **infra skill** (any `k-*` for a machine — `k-ubuntu`, `k-phones`, `k-pve`, etc.), the agent MUST:

1. **Read `k-infras` first** — load it before any infra work. It contains:
   - The **New Infra Setup Checklist** — 7 init skills in order (k-zsh → k-tailscale → k-tmux → k-ssh → k-clis → k-nvim → k-opencode)
   - The **short name convention** — each infra has a Tailscale name and a short name (tmux session name)
   - The **Equipment Inventory** — all machines with their names, IPs, and skill mappings
2. **Read the specific infra skill** (e.g. `k-ubuntu`) to find its **short name** (used as tmux session name in `kshrc.base` auto-tmux).
3. **Ensure the infra skill mentions `k-zsh`** and **`k-ssh`** in its `> **Related skills:**` header.
4. **Ensure the infra skill references `k-infras`** for the full setup checklist.
5. **Ensure the infra skill has a `## Host Identity` table** with both the Tailscale name and the short name.
6. **For Termux/Android skills** (`k-phones`): skip `k-nvim` and `k-opencode` from the checklist (they do not run on Termux).
7. **For Windows-type infra skills** (a Windows machine, with or without WSL — e.g. `k-blglaptop139`): **read `k-windows` first, before Step 0** — it's the seed/template for generic Windows/WSL/MSYS2 knowledge (WSL bootstrap, `.wslconfig`, NTFS link mechanics, MSYS2, SSH-mount-as-a-drive). Move anything genuinely generic into `k-windows` rather than writing it directly into the new infra skill (mirrors the `k-zsh/assets/kshrc.base` → per-infra `assets/kshrc` copy-then-personalize relationship). Add the new infra skill to `k-windows`'s "Child Windows-type infra skills" list once created, and mention `k-windows` in the new skill's own `> **Related skills:**` header.

- The main `SKILL.md` describes the **general case** (cross-Linux, cross-platform).
- **OS-specific details** go in `references/<os>.md` (e.g., `ubuntu.md`, `windows.md`, `pve.md`).
- **Device-specific details** go in `references/<infra>.md`.
- In `SKILL.md`, link to OS refs with a header note: `> **OS references:** references/ubuntu.md ...`
- If a block starts with "On Ubuntu..." or "On Windows..." in the main skill, it belongs in a reference file instead.

> See `rules/skill-infra-scope.md` for the full rule.

## Structural Contract

For every KπX skill:

- valid YAML frontmatter with `name`, `description`, and `metadata.version`
- one H1 plus the edit reminder directly under it
- a footer `## Changelog` table
- newest-first explicit changelog rows
- max 2 explicit rows before a final `[SUMMARY]` row
- provenance tags in `[AGENT]` format
- a `references/insights.md` file (create if missing) plus an `## Insights Discipline (mandatory)` section in `SKILL.md` that states:
  - read `references/insights.md` before non-trivial domain work
  - update it at task end when durable insights are learned
  - keep the file autonomous/evolutionary (add, refine, reorganize, prune stale)
- **`scripts/`** for executable files (`.sh`, `.py`, binaries) — these are deployed or symlinked from `~/.local/bin/`
- **`assets/`** for non-executable support files (configs, templates, `.json`, `.service`, `.conf`)
- **`references/`** for documentation (`.md` files, OS-specific notes, insights)
- **`tests/`** for test files (e.g. `tests/hooks/<hook>.test.mjs`, `tests/<script>.test.py`) — mirroring the structure of the `scripts/` or `assets/` they validate. Create a `tests/` dir when a hook/script/guard has runnable checks: it is the durable source of truth for non-regression proof. See `k-opencode/tests/hooks/make-check-guard.test.mjs` as the reference example. Tests are NOT deployed/symlinked (unlike `scripts/`).

## Insights Discipline Template

For new or normalized skills, add this block verbatim and replace `<skill-name>`:

```md
## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/<skill-name>/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/<skill-name>/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.
```

Creation rule: initialize `references/insights.md` during skill creation (not as an optional afterthought).

Runtime guards:

- `scripts/check_skills/skill_structure_guard.py` checks the shared `SKILL.md` structure
- `scripts/check_skills/skill_content_guard.py` checks that bundled top-level files are surfaced in the skill document
- `scripts/check_skills/check_skills.py` is the compact recheck entrypoint when a broader skills governance sweep is needed (invoked via `make check-skills`, part of the `make check` chain)

## Standard Workflow

1. Read the target skill and the relevant rules in `$HOME/.agents/AGENTS.md`.
2. Decide whether the task is a creation, refactor, rename, audit, or eval loop.
3. Keep the skill concise: describe where the truth lives, not volatile inventories.
4. Mention only the bundled `scripts/`, `references/`, and `assets/` that materially matter to the workflow.
5. Complete the skill edit in one pass: bump `metadata.version` and update the footer changelog.
6. If the target is `k-context`, update `## Session Log` in the same pass and review `## Active Projects` if the work changed project scope or status.
7. If the skill changed materially, update `$HOME/.agents/skills/k-context/SKILL.md`.

## Bundled Tools

### Scripts

- `scripts/run_loop.py` orchestrates iterative eval loops
- `scripts/run_eval.py` runs a single evaluation batch
- `scripts/aggregate_benchmark.py` aggregates iteration outputs into benchmark summaries
- `scripts/generate_report.py` formats evaluation results into reports
- `scripts/improve_description.py` rewrites or improves skill descriptions
- `scripts/package_skill.py` packages a skill directory for distribution
- `scripts/quick_validate.py` runs fast validation checks
- `scripts/utils.py` provides shared helpers for the skill-creator script set

### References

- `references/schemas.md` is the source of truth for the JSON schemas used by this workflow
- `references/insights.md` stores durable k-skill-creator runtime lessons and anti-repeat patterns

### Reviewer Prompts

- `agents/analyzer.md` defines the analyzer role
- `agents/comparator.md` defines the comparator role
- `agents/grader.md` defines the grader role

### Viewer Assets

- `eval-viewer/generate_review.py` generates review pages for eval runs
- `eval-viewer/viewer.html` is the viewer frontend
- `assets/eval_review.html` is the local review template asset

## When To Use Eval Tooling

Use the eval loop only when quality needs to be compared or optimized, for example:

- improving a trigger description
- comparing two competing skill structures
- validating a new workflow against realistic prompts
- benchmarking regressions after a refactor

Do not run the heavy loop for trivial wording changes when structural validation is enough.

## Packaging And Distribution

- Keep `LICENSE.txt` when packaging or mirroring this baseline skill.
- Preserve support dirs that are part of the inherited workflow for this skill itself.
- For downstream KπX skills, strip accidental sprawl and keep only useful bundled files.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-skill-creator/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-skill-creator/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-25 | [CLAUDE] | v2.6.0 — Added item 7 to the Infra Skill Checklist: for a Windows-type infra skill, read the new `k-windows` (generic Windows/WSL/MSYS2 platform hub) before Step 0, move generic content there instead of duplicating it, and register the new infra in `k-windows`'s "Child Windows-type infra skills" list. |
| 2026-08-20 | [COLAB] | v2.5.1 — Updated the Android infra-skill example and Termux exception to `k-phones`. |
| [SUMMARY] | — | v2.5.0 tests/ dir added to Structural Contract (→ `references/log.md`) · v2.4.0 Infrastructure Scope section (→ `references/log.md`) · v2.3.2 insights contract · v2.3.1–v1.0.0: insights discipline baseline, compact skill-writing rule, hooks audit entrypoint, KπX governance overlays, earlier historical rows condensed. |
