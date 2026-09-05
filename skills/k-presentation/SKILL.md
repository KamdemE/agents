---
name: k-presentation
description: >
  Build a slide deck as code: markdown holds every word, Python only places
  things, and the deck is assembled with python-pptx — on top of a template, or
  from nothing. Use when asked to create, rebuild, review, audit or fix any
  slide deck: academic defence, technical talk, design review, status report,
  keynote, narrative or teaching deck. Use it when a deck must obey a corporate
  or school template; when bullets look flat or indentation is invisible from
  the back of the room; when slides look empty, overloaded or "assembled
  rather than designed"; when images clash with the palette; when a deck needs
  a coherent visual system; when a native editable chart is wanted inside the
  deck; or to map an unknown template before building on it. Also covers when
  to reach for NotebookLM, Gamma or an image generator instead — and how to
  stay in control if you do.
license: private
metadata:
  author: KpihX
  version: "3.2.0"
  scope: content-authoring
allowed-tools: Bash, Read, Write, Edit
---

# k-presentation — decks as code

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Why this exists

Three artifacts in this skill's `assets/` (including `assets/fonts/` with Maven Pro + Roboto), plus two real canonical example decks built with this doctrine, are the evidence base — see **Example repositories** below for the two decks; if absent on a local machine, agents MUST clone them temporarily to `/tmp/` to inspect structure and build patterns:

- **`culling-presentation`** — 40 slides, full R&D professional presentation style, 16 figures, content-hash incremental cache (`DxO-Template.pptx`, Maven Pro + Roboto).
- **`culling-presentation-x`** — 17 slides (12 main + 5 annexes), light X academic defence style, built on official Polytechnique template (`Template_X.pptx`, Georgia / Century Gothic) with a rule validator (`render check`).
- `assets/Template_X.pptx`, `assets/Template_DxO.pptx` — both templates, emptied, with hidden help slides.
- `assets/fonts/` — bundled font assets (MavenPro-*.ttf, Roboto-*.ttf).
- `assets/Mother_Mirror.pdf` — 14 slides generated with NotebookLM. The best looking deck here, dissected in `references/visual-systems.md`.

## The doctrine

1. **Markdown owns every word.** One slide = one `.md` file with YAML
   front-matter. Python places, parses, draws — never writes a sentence. Free
   consequence: the build counts speaker-note words and tells you the talk's
   length.
2. **Build on the template when one exists.** It carries palette, fonts,
   layouts, page furniture, logos, and often mandatory hidden instruction
   slides. Reproducing that by hand always drifts. With no template,
   `deckkit.open_deck()` gives you a blank canvas — then *you* are the design
   authority, so write the palette down (`references/visual-systems.md`).
3. **One source of truth per concern.** Colours, fonts, bullet levels and
   geometry in one `theme.py`, with thin adapters for matplotlib and
   python-pptx. A colour defined three times will disagree in two.
4. **One shared string is the only coupling.** `figure: value_loop` in the
   markdown, `key = "value_loop"` on the builder, `build/figs/value_loop.png`
   on disk. No registry to maintain.
5. **A figure is authored at the exact size of its target box**, in inches.
   Then `fontsize=14` projects as 14 pt, and figure slides match text slides.
   Never `bbox_inches="tight"` — it changes the size and breaks the mapping.
6. **Fail loudly, with the remedy in the message.** A build that stops is
   cheaper than a plausible wrong deck. `check` verifies the contract in both
   directions, not just "does the PNG exist".
7. **Verify by rendering, not by reading.** Export to PNG and *look* at every
   slide. Every defect in `references/pitfalls.md` was invisible in code and
   obvious in the image.
8. **Numbers in filenames are sort keys, not page numbers.** Insert a slide as
   `04b_….md`; rename nothing.

## Order of operations

Do not skip phase 1. Every hour lost was lost by guessing a placeholder.

### 1 — Map the template

```bash
uv run --with python-pptx python .agents/skills/k-presentation/scripts/inspect_template.py deck.pptx
uv run --with python-pptx python .agents/skills/k-presentation/scripts/inspect_template.py deck.pptx --slides
```

Prints the theme palette, the master's body levels (sizes, fonts, `marL`,
bullet chars), every layout with each placeholder's `idx`, type and geometry in
inches, and the baked decorations you cannot remove per slide. `--slides` also
dumps an existing deck's paragraph levels — which tells you at once whether its
author used real levels or typed dashes into level-0 text.

