# k-pptx assets

Two blank templates and one reference deck. The templates are stripped of
content: they carry their master, their layouts, their theme, and hidden help
slides. Point a deck at one of them, bring your own, or use none at all.

The two full example decks built with this doctrine (`presentation`,
`presentation_x_v2`) are **not** bundled here — they are real decks with
real content, each in its own repository. See `SKILL.md` → **Example
repositories**.

| File | Size | Slide size | Layouts | Leading hidden slides |
|---|---|---|---|---|
| `Template_X.pptx` | 2.2 MB | 13.333 × 7.5 in (16:9) | 36 | 3 official + 5 generated |
| `Template_DxO.pptx` | 0.06 MB | 10 × 5.625 in (16:9) | 8 | 3 generated |
| `Mother_Mirror.pdf` | 19 MB | 19.1 × 10.7 in | — | reference deck, not a template |

## `Mother_Mirror.pdf` — the quality bar

Fourteen slides on Winnicott's mirror role, generated with Google NotebookLM,
kept here because it is the best looking deck in this repo and worth studying
before designing anything. **It is dissected slide by slide in
`../references/visual-systems.md`**: the sampled palette, the single
illustration register held for fourteen slides, the recurring character design,
colour used semantically rather than decoratively, how its two real photographs
are disciplined into behaving, its six repeated composition archetypes, and
which of those devices this stack can reproduce and how.

It is a **reference, not a template** — no master worth reusing, and it is
19 MB, the largest file in the skill. If repo weight becomes a problem, this is
the first thing to move out; nothing in the code depends on it.

## Provenance

**`Template_X.pptx`** — derived from the author's own `Presentation_FH.pptx`,
which is the official École polytechnique template. Its content slides were
removed; its **three official instruction slides were kept**, in first position,
with `show="0"`: present in the file, absent from the running order. They carry
the palette rules, how to use the master, the five text levels, and how to save
the file as a personal `.potx`. Keep them. Some authors deliberately keep them
at the top of every deck they build, so the rules travel with the file.

Its 36 layouts are unusually rich — covers, sommaires from 2 to 6 parts,
section dividers, single and double text blocks, bullets with a photo or with
the school arms, tables, timelines of 5 or 8 entries, image grids, org charts,
macarons, France and world maps. Read the layout inventory on the generated
help slides before inventing anything.

**`Template_DxO.pptx`** — derived from the built DxO technical deck, emptied of
all slides. Eight layouts, a plain white ground, no page furniture. Its 10 ×
5.625 in slide size is smaller than the X template's, so a figure authored for
one is not sized for the other — read the target box from `theme.py`, never
hardcode inches.

## The hidden help slides

Generated, and regenerable:

```bash
uv run --with python-pptx python ../scripts/make_help_slides.py Template_X.pptx
```

They carry, in the template's own colours: the theme palette with hex values,
the font scheme, the master's body levels with their `marL` and bullet char, and
the full layout inventory with each layout's placeholder `idx` values. The
script is idempotent — it tags its own slides and replaces them — and it inserts
them *after* any leading run of already-hidden slides, so official instruction
slides stay in first position.

Both templates leave `marL=0` on every body level. That is the norm, and it is
why `deckkit.set_bullets` sets the indent itself: see
`../references/typography.md`.

To proof-read hidden slides (PDF export skips them):

```bash
uv run --with python-pptx python ../scripts/make_help_slides.py Template_X.pptx \
    -o /tmp/visible.pptx --visible
```

## Three ways to start

```python
import deckkit as kit

prs, mode = kit.open_deck(kit.TEMPLATE_X, keep=3)  # keep the 3 official slides
prs, mode = kit.open_deck(kit.TEMPLATE_DXO)  # blank DxO ground
prs, mode = kit.open_deck()  # no template at all
```

With no template you get one usable layout and you draw the page furniture
yourself from `theme.py` (`kit.chrome`, `kit.title_of`, `kit.footer`). That is a
legitimate choice for a deck with no house style to respect — but you become the
design authority, so write the palette down and hold to it.

## Adding a template

Drop the `.pptx` or `.potx` here, empty it of content, generate its help slides,
and record its provenance in this file:

```bash
uv run --with python-pptx python ../scripts/inspect_template.py NewTemplate.pptx
uv run --with python-pptx python ../scripts/make_help_slides.py NewTemplate.pptx
```

Do not commit a template you are not allowed to redistribute. A house template
usually belongs to the organisation that made it.
