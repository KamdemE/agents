# File Governance — Language, Paths, Structure

> Non-negotiable rules for ALL file operations. Enforced by path_guard hook.

## Language (CRITICAL — NO EXCEPTIONS)

🔴 **ALL FILES, CODE, COMMENTS, DOCS, SKILLS, SCRIPTS, CONFIGS, COMMITS: ENGLISH ONLY. ALWAYS. NO MATTER WHAT LANGUAGE KπX IS SPEAKING IN THE CONVERSATION. THIS IS NON-NEGOTIABLE AND ABSOLUTE.**

**Response language:** match KπX's language in the current message (conversation only — never bleeds into files).

## Path Rules (MANDATORY)

**MANDATORY GENERALIZATION** — applies to ALL files within `$HOME/.agents/`:
- NEVER use hardcoded paths like `/home/<user>` or `~` in `.agents/` files
- ALWAYS use `$HOME`
- NEVER use the hardcoded username
- ALWAYS use `$USER`

## Single Source of Truth

- **Never duplicate content** across files. Every duplication is a future desync.
- **No live-queryable lists** — MCP lists, tool versions, collections, enabled items, runtime inventories → "read X directly"
- **Source-of-truth-first writing** — when something can change, name the source file/directory to inspect instead of enumerating its current contents
- **Concise writing** — tables/bullets over prose; one line if possible; no filler
- **Low-token docs** — AGENTS.md, SKILL.md, and other operational Markdown must stay compact. If a document restates details already owned by another source, replace with a pointer.

## File Routing

General rule: "ajuste/update/suit XXXX" → `skills/k-xxxx/SKILL.md` by default if no other context provided.

| Example | Resolves to |
|---------|-------------|
| "ajuste AGENTS" | `AGENTS.md` (canonical file; only exception) |
| `KpihX-Labs/AGENTS.md` | Symlink only → `.agents/AGENTS.md` |
| "ajuste VIBE" | `skills/k-vibe/SKILL.md` |
| "ajuste WORKSPACE" | `skills/k-workspace/SKILL.md` |
| "ajuste GIT" | `skills/k-git/SKILL.md` |
| "ajuste FINAL" | `skills/k-final/SKILL.md` |

## Home Directory Routes

| Path | Scope |
|------|-------|
| `$HOME/Gdrive_X/` | Pro/Academic Google Drive (rclone: `gdrive-x:`) |
| `$HOME/Gdrive/` | Personal Google Drive (rclone: `gdrive:`) |
| `$HOME/Work/` | Dev & prod code, infra, scripts |
| `$HOME/Pictures/` | Generated visuals, screenshots |
| `$HOME/Documents/` | Docs, PDFs, notes |
| `$HOME/Downloads/` | Temporary downloaded files |
| `$HOME/Videos/` | Recordings, screencasts |

## Template Directories

| Path | Scope |
|------|-------|
| `$HOME/Work/techskills/templates/` | Python boilerplate (pyproject.toml, config.py), Docsify |
| `$HOME/Work/KpihX-Labs/Homelab/presentation/tutos_live/templates/` | Homelab docker-compose files, gitlab-ci history |

When creating a new project: check these dirs for concrete examples before writing from scratch. Use `ls` or `k-qmd` to browse.

## Knowledge Base (k-qmd)

Always load `k-qmd` skill before querying.

Main collections: `techskills`, `presentation`, `agents`, `k-ai`, `codex`, `gemini`, `copilot`, `vibe`.

When to query: before inventing an approach, when unsure where something lives, or to inspect another agent's config/history. Match scope to collection. Always check `$HOME/Work/techskills/templates/` before creating new files from scratch.
