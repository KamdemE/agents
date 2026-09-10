# K-Context Hygiene

> Rules for maintaining `k-context` runtime state.

## Zero Information Loss (MANDATORY — reads before any other rule)

🔴 **NEVER lose information. NEVER delete. NEVER overwrite. Append-only is the only mode.**
- Every edit to any `.md` file under `.agents/` must be **additive** — new entries, new lines, new sections.
- For `k-context`: when `## Session Log`, `## Changelog`, or `Active Projects` hit their limit: **copy the overflow to `references/log.md` BEFORE condensing**. The compacted `[SUMMARY]` row is a summary of what was moved, never a replacement.
- For all other skills (except `k-context`): when their changelog reaches its limit (max 2 explicit rows), the older rows are simply condensed and summarized inside the table's `[SUMMARY]` row itself. No separate `references/log.md` is created or maintained for them.
- Archive files (`references/log.md` for `k-context`, `references/issues.md`) are **immutable** — no edits, no deletions, no rearrangements. Corrections = new appended entries pointing to the fix.
- Rotation (for `k-context`) = **copy, never cut**. The information must exist in TWO places before the original is condensed.
- This Zero Information Loss policy applies to all files under `.agents/`.

## Live Updates (agent-owned)
At any significant advance (new project, status change, commit, issue fix, non-trivial evolution) → update BOTH `Active Projects` and `Session Log` in `k-context/SKILL.md` immediately, proactively, without asking. Don't wait for session end.


## Limits
| Section | Max | Behavior when full |
|---------|-----|--------------------|
| Active Projects | 20 live rows | Condense stale/completed items into `[ARCHIVE]` row |
| Session Log | 10 entries (newest-first) | Condense older into `[SUMMARY]` row |
| Changelog (SKILL.md) | 2 real rows | Condense older into `[SUMMARY]` row |
Never condense early. Only when the limit is reached.

## k-context Edit Completion
When editing `k-context/SKILL.md`: update `## Session Log` + review `## Active Projects` in the same pass.

## Sessions
- Session end: Stop hook enforces final k-context check before closing
- TODOs in k-context: Only KπX adds; agents execute + remove

## Issue Surfacing Mandate
Any opinion on the work (good, bad, suboptimal, security) → surface in `Commentaires` (FREE OPINION, frank, no length limit). Any detected bug, risk, stale reference, duplication, desync → surface in `Remarques` (FREE ALERT, cold-headed, even off-request). Anything worth knowing outside KπX's context (better method, intuition behind the build, new tool) → surface in `Insights` (TUTOR mode, feeds curiosity). Three independent free-expression territories — each whenever pertinent, never either/or, ALL strongly recommended, NO length limit. If ignored, keep repeating every turn (even verbatim) while still pertinent, until addressed. A seen falsehood is flagged in `Remarques` immediately — never ask permission to flag. Flag first, offer the deep-dive second.

## Brainstorm Registry
Long-lived ideas go in `references/`. Add a `.md` file when a brainstorm should survive sessions. Register each file in `## Brainstorm Registry`.

## What's Up
See `rules/whats-up.md` for the full protocol.
