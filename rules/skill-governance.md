# Skill Governance

> Rules for creating, editing, and maintaining KπX skills.

## Before ANY skill edit
1. Map first: `tree -L 2 $HOME/.agents/skills/` · `rg -l '<keyword>' $HOME/.agents/skills/`
2. Read the domain's `SKILL.md` fully
3. Extend existing — never duplicate identity tables, path lists, or runbooks
4. Create only if nothing equivalent exists

| Rule | Detail |
|------|--------|
| Single owner | Identity/admin/PDF paths → `kpihx`. Browser → `k-browser`. Mail → `k-mail`. |
| No duplicates | Never recopy identity tables or path lists in a second skill |
| No desync | Same fact = one source file; others POINT (relative link or `$HOME/.agents/skills/...` path) |
| Location | New skill `k-<domain>/` under `$HOME/.agents/skills/` + entry in `.skill-lock.json` |
| After edit | Bump `metadata.version` + `## Changelog` in the touched skill; `make check` BEFORE commit |

## Skill Structure (MANDATORY)
Every `k-*` skill: `SKILL.md` at root (YAML frontmatter, `⚠️ WHEN EDITING...` reminder, `## Changelog` at bottom). Optional: `scripts/`, `references/`, `assets/`.

## Skill Size Limits (MANDATORY)
To keep the documentation clean, scannable, and maintainable, `SKILL.md` files must never exceed **300 lines**.
- When a `SKILL.md` file approaches or exceeds this limit, agents must proactively synthesize the content, extract detailed installation guides, command references, and troubleshooting steps into standalone markdown files under the `references/` subdirectory of that skill, and add a link in the main `SKILL.md`.
- No information must be lost: the creation of these reference files is mandatory to preserve details.
- This limit is strictly enforced by the audit pipeline.
- **Exception — `k-context`:** this flat 300-line target does NOT apply to `k-context/SKILL.md`. `k-context` already has its own dedicated capacity-management mechanism (see `rules/k-context-hygiene.md`): `## Session Log` capped at 10 explicit rows, `## Changelog` capped at 2 explicit rows, both rolling overflow to `references/log.md` — while `## Active Projects` and `## Active TODOs` are allowed to grow (append-only, condensed into `[ARCHIVE]`/removed only per k-context's own rules, never by a blanket line-count cutoff). The audit pipeline explicitly skips the 300-line check for `k-context`.

## Changelog Rules
- Newest-first. SKILL.md: max 2 real entries + `[SUMMARY]`.
- Summary rows stay short; never replace real entries before the limit.

## Agent-Owned Runtime Memory
Each agent owns its `k-<agent>/SKILL.md`. When you learn a new runtime fact, workaround, or config rule — UPDATE the skill proactively in the same workstream, without asking.

## k-* Proactive Freshness (MANDATORY)
After using any `k-*` skill: confirm the owning `SKILL.md` still matches reality. If wrong/incomplete → patch it immediately (operational text + version bump + changelog).

## Insights Governance
Every skill domain maintains `references/insights.md`. Agents manage these files autonomously (add/update/restructure). If missing → create it immediately. After creating → mention it in SKILL.md.

## .skill-lock.json Sync
Skill added/removed/moved → update `$HOME/.agents/.skill-lock.json`.

## Agent Provenance
Tag edits with `[CLAUDE]`, `[GEMINI]`, `[OPENCODE]`, etc. Last writer wins.
