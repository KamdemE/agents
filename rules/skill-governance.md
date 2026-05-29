# Skill Governance — Creation & Maintenance

> How to create, edit, and maintain KπX skills. Loaded from `AGENTS.md` kernel.

## Skill Creation Protocol

Before ANY skill creation or modification:
1. **Map first:** `tree -L 2 $HOME/.agents/skills/` · `rg -l '<keyword>' $HOME/.agents/skills/` · read the domain's `SKILL.md`
2. **Extend existing** — never duplicate identity tables, path lists, or runbooks
3. **Create only if nothing equivalent exists**

| Rule | Detail |
|------|--------|
| Single owner | Identity/admin/PDF paths → `kpihx`. Browser mechanics → `k-browser`. Mail → `k-mail`. |
| No duplicates | Never recopy identity tables, path lists, or runbooks in a second skill |
| No desync | Same fact = one source file; others **point** (relative link or `$HOME/.agents/skills/...` path) |
| Location | New skill `k-<domain>/` under `$HOME/.agents/skills/` + entry in `.skill-lock.json` |
| After edit | `metadata.version` + `## Changelog` in the touched skill; `make audit` BEFORE commit |

## Skill Structure MANDATORY

Every `k-*` skill MUST use the standard layout:
- `SKILL.md` at root (valid YAML frontmatter, `⚠️ WHEN EDITING THIS FILE...` reminder after H1, `## Changelog` at bottom)
- `scripts/` (executables) — created only as needed
- `references/` (docs/specs) — created only as needed
- `assets/` (templates, icons, output files) — created only as needed
- Non-standard dirs (e.g., `templates/`) are forbidden unless AGENTS explicitly documents the exception

## Skill Writing Rules

- Skills stay compact and source-of-truth first. Give the minimum operational map, then point to the owning file/dir to inspect.
- Do NOT re-copy long procedures, hook matrices, inventories, or rules that already live elsewhere.
- KπX-owned skills: `k-` prefix. External skills: no prefix (currently only `microsoft-foundry`).
- Reference baseline: `k-skill-creator` is the upstream reference that KπX forks and overlays with governance rules.

## Changelog Rules

- Newest-first
- SKILL.md: max 2 real entries + `[SUMMARY]`
- Summary rows must stay short and bounded; never replace real entries before the limit is reached
- Source-of-truth-first writing: when something can change, name the source file/directory to inspect instead of enumerating its current contents

## Version Bump

- Every edit → bump `metadata.version` (patch = minor edit, minor = new section)
- Every edit → update BOTH header (`metadata.version`) AND footer (`## Changelog`) in the same pass

## Agent-Owned Runtime Memory

Each agent owns its matching runtime skill (`k-codex`, `k-opencode`, `k-gemini`, etc.). As soon as the agent learns a new runtime fact, workaround, escalation pattern, config rule, failure mode, or repeated mistake for itself, it MUST update its own `k-<agent>/SKILL.md` proactively, in the same workstream, without asking KπX first.

## k-* Proactive Freshness (MANDATORY)

After using any `k-*` skill, confirm the owning `SKILL.md` still matches reality. If something was wrong, incomplete, or the documented steps failed and you found a working fix — patch that skill in the same workstream (operational text + `metadata.version` bump + `## Changelog`). Never leave skill drift or a successful workaround only in chat output.

## Insights Governance

- Every skill domain maintains `references/insights.md` runtime-memory file
- Agents autonomously manage these files: add/update/restructure/prune
- If a skill has no `references/insights.md`, create it immediately
- After creating a missing insights file, update the skill's `SKILL.md` to explicitly mention it
- Briefly inform KπX when new insights are added

## .skill-lock.json Sync

Skill added/removed/moved → update `$HOME/.agents/.skill-lock.json`.

## Agent Provenance

Tag edits with `[CLAUDE]`, `[GEMINI]`, `[OPENCODE]`, etc. (last writer wins).
