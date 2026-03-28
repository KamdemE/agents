---
name: qmd
description: Search markdown knowledge bases, notes, and documentation using QMD. Use when users ask to search notes, find documents, or look up information.
license: MIT
compatibility: Requires qmd CLI or MCP server. See references/mcp-setup.md for full setup.
metadata:
  author: tobi (upstream) / [CLAUDE] (KπX annotations)
  version: "2.3.0"
allowed-tools: Bash(qmd:*), mcp__qmd-mcp__*
---

# QMD - Quick Markdown Search

Local search engine for markdown content — BM25 + vector + hyde hybrid with local LLM reranking.

## Status

!`qmd status 2>/dev/null || echo "Not installed — see references/mcp-setup.md"`

## Installation

> ⚠️ **Full setup procedure: `references/mcp-setup.md`**

```bash
# Use npm (NOT bun) — better-sqlite3 is a native module compiled against the
# active Node.js version. With a custom npm prefix (e.g. ~/.npm-global), use
# the full binary path in MCP configs instead of bare `qmd`.
npm install -g @tobilu/qmd

# Add a collection (path first, --name is a flag — NOT positional)
# --mask overrides the default glob (default: **/*.md)
qmd collection add ~/path/to/docs --name myname --mask "**/*.{md,txt}"

# ALWAYS add a context description right after (improves reranking)
qmd context add qmd://myname/ "What this collection contains"

# Verify, then embed
qmd collection show myname
qmd embed myname
```

**Post-commit auto-update:** copy `references/post-commit-hook.sh` to `.git/hooks/post-commit`, set `COLLECTION` + `PATTERN`, `chmod +x`. Keeps the index fresh on every commit — recommended for doc repos.

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

### YAML config (alternative to CLI — `~/.config/qmd/index.yml`)

Declarative approach; changes take effect immediately:

```yaml
global_context: "Optional hint applied to all collections."

collections:
  notes:
    path: ~/Documents/notes
    pattern: "**/*.md"
    context:
      "/": "Personal notes and ideas"
      "/meetings": "Meeting notes"

  code:
    path: ~/Work/myproject
    pattern: "**/*.{md,ts,py}"
    context:
      "/": "Source code and docs for myproject"
```

### Supported `--mask` / `pattern` extensions

Any text-based format works: `.md` `.txt` `.markdown` `.rst` `.html` `.json` `.yml` `.yaml` `.toml` `.sh` `.ts` `.js` `.py` `.go` `.rs` — standard glob syntax.

## MCP: `query`

```json
{
  "searches": [
    { "type": "lex", "query": "CAP theorem consistency" },
    { "type": "vec", "query": "tradeoff between consistency and availability" }
  ],
  "intent": "optional disambiguation string",
  "collections": ["docs"],
  "limit": 10
}
```

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
| 2026-03-28 | [CLAUDE] | v2.3.0 — restored full query type docs; added --mask, YAML config, update-cmd, include/exclude |
| [SUMMARY] | — | v2.0–2.2 — upstream install + KπX annotations + compaction |
