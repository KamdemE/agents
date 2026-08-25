# Visual systems — why some decks look art directed

A deck reads as designed when the viewer cannot tell where one element was
sourced and another authored. It reads as assembled when they can. Almost
everything below is about removing that tell.

Read this when the goal is not merely "correct" but *beautiful and coherent* —
a narrative deck, a keynote, a subject that deserves atmosphere.

The worked example is real and shipped with the skill:
**`assets/Mother_Mirror.pdf`** — 14 slides on Winnicott's mirror role,
generated with Google NotebookLM. It is the highest-quality reference in this
repo. Open it before designing anything.

---

## 1. What that deck actually does

Measured, not guessed — the palette below was sampled from the rendered pages.

### A ground, not a background

| role | value | where |
|---|---|---|
| paper | `#F5F1EA` → `#F2EEE3` | the slide, **and inside every illustration** |
| ink | `#473D36` | titles, body |
| accent | `#A86C54` | emphasis, icons, diagram strokes |
| accent wash | `#C09078` | fills, watercolour |
| cool grey-blue | ~`#7F8C99` | used **semantically**, see below |

The decisive move is the first row. Every illustration is drawn *on the same
cream*, so a full-bleed drawing has no edge — the eye reads one surface, not a
picture placed on a page. Slide 1 (a charcoal eye with a face in the iris) has
no visible boundary at all.

### One illustration register, held for 14 slides

Everything is hand-drawn in a **graphite / charcoal / light-watercolour**
register: the eye, the engraved portrait, the line-drawn mother and baby, the
marble head, the barometer, the mirror, the scale, the hands, the squiggle.
Different subjects, one hand. That is what separates it from ordinary generated
imagery, which is detectable precisely because each image was produced in
isolation and carries its own aesthetic.

Two devices reinforce it:

- **A recurring character.** The dark-haired woman on slides 6 and 7 is the
  same design — same solid-black chignon, same treatment. A deck with recurring
  characters reads as one book.
- **Colour carrying meaning.** Slide 4 renders the unresponsive face as a cold
  grey-blue marble head while the baby stays warm. Slide 11 puts a steel-blue
  broken mirror against a warm cream eye — the *treatment is the argument*:
  Lacan's cold mirror versus Winnicott's warm one. Colour is not decoration
  there; it is the claim.

### Photographs made to behave

Slide 5 is the exception that proves the rule: two real photographs, Venetian
masks and a wooden prosthetic arm. They survive because they are disciplined —
identical panel size, identical aspect, symmetric placement, a thin rule
between, and hues that stay inside the palette (warm gold, desaturated grey).
Nothing about them is left to chance.

### Composition archetypes, repeated

Six, and they recur:

1. **full-bleed illustration + title + subtitle** (cover)
2. **portrait panel left + text column right**, pull-quote under the portrait
3. **three-step horizontal diagram**, one caption per step, closing statement
4. **centred object as spine + satellite text blocks** (the scale, the framed
   painting)
5. **two symmetric columns**, each with an equal image, separated by a rule
6. **text blocks left + illustration right**

Variety comes from the content. Fourteen slides with fourteen layouts would
look improvised; fourteen built from six archetypes look composed.

### Typography

A high-contrast display serif for every title and heading — always centred,
always the same height — and a neutral humanist sans for body text. Sizes vary
a lot; weights barely. Contrast comes from **scale**, not from bold.

### Emphasis inside the sentence

This is the device most pipelines cannot do and it is everywhere in that deck:
single words coloured in the accent, mid-sentence — `le lieu`, `aliénante`,
`respiration ontologique`. It guides the eye without shouting the way bold
does. Two typographic gags earn their place too: the strike-through on
*apperception* (slide 4), and the mirror-handle flourish that doubles as the
full stop on the cover.

### No page furniture at all

No page numbers, no footers, no breadcrumb. A narrative deck earns that; an
academic one usually cannot — see `rules-soutenance-x.md`, where numbering is
mandatory.

---

## 2. How to reproduce it with this stack

Not a hypothetical: here is where each device lives.

### The ground — the one thing to get right first

```python
# theme.py
PAPER, INK = "F5F1EA", "473D36"
ACCENT, WASH = "A86C54", "C09078"
COOL = "7F8C99"  # reserved for "cold / rigid" meaning only
```

```python
# deck.py, first thing on every slide
kit.set_background(slide, theme.PAPER)
```

```python
# figures/__init__.py or your figure module
figkit.use(
    palette={
        "paper": "#F5F1EA",
        "ink": "#473D36",
        "accent": "#A86C54",
        "wash": "#C09078",
        "white": "#F5F1EA",
    },  # note: white IS the paper
    serif=["Playfair Display", "Georgia", "DejaVu Serif"],
    geometric=["Inter", "Roboto", "DejaVu Sans"],
)
```

Mapping `white` to the paper value is the trick: `figkit` uses it for
`savefig.facecolor`, so a figure's ground and the slide's ground become the
same value and the seam disappears. Verify by rendering one full-bleed figure
and looking for an edge.

### The illustration register — two honest routes

