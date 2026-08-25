# Typography, hierarchy, density

## The defect this skill exists to prevent

Feedback from a real defence: *the indentation was not visible enough for a jury
sitting far from the screen.*

Two causes, and both must be fixed.

**The author typed the hierarchy into the text.** `-   ` and `        -> `
inside level-0 paragraphs. Every paragraph was level 0; PowerPoint knew nothing
about any structure.

**The template's master sets `marL=0` on every body level.** Both templates in
`assets/` do. Hierarchy is carried by size alone — a 24 → 18 pt step, at the
same left edge. From five metres that is not a hierarchy, it is a list of
slightly different sizes.

## The fix: three cues at once

| level | size | indent | bullet |
|---|---|---|---|
| 0 | 24 pt | 0 | none |
| 1 | 18 pt | 0.46 in | em dash, accent colour |

- **Size step.** Keep a real ratio; 24/18 is 3:4 and reads.
- **Absolute indent.** Set `marL` yourself. It is not inherited.
- **Hanging coloured bullet.** `indent` negative, `buClr` in the accent.

`deckkit.set_bullets` does all three. `hang_in` is 0.38 in and not 0.26 for a
measured reason: an em dash fills almost all of a 0.26 in hang and the bullet
ends up glued to the text (`—repérer`). The hang must be the glyph width plus
visible space.

## Two levels, and a hard stop

Both templates declare five levels, descending to 12 pt bold and then 10 pt.
**Do not use them.** 10 and 12 pt do not survive projection; using them
reproduces the very defect being fixed.

`slides.py` raises on a third level, with the reason in the message. A third
level means the slide carries two ideas and must be split. Treat that error as
correct.

Floor for anything projected: **16 pt**. In a narrow column, scale the pair
(24/18 × 0.88 → 21/16) rather than dropping a level.

## Never automatic capitals

`caps=True` is fine in the file and breaks under font substitution: accented
capitals decompose into a letter plus a floating accent (`PROBLÈME` →
`PROBLE\`ME`, while `É` survives). Bold plus colour distinguishes a heading
without depending on the available font.

## Set the font explicitly

Body placeholders do not all inherit the same face across layouts of one
template: one layout drops to the secondary font while its neighbour stays on
the primary, and you get two adjacent slides in two typographies. Mirror the
template's own boundary — primary serif for the argument, secondary geometric
for the apparatus (captions, breadcrumbs, page numbers), which is exactly what
the X template's instruction slide prescribes for its levels 1–3 versus 4–5.

## Emphasis inside the sentence

Colouring a single word in the accent, mid-sentence, guides the eye better than
bold. `deckkit.write_rich` supports `**strong**`, `__accent__`, `*stress*`. Used
well it is the most economical emphasis available; used on every third word it
is noise.

## Density — the rule that is actually binding

Presentation rules often say two things in one breath, on different registers.
The École polytechnique directive is the clear case:

> l'espace disponible sur la planche **doit** être utilisé de manière optimale,
> elle ne doit être ni vide, ni surchargée

> il est **habituel** qu'une planche comporte moins de six lignes et moins de
> six mots par ligne

One is an obligation, the other a habit. When they collide — six lines pinned to
the top of a 4.6 in placeholder leave three inches of void, which *is* "empty" —
the obligation wins. Operationally, and checked automatically:

- a text block (a column, heading included): **5 lines** max;
- a single-block slide: **6 lines** max;
- **6 words per line**, held strictly — this is the limit that actually stops a
  slide becoming prose;
- the block is **centred vertically**, so the air reads as intent;
- annexes are exempt: read on demand, not grasped at a glance;
- figures, tables, timelines and org charts are not counted in lines.

Whatever you decide, quote the sentences and state the arbitration in the
deck's `RULES.md`. An interpretation you can defend is fine. An undocumented one
is not.
