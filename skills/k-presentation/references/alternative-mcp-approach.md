# Alternative approach — the `powerpoint` MCP tool (retired, kept for the record)

> **🔴 PURGED 2026-08-26:** the `powerpoint` uv tool (`~/.local/bin/powerpoint`,
> `~/.local/share/uv/tools/powerpoint/`) has been fully uninstalled
> (`uv tool uninstall powerpoint`) and its stale registry row removed from
> `k-clis/SKILL.md`. It no longer exists on any  machine. This file remains
> as the historical record only (zero-information-loss) — do not attempt to
> reinstall without the user's explicit request.

Before this skill's "decks as code" doctrine (`deckkit.py` / `figkit.py` /
`slides.py` / `render.py`) became the standard, an earlier lineage of this
skill drove a third-party MCP server instead: `powerpoint`
(`uv tool install "git+https://github.com/Ichigo3766/powerpoint-mcp.git"`,
a fork tracked upstream as `powerpoint-mcp`). This file is that lineage's
complete record, kept per the kernel's zero-information-loss rule — **not**
a recommendation to use it again. Read `template-first.md` and
`architecture.md` first; come here only if you are deciding whether the MCP
tool still has a place, or chasing one of its surviving lessons.

## Why it was retired

- **External dependency.** The fork is not -owned or maintained; its
  capabilities, and its continued existence, are outside our control.
- **Fixed, hard-coded layout indices** — `title=0`, `title_and_content=1`,
  `section_header=2`, `comparison=4`, `title_only=5`, `picture_with_caption=8`
  — which is exactly the anti-pattern `template-first.md` and `pitfalls.md`
  warn against: a placeholder's `idx` is not in reading order and is not
  stable across templates. Map a template by name and coordinates
  (`inspect_template.py`), never by a remembered index.
- **No verification pipeline of its own.** `render.py check` + `preview.py`
  in the current doctrine now cover, and exceed, the manual dump-and-render
  loop this tool relied on (see *Genuinely superseded* below).

## What it was, for the record

- Installed as a **console entrypoint that starts an MCP server**, exposing
  tools: `create-presentation`, `open-presentation`, `save-presentation`,
  `add-slide-title-only`, `add-slide-section-header`,
  `add-slide-title-content`, `add-slide-title-with-table`,
  `add-slide-title-with-chart`, `add-slide-picture-with-caption`,
  `generate-and-save-image` (Forge/SD WebUI-backed image generation).
- Install gotcha: the package's own metadata name is `powerpoint`, not
  `powerpoint-mcp` — passing the latter to `uv tool install` fails with
  `Package metadata name "powerpoint" does not match given name`.

## The lesson that generalises: don't drive the MCP server interactively

The one full execution on record (2026-08-03, a 23-slide ResNet research
deck) found the live MCP round-trip **brittle**, and instead wrote a
`build_deck.py` that imported `PresentationManager` / `ChartManager`
**directly** from the installed package's own source
(`~/.local/share/uv/tools/powerpoint/lib/python3.12/site-packages/powerpoint/`)
and drove them with the tool's own venv Python — fully scriptable,
reproducible, diffable. That instinct — prefer direct, versioned code over a
live server round-trip — is exactly what `deckkit.py` / `figkit.py` /
`render.py` now give natively, with no third-party package to reach into.

## What was ported forward (the three things worth keeping)

Nothing below needs re-reading here day to day — each now lives at its real
home. Listed once, so the trail from "why does `chart()` exist" back to its
origin is never lost.

- **Native, in-PowerPoint editable charts.** `deckkit.py` had no equivalent —
  drawing a result is a `figkit` figure, but a chart the audience can
  re-open and edit is different. Ported as `deckkit.chart()`, built from the
  same `{"categories": [...], "series": [...]}` shape
  `ChartManager.add_chart_to_slide` used.
- **The `shape_type == 14` picture-placeholder gotcha.** Still true of
  python-pptx in general. Now lives in `pitfalls.md`, alongside every other
  reproduced defect — not lost, just relocated to where it is actually
  looked up.
- **The fact-rigor pass** (verify every number against a source before
  writing the narrative). This was genuinely missing from the main
  doctrine, not merely redundant with something it already did. Now lives in
  `ai-tools.md` → *The line not to cross*.

## Genuinely superseded (context only — do not reapply)

- **Bullet convention**: `\n` = top-level bullet, `\t` = sub-bullet prefix,
  read by `PresentationManager._add_formatted_bullets`. Specific to that
  package's own text parser; `slides.py`'s YAML front-matter + two-space
  indentation grammar replaces it outright.
- **Fixed, hard-coded layout indices** (see *Why it was retired* above) —
  replaced by naming a layout and mapping it with `inspect_template.py`.
- **The end-to-end verification loop** (dump slide/shape/table/chart counts
  via python-pptx, then `libreoffice --headless --convert-to pdf` and check
  page count) — superseded by `render.py check` (the markdown ↔ layout
  contract, checked in both directions) plus `preview.py` (a real render,
  contact sheets included). Nothing further to port.
- **Diagram generation via PIL**, pixel-verified before embedding —
  superseded by `figkit.py`, which does the same job with the deck's own
  theme already wired in.

## Provenance

First recorded 2026-04-07 (initial mapping of the tool). First and only full
execution 2026-08-03 (ResNet deck, see above). Retired from the main
doctrine 2026-08-25, when this skill was consolidated onto the in-house
`deckkit` / `figkit` stack developed independently in the
`framework-internship-culling` project.