Two findings that always matter: **placeholder `idx` is not in reading order**
(pair by coordinates, and comment the coordinates that justify it), and **what
the master does to `marL`** (usually nothing — see
`references/typography.md`).

Optional but recommended: give the template hidden cheat sheets that travel
with the file.

```bash
uv run --with python-pptx python .agents/skills/k-presentation/scripts/make_help_slides.py deck.pptx
```

### 2 — Read the rules that bind

A school directive or a house style is an input, not a formality. Quote the
binding sentences into a `RULES.md` beside the deck, with where each is
honoured. When two rules conflict, say which wins and why. For École
polytechnique defences the digest already exists:
`references/rules-soutenance-x.md`.

### 3 — Decide the spine, in prose, before any slide exists

What is the question, and what are the 3–5 moves that answer it. If the deck
accompanies a document the audience has read, the spine must **differ** from
it — usually an explicit grading criterion.

### 4 — Decide the visual system

Four decisions, and no gallery makes them for you: a ground, two colours plus
an accent, one contrasted type pair, four to six slide archetypes. If the
template answers them, you are done. If not, read
`references/visual-systems.md` and `references/design-sources.md`.

### 5 — Scaffold

Copy `scripts/` into the deck folder, adapt `theme.py`, then write slides.

```
<deck>/
├── README.md      the format contract, and known limits
├── RULES.md       the rules that bind, quoted, and where each is honoured
├── theme.py       palette · fonts · bullet levels · geometry — once
├── slides.py      markdown → objects. Parses only.
├── deck.py        one filler per layout. Places only.
├── figures/       figkit + one module per family, each exposing ALL
├── slides/        NN_name.md, A1_name.md for annexes
├── preview.py     pptx → PNG + contact sheets
├── render.py      the single entry point
└── build/         100 % regenerable — delete it and re-run
```

### 6 — Write content first, styling never

A slide declares a `layout:` that must exist in the template; the filler fills
that layout's placeholders. If a layout cannot hold the content well, change
the layout or draw a figure — do not fight the geometry with manual text
boxes. Before the narrative is final, run the fact-rigor pass in
`references/ai-tools.md` → *The line not to cross* on every number the deck
will claim.

### 7 — Validate, render, look

```bash
uv run python render.py check      # contract, both directions
uv run python render.py all        # figures + deck + preview
```

Then open every PNG and the contact sheets. Look for: text floating in a void,
text over a watermark, a caption colliding with page furniture, a connector
hidden behind a box, doubled page numbers, prompt text left in an unused
placeholder, broken accents, and a title whose height moves between slides.

### 8 — Report honestly

What changed, what you interpreted and on which sentence, what remains manual
(a timed rehearsal always does), and which defects are render artefacts rather
than file defects — and how you proved it (read the XML).

## Profiles

Same machinery, different settings. Say which profile you are in before
arguing about density.

| Profile | Density | Page furniture | Images | Figures |
|---|---|---|---|---|
| **Academic / defence** | strict caps, rules quoted in `RULES.md` | numbering mandatory, breadcrumb useful | only if they carry a message | diagrams that make the argument |
| **Technical talk** | dense is fine; the figure *is* the slide | numbering, section rail | measurements, boards, real data | many, and traceable to files |
| **Narrative / keynote** | one idea per slide, large type | often none at all | central, all under one treatment | illustration over diagram |
| **Exec / status** | one takeaway per slide, stated first | numbering, date | rarely | one chart, one sentence |

`presentation_x_v2` is the academic profile; `presentation` the technical one;
`assets/Mother_Mirror.pdf` the narrative one.

## Invariants `check` must enforce

Generic, written once — see `scripts/deckkit.py::validate`:

- the declared `layout:` exists in the template;
- fields required by that layout's filler are present;
- `##` block count matches what the layout expects;
- bullet depth ≤ the deepest *projectable* level;
- every declared figure and image exists on disk;
- density and words-per-line caps hold (state them in `RULES.md`);
- no forbidden slide (a "Thank you / Questions" closing slide is banned by the
  X directive).

## When something looks wrong

`references/pitfalls.md` first. It catalogues real, reproduced defects with fix
and reason: auto-fields surviving under your text, footer placeholders
`add_slide()` silently skips, `arc3` connectors hiding behind the boxes they
should clear, accented capitals decomposing under font substitution, layout
decorations that cannot be deleted per slide, mounts that refuse `unlink`. Do
not re-derive them.

## Mandatory `check-dashes` (NEVER forget)

