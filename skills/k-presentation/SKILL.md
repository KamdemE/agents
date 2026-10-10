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
  author: 
  version: "1.0.0"
  scope: content-authoring
allowed-tools: Bash, Read, Write, Edit
---

# k-presentation — decks as code

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

## Why this exists

Three artifacts in this skill's `assets/` (including `assets/fonts/` with Maven Pro + Roboto), plus real canonical example decks built with this doctrine, are the evidence base — see **Example repositories** below for the two canonical decks; if absent on a local machine, agents MUST clone them temporarily to `/tmp/` to inspect structure and build patterns:

- **`culling-presentation`** — 40 slides, full R&D professional presentation style, 16 figures, content-hash incremental cache (`DxO-Template.pptx`, Maven Pro + Roboto).
- **`culling-presentation-x`** — 17 slides (12 main + 5 annexes), light X academic defence style, built on official Polytechnique template (`Template_X.pptx`, Georgia / Century Gothic) with a rule validator (`render check`).
- `assets/templates/Template_X.pptx`, `assets/templates/Template_DxO.pptx`, `assets/templates/Template_Dark_Tech.pptx`, `assets/templates/Template_Dark8tech2.pptx`, `assets/templates/Template_AI_Marketing_Slidesgo.pptx` — blank templates, emptied, with hidden help slides.
- `assets/fonts/` — bundled font assets (MavenPro-*.ttf, Roboto-*.ttf).
- `assets/exs/Presentation_Mother_Mirror.pdf` — 14 slides generated with NotebookLM. The best looking deck here, dissected in `references/visual-systems.md`.
- `assets/exs/Presentation_YUPAYX_Soutenance_Johan_Touko.pptx` — 25 slides, licence pro defence style (Institut Universitaire Saint Jean / SESAME), platform management for YUPAYX payment aggregator. Reference for **professional programme defence** profile (not academic X, not R&D). Sections: Contexte → Problématique → Solutions existantes → Notre solution → Choix outils → Modélisation (UC, activités, classes) → Architecture → Démonstration → Conclusion.
- `assets/exs/Presentation_ElGamal_Crypto_3GI_ENSPY.pptx` — 69 slides, ENSPY 3GI crypto course presentation (2023-2024). Full ElGamal coverage: historique, courbes elliptiques (addition de points, cas identiques/oppozés), principe chiffré/déchiffré, signature. Heavy use of animations, embedded diagrams, and step-by-step mathematical walkthroughs. Reference for **dense technical/academic course** profile.
- `assets/exs/Album_Photo_Bapteme__Lyse.pptx` — 12 slides, personal photo album of the user's first communion and cousin Lyse's baptism. Reference for **personal/nostalgic photo album** profile.
- `assets/exs/Presentation_Au_Dela_Du_Binaire_Kibib_Mebib_ENSPY.pptx` — 3.2 MB, binary units (kibi, mebi) exposé ENSPY (2023). Reference for **technical vulgarisation** profile.
- `assets/exs/Presentation_Binary_System_Unit_ENSPY.pptx` — 3.2 MB, binary system unit exposé ENSPY (2023). Pair with above.
- `assets/exs/Presentation_Computers_ENSPY.pptx` — 4 MB, computers exposé ENSPY (2022). Reference for **IT general audience** profile.
- `assets/exs/Presentation_Ethique_Milieu_Etudiantin_ENSPY.pptx` — 870 KB, ethics in student environment exposé ENSPY (2022). Reference for **short persuasive/narrative** profile.
- `assets/exs/Presentation_TD_Electromagnetisme_MSP1_ENSPY_2021.pptx` — 2.6 MB, electromagnetism TD exposé ENSPY MSP1 (2021). Reference for **physics teaching** profile.
- `assets/exs/Presentation_Fondements_Geometrie_ENSPY.pptx` — 11.5 MB, geometry foundations exposé (2022). Reference for **history of maths/science narrative** profile.
- `assets/exs/Presentation_Importance_Informatique_LYBIBAF.pptx` — 1.1 MB, importance of CS exposé LY.BI.BAF (2022). Reference for **early-career persuasive** profile.
- `assets/exs/Presentation_Innovation_IA_DevDurable_Femmes_DAAD_2024.pptx` — 27.5 MB, DAAD Women+AI event: innovation, sustainable development, and women in AI (2024). Reference for **academic conference** profile.
- `assets/exs/Presentation_Modal_Verbs_ENSPY.pptx` — 2.5 MB, English modal verbs exposé ENSPY (2022). Reference for **language teaching** profile.

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
`assets/exs/Presentation_Mother_Mirror.pdf` the narrative one.

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

