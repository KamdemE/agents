# Building on a template you did not make

## Why this is not optional

A corporate or school template carries the palette, the type pair, the layouts,
the page furniture, the logos, and often mandatory instruction slides.
Reproducing all that by hand always drifts, and the drift is exactly what a
reviewer notices. Build on the file.

Where none exists, `deckkit.open_deck()` with no argument gives you a blank
16:9 document and you become the design authority — legitimate, but then write
the palette down and hold to it (`visual-systems.md`).

## Phase 1, always: map it

```bash
uv run --with python-pptx python scripts/inspect_template.py deck.pptx
uv run --with python-pptx python scripts/inspect_template.py deck.pptx --slides
```

You are looking for five things.

**The theme palette.** `ppt/theme/theme1.xml` `<a:clrScheme>` is the only
legitimate source of a brand colour. Never eyedrop a screenshot.

**The body levels.** Sizes, fonts, and above all `marL`. If every level shows
`marL=0`, the template carries hierarchy by size alone — the single most common
cause of an illegible deck. See `typography.md`.

**The layout inventory.** Exact names, because a slide's `layout:` must match
one. Rich templates reward reading: the X template has 36 layouts including
sommaires from 2 to 6 parts, section dividers, timelines, org charts and image
grids. Inventing a layout when one exists is wasted work.

**Placeholder `idx` and geometry.** `idx` values are **not** in reading order.
Pair them by coordinates and write the mapping down as a comment quoting the
coordinates that justify it. This is the single biggest time sink if skipped.

**The baked decorations.** Shapes that live in the layout, not the slide: a
`p.` label, a coat of arms, a rule. You cannot remove them per slide. Use them,
or cover them (`deckkit.cover`), and check the cover does not clip a neighbour.

Then `--slides` on an existing deck that works: it prints each paragraph's
`level`, which tells you immediately whether its author used real levels or
typed dashes into level-0 text.

## Hidden instruction slides

Templates often ship help slides at the top carrying `show="0"`: present in the
file, absent from the running order. Some authors deliberately keep them on
every deck so the rules travel with the file.

**Keep them.** `deckkit.drop_slides_after(prs, keep=3)`. Ask before deleting.
You can add your own with `scripts/make_help_slides.py`, which reads the theme,
the levels and the layout inventory and writes them onto hidden sheets in the
template's own colours — idempotent, and inserted after any leading hidden run
so official slides stay first.

## Choosing a layout, and when to stop

Pick the layout whose geometry already fits the content. Then check it against
its own decorations: on the X template's "bullets + coat of arms", both text
columns overlap the emblem the master centres, so it only works with very short
lines.

If a layout cannot hold the content well, **change the layout or draw a
figure**. Fighting a layout's geometry with manual text boxes is how a deck
starts looking assembled. That judgement was made four times in
`presentation_x_v2`; each time the figure was better.

## Not editing the master

Read from it, never write to it. It is shared, it may be revised, and a deck
that silently edits its template will surprise the next person. Everything this
skill does — covers, text boxes at layout coordinates, explicit indents — is a
way of respecting that.

## Slide size

Read it, do not assume: the X template is 13.333 × 7.5 in, the DxO one 10 ×
5.625 in. Both are 16:9, and a figure authored for one is not sized for the
other. Put the target boxes in `theme.py` and derive figure sizes from them.
