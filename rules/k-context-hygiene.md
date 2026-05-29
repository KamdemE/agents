# K-Context Hygiene — Session Log & Memory

> Rules for maintaining `k-context` runtime state. Enforced by session_guard hook.

## k-context Live Updates (agent-owned)

The agent owns `Active Projects` and `Session Log` in k-context. At any significant advance — new project, new topic, status change, new commit, non-trivial evolution, issue fix — update both sections immediately, proactively, without asking. Don't wait for session end.

## Limits

| Section | Max | Behavior when full |
|---------|-----|--------------------|
| `Active Projects` | 20 live rows | Condense stale/completed items into `[ARCHIVE]` row |
| `Session Log` | 10 entries (newest-first) | Condense older entries into `[SUMMARY]` row |
| `Changelog` (SKILL.md) | 2 real rows | Condense older into `[SUMMARY]` row |

Never condense or summarize early. Only when the limit is reached.

## k-context Edit Completion

When editing `skills/k-context/SKILL.md`:
- Update `## Session Log` in the same pass
- Review `## Active Projects` if the work changed project scope or status

## Sessions

- **Session end mandate:** Stop hook enforces a final k-context check before closing
- **TODOs in k-context:** Only KπX adds; agents execute + remove

## Issue Surfacing Mandate

Any detected bug, risk, stale reference, duplication, desync, or outdated instruction MUST be surfaced in `Remarques` immediately and repeated until addressed.

## Brainstorm Registry

Long-lived ideas and WIP project visions go in `skills/k-context/references/`.
- Add a new `.md` file when a brainstorm should survive sessions and QMD indexing
- Register each file in `## Brainstorm Registry` in `k-context/SKILL.md`
- Do NOT treat brainstorm files as operational runbooks until promoted to a skill or `techskills`/`presentation`

## What's Up Protocol

See `rules/whats-up.md` for the complete greeting/status digest workflow.
