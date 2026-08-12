---
name: k-pptx
description: PPTX generation workflow memory — `powerpoint` MCP CLI behavior, source paths, random-explorer presentation pipeline, and safe usage patterns for slide creation from markdown plus notebook assets.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
  scope: tool-memory
allowed-tools: "Bash(*), *"
---

# Tool Memory — k-pptx

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Purpose

Use this skill before generating or editing `.pptx` decks with the local `powerpoint` CLI/MCP tool.

## Source Of Truth

| Item | Path |
|------|------|
| CLI launcher | `$HOME/.local/bin/powerpoint` |
| uv tool env | `$HOME/.local/share/uv/tools/powerpoint/` |
| Package metadata | `$HOME/.local/share/uv/tools/powerpoint/lib/python3.12/site-packages/powerpoint-0.1.0.dist-info/METADATA` |
| Installed module | `$HOME/.local/share/uv/tools/powerpoint/lib/python3.12/site-packages/powerpoint/` |
| Real-world deck example | `$HOME/Work/X/random-explorer/presentation/Random_Explorer.pptx` |
| Markdown source used for that deck | `$HOME/Work/X/random-explorer/presentation/Random_Explorer.md` |
| Notebook outputs used as assets | `$HOME/Work/X/random-explorer/presentation/assets/` |

## What The Tool Is

- `powerpoint` is a **console entrypoint** (`powerpoint = powerpoint:main`) that starts an MCP server runtime.
- `powerpoint --help` exposes one runtime argument:
  - `--folder-path` (folder where generated decks and images are saved)
- Installed package version: `powerpoint 0.1.0`.
- Upstream fork tracked by uv metadata:
  - `https://github.com/Ichigo3766/powerpoint-mcp.git`

## Available MCP Tooling (server-side)

From the installed package metadata and server module:

- `create-presentation`
- `open-presentation`
- `save-presentation`
- `add-slide-title-only`
- `add-slide-section-header`
- `add-slide-title-content`
- `add-slide-title-with-table`
- `add-slide-title-with-chart`
- `add-slide-picture-with-caption`
- `generate-and-save-image` (Forge/SD WebUI-backed image generation)

## Practical Workflow (KπX)

1. Prepare deck narrative in markdown (example: `Random_Explorer.md`).
2. Export notebook figures/images into `presentation/assets/` (example naming: `nb_cell*_out*.png`).
3. Start/use `powerpoint` MCP with `--folder-path` set to the presentation folder.
4. Build deck slide-by-slide through MCP tools (title/content/table/chart/image).
5. Call `save-presentation` to finalize the `.pptx`.
6. Verify resulting `.pptx` in presentation software.

## Runtime Checks

```bash
command -v powerpoint
powerpoint --help
ls -l "$HOME/.local/bin/powerpoint"
ls -la "$HOME/.local/share/uv/tools/powerpoint/lib/python3.12/site-packages/powerpoint/"
```

## Caveats

- This tool is **not** a one-shot markdown-to-pptx converter command; it is an MCP-server-style workflow.
- `generate-and-save-image` depends on SD WebUI/Forge configuration (`SD_WEBUI_URL`, optional auth env vars).
- Keep deck assets and markdown close to the target folder to simplify path handling.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-pptx/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-pptx/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-03 | [AGENT] | v1.1.0 — First full k-pptx execution (ResNet deep-research deck, 23 slides): programmatic `build_deck.py` driving PresentationManager/ChartManager directly with the uv tool venv python (no MCP server round-trips); insights.md expanded with uv install name gotcha, `\n`/`\t` bullet conventions, layout indices, chart data dict, PlaceholderPicture shape_type 14 verification, LibreOffice PDF smoke-test loop. |
| 2026-04-13 | [CODEX] | v1.0.1 — Standardized insights discipline and autonomous maintenance hooks for this skill. |
| [SUMMARY] | — | Older changelog entries were copied to `references/log.md`; the live table keeps only the two newest entries. |
