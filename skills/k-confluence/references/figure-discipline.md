# Figure Discipline

Use this reference whenever a page carries figures that come from somewhere else —
a slide deck, a report generator, a notebook, a plotting module in the repo.

This is the part of Confluence work that goes wrong most often and most
expensively, because a wrong figure is *confidently* wrong: it renders, it looks
professional, and it quietly argues something the text does not say.

## 1 · Only figures the canonical source actually ships

Documentation that adapts an existing artefact — a deck, a report, a paper — must
draw its figures from **what that artefact actually renders**, not from the
directory where its build output happens to land.

Those two sets are almost never the same. A figure directory typically also holds:

- **long-form builders nobody registered** — panels written during exploration,
  still compiling, never placed in the final artefact;
- **stale output** from pages or sections that no longer exist;
- **galleries and appendices** that were cut for length.

Using one of those is not a small error. It is a figure **that has never been
reviewed by anyone**, presented with the authority of the source it appears to
come from.

**So derive the legal set mechanically, never from the file listing.** Parse the
source's own manifest — the front matter of its pages, its build registry, its
table of contents — and treat that as the only admissible set.

**Then encode it so it cannot be broken by accident:**

```python
PROVENANCE = {"figure_name": "the source page it was isolated from", ...}

def img(page, name, alt, caption=""):
    if name not in PROVENANCE:
        raise SystemExit(f"{name} has no provenance — is it in the source at all?")
    ...
```

A dictionary that the patch script consults on every insertion is worth more than
any amount of care, because care does not survive a long task.

## 2 · One figure per argument, at the argument

A composite board is not a figure. It is several figures sharing a canvas because
a slide has one canvas and a talk has one presenter.

A page has neither constraint. It argues one thing per heading, so it needs
**one figure per heading** — the lane that argues *that* point, and nothing else.

Dropping a whole board under a heading answers that heading's question **and three
others the reader has not been asked yet**. It reads as dumping, because it is.

| symptom | what it means |
|---|---|
| the caption has to say «look at the top-left panel» | the figure is an aggregate |
| the same figure appears under three headings | no heading has its own figure |
| the caption explains four things | four figures were merged into one |

## 3 · Isolate the sub-code — never crop, never re-implement

Three ways to get one lane out of a composite, in decreasing order of safety:

**Re-run the drawing code of that lane.** Import the module, call the block that
draws it onto its own canvas, save. The palette, the fonts, the numbers and the
maths are the source's own, so the figure *cannot* drift from what the source
shows. This is the default.

**Slice by the source's own layout constants.** When the composite draws onto a
single axes whose data units are inches, its band boundaries are literals in the
code — `ax.plot([0, w], [2.66, 2.66])` is a divider at 2.66. Save that rectangle
through the plotting library's own transforms:

```python
corners = ax.transData.transform([(x0, y0), (x1, y1)])
box = Bbox.from_extents(*corners.ravel()).transformed(fig.dpi_scale_trans.inverted())
fig.savefig(path, dpi=DPI, bbox_inches=box)
```

Nothing is estimated: the numbers come from the source, and the unit conversion
comes from the library rather than from arithmetic of your own.

**Select axes and hide the rest.** When the composite is built from separate axes,
union their measured tight bounds — and switch the others off first, or the box
will pass over a neighbour's tick labels.

**Never crop at a guessed fraction of the image.** It is guesswork that looks like
work, it breaks on any re-render, and it slices type.

**Never re-implement a panel from memory.** It will diverge, and the divergence
will be invisible until someone compares the page against the source in a meeting.

## 4 · Chrome comes off, layout gets re-fitted

Strip what belongs to the source's frame and not to the argument: navigation
rails, step numbers, slide heads, banners. The page has its own heading.

Then look at what is left. A lane spaced to fill a tall canvas beside a panel that
is no longer there arrives with inches of white in it. **That white is not
neutral** — it reads as a missing panel. Re-fit the lane to its own content, and
say in a comment why the spacing differs from the source.

## 5 · Every display formula is rendered

An expression that stands on its own line is a display formula and must be an
image, rendered from the source's own maths engine. Unicode approximations
(`Φ = w + ½·max(ratio − 1, 0)·ρ`) are not acceptable at display size.

Inline symbol references in running prose — `ρ`, `∇I`, `σ_max` — may stay as
inline code.

**Watch for the duplicate.** If a rendered formula is already on the page, a
`<code>` restatement of it two lines below is the same expression twice, in two
notations. Delete the text one.

## 6 · No caption without a figure

A caption with nothing above it is the loudest possible signal that a figure was
removed, renamed, or never uploaded. Sweep for the pattern explicitly — it is
easy to detect and impossible to notice by reading.

The same goes for pointers into a figure that is not there: «the panel on the
right», «the figure below», «top-left». If the figure is on the page, the pointer
is fine. If it is not, the sentence is describing something the reader cannot see.

## 7 · A section with no legal figure gets no figure

When the canonical source has nothing for a section, **the section gets no
figure**. Prose with its numbers is honest. A picture the source never shows is
not, however well it would fill the space.

If that leaves a page with no figures at all, that is a finding about the page's
scope — report it rather than papering over it.

## 8 · Resolve attachment ids at patch time, by name

An attachment id is assigned by the server at upload. Writing one into a script
from a previous run's output produces references that resolve to nothing the first
time an upload is repeated.

```python
def att(page, name):
    return list_attachments(page)[name]["id"]   # looked up now, never remembered
```

Upload with a **deterministic name**, and let every reference go through that
lookup. Update an existing attachment in place (`POST .../attachment/<id>/data`)
so the id — and every `<img src>` already in the body — survives.

## 9 · No figure on two pages, with one exception

A figure belongs to the argument it makes, and an argument is made once. If the
same figure is on two pages, one of them is arguing something that is not its job.

The one legitimate exception is **hub-previews-then-argues**: a landing page may
carry its section's opening or headline visual, which its child page then argues
in full. State that intent when you do it, so the next reader does not "fix" it.

A **definition** restated where it is used is also fine — a one-line formula that
one page derives and another page flows on top of.

## 10 · Look at every figure you generate

Render a contact sheet and open it. Every defect in this file was found by
looking, and none of them by reading the code that produced it: type sliced by a
crop, a legend clipped at the canvas edge, a formula colliding with a marker, two
inches of inherited white, an interceptor that also caught the colour-bar label.
