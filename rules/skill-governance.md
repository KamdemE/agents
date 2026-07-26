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
