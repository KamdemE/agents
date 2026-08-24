---
name: "k-loom"
description: "Loom — lightweight persistent code index MCP for cross-session code search and context retrieval"
license: "private"
metadata:
  author: "KpihX"
  version: "1.6.1"
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
| After commit | **Automatic — global git hook** (see below) | ~2-5s |
| After file edits (no commit) | `loom sync` | ~2-5s |
| Full rebuild | `loom analyze .` | ~10-60s |

## Agent Reflexes (MANDATORY on any indexed code/git project)

🔴 **Loom is GIT-PROJECTS-ONLY (KπX directive 2026-08-24): it applies to GIT repos EXCLUSIVELY — NEVER `loom analyze` a non-git directory.** On any git project containing code, agents MUST use Loom as the structural layer — not just grep/read.

1. **Session start on an indexed project:** call MCP `get_status` (or CLI `loom stats`) → check freshness. If `last_analyzed_ago` is stale (> a few days) or the index is missing → run `loom sync`, then re-check; if still no index → propose (or run if authorized) `loom analyze .`.
2. **Resume work:** call MCP `get_delta` (with the previous session id when known) to see ONLY what changed since last time — never re-read unchanged functions.
3. **Callgraph questions = Loom first:** "who calls X", "what breaks if I change X", blast-radius before refactors, dead-code sweeps → `callers` / `callees` / `blast-radius` / `dead-code` (MCP tools or CLI equivalents). Grep only confirms afterwards.
4. **End of meaningful passes:** store agent understanding via `store_understanding` (summary of hot functions) so future sessions skip re-reads.
5. **Freshness caveat:** AST/grep stay the source of truth for uncommitted edits — after heavy un-committed edits, run `loom sync` before trusting the graph.

Layering reflex: **plocate** = syntactic file search · **opencode-ast** = fresh structure of ONE file · **Loom** = persistent cross-file/cross-session relations · **qmd** = semantic/know-how (md, past sessions).

## Global Git Hook (auto-sync on EVERY repo)

Source of truth: `$HOME/.agents/skills/k-loom/assets/git-post-commit.sh` — the ONLY Loom-owned hook asset (this skill owns the Loom behavior; **`k-git` owns ALL generic hook plumbing**, incl. the pass-through asset used by every other hook type). Deployed as symlinks in `$HOME/.config/git/hooks/` and registered in `assets/links.jsonc`. Activated once with:

```bash
git config --global core.hooksPath "$HOME/.config/git/hooks"
```

On every commit, in EVERY repo:
1. The repo-local `post-commit` hook is re-chained and executed first (core.hooksPath would otherwise bypass it — nothing regresses).
2. If `$HOME/.loom/projects/<dirname>.db` exists → backgrounded `loom sync` (~2-5s).
3. Optional auto-index of brand-new repos: export `LOOM_AUTO_ANALYZE=1` to arm `loom analyze .` (slow, off by default).

Every OTHER hook type (`pre-commit`, `commit-msg`, `pre-push`, …) is covered by the GENERIC pass-through asset owned by **`k-git`** (`assets/git-hook-passthrough.sh`, one script + N symlinks named after each hook type) which simply re-chains repo-local hooks — zero behavior change.

## Ignore & Secrets Policy (GRAVÉ — .env NEVER indexed)

🔴 **Real secret files must NEVER be indexed. Templates (`.env.example`) stay indexed.**
🔴 **Loom is GIT-PROJECTS-ONLY** (KπX directive 2026-08-24): never `loom analyze` a non-git directory. Git repos automatically honor `.gitignore` + `.git/info/exclude` + the global excludesFile through `git ls-files --exclude-standard`.

| Layer | Owner | Scope |
|-------|-------|-------|
| Global git excludesFile | **`k-git`** → `assets/git-ignore-global` → `$HOME/.config/git/ignore` (XDG) | ALL git repos: `.env`, `.env.*` (+ negations keep `.env.example`/`.env.sample`), keys/certs (`*.pem`, `*.key`, `id_rsa*`…), credential dotfiles (`.netrc`, `.npmrc`, `.pypirc`), stores (`secrets.json`, `credentials*.json`). Full doc: `k-git` → `assets/gitignore`. |
| Per-repo `.loomignore` | this skill | Optional extra filter at a git repo's root (committed artifacts, tracked `.env` not yet untracked). Applied on top of everything. |
| Loom defaults | built-in | Already skip `node_modules`, `.venv`, `venv`, `dist`, `build`, `target`, `__pycache__`, … |

**Caveats:** TRACKED files bypass ignores (`git ls-files -c`) — untrack at source. Incremental sync does NOT re-filter — secrets indexed before the rules existed persist: delete the project DB (`~/.loom/projects/<name>.db*`) then `loom analyze .` (cache fully regenerable). Full original policy text (pre-condensation): `references/log.md` (2026-08-24).

## `.loom` Hygiene

- Loom creates one DB per directory name (`~/.loom/projects/<name>.db`) LAZILY — every agent session started in any folder spawns an empty stub DB. Stubs (0 nodes) and ghosts from renamed projects are debris.
- 🔴 **After renaming a project directory:** re-index under the new name (`loom analyze .`) and archive/remove the old `<old-name>.db` ghost — otherwise two divergent indexes coexist (happened with `tg_proxy.db` vs `tg-proxy.db`, cleaned 2026-08-24).
- Cleanup candidates detection: 0-node DBs (`meta`/FTS tables only), DBs whose directory no longer exists, duplicated names differing by `_`/`-`. Debris purging is part of `k-optim` Meta scope.


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
| 2026-08-24 | [COLAB] | **v1.6.1 — Check-skills audit**: rotated changelog to comply with structure rules; no log.md. |
| 2026-08-24 | [COLAB] | **v1.6.0 — Prop A hook ownership cleanup**: generic `git-hook-passthrough.sh` MOVED to `k-git/assets/` (k-git owns ALL hook plumbing); redundant dedicated `git-pre-commit.sh` DELETED per explicit KπX order (generic pass-through covers pre-commit via its own symlink); `~/.config/git/hooks/pre-commit` + 8 other type-symlinks retargeted to `k-git/assets/git-hook-passthrough.sh`; links.jsonc: 9 pass-through entries re-tagged under k-git block, only `git-hooks-post-commit` remains under k-loom. This skill now owns exactly ONE hook asset: `git-post-commit.sh`. |
| [SUMMARY] | — | v1.5.0 Git-only scope (→ `references/log.md`) · v1.4.0 secrets ignore · v1.3.0 Loom activation · v1.2.0 proxies/ move · v1.1.0 auto-sync (→ `references/log.md`) · v1.0.0 created (→ `references/log.md`) |
