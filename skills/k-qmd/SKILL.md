---
name: k-qmd
description: >
  Search KπX knowledge bases with QMD (BM25+vector hybrid). Load before any
  mcp__qmd-mcp__* call, or when searching past sessions, agent history, Ubuntu
  tutorials, homelab docs, or any local markdown knowledge base.
license: MIT
compatibility: Requires qmd CLI or MCP server. See references/mcp-setup.md for full setup.
metadata:
  author: tobi (upstream) / [CLAUDE] (KπX annotations)
  version: "2.12.1"
allowed-tools: Bash(qmd:*), mcp__qmd-mcp__*
---

# K-QMD - Quick Markdown Search

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Role

`k-qmd` is the entrypoint for searching local KπX knowledge bases.

- use it before any `mcp__qmd-mcp__*` call
- use it when you need past sessions, local docs, or agent/runtime knowledge
- keep this skill compact: exact setup and long command examples live in references

## Source Of Truth

| Topic | Where to look |
|------|----------------|
| Full install and MCP setup | `references/mcp-setup.md` |
| Optimization playbook | `references/qmd-optimization.md` |
| Embedded-folder `.gitignore` pattern | `references/gitignore-embedded-folder.template` |
| Auto-refresh hook example | `references/post-commit-hook.sh` |
| Live qmd runtime state | `qmd status`, `qmd collection list`, `qmd context list` |
| Declarative config | `$HOME/.config/qmd/index.yml` |

## KπX Collection Map

| Collection | Root path | Use for |
|-----------|-----------|---------|
| `tutos_live` | `$HOME/Work/tutos_live/` | Ubuntu fixes, tools, shell patterns |
| `presentation` | `$HOME/Work/Homelab/presentation/` | homelab architecture and project knowledge |
| `agents` | `$HOME/.agents/` | AGENTS, skills, hook architecture, session notes |
| `claude-memory` | `$HOME/.claude/projects/-home-kpihx/memory/` | Claude persistent memory |
| `codex` | `$HOME/.codex/` | Codex config/rules/docs only |
| `gemini` | `$HOME/.gemini/` | Gemini config/extensions only |
| `copilot` | `$HOME/.copilot/` | Copilot config and state checkpoints |
| `vibe` | `$HOME/.vibe/` | VIBE config and prompts |
| `openclaw` | `$HOME/.openclaw/workspace/` | OpenClaw KπX-local workspace knowledge |

Raw runtime histories stay out of QMD on purpose. Use the corresponding `k-*` runtime skill to find their on-disk paths, then inspect the files directly only when needed.

## Operational Rules

- run `qmd update <collection>` before searching when freshness matters
- run `qmd embed <collection>` only when new files were added or content changed materially
- keep QMD hot-only; large raw transcripts and chat/session histories do not belong in the index
- when a runtime skill already gives the path to a history folder, prefer that path over indexing the raw history into QMD
- always scope searches to the relevant collections when possible
- do not hardcode live collection inventories in other skills; point back here or to qmd itself
- when a repo collection name matches the repo root name, prefer symlinking `.git/hooks/post-commit` directly to the shared hook template instead of copying it

## Querying

### MCP

Use `query` with:
- `collections` to scope
- `searches` for `lex`, `vec`, or mixed retrieval
- `intent` only when disambiguation helps

Other qmd MCP tools to remember:
- `get`
- `multi_get`
- `status`

### CLI Fallback

When MCP is unavailable, use the qmd CLI directly:
- `qmd query ...`
- `qmd search ...`
- `qmd get ...`
- `qmd multi-get ...`

Exact command shapes and setup details live in `references/mcp-setup.md`.

## Collection Scope Reflex

- Ubuntu/system fix → `tutos_live`
- homelab architecture/project memory → `presentation`
- agent workflow, hooks, AGENTS, skills → `agents`
- agent-specific runtime config/docs → one of `claude-memory`, `codex`, `gemini`, `copilot`, `vibe`, `openclaw`
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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CODEX] | v2.12.1 — clarified in the optimization reference that the first Vulkan rebuild may print a temporary CPU/no-GPU warning and that the steady-state device truth must be checked with `qmd status` |
| 2026-04-04 | [CODEX] | v2.12.0 — documented the shared symlinkable post-commit hook model and aligned the hook reference with the repo-name-derived collection behavior |
| [SUMMARY] | — | v2.12.0–v2.0.0 covered the shared hook model, the optimization guide, the hot-only rewrite, prior collection strategy, the compact rewrite, the `k-qmd` rename, trigger clarifications, install/setup, masks, YAML config, query flows, collection scoping, gitignore template, and embed hygiene |