`scripts/check-dashes.sh` is a symlink to the canonical copy in
`skills/k-tex/scripts/check-dashes.sh` — single source of truth, never a
duplicate. Every deck project MUST run it FIRST in its own `make check`,
before any build: it fails on any em-dash (`---`) in tracked `.tex` files
(beamer/poster sources) outside `%` comments.

## Build debris vs renders (NEVER forget)

`build/` debris is 100 % regenerable and stays untracked — but final renders
are ALWAYS committed. Every deck repo `.gitignore` MUST carry:

```gitignore
build/*
!build/*.pptx
!build/*.pdf
```

(Use `build/*`, never bare `build/`: a bare dir exclusion cannot be
re-included by `!` negations.)

## Example repositories

Two canonical decks were built with this exact doctrine and prove it works end to end.
If absent on disk, agents MUST clone them to `/tmp/` to inspect structure, slide `.md` files, `theme.py`, and `render.py`:

| Deck | Profile / Style | Local Location | GitHub Remote | GitLab Remote |
|---|---|---|---|---|
| **`culling-presentation`** | Full R&D Professional (40 slides, Maven Pro + Roboto, 16 figures, `DxO-Template.pptx`) | `$HOME/KpihX-Labs/Culling/culling-presentation` | `https://github.com/KpihX/culling-presentation` | `https://gitlab.com/k-culling/culling-presentation` |
| **`culling-presentation-x`** | Light X Academic (17 slides, Georgia / Century Gothic, 16 figures, `Template_X.pptx`) | `$HOME/KpihX-Labs/Culling/culling-presentation-x` | `https://github.com/KpihX/culling-presentation-x` | `https://gitlab.com/k-culling/culling-presentation-x` |

## References

| File | Read it when |
|---|---|
| `references/architecture.md` | starting a deck, or porting the pipeline |
| `references/template-first.md` | building on a template you did not make |
| `references/typography.md` | bullets, hierarchy, legibility, density |
| `references/visual-systems.md` | the deck must be beautiful, not just correct |
| `references/design-sources.md` | you need a palette, a type pair, icons, images |
| `references/ai-tools.md` | considering NotebookLM, Gamma, an image generator |
| `references/pitfalls.md` | anything renders wrong |
| `references/rules-soutenance-x.md` | any École polytechnique oral defence |
| `references/alternative-mcp-approach.md` | you're wondering whether the retired MCP-tool workflow (v1.x) still applies, or chasing one of its three surviving lessons (native charts, the `shape_type==14` gotcha, the fact-rigor pass) |
| `references/insights.md` | before any non-trivial work in this domain (mandatory, see below) |

## Scripts

| File | What it is |
|---|---|
| `scripts/inspect_template.py` | map a template: theme, body levels, layouts, placeholders, decorations |
| `scripts/make_help_slides.py` | give a template hidden cheat sheets: palette, levels, layout inventory, grammar, archetypes |
| `scripts/slides.py` | markdown parser: YAML front-matter, real bullet levels, `\|` cells, notes |
| `scripts/deckkit.py` | python-pptx primitives: levelled bullets, inline emphasis, footers, tables, **native editable charts**, backgrounds, image fit, validation, timing budget |
| `scripts/figkit.py` | matplotlib with inches as data units, plus duotone/tint/desaturate image treatments |
| `scripts/preview.py` | pptx → PDF → PNG per slide + contact sheets |
| `scripts/render.py` | entry-point skeleton: `figures \| deck \| preview \| check \| all` |
| `scripts/check-dashes.sh` | symlink → canonical em-dash gate in `k-tex` (runs FIRST in `make check`) |

## Assets

`assets/AGENTS.md` documents bundled files (templates, reference deck, `assets/fonts/`). Templates are blank, carry hidden help slides, and are regenerable. `assets/fonts/` holds Maven Pro and Roboto fonts.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-presentation/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-presentation/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-05 | [LIVE] | v3.2.0 — Mandatory `check-dashes` (symlink → k-tex canonical, FIRST in `make check`, NEVER forget) + renders rule (`build/*` + `!build/*.pptx` + `!build/*.pdf`, renders always committed) + scripts table row. |
| 2026-09-05 | [LIVE] | v3.1.2 — Renamed `assets/README.md` → `assets/AGENTS.md`. |
| [SUMMARY] | — | v3.1.1 k-pptx→k-presentation sweep · v3.1.0 k-pptx→k-presentation rename (fonts bundled, example repos) · v3.0.1 powerpoint uv tool purged · v1.1.0 first full execution under old MCP doctrine · v1.0.0 initial mapping · folded into v3.0.0. |
