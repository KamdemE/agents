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
  version: "2.4.0"
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

When creating or editing an **infra skill** (any `k-*` for a machine — `k-ubuntu`, `k-25`, `k-pve`, etc.), the agent MUST:

1. **Read `k-infras` first** — load it before any infra work. It contains:
   - The **New Infra Setup Checklist** — 7 init skills in order (k-zsh → k-tailscale → k-tmux → k-ssh → k-clis → k-nvim → k-opencode)
   - The **short name convention** — each infra has a Tailscale name and a short name (tmux session name)
   - The **Equipment Inventory** — all machines with their names, IPs, and skill mappings
2. **Read the specific infra skill** (e.g. `k-ubuntu`) to find its **short name** (used as tmux session name in `kshrc.base` auto-tmux).
3. **Ensure the infra skill mentions `k-zsh`** and **`k-ssh`** in its `> **Related skills:**` header.
4. **Ensure the infra skill references `k-infras`** for the full setup checklist.
5. **Ensure the infra skill has a `## Host Identity` table** with both the Tailscale name and the short name.
6. **For Termux/Android skills** (`k-25`): skip `k-nvim` and `k-opencode` from the checklist (they do not run on Termux).

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
| 2026-07-22 | [OPENCODE] | v2.4.0 — Added Infrastructure Scope section: cross-infrastructure first design, OS-specific details go in `references/<os>.md`. References `rules/skill-infra-scope.md`. |
| 2026-04-13 | [CODEX] | v2.3.2 — Added explicit skill-creation contract for `references/insights.md` and mandatory `## Insights Discipline` usage in downstream skills. |
| [SUMMARY] | — | v2.3.1–v1.0.0: standardized insights discipline baseline, compact skill-writing rule, hooks audit entrypoint, KπX governance overlays, and earlier historical rows condensed for table limits. |