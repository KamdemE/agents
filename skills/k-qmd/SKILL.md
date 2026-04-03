---
name: k-qmd
description: >
  Search KπX knowledge bases with QMD (BM25+vector hybrid). Collections: tutos_live
  (Ubuntu fixes/tools), presentation (homelab architecture/projects), agents (AGENTS.md,
  skills, session history), k-ai, claude-memory, codex, gemini, copilot, vibe, openclaw.
  Load before any mcp__qmd-mcp__* call, or when searching past sessions, agent history,
  Ubuntu tutorials, homelab docs, or any local markdown knowledge base.
license: MIT
compatibility: Requires qmd CLI or MCP server. See references/mcp-setup.md for full setup.
metadata:
  author: tobi (upstream) / [CLAUDE] (KπX annotations)
  version: "2.7.0"
allowed-tools: Bash(qmd:*), mcp__qmd-mcp__*
---

# K-QMD - Quick Markdown Search

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

Local search engine for markdown content — BM25 + vector + hyde hybrid with local LLM reranking.

## Status

!"qmd status 2>/dev/null || echo "Not installed — see references/mcp-setup.md"

## Installation

> ⚠️ **Full setup procedure: `references/mcp-setup.md`**

```bash
# Use npm (NOT bun) — better-sqlite3 is a native module compiled against the
# active Node.js version. With a custom npm prefix (e.g. $HOME/.npm-global), use
# the full binary path in MCP configs instead of bare `qmd`.
npm install -g @tobilu/qmd

# Add a collection (path first, --name is a flag — NOT positional)
# --mask overrides the default glob (default: **/*.md)
qmd collection add $HOME/path/to/docs --name myname --mask "**/*.{md,txt}"

# ALWAYS add a context description right after (improves reranking)
qmd context add qmd://myname/ "What this collection contains"

# Verify, then embed
qmd collection show myname
qmd embed myname
```

**Post-commit auto-update:** copy `references/post-commit-hook.sh` to `.git/hooks/post-commit`, set `COLLECTION` + `PATTERN`, `chmod +x`. Keeps the index fresh on every commit — recommended for doc repos.

**New folder to embed (git + qmd):** use `references/gitignore-embedded-folder.template` as the starting `.gitignore`. It implements the whitelist negation pattern (`*` + `!*/` + `!*.ext`) with all sections pre-labelled. Copy → uncomment extensions → add sensitive exclusions.

## Collection Management

### CLI

```bash
qmd collection add <path> --name <n> [--mask "**/*.{md,yml}"]  # add
qmd collection list                    # all collections + file counts
qmd collection show <name>             # path, pattern, include flag
qmd collection remove <name>           # remove (files untouched)
qmd collection rename <old> <new>      # rename
qmd collection include/exclude <name>  # toggle default search scope
qmd collection update-cmd <name> 'git pull --rebase'  # auto-sync before re-index
qmd context add qmd://<name>/ "desc"   # add context (do for every collection)
qmd context add qmd://<name>/subdir "specific section desc"
qmd context list
qmd ls <name>                          # list indexed files
qmd update [--pull] [<name>]           # re-index (--pull runs update-cmd first)
qmd embed [<name>]                     # re-embed vectors
```

### YAML config (alternative to CLI — `$HOME/.config/qmd/index.yml`)

Declarative approach; changes take effect immediately:

```yaml
global_context: "Optional hint applied to all collections."

collections:
  notes:
    path: $HOME/Documents/notes
    pattern: "**/*.md"
    context:
      "/": "Personal notes and ideas"
      "/meetings": "Meeting notes"

  code:
    path: $HOME/Work/myproject
    pattern: "**/*.{md,ts,py}"
    context:
      "/": "Source code and docs for myproject"
```

### Supported `--mask` / `pattern` extensions

Any text-based format works: `.md` `.txt` `.markdown` `.rst` `.html` `.json` `.yml` `.yaml` `.toml` `.sh` `.ts` `.js` `.py` `.go` `.rs` — standard glob syntax.

## Before Searching — Always Update First

Before any search, re-index the target collections to guarantee fresh results:

```bash
qmd update <name>          # re-index changed files (fast, no re-embed)
qmd update --pull <name>   # pull first if update-cmd is set (e.g. git pull)
qmd embed <name>           # re-embed vectors (slower, only needed after content changes)
```

**Rule:** `qmd update` before every search session. `qmd embed` only when new files were added or content changed significantly.

## MCP: `query`

```json
{
  "searches": [
    { "type": "lex", "query": "CAP theorem consistency" },
    { "type": "vec", "query": "tradeoff between consistency and availability" }
  ],
  "intent": "optional disambiguation string",
  "collections": ["agents", "tutos_live"],
  "limit": 10
}
```

**Scoping collections:** Always pass `collections` to restrict search scope. Without it, qmd searches all enabled collections — much slower and noisier.

| Scope | `collections` value |
|-------|---------------------|
| Single | `["agents"]` |
| Multiple | `["tutos_live", "presentation"]` |
| All (explicit) | omit the field or `[]` |

> 💡 **Collection scope reflex:** Know what you're looking for → scope it. Ubuntu fix → `tutos_live`. Agent config → `agents` or `claude`/`codex`/etc. Architecture → `presentation`. Past session → `k-ai` or `claude`.

### Query Types

| Type | Method | Best for |
|------|--------|----------|
| `lex` | BM25 | Exact terms, names, code identifiers |
| `vec` | Vector | Natural language questions |
| `hyde` | Vector | Write the answer you expect (50-100 words) |
| `expand` | Auto | Single-line query → LLM expands to lex/vec/hyde |

**lex:** `term` (prefix match) · `"phrase"` (exact) · `-term` (exclude, lex only)

**Combining:**

| Goal | Approach |
|------|----------|
| Know exact terms | `lex` only |
| Don't know vocabulary | Single-line (implicit `expand:`) or `vec` |
| Best recall | `lex` + `vec` |
| Complex topic | `lex` + `vec` + `hyde` |
| Ambiguous query | Add `intent` to any combination |

First query gets 2× weight in fusion — put your best guess first.

**`intent`:** Steering signal (not a search itself). Disambiguates terms like "performance" → web perf vs. team health. Affects expansion, reranking, and snippet extraction.

## Other MCP Tools

| Tool | Use |
|------|-----|
| `get` | Retrieve doc by path or `#docid` |
| `multi_get` | Retrieve multiple by glob / comma list |
| `status` | Index health, collection stats |

## CLI (fallback when MCP unavailable)

```bash
qmd query "question"                       # auto-expand + rerank
qmd query $'lex: X\nvec: Y'               # structured
qmd search "keywords"                      # BM25 only (no LLM)
qmd get "#abc123"                          # by docid
qmd multi-get "journals/2026-*.md" -l 40  # batch snippets by glob
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `ERR_DLOPEN_FAILED` / MODULE_VERSION mismatch | Reinstall via `npm` (not bun); use full binary path in MCP config |
| MCP not found in agent | Restart agent after editing config |
| No results | Run `qmd embed`; check `qmd collection list` |
| Slow first search | Normal — local models loading (~3 GB) |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.7.0 — renamed the skill to `k-qmd` and aligned its identity with the KπX `k-*` convention while keeping the `qmd` CLI/MCP runtime unchanged |
| 2026-03-29 | [CLAUDE] | v2.6.0 — description rewritten: explicit collections list + trigger conditions |
| [SUMMARY] | — | v2.0–2.5: install, --mask, YAML config, update-cmd, query docs, collection scoping, gitignore template, embed scope hygiene |
