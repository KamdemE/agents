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
  version: "2.1.0"
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
- Keep `k-skill-creator` itself as the allowed exception that also ships upstream support dirs when needed, notably `agents/` and `eval-viewer/`.
- When a skill is renamed, moved, or added, propagate the change to `$HOME/.agents/AGENTS.md`, `$HOME/.agents/.skill-lock.json`, and any impacted `k-*` references.

## Structural Contract

For every KπX skill:

- valid YAML frontmatter with `name`, `description`, and `metadata.version`
- one H1 plus the edit reminder directly under it
- a footer `## Changelog` table
- newest-first explicit changelog rows
- max 2 explicit rows before a final `[SUMMARY]` row
- provenance tags in `[AGENT]` format

Runtime guards:

- `hooks/core/skill_structure_guard.py` checks the shared `SKILL.md` structure
- `hooks/core/skill_content_guard.py` checks that bundled top-level files are surfaced in the skill document
- `hooks/core/audit.py` is the compact recheck entrypoint when a broader hooks/skills governance sweep is needed

## Standard Workflow

1. Read the target skill and the relevant rules in `$HOME/.agents/AGENTS.md`.
2. Decide whether the task is a creation, refactor, rename, audit, or eval loop.
3. Keep the skill concise: describe where the truth lives, not volatile inventories.
4. Mention bundled `scripts/`, `references/`, and `assets/` that matter to the workflow.
5. Bump `metadata.version` and update the footer changelog.
6. If the skill changed materially, update `$HOME/.agents/skills/k-context/SKILL.md`.

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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.1.0 — added `hooks/core/audit.py` as the compact governance recheck entrypoint and kept the skill aligned with the live hook/guard standard |
| 2026-04-03 | [CODEX] | v2.0.0 — restored the skill after the interrupted rewrite, reframed it as the KπX forked baseline for skill standards, and documented all bundled scripts, reviewer prompts, references, and viewer assets so the shared guards can validate it cleanly |
| [SUMMARY] | — | v1.1.0 aligned the skill name with the KπX `k-*` convention and propagated the rename contract to AGENTS and the shared hook guards; v1.0.0 upstream baseline workflow retained with KπX governance overlays documented here instead of being inferred piecemeal from unrelated skills |
