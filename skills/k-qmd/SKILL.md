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
  version: "2.20.0"
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
| Centralized collection updater | `scripts/update_collections.sh` (used by git hooks to auto-update QMD) |
| Collection health gate | `scripts/check_collections.sh` (`ksh status`, `auto_clean`, k-optim Meta) |
| Live qmd runtime state | `qmd status`, `qmd collection list`, `qmd context list` |
| Declarative config | `$HOME/.config/qmd/index.yml` |
| WSL GPU passthrough trap (CUDA driver present but runtime missing) | `references/wsl.md` |

## KπX Collection Map

| Collection | Root path | Use for |
|-----------|-----------|---------|
| `techskills` | `$HOME/Work/techskills/` | Ubuntu fixes, tools, shell patterns |
| `presentation` | `$HOME/Work/KpihX-Labs/Homelab/presentation/` | homelab architecture and project knowledge |
| `agents` | `$HOME/.agents/` | AGENTS, skills, hook architecture, session notes |


Raw runtime histories stay out of QMD on purpose. Use the corresponding `k-*` runtime skill to find their on-disk paths, then inspect the files directly only when needed.

## Local Embedding Models (GGUF, 100% local)

QMD embeds **locally** with GGUF models — no Ollama, no external service dependency. Models are downloaded to `~/.cache/qmd/models/` and declared in `$HOME/.config/qmd/index.yml` under `models:` (prefix `hf:` = HuggingFace GGUF, run via the bundled llama.cpp runtime, not Ollama):

| Model (GGUF) | Role | Size |
|--------------|------|------|
| `embeddinggemma-300M-Q8_0.gguf` | Embedding (semantic) | 314 MB |
| `qmd-query-expansion-1.7B-q4_k_m.gguf` | Query expansion (generation) | 1.2 GB |
| `qwen3-reranker-0.6b-q8_0.gguf` | Reranker | 610 MB |

Total ~2.1 GB in `~/.cache/qmd/models/`. The vector half of QMD's BM25+vector hybrid is fully sovereign/local. To change the embedding model, edit `models.embed` in `index.yml` and re-run `qmd embed <collection>`.

## Operational Rules

- run `qmd update <collection>` before searching when freshness matters — prefer `qmdr query` for important searches
- run `qmd embed <collection>` only when new files were added or content changed materially
- before any important semantic or exploratory search, run `qmd status`; if `Pending > 0`, run `qmd embed` before querying
- prefer `qmdr query/vsearch ...` for important searches so the freshness gate is enforced automatically
- use plain `qmd` for admin/read flows: `status`, `get`, `multi-get`, `embed`, `update`, `cleanup`, `collection ...`
- keep QMD hot-only; large raw transcripts and chat/session histories do not belong in the index
- when a runtime skill already gives the path to a history folder, prefer that path over indexing the raw history into QMD
- always scope searches to the relevant collections when possible
- do not hardcode live collection inventories in other skills; point back here or to qmd itself
- local repository post-commit hooks are standalone executable copies of the shared template; do not register them as `.agents` symlinks

## Centralized Git Auto-Update Pattern

To automatically update a QMD collection whenever a commit is made in any repository, create or modify the `.git/hooks/post-commit` file in that repository to delegate to the centralized updater script:

```bash
#!/bin/sh
# Centralized QMD collection auto-update hook
UPDATER="$HOME/.agents/skills/k-qmd/scripts/update_collections.sh"

if [ -f "$UPDATER" ]; then
    # Syntax: bash "$UPDATER" "<collection_name>" "[extensions]"
    # e.g., to update 'my-collection' for markdown and yaml changes:
    bash "$UPDATER" "my-collection" "md,yml,yaml"
fi
exit 0
```
Make sure the hook is executable: `chmod +x .git/hooks/post-commit`.

## Querying

### CLI

QMD is now CLI-first in KπX runtimes. Use:
- `qmd query ...`
- `qmdr query ...`
- `qmd get ...`
- `qmd multi-get ...`
- `qmdr query ...`
- `qmdr query ...`
- `qmdr vsearch ...`

Rule of thumb:
- `qmd` = inspect, administer, or fetch exact content
- `qmdr query/vsearch` = important query/exploration where freshness must be guaranteed first

Exact command shapes and setup details live in `references/mcp-setup.md`.

## Collection Scope Reflex

- Ubuntu/system fix → `techskills`
- homelab architecture/project memory → `presentation`
- agent workflow, hooks, AGENTS, skills → `agents`
- agent-specific runtime config/docs → use the `k-*` runtime skill directly (not indexed in QMD)
- raw agent histories → use the corresponding `k-*` runtime skill path, not QMD

## Troubleshooting

- native module or install issues → reinstall via `npm`, not bun
- `qmd embed` runs on CPU despite a real GPU being present (WSL) → `references/wsl.md` (driver passthrough ≠ CUDA runtime)
- missing MCP results → check qmd config/runtime directly, then re-index
- collection shows 0 files but docs exist on disk → run `scripts/check_collections.sh`; fix `$HOME/.config/qmd/index.yml` path typos, then `qmd update <collection>` + `qmd embed <collection>`
- slow first query → expected if local models or reranking backends are cold

## References

- `references/mcp-setup.md` — full installation, config, and CLI/MCP usage details
- `references/qmd-optimization.md` — inspection checklist, SQLite probes, cleanup flow, and latest QMD optimization actions
- `references/gitignore-embedded-folder.template` — baseline whitelist-style `.gitignore` for embedded folders
- `references/post-commit-hook.sh` — shared git hook template for repo-name-derived collections; safe by default (`update-only`, optional debounced embeddings)
- `scripts/qmdr` — explicit wrapper that auto-runs the freshness gate before `query` or `vsearch`
- `references/wsl.md` — WSL GPU passthrough trap: driver visible via `nvidia-smi` but CUDA runtime missing, `qmd embed` silently runs on CPU

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-qmd/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-qmd/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-24 | [CLAUDE] | v2.20.0 — Added `references/wsl.md`: WSL GPU passthrough trap found on `blglaptop139-wsl` — `nvidia-smi`/driver visible, but no CUDA runtime toolkit, so `qmd embed` silently ran 100% on CPU despite a real NVIDIA RTX 5070 present (Vulkan fallback unusable too — no NVIDIA Vulkan ICD registered in WSL, only Mesa software ICDs). Fix: NVIDIA's driver-less `wsl-ubuntu` CUDA Toolkit apt repo. Linked from Source Of Truth, References, and Troubleshooting. |
| 2026-08-24 | [COLAB] | v2.19.0 — Converted the three local QMD post-commit hooks (Homelab/presentation, techskills, k_ai) from registered `.agents` symlinks into executable standalone copies of `references/post-commit-hook.sh`; registry entries removed by KπX order. |
| [SUMMARY] | — | v2.18.0 update_collections.sh + auto-update pattern (→ `references/log.md`) · v2.15.0 purged collections (→ `references/log.md`) · v2.14.8 QMD rebuilt Node mismatch fix (→ `references/log.md`) · v2.14.7 Insights: transient `chunks failed` after parallel post-commit embed; v2.14.4 presentation path typo fix; v2.14.3 audit compact; v2.14.2 path correction; older → file history |
