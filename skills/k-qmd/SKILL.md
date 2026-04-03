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
  version: "2.8.1"
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
| `k-ai` | `$HOME/.k-ai/` | KπX AI agent project |
| `claude-memory` | `$HOME/.claude/projects/-home-kpihx/memory/` | Claude persistent memory |
| `codex` | `$HOME/.codex/` | Codex config and history |
| `gemini` | `$HOME/.gemini/` | Gemini config and history |
| `copilot` | `$HOME/.copilot/` | Copilot config and history |
| `vibe` | `$HOME/.vibe/` | VIBE config and history |
| `openclaw` | `$HOME/.openclaw/workspace/` | OpenClaw workspace knowledge |

## Operational Rules

- run `qmd update <collection>` before searching when freshness matters
- run `qmd embed <collection>` only when new files were added or content changed materially
- always scope searches to the relevant collections when possible
- do not hardcode live collection inventories in other skills; point back here or to qmd itself

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
- agent-specific runtime/history → one of `claude-memory`, `codex`, `gemini`, `copilot`, `vibe`, `openclaw`
- KπX AI project → `k-ai`

## Troubleshooting

- native module or install issues → reinstall via `npm`, not bun
- missing MCP results → check qmd config/runtime directly, then re-index
- slow first query → expected if local models or reranking backends are cold

## References

- `references/mcp-setup.md` — full installation, config, and CLI/MCP usage details
- `references/gitignore-embedded-folder.template` — baseline whitelist-style `.gitignore` for embedded folders
- `references/post-commit-hook.sh` — example git hook to refresh a collection synchronously and launch embeddings in the background without blocking commits

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.8.1 — updated the bundled post-commit hook reference to the non-blocking pattern: collection-scoped `update`, deduplicated background `embed`, and explicit log location |
| 2026-04-03 | [CODEX] | v2.8.0 — rewrote the skill into a compact source-of-truth map, kept the collection map visible, and moved volatile setup/command detail behind references instead of embedding large live-like inventories in the skill body |
| [SUMMARY] | — | v2.8.0–v2.0.0 covered the compact rewrite, the `k-qmd` rename, trigger clarifications, install/setup, masks, YAML config, query flows, collection scoping, gitignore template, and embed hygiene |
