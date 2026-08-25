# Architecture — the contract both decks share

Two example decks, built months apart for different audiences, converged on
the same shape. This is that shape. Both live in their own repository, not
inside this skill — see `SKILL.md` → **Example repositories**.

- **`presentation`** — 40 slides, internal DxO technical talk. 180 figures,
  a content-hash incremental cache, a verified mirror of a production pipeline.
- **`presentation_x_v2`** — 12 slides + 5 annexes, École polytechnique
  soutenance, built on the school's template, with a rule validator.

## The files, and what each is forbidden from doing

```
<deck>/
├── README.md      the format contract, and known limits
├── RULES.md       the rules that bind, quoted, and where each is honoured
├── theme.py       palette · fonts · bullet levels · named geometry
├── slides.py      markdown → objects.        Parses. Nothing else.
├── deck.py        one filler per layout.     Places. Writes no sentence.
├── figures/       style/figkit + modules, each exposing ALL
├── slides/        NN_name.md, A1_name.md for annexes
├── preview.py     pptx → PNG + contact sheets
├── render.py      the single entry point
└── build/         100 % regenerable
```

| module | may | may not |
|---|---|---|
| `slides.py` | parse, validate syntax, raise | know a colour, a coordinate, a layout |
| `theme.py` | define palette, type, levels, grid | know a slide's content |
| `deck.py` | know where things go on a layout | invent a word or a colour |
| `figures/*` | draw | write a sentence that belongs in markdown |
| `render.py` | dispatch | do any of the above |

The boundary that matters is not "text versus code" but **"a sentence versus an
annotation glued to a datum"**. A head, a sub-head, a caption, a column, a
speaker note is a sentence: it lives in markdown. An arrow that must land on the
bar at 0.834 lives next to the coordinates that place it.

## The couplings, and there are only two

**A shared string.** `figure: value_loop` in the markdown, `key = "value_loop"`
on the builder's first line, `build/figs/value_loop.png` on disk. No registry to
maintain, and `check` verifies it in both directions.

**A layout name.** `layout: Double bloc de texte` must be a layout the template
declares, and `deck.SPECS` must have a filler for it. Both directions checked.

Everything else is injection: `deckkit` and `figkit` take colours and sizes as
arguments so `theme.py` stays the only source of truth.

## Numbering

The number leading a filename is a **sort key**, not a page number. Inserting a
slide between 4 and 5 is `04b_….md`, and renames nothing. `slides.load()`
numbers by position; files starting with `A` are annexes numbered separately,
because most presentation rules allow back-up slides after the closing slide
without counting them in the budget.

## Failing well

Fail early, loudly, with the remedy in the message. A build that stops costs
minutes; a plausible wrong deck costs the meeting.

```
04_org.md: field `part:` missing (required by "Organigramme").
07_mission.md: figure `value_loop` not built (build/figs). Run `render.py figures`.
06_ambi.md: bullet at level 2 — the deepest projectable level is 1.
```

The one place to be deliberately loose: a builder whose key cannot be read is
rebuilt every time. Wrong in the safe direction.

## The incremental cache — when it is worth it

`assets/presentation/` fingerprints every figure by **content**, not timestamp:
it walks the builder's AST, collects the globals, local imports, module
attributes and closure values it actually reaches, hashes them together with the
owning markdown, and stores `{key: sha256}`. The argument is exact — a timestamp
says that editing a comment invalidates 37 figures, a content hash says the
truth.

Two details make it work: hash **before** the first draw (drawing fills module
caches, and a digest taken after never matches what a fresh interpreter would
compute), and discard any `repr` containing a memory address.

Worth it above roughly 30 figures or when a figure costs seconds. Below that, a
full rebuild costs nothing and the cache is a liability. `presentation_x_v2` has
eleven figures and no cache, on purpose.

## What to fix if you port it

Known weaknesses of the older tree, already corrected in `scripts/`:

1. front-matter was `text.split("---", 2)`, not YAML — it shifted silently on a
   `---` inside notes;
2. no bullet syntax at all, so hierarchy had to be faked in the text;
3. `check` only asked whether a PNG existed;
4. the palette existed in three places;
5. geometry was a cloud of literal `Inches()` in seven functions;
6. two twin trees maintained by hand — a fix found in one had to be applied in
   both. Prefer one tree and a manifest.
