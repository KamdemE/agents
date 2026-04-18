---
name: k-qmd
description: >
  Search KπX knowledge bases with QMD (BM25+vector hybrid) through the local CLI.
  Load when searching past sessions, agent history, Ubuntu tutorials, homelab
  docs, or any local markdown knowledge base.
license: MIT
compatibility: Requires local qmd CLI. CLI-first runtime; no qmd MCP should remain configured in agent runtimes.
metadata:
  author: tobi (upstream) / [CLAUDE] (KπX annotations)
  version: "2.14.1"
allowed-tools: Bash(qmd:*), Bash(qmdr:*)
---

# K-QMD - Quick Markdown Search

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Role

`k-qmd` is the entrypoint for searching local KπX knowledge bases.

- use it before any important QMD CLI search flow
- use it when you need past sessions, local docs, or agent/runtime knowledge
- keep this skill compact: exact setup and long command examples live in references

## Source Of Truth

| Topic | Where to look |
|------|----------------|
| Full install and MCP setup | `references/mcp-setup.md` |
| Optimization playbook | `references/qmd-optimization.md` |
| Embedded-folder `.gitignore` pattern | `references/gitignore-embedded-folder.template` |
| Auto-refresh hook example | `references/post-commit-hook.sh` |
| Fresh-search wrapper | `scripts/qmdr` |
| Live qmd runtime state | `qmd status`, `qmd collection list`, `qmd context list` |
| Declarative config | `$HOME/.config/qmd/index.yml` |

## KπX Collection Map

| Collection | Root path | Use for |
|-----------|-----------|---------|
| `techskills` | `$HOME/Work/techskills/` | Ubuntu fixes, tools, shell patterns |
| `presentation` | `$HOME/Work/Homelab/presentation/` | homelab architecture and project knowledge |
| `agents` | `$HOME/.agents/` | AGENTS, skills, hook architecture, session notes |
| `claude-memory` | `$HOME/.claude/projects/-home-kpihx/memory/` | Claude persistent memory |
| `codex` | `$HOME/.codex/` | Codex config/rules/docs only |
| `gemini` | `$HOME/.gemini/` | Gemini config/extensions only |
| `copilot` | `$HOME/.copilot/` | Copilot config and state checkpoints |
| `vibe` | `$HOME/.vibe/` | VIBE config and prompts |

Raw runtime histories stay out of QMD on purpose. Use the corresponding `k-*` runtime skill to find their on-disk paths, then inspect the files directly only when needed.

## Operational Rules

- run `qmd update <collection>` before searching when freshness matters
- run `qmd embed <collection>` only when new files were added or content changed materially
- before any important semantic or exploratory search, run `qmd status`; if `Pending > 0`, run `qmd embed` before querying
- prefer `qmdr query/search/vsearch ...` for important searches so the freshness gate is enforced automatically
- use plain `qmd` for admin/read flows: `status`, `get`, `multi-get`, `embed`, `update`, `cleanup`, `collection ...`
- keep QMD hot-only; large raw transcripts and chat/session histories do not belong in the index
- when a runtime skill already gives the path to a history folder, prefer that path over indexing the raw history into QMD
- always scope searches to the relevant collections when possible
- do not hardcode live collection inventories in other skills; point back here or to qmd itself
- when a repo collection name matches the repo root name, prefer symlinking `.git/hooks/post-commit` directly to the shared hook template instead of copying it

## Querying

### CLI

QMD is now CLI-first in KπX runtimes. Use:
- `qmd query ...`
- `qmd search ...`
- `qmd get ...`
- `qmd multi-get ...`
- `qmdr query ...`
- `qmdr search ...`
- `qmdr vsearch ...`

Rule of thumb:
- `qmd` = inspect, administer, or fetch exact content
- `qmdr` = important search/exploration where freshness must be guaranteed first

Exact command shapes and setup details live in `references/mcp-setup.md`.

## Collection Scope Reflex

- Ubuntu/system fix → `techskills`
- homelab architecture/project memory → `presentation`
- agent workflow, hooks, AGENTS, skills → `agents`
- agent-specific runtime config/docs → one of `claude-memory`, `codex`, `gemini`, `copilot`, `vibe`
- raw agent histories → use the corresponding `k-*` runtime skill path, not QMD

## Troubleshooting

- native module or install issues → reinstall via `npm`, not bun
- missing MCP results → check qmd config/runtime directly, then re-index
- slow first query → expected if local models or reranking backends are cold

## References

- `references/mcp-setup.md` — full installation, config, and CLI/MCP usage details
- `references/qmd-optimization.md` — inspection checklist, SQLite probes, cleanup flow, and latest QMD optimization actions
- `references/gitignore-embedded-folder.template` — baseline whitelist-style `.gitignore` for embedded folders
- `references/post-commit-hook.sh` — shared git hook template for repo-name-derived collections; safe by default (`update-only`, optional debounced embeddings)
- `scripts/qmdr` — explicit wrapper that auto-runs the freshness gate before `query`, `search`, or `vsearch`

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-qmd/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-qmd/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-13 | [CODEX] | v2.14.1 — Standardized insights discipline and autonomous maintenance hooks for this skill. |
| 2026-04-04 | [CODEX] | v2.14.0 — removed one retired runtime collection from the active KπX QMD map |
| [SUMMARY] | — | +1 older changelog entries kept in file history; condensed for table limits |