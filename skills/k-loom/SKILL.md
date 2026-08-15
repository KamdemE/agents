---
name: "k-loom"
description: "Loom — lightweight persistent code index MCP for cross-session code search and context retrieval"
license: "private"
metadata:
  author: "KpihX"
  version: "1.2.0"
  scope: "code-tooling"
---

# Loom — Persistent Code Index

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **What it is:** Persistent SQLite index of your codebase. Cross-session code search — unlike AST parsers that parse fresh. Relationship-aware: who calls what, where is this defined.
>
> **When to use:** Find code you indexed yesterday without re-reading files.

---

## Installation & MCP

```bash
uv tool install loom-tool                     # one time → `loom` + `loom-mcp` in PATH
cd ~/KpihX-Labs/proxies/tg-proxy && loom analyze .    # build index (~10-60s)
cd ~/KpihX-Labs/proxies/tg-proxy && loom install      # git post-commit hook → auto-sync on commit
```

The git hook runs `loom sync --old-sha HEAD~1 --new-sha HEAD` after every commit (~2-5s, incremental).

MCP config in `opencode.jsonc` (already set):
```jsonc
"loom": { "type": "local", "command": ["loom-mcp"], "enabled": true, "timeout": 60000 }
```

---

## Real Commands (loom 0.7.1)

| Command | Description |
|---------|-------------|
| `loom analyze <path>` | Build or refresh the full index for a repo |
| `loom sync` | Incremental sync (SHA-256 driven). Run after file edits without committing |
| `loom query <query>` | FTS5 full-text search across all nodes (functions, classes, files) |
| `loom callers <name>` | List direct callers of a function (one-hop incoming CALLS) |
| `loom callees <name>` | List functions this target calls (one-hop outgoing CALLS) |
| `loom blast-radius <name>` | Show transitive callers (full impact graph) |
| `loom stats` | Graph statistics: node count, edge count, breakdown by kind |
| `loom communities` | Run Louvain community detection. Shows structural clusters |
| `loom context` | Print compressed codebase overview (~200 tokens) for agent session start |
| `loom dead-code` | Mark functions with no incoming CALLS as dead code |
| `loom export [output.html]` | Export graph as self-contained interactive HTML file |
| `loom install` | Install git post-commit hook and auto-configure MCP |
| `loom serve` | Start the MCP stdio server |
| `loom savings` | Show token savings from Loom cache hits |
| `loom summaries` | Show nodes with agent-written summaries |

---

## Workflows

```bash
# Cross-reference
loom query "bot_handler"          # find definition
loom callers "bot_handler"        # who calls it?
loom callees "bot_handler"        # what does it call?
loom blast-radius "bot_handler"   # full impact graph

# Overview
loom stats && loom context        # node counts + ~200-token compressed summary
loom dead-code                    # find functions with no callers

# Visual
loom export /tmp/graph.html --open
```

## Sync

| Situation | Command | Time |
|-----------|---------|------|
| After commit | Automatic (git hook) | ~2-5s |
| After file edits (no commit) | `loom sync` | ~2-5s |
| Full rebuild | `loom analyze .` | ~10-60s |

## Dead-Code — Known False Positives

`loom dead-code` is **static** — it only sees direct CALLS edges. It misses calls from:

| Category | Missed by loom | Examples |
|----------|---------------|----------|
| Test frameworks | pytest name discovery | `tests/` methods |
| CLI frameworks | typer decorators | `do_*`, `main`, `_version_callback` |
| HTTP servers | `BaseHTTPRequestHandler` | `serve`, `do_GET`, `do_POST` |
| Constructors | Python runtime | `__init__`, `__call__` |
| Dynamic dispatch | Higher-order functions | `execute` (from `_make_rpc`) |

**Filter:** `loom query "dead" --limit 100 | rg "src/" | rg -v "tests/|do_bot|do_chat|do_folder|do_webhook|do_raw|do_updates|do_main|main|execute|_make_rpc|_version_callback"`

## Tool Chain Priority

```
1. plocate  → find files (fastest, system index — never `locate`, DB auto-updated daily)
2. opencode-ast    → file structure (plugin, fresh parse)
3. loom query      → cross-reference (persistent index)
4. qmdr            → KπX know-how (past decisions)
```

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-15 | [COLAB] | **v1.2.0 — Example path updated** in the Installation section (`~/KpihX-Labs/tg_proxy` → `~/KpihX-Labs/proxies/tg-proxy`) after tg-proxy moved into `proxies/`. |
| 2026-07-26 | [OPENCODE] | v1.1.0 — Rewritten: real commands (loom 0.7.1), auto-sync via git hook, maintenance routine, dead-code FP guide. |
| [SUMMARY] | — | v1.0.0 — Created — initial skill documentation (→ `references/log.md`). |
