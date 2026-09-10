# k-presentation assets

Two blank templates and fourteen reference decks. The templates are stripped of
content: they carry their master, their layouts, their theme, and hidden help
slides. Point a deck at one of them, bring your own, or use none at all.

The two full example decks built with this doctrine (`presentation`,
`presentation_x_v2`) are **not** bundled here — they are real decks with
real content, each in its own repository. See `SKILL.md` → **Example
repositories**.

Additional example decks live in `exs/`:

| File | Size | Slide size | Profile |
|---|---|---|---|
| `Presentation_Mother_Mirror.pdf` | 19 MB | 19.1 × 10.7 in | Narrative / NotebookLM reference |
| `Presentation_YUPAYX_Soutenance_Johan_Touko.pptx` | 14 MB | 16:9 | Professional licence defence (SESAME Saint Jean) |
| `Presentation_ElGamal_Crypto_3GI_ENSPY.pptx` | 63 MB | 16:9 | Dense technical/academic course (ENSPY 3GI, 69 slides) |
| `Album_Photo_Bapteme_KpihX_Lyse.pptx` | 12 MB | 16:9 | Personal photo album (KπX first communion + Lyse baptism) |
| `Presentation_Au_Dela_Du_Binaire_Kibib_Mebib_ENSPY.pptx` | 3.2 MB | 16:9 | Technical vulgarisation (ENSPY 2023) |
| `Presentation_Binary_System_Unit_ENSPY.pptx` | 3.2 MB | 16:9 | Technical vulgarisation (ENSPY 2023) |
| `Presentation_Computers_ENSPY.pptx` | 4 MB | 16:9 | IT general audience (ENSPY 2022) |
| `Presentation_Ethique_Milieu_Etudiantin_ENSPY.pptx` | 870 KB | 16:9 | Short persuasive/narrative (ENSPY 2022) |
| `Presentation_TD_Electromagnetisme_MSP1_ENSPY_2021.pptx` | 2.6 MB | 16:9 | Physics teaching (ENSPY MSP1 2021) |
| `Presentation_Fondements_Geometrie_ENSPY.pptx` | 11.5 MB | 16:9 | History of maths/science narrative (2022) |
| `Presentation_Importance_Informatique_LYBIBAF.pptx` | 1.1 MB | 16:9 | Early-career persuasive (LY.BI.BAF 2022) |
| `Presentation_Innovation_IA_DevDurable_Femmes_DAAD_2024.pptx` | 27.5 MB | 16:9 | Academic conference (DAAD 2024) |
| `Presentation_Modal_Verbs_ENSPY.pptx` | 2.5 MB | 16:9 | Language teaching (ENSPY 2022) |

## Blank templates

| File | Size | Slide size | Layouts | Leading hidden slides |
|---|---|---|---|---|
| `templates/Template_X.pptx` | 2.2 MB | 13.333 × 7.5 in (16:9) | 36 | 3 official + 5 generated |
| `templates/Template_DxO.pptx` | 0.06 MB | 10 × 5.625 in (16:9) | 8 | 3 generated |
| `templates/Template_Dark_Tech.pptx` | 42 MB | 13.333 × 7.5 in (16:9) | — | Dark theme, tech-forward |
| `templates/Template_Dark8tech2.pptx` | 61 MB | 13.333 × 7.5 in (16:9) | — | Dark theme variant |
| `templates/Template_AI_Marketing_Slidesgo.pptx` | 12 MB | 13.333 × 7.5 in (16:9) | — | Marketing/Slidesgo style |

## `exs/Presentation_Mother_Mirror.pdf` — the quality bar

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

**`templates/Template_X.pptx`** — derived from the author's own `Presentation_FH.pptx`,
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

**`templates/Template_DxO.pptx`** — derived from the built DxO technical deck, emptied of
all slides. Eight layouts, a plain white ground, no page furniture. Its 10 ×
5.625 in slide size is smaller than the X template's, so a figure authored for
one is not sized for the other — read the target box from `theme.py`, never
hardcode inches.

## The hidden help slides

Generated, and regenerable:

```bash
uv run --with python-pptx python ../scripts/make_help_slides.py templates/Template_X.pptx
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
uv run --with python-pptx python ../scripts/make_help_slides.py templates/Template_X.pptx \
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

## `exs/Presentation_YUPAYX_Soutenance_Johan_Touko.pptx` — licence pro defence reference

Twenty-five slides from a real professional programme defence at Institut
Universitaire Saint Jean (SESAME Financial Services). Theme: YUPAYX payment
aggregator platform management. Profile: **professional licence defence** —
denser than X academic, more structured than a keynote, with table comparisons,
UML diagrams (activity, class), architecture slides, and a live demonstration
section.

Structure: Couverture → Plan → Contexte (3 slides) → Problématique (3 slides)
→ Solutions existantes (2 slides + comparison table) → Notre solution → Choix
des outils → Modélisation (6 slides: UC, activités, classes ×3 modules) →
Architecture → Démonstration → Conclusion.

**Provenance:** `KpihX-Datas1/Travaux/Documents/Modèles/Modèles Johan Soutenance/`,
author Johan Philbert Touko Seugoua. Copied here as-is (not a template —
content kept for structural reference).
