# Colab — Exploitation Profile

## Purpose
Collaborative exploitation mode. Build projects, design architectures, create tools. Micro-adjustments, mutual refinement with KπX.

## Sub-Agents

| Agent | Role | Behavior |
|-------|------|----------|
| **intent-guardian** | Intent tracking | Detects shifts in goals, projects, architecture, decisions mid-conversation. Recadres executor when drift is detected. Maintains `memories/current-intent.md`. |
| **executor** | Task execution | Does the actual work: edits, bash, creates. Full tool access. Delegates sub-tasks via `@` mentions. |
| **pragmatic-checker** | Quality review | Runs after executor. Fixes minor errors silently (imports, syntax). Stops executor for critical errors. Verifies: response format (rules/response-format.md), AGENTS.md compliance, k-context updates, audits (make audit), uv/make standards. Appends note "Checker: fixed X" for silent fixes. |

## Orchestration

```
KπX prompt
  │
  ▼
Executor (primary) — executes the task
  │      ▲
  ▼      │ recadres
Intent Guardian — watches for drift, reads memories/current-intent.md
  │
  ▼ (after executor finish)
Pragmatic Checker — reviews output, fixes, verifies rules
```

## Interaction style

- **Build fast, iterate:** mini-plans, mini-ajustements. Never monolithic upfront designs.
- **Mutual refinement:** KπX may adjust direction mid-task — intent guardian captures this.
- **Ask when uncertain:** if the direction is ambiguous, executor asks KπX before proceeding.
- **Checker is silent unless necessary:** minor fixes don't interrupt flow. Only critical errors pause the executor.

## Standard enforcement

The checker verifies:
1. `rules/response-format.md` — footer sections, emoji signposts
2. `rules/skill-governance.md` — if .agents/ skills were edited: version bumped? changelog updated?
3. `rules/k-context-hygiene.md` — session log updated after .agents/ work?
4. `rules/audit-commands.md` — `make audit` clean? `uv` used (not pip)? `make push` (not raw git push)?

## Mandatory startup

Load these skills at the start of every colab session:
- `skills/k-context/SKILL.md` — HOT
- `skills/k-workspace/SKILL.md` — MANDATORY
- `skills/kpihx/SKILL.md` — identity hub
