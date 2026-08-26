# Pitfalls — defects reproduced, with the fix and the reason

Every entry here was observed on a real render, not inferred. Each was
invisible in the code and obvious in the image. Do not re-derive them.

---

## python-pptx and OOXML

### An auto-field survives under your text

**Symptom.** Slide 2 shows `52/12`. Slide 3 shows `63/12`. The footer shows
`05/08/2025I · Part one`.

**Cause.** A template's slide-number and date placeholders contain an automatic
`<a:fld>`. `paragraph.runs` does not expose it, so clearing the runs leaves it
in place, and it keeps rendering the slide's real index in the file — hidden
instruction slides included — with your own text appended.

**Fix.** When clearing a text frame, remove `a:fld` and `a:br` as well as
`a:r`:

```python
for tag in ("a:r", "a:fld", "a:br"):
    for el in p0._p.findall(qn(tag)):
        p0._p.remove(el)
```

### …and the doubling comes back anyway

**Symptom.** The XML is provably clean — one run, the right text, no field —
and the render still shows the auto value next to yours.

**Cause.** Some renderers special-case the `dt` and `sldNum` placeholder
*types* and re-inject the field value at draw time.

**Fix.** Stop using those placeholders. Read their geometry from the layout and
draw a plain text box there instead (`deckkit.footer`). Same visual result,
no field semantics attached.

### `add_slide()` silently skips footer placeholders

**Symptom.** After `add_slide(layout)`, `slide.placeholders` yields `0, 10, 12`
— but the layout clearly defines `idx=2` (date) and `idx=4` (slide number), so
your page numbers appear nowhere.

**Cause.** python-pptx clones title and body placeholders from the layout, not
footer-category ones.

**Fix.** Either deep-copy the element yourself
(`slide.shapes._spTree.append(copy.deepcopy(ph._element))`) — but then read the
entry above — or, better, use a plain text box at the layout's coordinates.

### An inserted picture reports the "wrong" `shape_type`

**Symptom.** Code that checks `shape.shape_type == 13` (`PICTURE`) to confirm
an image landed finds nothing, even though the picture is visibly there.

**Cause.** Inserting into an existing **picture placeholder** (a
`picture_with_caption`-style layout, via `placeholder.insert_picture(...)`)
returns a `PlaceholderPicture`, not a plain `Picture` — its `shape_type` is
`14` (`PLACEHOLDER`), not `13`. (Ported from
`references/alternative-mcp-approach.md`.)

**Fix.** For a placeholder-inserted picture, check `shape.shape_type == 14
and shape.image is not None`. `13` only applies to a picture added directly
with `shapes.add_picture()` — what `deckkit.fit_picture` does, so it is
unaffected by this.

### Removing a slide leaves an orphan part

**Symptom.** A zip warning on every save.

**Cause.** Removing an entry from `sldIdLst` unlinks the slide from the running
order but leaves its part in the package.

**Fix.** `prs.part.drop_rel(rId)` *before* `lst.remove(sld_id)`. See
`deckkit.drop_slides_after`.

### Saving over the file you opened

**Symptom.** `UserWarning: Duplicate name: 'ppt/slides/slide5.xml'`.

**Fix.** Save to a sibling temp path, then `Path.replace()` it over the target.

### `paragraph.runs` returns fresh proxies

`run is runs[0]` is always false. Iterate by index if you need identity.
(Found while rewriting a master footer in the DxO deck.)

### Layout decorations cannot be removed per slide

**Symptom.** A `p.` sits next to every sommaire entry, and the rule you must
follow says page references there are useless.

**Cause.** It is a plain text box baked into the LAYOUT, not a placeholder on
the slide.

**Fix.** You cannot delete it without editing the master, which you should
refuse to do. Cover it with a background-coloured rectangle
(`deckkit.cover`), and say so in a comment. Verify the cover visually: it must
not clip an adjacent ornament.

### Placeholder `idx` values are not in reading order

**Symptom.** Page numbers 3, 4, 5, 7 render as 7, 5, 4, 3.

**Cause.** You guessed the mapping from the numeric order of `idx`.

**Fix.** Pair placeholders by their `(left, top)` coordinates against the
elements they belong to, and write the derived mapping down as a comment with
the coordinates that justify it. `inspect_template.py` prints them sorted by
position for exactly this.

### An empty placeholder is not neutral

PowerPoint shows its prompt text (`Texte`, `Prénom Nom`, `image`) while
editing, and some renderers export it. Drop what you do not fill
(`deckkit.drop_placeholders`).

---

## Typography and legibility

### Indentation invisible from the back of the room

**Symptom.** A jury five metres away sees a flat list.

**Two causes, both must be fixed.** The author typed the hierarchy into the
text (`-   `, `   -> `) leaving every paragraph at level 0; and the template's
master sets `marL=0` on all body levels, carrying hierarchy by size alone.