Canonical is `scripts/check-dashes.sh` (global, single source, sources `libs/humanize/humanize_lib.sh` — not `skills/k-tex/assets/`). `scripts/check-dashes.sh` + `assets/Makefile` + `assets/.gitignore` are **copies** (not symlinks) of central `scripts/check-dashes.sh` + `skills/k-tex/assets/Makefile` / `.gitignore` into each new deck at scaffold. Every deck MUST run `sh scripts/check-dashes.sh` FIRST in `make build` (via `check:` target, must pass) — scans tracked `*.tex`+`*.md`+`*.txt`+`*.rst`+`*.adoc` for 4 blocked patterns `---`, `—` (U+2014), ` -- `, spaced ` – ` (U+2013). Exemptions: TeX `%` comments (`^[[:space:]]*%` in `.tex`), `^---$` HR/frontmatter (standalone `---`), interval `2024–2025` (`alnum–alnum` collé, only spaced ` – ` blocked). Makefile still calls `sh scripts/check-dashes.sh` first — script is a copy of central `scripts/check-dashes.sh`. Hook `skills/k-opencode/scripts/plugins/hooks/humanize-guard.js` (hard, `tool.execute.before`) provides write-time gate via same `libs/humanize/humanize_lib.js` (code whitelist `isCodeFile`).

## Standard Makefile & `.gitignore`

Centralized in `skills/k-presentation/assets/Makefile` + `skills/k-presentation/scripts/check-dashes.sh`, both registered symlinks to `skills/k-tex/assets/Makefile` / `skills/k-tex/scripts/check-dashes.sh`. `skills/k-presentation/assets/.gitignore` is the deck-specific file (`build/*` + `!build/*.pdf` + `!build/*.pptx` + `__pycache__/` + `*.pyc`), copied into each new deck at scaffold with the Makefile. `check:` calls `sh scripts/check-dashes.sh` FIRST and gates `build`; `push` is standalone.

## Example repositories

Two canonical decks were built with this exact doctrine and prove it works end to end.
If absent on disk, agents MUST clone them to `/tmp/` to inspect structure, slide `.md` files, `theme.py`, and `render.py`:

| Deck | Profile / Style | Local Location | GitHub Remote |
|---|---|---|---|
| **`culling-presentation`** | Full R&D Professional (40 slides, Maven Pro + Roboto, 16 figures, `Template_DxO.pptx`) | `$HOME/Labs/<project>/culling-presentation` | `https://github.com/<user>/culling-presentation` |
| **`culling-presentation-x`** | Light X Academic (17 slides, Georgia / Century Gothic, 16 figures, `Template_X.pptx`) | `$HOME/Labs/<project>/culling-presentation-x` | `https://github.com/<user>/culling-presentation-x` |

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
| `scripts/check-dashes.sh` | copy of central `scripts/check-dashes.sh` (humanize, extended — 4 patterns, HR + interval exemptions, sources `libs/humanize/humanize_lib.js`; runs FIRST in `make build` via `check` target) |

## Assets

`assets/AGENTS.md` documents bundled files (templates, reference deck, `assets/fonts/`). Templates are blank, carry hidden help slides, and are regenerable. `assets/fonts/` holds Maven Pro and Roboto fonts. `assets/exs/` holds example decks for reference.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-presentation/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-presentation/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

