# k-pptx Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.

### 2026-08-03 — ResNet deck build (first full k-pptx execution)

- **`powerpoint-mcp` install via uv**: `uv tool install "git+https://github.com/Ichigo3766/powerpoint-mcp.git"` — do NOT pass a package-name arg (`powerpoint-mcp`). The pyproject package metadata name is `powerpoint`, so uv fails with "Package metadata name `powerpoint` does not match given name". Executable lands as `powerpoint`; venv python at `$HOME/.local/share/uv/tools/powerpoint/bin/python` (carries python-pptx, Pillow, chart manager).
- **Prefers programmatic generation over the MCP server**: calling the `powerpoint` CLI/MCP server interactively is brittle. The robust pattern: write a `build_deck.py` that imports `PresentationManager`/`ChartManager` from `$HOME/.local/share/uv/tools/powerpoint/lib/python3.12/site-packages/powerpoint/` and drives them directly with the venv python. Fully reproducible, scriptable, verifiable.
- **Bullet conventions** in `PresentationManager._add_formatted_bullets`: `\n` (ASCII 10) separates top-level bullets; `\t` (ASCII 9) prefixes a sub-bullet. Slides use layout indices: title=0, title_and_content=1, section_header=2, comparison=4, title_only=5, picture_with_caption=8.
- **Charts**: use layout 5 (Title Only) and `ChartManager.add_chart_to_slide(slide, data_dict, left, top, width, height)` with `{"categories": [...], "series": [{"name": ..., "values": [...]}]}`. The chart manager pulls pptx charts directly (no picture fallback) — verified a LINE chart embeds as a real editable chart object.
- **Picture verification gotcha**: `insert_picture` on picture_with_caption (layout 8) returns a `PlaceholderPicture` with shape_type **14** (not the expected 13). Verifying "picture embedded" by checking `shape_type == 13` yields a false negative. The reliable check: `ph.shape_type == 14 and ph.image is not None` (`.image` gives access to the actual embedded bytes).
- **End-to-end verification loop** (must do every time): (1) dump all slides via python-pptx — count, per-slide shapes, tables (rows/cols/header), chart categories+series, embedded picture dims; (2) smoke-render with `libreoffice --headless --convert-to pdf` and confirm page count == slide count. This catches structural breakage that MCP responses hide.
- **Diagrams**: generate assets with PIL in a small script (`make_*.py`) before the build so they are deterministic, versionable, and pixel-verified (format + dimensions checked before embedding).
- **Fact rigor for technical decks**: run a fact-verifier pass on every number before the narrative is written; keep a live-verified facts list (arXiv metadata, official result tables, citation counts from Semantic Scholar API) and correct the dossier/deck against it. Deck numbers must match the dossier exactly.