**Drawn, in one hand.** Slide 3 of the reference is *already* within reach:
simplified line heads, accent-coloured arrows, one caption under each step.
That is `figkit.box`, `arrow`, `disc`, `text_block` with the accent injected.
Slide 10's spine-plus-satellites is `figkit` too, minus the rendered scale. This
route never dates, needs no licence, and is fully regenerable.

**Generated, then subjugated.** For a charcoal eye or an engraved portrait,
generate — but with **one style prompt reused verbatim** for every image:
medium, paper colour named by hex, line weight, palette, framing, level of
abstraction. Then run every result through the same treatment anyway:

```python
# theme.py — the house treatment, one dict, passed everywhere
IMAGE_TREATMENT = dict(treatment="duotone", dark=INK, light=PAPER, gamma=0.9)
```

```python
figkit.treated_photo(
    ax, 0, 0, 4.6, 4.9, "assets/img/portrait.jpg", frame=False, **theme.IMAGE_TREATMENT
)
```

The treatment is what rescues coherence when the generator drifts — and it is
exactly what turns a stock portrait into a member of the family. `duotone`,
`tint` and `desaturate` are in `figkit`; pick **one** per deck.

### Emphasis inside the sentence

```markdown
- La fonction : structurante mais __aliénante__
  - l'enfant voit une **image unifiée**, mais c'est une fiction
```

`deckkit.write_rich` splits that into runs: `**strong**` bold, `__accent__` in
the accent colour, `*stress*` italic. Wire the accent once:

```python
kit.set_bullets(ph[10], col.bullets, levels=theme.LEVELS, accent=theme.ACCENT)
```

### Semantic colour

Reserve one colour for one meaning and never spend it elsewhere. In the
reference, cool grey-blue means *rigid, cold, non-responsive*. Declare it in
`theme.py` with the comment that binds it, exactly as the technical deck in
this repo binds one colour per class.

### The archetypes

Write them as fillers, one per archetype, and reuse. Four to six is the right
number. If a seventh appears, ask whether it is a new idea or an
inconsistency.

### What we cannot reproduce, and should not pretend to

A hand-drawn charcoal eye is not coming out of matplotlib. Say so, and choose:
either commission/generate the illustrations and treat them, or design a
geometric visual language that is genuinely ours. Both are respectable. What is
not respectable is a deck where three slides are illustrated and nine are bare
because the budget ran out — that inconsistency is more visible than either
choice.

---

## 3. The image treatments, and when to use which

Implemented in `scripts/figkit.py`. One per deck, no mixing.

| Treatment | Strength | Use when |
|---|---|---|
| `duotone(dark, light)` | strong | photographs, portraits, archive material — their own colour is not information |
| `tint(colour, alpha)` | medium | annotated figures, screenshots, coloured contours — structure must survive |
| `desaturate(amount)` | mild | the deck already has one loud accent doing the talking |
| `none` | — | a figure you authored, already in the palette |

If an image carries information a treatment would destroy — a diagram whose
meaning is in its colours — do not treat it. Give it a framed panel and let it
be visibly a quotation from elsewhere. A deliberate exception, stated in a
caption, reads as rigour; an accidental one reads as carelessness.

---

## 4. Typographic atmosphere

- **One pair, contrasted.** Display serif for the argument, neutral sans for the
  apparatus — never two serifs. Both templates in `assets/` already declare
  their pair; use theirs.
- **Scale, not weight.** A 40 pt title over 18 pt body says more than bold 24
  over regular 24. Fix a ratio and hold it.
- **Air as a material.** Generous margins read as confidence — but only when
  something anchors them: a rule, a tag, a disc. Air plus nothing reads as an
  unfinished slide (see `pitfalls.md`).
- **One vertical position per role.** Titles at one height, captions at one
  height, on every slide. Nothing betrays assembly faster than a title that
  moves.

---

## 5. Provenance, licences, and not lying

A beautiful deck that cannot be shown is worthless.

- **Record the source of every image**, in the caption or the notes. The
  technical deck in this repo credits each corpus under the figure that uses
  it.
- **Check what the licence permits.** Some datasets forbid public display of
  any recognisable face; some are non-commercial only. A treatment does not
  launder a licence.
- **Say when an illustration was generated.** For an academic or professional
  reader, an uncredited generated image is a real problem, and a one-line note
  costs nothing.
- **Never present a generated portrait as a document.** Treating a real
  portrait to match the palette is design. Generating a plausible face and
  letting it pass for the person is not. Note that the reference deck's
  Winnicott portraits are stylised *illustrations*, which is the honest form.

---

## 6. Checklist — run it on the contact sheets, not on one slide

- [ ] Remove the content: would I still recognise the deck? (If not, there is
      no visual system.)
- [ ] Is the ground the same value on the slide and inside every figure?
- [ ] Does every image share one treatment?
- [ ] Is there a fifth colour anywhere? What does it mean?
- [ ] Do titles sit at the same height on every slide? And captions?
- [ ] Do the archetypes repeat, or does each slide invent a layout?
- [ ] Any air with nothing anchoring it?
- [ ] Any projected text below 16 pt? (See `typography.md`.)
- [ ] Does every image have a recorded source?