**Fix.** Real paragraph levels, plus three simultaneous cues per level: a size
step, an absolute `marL`, and a coloured hanging bullet. See
`typography.md`.

### The bullet glyph glued to the text

**Symptom.** `—repérer ce qui mérite l'attention`.

**Cause.** An em dash fills almost all of a 0.26 in hanging indent.

**Fix.** Make the hang the glyph width *plus* visible space — 0.38 in for an em
dash at 18 pt.

### Accented capitals decompose

**Symptom.** `LE PROBLÈME POSÉ` renders `LE PROBLE`ME POSÉ`. Note that `É`
survives and `È` does not.

**Cause.** Automatic uppercasing plus a substituted face whose accented
capitals are incomplete.

**Fix.** Do not uppercase automatically. Bold plus colour distinguishes a
heading without depending on the available font.

### Missing glyphs in a substituted face

**Symptom.** `coût` renders `cou^t`, `août` renders `aou^t`, `Jusqu'où`
renders `Jusqu'ou``. Meanwhile `problème`, `hôtel` and `très` are fine.

**Diagnosis.** Check the source encoding first — the markdown was verified NFC,
so no combining characters. Then check the run text in the produced XML: it was
correct. The defect is the *substituted* font used by the renderer, which lacks
`û`, `ù` and the accented capitals. A `~/.config/fontconfig/fonts.conf` alias
does not help: some renderers keep their own substitution table and ignore it.

**Conclusion.** It is an appearance bug in the preview, not a file bug. Prove
it by reading the XML, document it, and do **not** distort correct spelling to
please a broken preview. On a machine with the real font installed it renders
normally.

### Two adjacent slides in two typographies

**Cause.** Body placeholders do not all inherit the same face across layouts of
one template: one layout drops to the secondary font while its neighbour stays
on the primary.

**Fix.** Set the font explicitly on every run. Mirror the template's own rule
for the boundary — e.g. primary serif for the argument, secondary geometric for
the apparatus (captions, breadcrumbs, page numbers).

---

## Composition

### Text floating in a void

**Symptom.** Six lines pinned to the top of a 4.6 in placeholder, three inches
of white underneath. The slide reads as unfinished even though it respects the
line budget — and "must not be empty" is usually the *binding* rule while the
line count is only a habit.

**Fix.** `text_frame.vertical_anchor = MSO_ANCHOR.MIDDLE`. Same content, read
as deliberately airy. Add a gutter rule when two short columns need something
to hold them.

### A photograph that does not fit its band

**Symptom.** A 2.67-aspect image centred in a 6.94-aspect full-bleed band, with
white gaps either side; cropping it to fill would cut the faces the image was
chosen for.

**Fix.** Do not force it. Either author a figure at the band's exact aspect, or
change the layout. Fighting a layout's geometry with manual text boxes is how a
deck starts looking assembled instead of designed.

### Text over a watermark

**Symptom.** On a "bullets + coat of arms" layout, both text columns overlap
the emblem the master centres, and the emblem wins.

**Fix.** Check the layout's decorations against its placeholder boxes before
choosing it. Here the columns (1.04→6.17 and 7.28→12.41) both intersect the
arms (4.93→8.40): the layout only works with very short lines. It was replaced
by a purpose-drawn figure.

### A connector that disappears

**Symptom.** A feedback arrow meant to loop under a row of boxes is not there.

**Cause.** `arc3` computes its curvature from the chord, so a wide return arc
passes *behind* the boxes it was meant to clear — and they are drawn at a
higher zorder.

**Fix.** An explicit three-segment path: down, across, up, with the arrowhead
on the last segment (`figkit.return_path`).

### A figure whose type does not match the slide

**Cause.** `savefig(..., bbox_inches="tight")`. Tight cropping changes the
PNG's dimensions, so the figure is rescaled when placed and its 14 pt becomes
something else.

**Fix.** Author the figure at the target box's exact size in inches and save
without tight bounds.

### Text overflowing a figure

matplotlib does no line breaking at all. Wrap before drawing
(`figkit.wrap`, `figkit.text_block`).

---

## Environment

### The mount refuses `unlink`

**Symptom.** `PermissionError: Operation not permitted` when clearing an output
directory, while writing to the same directory works.

**Fix.** Overwrite instead of deleting, and report leftovers from a longer
previous run rather than trying to remove them.

### Hidden slides are absent from the PDF

`show="0"` slides are excluded from PDF export, so they never appear in a
preview. Generate a visible copy to proof-read them.

### A stale figure shipped for a whole pass

**Symptom.** Two slides showed a frozen PNG with an old label.

**Cause.** `check` only asked whether the file existed — the wrong question.

**Fix.** Cross the set of keys declared by slides with the set produced by the
figure builders, in **both** directions, and fail on either orphan.
