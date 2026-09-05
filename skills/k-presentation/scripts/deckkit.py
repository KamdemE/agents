"""python-pptx primitives for building on a template.

Every function here exists because something rendered wrong once. The comments
say what broke; do not simplify them away.

The module is deliberately theme-agnostic: it takes colours and sizes as
arguments so a deck's own `theme.py` stays the single source of truth. Wire it
up in your `deck.py`:

    import deckkit as kit
    kit.set_bullets(ph[10], col.bullets, levels=theme.LEVELS,
                    heading=col.name, heading_style=theme.HEADING)

What belongs where
------------------
  slides.py   parses          — no geometry, no colour
  theme.py    palette, fonts, bullet levels, named geometry — once
  deckkit.py  how to write into a placeholder without fighting OOXML
  deck.py     one filler per template layout: WHERE things go on that layout
"""

from __future__ import annotations

import pathlib
from dataclasses import dataclass

from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_CONNECTOR, MSO_SHAPE
from pptx.enum.text import MSO_ANCHOR, PP_ALIGN
from pptx.oxml.ns import qn
from pptx.util import Emu, Inches, Pt

EMU_PER_INCH = 914400


# =========================================================== data types ===
@dataclass(frozen=True)
class Level:
    """One projected bullet level.

    `indent_in` is an ABSOLUTE indent in inches, not an inheritance. Most
    template masters set `marL=0` on all body levels and carry hierarchy by
    size alone — run inspect_template.py and look at the marL column. Setting
    it here is what makes the structure visible from the back of a room.
    """

    size: float  # points, ideally a size the template declares
    indent_in: float  # absolute left indent, inches
    bullet: str | None  # glyph, or None for no bullet
    colour: str  # "003E5C"
    bullet_colour: str
    space_before: float  # points


@dataclass(frozen=True)
class TextStyle:
    size: float
    colour: str
    bold: bool = False
    italic: bool = False
    font: str | None = None


@dataclass(frozen=True)
class Box:
    """A slide region, in inches — python-pptx's natural unit."""

    left: float
    top: float
    width: float
    height: float

    def as_emu(self):
        return (
            Inches(self.left),
            Inches(self.top),
            Inches(self.width),
            Inches(self.height),
        )


def inches(value) -> float:
    return value / EMU_PER_INCH


def box_of(shape) -> Box:
    """The geometry of any shape or placeholder, in inches."""
    return Box(
        inches(shape.left), inches(shape.top), inches(shape.width), inches(shape.height)
    )


# ======================================================= template access ===
def layout_named(prs, name: str):
    for layout in prs.slide_masters[0].slide_layouts:
        if layout.name == name:
            return layout
    have = sorted(x.name for x in prs.slide_masters[0].slide_layouts)
    raise SystemExit(f"layout not in template: {name!r}\navailable: {have}")


def layout_box(layout, idx: int, *, widen: float = 0.0) -> Box | None:
    """Geometry of a layout placeholder — use it instead of hardcoding.

    Reading the coordinates from the layout keeps a deck aligned with its
    template even if the template is revised.
    """
    for p in layout.placeholders:
        if p.placeholder_format.idx == idx:
            b = box_of(p)
            return Box(b.left, b.top, b.width + widen, b.height)
    return None


def placeholders(slide) -> dict:
    return {p.placeholder_format.idx: p for p in slide.placeholders}


def drop_placeholders(slide, *idxs: int) -> None:
    """Remove unused placeholders.

    An empty placeholder is not neutral: PowerPoint shows its prompt text
    ("Texte", "Prénom Nom") while editing, and some renderers export it. What
    is unused gets removed, not left blank.
    """
    for idx in idxs:
        for p in list(slide.placeholders):
            if p.placeholder_format.idx == idx:
                p._element.getparent().remove(p._element)
                break


def drop_slides_after(prs, keep: int) -> None:
    """Keep the first `keep` slides of the base file, delete the rest.

    Drop the RELATION before removing the `sldIdLst` entry. Removing the entry
    alone unlinks the slide from the running order but leaves its part orphaned
    in the zip, which the OPC layer complains about on every save.

    `keep` is rarely 0: templates often ship instruction slides carrying the
    palette and the usage rules, and some authors deliberately keep them at the
    top of every deck they build. They usually carry `show="0"` — present in
    the file, absent from the running order. Ask before deleting them.
    """
    lst = prs.slides._sldIdLst
    rel_ns = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id"
    for sld_id in list(lst)[keep:]:
        prs.part.drop_rel(sld_id.attrib.get(rel_ns))
        lst.remove(sld_id)


# ======================================================== paragraph level ===
def _pPr(paragraph):
    return paragraph._p.get_or_add_pPr()


def no_bullet(paragraph) -> None:
    pPr = _pPr(paragraph)
    for tag in ("a:buChar", "a:buAutoNum", "a:buNone", "a:buClr", "a:buFont"):
        for el in pPr.findall(qn(tag)):
            pPr.remove(el)
    pPr.append(pPr.makeelement(qn("a:buNone"), {}))


def set_bullet(paragraph, glyph: str, colour: str, font: str) -> None:
    """A coloured bullet glyph. python-pptx has no API for this."""
    pPr = _pPr(paragraph)
    for tag in ("a:buChar", "a:buAutoNum", "a:buNone", "a:buClr", "a:buFont"):
        for el in pPr.findall(qn(tag)):
            pPr.remove(el)
    clr = pPr.makeelement(qn("a:buClr"), {})
    clr.append(pPr.makeelement(qn("a:srgbClr"), {"val": colour}))
    pPr.append(clr)
    pPr.append(pPr.makeelement(qn("a:buFont"), {"typeface": font}))
    pPr.append(pPr.makeelement(qn("a:buChar"), {"char": glyph}))


def set_indent(paragraph, marL_in: float, indent_in: float) -> None:
    pPr = _pPr(paragraph)
    pPr.set("marL", str(int(Inches(marL_in))))
    pPr.set("indent", str(int(Inches(indent_in))))


def set_spacing(paragraph, before_pt: float, line_pct: float | None = None) -> None:
    pPr = _pPr(paragraph)
    for tag in ("a:lnSpc", "a:spcBef"):
        for el in pPr.findall(qn(tag)):
            pPr.remove(el)
    if line_pct is not None:
        ln = pPr.makeelement(qn("a:lnSpc"), {})
        ln.append(pPr.makeelement(qn("a:spcPct"), {"val": str(int(line_pct * 1000))}))
        pPr.insert(0, ln)
    sb = pPr.makeelement(qn("a:spcBef"), {})
    sb.append(pPr.makeelement(qn("a:spcPts"), {"val": str(int(before_pt * 100))}))
    pPr.append(sb)


def clear(tf):
    """Empty a text frame, keeping exactly one paragraph.

    Removes `a:fld` as well as `a:r`. This is the line people miss: a template's
    slide-number and date placeholders contain an automatic FIELD, which
    `paragraph.runs` does not expose. Leave it in place and the field keeps
    rendering the slide's real index — hidden instruction slides included —
    with your own text appended: slide 2 came out as "52/12".

    Even with the field removed, some renderers re-inject the auto value next
    to your text for `dt`/`sldNum` placeholder TYPES. If you see that, stop
    using those placeholders and use `textbox()` at the layout's coordinates —
    see `footer()`.
    """
    tf.word_wrap = True
    p0 = tf.paragraphs[0]
    for extra in list(tf.paragraphs[1:]):
        extra._p.getparent().remove(extra._p)
    for tag in ("a:r", "a:fld", "a:br"):
        for el in p0._p.findall(qn(tag)):
            p0._p.remove(el)
    return p0


def paragraphs(tf, count: int) -> list:
    first = clear(tf)
    return [first] + [tf.add_paragraph() for _ in range(count - 1)]


def write(paragraph, text: str, style: TextStyle, *, caps: bool = False):
    """Write one run.

    Set the font explicitly. Body placeholders do not all inherit the same face
    across layouts of the same template — one layout can drop to the secondary
    font while its neighbour stays on the primary — which yields two adjacent
    slides in two typographies.

    `caps` is a trap worth knowing: uppercasing accented text is fine in the
    file, but under font substitution the accented capitals can decompose into
    a letter followed by a floating accent ("PROBLÈME" → "PROBLE`ME"). Prefer
    bold plus colour over automatic capitals.
    """
    run = paragraph.add_run()
    run.text = text.upper() if caps else text
    run.font.size = Pt(style.size)
    run.font.bold = style.bold
    run.font.italic = style.italic
    run.font.color.rgb = RGBColor.from_string(style.colour)
    if style.font:
        run.font.name = style.font
    return run


# ============================================================== writing ===
def set_text(
    placeholder,
    text: str,
    style: TextStyle | None = None,
    *,
    align=None,
    anchor=None,
    caps: bool = False,
) -> None:
    tf = placeholder.text_frame
    p = clear(tf)
    no_bullet(p)
    set_indent(p, 0, 0)
    if align is not None:
        p.alignment = align
    if anchor is not None:
        tf.vertical_anchor = anchor
    if style is None:
        p.add_run().text = text
    else:
        write(p, text, style, caps=caps)


def set_bullets(
    placeholder,
    bullets,
    *,
    levels: list[Level],
    heading: str | None = None,
    heading_style: TextStyle | None = None,
    quote: str | None = None,
    quote_style: TextStyle | None = None,
    scale: float = 1.0,
    anchor=MSO_ANCHOR.MIDDLE,
    hang_in: float = 0.38,
    line_pct: float = 92,
    accent: str | None = None,
) -> None:
    """Write a bullet list with REAL levels.

    Three simultaneous cues per level, because one alone is invisible at five
    metres:

      * a size step        (e.g. 24 → 18 pt, a 3/4 ratio)
      * a real indent      (`marL`, which the master usually leaves at zero)
      * a coloured bullet  (hanging, via a negative `indent`)

    `hang_in` is 0.38 and not 0.26 for a measured reason: an em dash fills
    almost all of a 0.26 in hanging indent, and the bullet ended up glued to
    the text ("—repérer"). The hang must be the glyph width PLUS visible space.

    `anchor` defaults to MIDDLE, not TOP. Six lines pinned to the top of a
    4.6 in placeholder leave three inches of void underneath: the slide looks
    unfinished even though it respects the line budget. Centring makes the same
    content read as deliberately airy.
    """
    tf = placeholder.text_frame
    tf.word_wrap = True
    tf.vertical_anchor = anchor

    total = len(bullets) + (1 if heading else 0) + (1 if quote else 0)
    if total == 0:
        return
    paras = paragraphs(tf, total)
    i = 0

    if heading:
        p = paras[i]
        i += 1
        no_bullet(p)
        set_indent(p, 0, 0)
        set_spacing(p, 0)
        st = heading_style or TextStyle(size=15, colour="000000", bold=True)
        write(
            p,
            heading,
            TextStyle(
                round(st.size * scale, 1), st.colour, st.bold, st.italic, st.font
            ),
        )
    if quote:
        p = paras[i]
        i += 1
        no_bullet(p)
        set_indent(p, 0, 0)
        set_spacing(p, 6 if heading else 0, line_pct=95)
        st = quote_style or TextStyle(size=20, colour="000000", italic=True)
        write(
            p,
            f"« {quote} »",
            TextStyle(
                round(st.size * scale, 1), st.colour, st.bold, st.italic, st.font
            ),
        )

    for bullet in bullets:
        lvl = levels[bullet.level]
        p = paras[i]
        i += 1
        p.level = bullet.level
        if lvl.bullet:
            set_indent(p, lvl.indent_in + hang_in, -hang_in)
            set_bullet(p, lvl.bullet, lvl.bullet_colour, "Arial")
        else:
            set_indent(p, lvl.indent_in, 0)
            no_bullet(p)
        set_spacing(p, lvl.space_before, line_pct=line_pct)
        write_rich(
            p,
            bullet.text,
            TextStyle(round(lvl.size * scale, 1), lvl.colour),
            accent=accent,
        )


def textbox(
    slide,
    box: Box,
    text: str,
    style: TextStyle,
    *,
    align=PP_ALIGN.LEFT,
    anchor=MSO_ANCHOR.MIDDLE,
    caps: bool = False,
):
    shape = slide.shapes.add_textbox(*box.as_emu())
    tf = shape.text_frame
    tf.word_wrap = True
    tf.vertical_anchor = anchor
    p = clear(tf)
    p.alignment = align
    no_bullet(p)
    write(p, text, style, caps=caps)
    return shape


def footer(
    slide,
    layout,
    idx: int,
    text: str,
    style: TextStyle,
    *,
    align=PP_ALIGN.LEFT,
    widen: float = 0.0,
):
    """Page furniture as a PLAIN TEXT BOX at the layout placeholder's position.

    Two reasons not to use the `dt` / `sldNum` placeholders themselves, even
    though they exist at exactly the right coordinates:

    1. `add_slide()` does not clone footer-category placeholders from the
       layout, only title and body ones — verified: after `add_slide`, idx 2
       and 4 are simply absent from the shape tree.
    2. Clone them yourself and a renderer may add the FIELD value next to your
       text: slide 3 came out "63/12" (real index 6, then our "3/12") and
       "05/08/2025I · Part one". The produced XML was clean — the doubling
       happened at render time, not in the file.

    A plain text box at the coordinates read from the layout gives the same
    visual result with neither risk.
    """
    box = layout_box(layout, idx, widen=widen)
    if box is None:
        return None
    return textbox(slide, box, text, style, align=align)


def separator(
    slide, *, x: float, top: float, bottom: float, colour: str, width_pt: float = 1.0
):
    """A thin vertical rule. Two short columns floating in a tall placeholder
    read as unfinished; a rule at the gutter makes them read as composed — and
    keeps two-column layouts of the same template consistent with each other.
    """
    line = slide.shapes.add_connector(
        MSO_CONNECTOR.STRAIGHT, Inches(x), Inches(top), Inches(x), Inches(bottom)
    )
    line.line.color.rgb = RGBColor.from_string(colour)
    line.line.width = Pt(width_pt)
    return line


def cover(slide, box: Box, colour: str = "FFFFFF"):
    """Hide a layout decoration with a background-coloured rectangle.

    Baked shapes live in the LAYOUT, not the slide: you cannot remove them per
    slide without editing the master, which you should refuse to do. When a
    rule forbids what a decoration announces — e.g. a "p." page reference the
    directive calls useless — cover it.
    """
    shape = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, *box.as_emu())
    shape.fill.solid()
    shape.fill.fore_color.rgb = RGBColor.from_string(colour)
    shape.line.fill.background()
    shape.shadow.inherit = False
    shape.text_frame.text = ""
    return shape


def fit_picture(slide, box: Box, path, *, anchor: str = "center"):
    """Place an image inside `box`, aspect preserved, centred.

    Scale is aspect-only, so it is correct whatever DPI the file claims. A
    figure authored at the box's exact aspect ratio therefore fills it exactly,
    which is what keeps figure typography 1:1 with slide typography.
    """
    from PIL import Image

    with Image.open(path) as im:
        iw, ih = im.size
    scale = min(box.width / iw, box.height / ih)
    w, h = iw * scale, ih * scale
    left = box.left + (box.width - w) / 2
    top = box.top if anchor == "top" else box.top + (box.height - h) / 2
    return slide.shapes.add_picture(
        str(path), Inches(left), Inches(top), Inches(w), Inches(h)
    )


def table(
    slide,
    box: Box,
    rows: list[tuple[str, ...]],
    *,
    header_fill: str,
    header_style: TextStyle,
    body_style: TextStyle,
    key_style: TextStyle | None = None,
    stripe: str | None = None,
    plain: str = "FFFFFF",
):
    """A real PowerPoint table, not a picture of one.

    Worth the extra code for annexes: the jury can read it on screen during
    questions, and it stays selectable and searchable.
    """
    if len(rows) < 2:
        raise SystemExit("table: header plus at least one row expected.")
    ncol = len(rows[0])
    if any(len(r) != ncol for r in rows):
        raise SystemExit(f"table: ragged rows {[len(r) for r in rows]}")

    shape = slide.shapes.add_table(len(rows), ncol, *box.as_emu())
    tbl = shape.table
    for c, head in enumerate(rows[0]):
        cell = tbl.cell(0, c)
        p = clear(cell.text_frame)
        no_bullet(p)
        write(p, head, header_style)
        cell.fill.solid()
        cell.fill.fore_color.rgb = RGBColor.from_string(header_fill)
    for r, row in enumerate(rows[1:], start=1):
        for c, value in enumerate(row):
            cell = tbl.cell(r, c)
            p = clear(cell.text_frame)
            no_bullet(p)
            write(p, value, (key_style or body_style) if c == 0 else body_style)
            cell.fill.solid()
            fill = plain if (stripe is None or r % 2) else stripe
            cell.fill.fore_color.rgb = RGBColor.from_string(fill)
    return tbl


def chart(
    slide,
    box: Box,
    data: dict,
    *,
    chart_type=None,
    series_colours: list[str] | None = None,
):
    """A real, editable PowerPoint chart — not a picture of one.

    Ported from the retired MCP-tool lineage
    (`references/alternative-mcp-approach.md`), the one capability it had
    that this module did not. `data` is
    `{"categories": [...], "series": [{"name": ..., "values": [...]}]}`.

    Prefer a `figkit` figure when the deck's own visual system must hold — a
    native chart draws with PowerPoint's own palette and cannot be duotoned or
    tinted like an image. Reach for `chart()` instead when the audience is
    expected to open the file afterwards and edit the numbers, or when a
    reviewer specifically asked for a live chart object rather than a picture.
    """
    from pptx.chart.data import CategoryChartData
    from pptx.enum.chart import XL_CHART_TYPE

    chart_data = CategoryChartData()
    chart_data.categories = data["categories"]
    for series in data["series"]:
        chart_data.add_series(series["name"], series["values"])

    kind = chart_type or XL_CHART_TYPE.COLUMN_CLUSTERED
    graphic_frame = slide.shapes.add_chart(kind, *box.as_emu(), chart_data)
    chart_obj = graphic_frame.chart
    if series_colours:
        for plot_series, colour in zip(chart_obj.plots[0].series, series_colours):
            plot_series.format.fill.solid()
            plot_series.format.fill.fore_color.rgb = RGBColor.from_string(colour)
    return chart_obj


# ============================================================ validation ===
def validate(
    all_slides,
    *,
    specs: dict,
    figs_dir: pathlib.Path,
    root: pathlib.Path,
    text_layouts: frozenset,
    max_lines_single: int = 6,
    max_lines_per_block: int = 5,
    max_words_per_line: int = 6,
    max_level: int = 1,
) -> list[str]:
    """Check the markdown ↔ layout contract in BOTH directions.

    The weakness this replaces: a `check` that only asks "does the PNG exist?"
    — which is exactly the wrong question. Two slides once showed a stale
    frozen PNG for a whole pass because nothing verified that a declared key
    was actually produced by a builder.

    `specs` maps a layout name to `(filler, required_fields, n_blocks)`.
    `text_layouts` are the layouts whose content is projected prose; figures,
    tables, timelines and org charts are governed by other rules and are not
    counted in lines.
    """
    problems: list[str] = []
    for s in all_slides:
        if s.layout not in specs:
            problems.append(
                f"{s.path.name}: layout not handled "
                f"“{s.layout}”. Known: {sorted(specs)}"
            )
            continue
        _, required, nblocks = specs[s.layout]
        for key in required:
            if not s.meta.get(key):
                problems.append(
                    f"{s.path.name}: field `{key}:` missing (required by “{s.layout}”)."
                )
        if nblocks is not None and len(s.columns) != nblocks:
            problems.append(
                f"{s.path.name}: “{s.layout}” expects {nblocks} "
                f"`##` block(s), file declares {len(s.columns)}."
            )
        if s.depth > max_level:
            problems.append(f"{s.path.name}: bullet depth {s.depth} > {max_level}.")
        if s.figure and not (figs_dir / f"{s.figure}.png").exists():
            problems.append(
                f"{s.path.name}: figure `{s.figure}` not built "
                f"({figs_dir}). Run `render.py figures`."
            )
        if s.image and not (root / s.image).resolve().exists():
            problems.append(f"{s.path.name}: image missing — {s.image}")

        if s.is_annexe:
            # Annexes are projected only if a question calls for them: they are
            # reference material one reads, not a main idea grasped at a
            # glance. Density caps do not apply.
            continue
        if s.layout in text_layouts:
            if s.columns:
                for col in s.columns:
                    n = len(col.bullets) + 1
                    if n > max_lines_per_block:
                        problems.append(
                            f"{s.path.name}: block “{col.name}” has {n} "
                            f"lines, cap {max_lines_per_block}."
                        )
            elif s.line_count > max_lines_single:
                problems.append(
                    f"{s.path.name}: {s.line_count} projected "
                    f"lines, cap {max_lines_single}."
                )
        for sec in s.sections:
            for b in sec.bullets:
                for cell in b.cells:
                    words = len(cell.split())
                    if words > max_words_per_line:
                        problems.append(
                            f"{s.path.name}: {words} words in “{cell[:44]}” "
                            f"(cap {max_words_per_line})."
                        )
    return problems


def budget(all_slides, *, words_per_minute: int = 140, talk_minutes: int = 15) -> None:
    """Print a per-slide speaking budget from the speaker notes.

    Printed on every build because the only way to hold a time limit is to know
    which slide is too long before the first rehearsal. 140 wpm is a poised
    delivery with pauses — 180 is reading speed and gives a falsely reassuring
    estimate. Annexes are excluded: they are not spoken.
    """
    talk = [s for s in all_slides if not s.is_annexe]
    words = sum(len(s.notes.split()) for s in talk)
    minutes = words / words_per_minute
    print(
        f"[deck] speaking budget ({words_per_minute} wpm, stage directions included):"
    )
    for s in talk:
        secs = len(s.notes.split()) / words_per_minute * 60
        print(
            f"       {s.label:>2}  {secs:4.0f}s  "
            f"{'#' * max(1, round(secs / 6)):<20} {s.path.stem}"
        )
    verdict = "within" if minutes <= talk_minutes else "OVER"
    print(
        f"[deck] total: {words} words, ~{minutes:.1f} min "
        f"({verdict} the {talk_minutes} min limit)."
    )


# ================================================= with or without template ===
#: Where the two bundled templates live, relative to this file.
BUNDLED = pathlib.Path(__file__).resolve().parent.parent / "assets"
TEMPLATE_X = BUNDLED / "Template_X.pptx"  # École polytechnique, 16:9
TEMPLATE_DXO = BUNDLED / "Template_DxO.pptx"  # DxO, 10 x 5.625 in


def open_deck(
    template: str | pathlib.Path | None = None,
    *,
    keep: int = 0,
    size_in: tuple[float, float] = (13.333, 7.5),
):
    """Open the base document, with or without a template.

    Three ways to start, in decreasing order of preference:

    1. `open_deck("Template_X.pptx", keep=3)` — a real template. You inherit
       its palette, fonts, layouts, page furniture and logos, and you keep its
       leading hidden instruction slides.
    2. `open_deck(deckkit.TEMPLATE_DXO)` — one of the two bundled templates.
    3. `open_deck()` — no template at all. You get a blank 16:9 document with
       ONE usable layout, and everything (title, rules, footer, palette) must
       be drawn from your `theme.py`. Perfectly workable — see `chrome()` — but
       you are now the design authority, so write the palette down and stick
       to it.

    Returns `(prs, layout_mode)` where `layout_mode` is "template" or "blank".
    Branch on it in your fillers when a layout placeholder may not exist.
    """
    from pptx import Presentation

    if template is None:
        prs = Presentation()
        prs.slide_width = Inches(size_in[0])
        prs.slide_height = Inches(size_in[1])
        return prs, "blank"

    prs = Presentation(str(template))
    drop_slides_after(prs, keep)
    return prs, "template"


def blank_layout(prs):
    """The emptiest layout of the document — the canvas for `blank` mode."""
    import re

    layouts = list(prs.slide_masters[0].slide_layouts)
    for layout in layouts:
        if re.search(r"\b(blank|vide|empty)\b", layout.name, re.IGNORECASE):
            return layout
    return min(layouts, key=lambda x: len(list(x.placeholders)))


def chrome(
    slide,
    *,
    title: str,
    title_box: Box,
    title_style: TextStyle,
    rule_colour: str | None = None,
    rule_inset: float = 0.0,
    align=PP_ALIGN.CENTER,
):
    """Draw the page furniture a template would have given you.

    Use in `blank` mode, or on a template layout that has no title
    placeholder. Keep the geometry in `theme.py`, not here, so a title sits at
    the same height on every slide — the single most visible sign of a deck
    that was assembled rather than designed.
    """
    shape = textbox(
        slide, title_box, title, title_style, align=align, anchor=MSO_ANCHOR.MIDDLE
    )
    if rule_colour:
        y = title_box.top + title_box.height + 0.10
        separator_h(
            slide,
            y=y,
            left=title_box.left + rule_inset,
            right=title_box.left + title_box.width - rule_inset,
            colour=rule_colour,
        )
    return shape


def separator_h(
    slide, *, y: float, left: float, right: float, colour: str, width_pt: float = 1.0
):
    """A horizontal rule, the companion of `separator()`."""
    line = slide.shapes.add_connector(
        MSO_CONNECTOR.STRAIGHT, Inches(left), Inches(y), Inches(right), Inches(y)
    )
    line.line.color.rgb = RGBColor.from_string(colour)
    line.line.width = Pt(width_pt)
    return line


def title_of(
    slide,
    layout,
    text: str,
    *,
    style: TextStyle | None = None,
    fallback_box: Box | None = None,
    rule_colour: str | None = None,
) -> None:
    """Set the slide title through the layout if it has one, else draw it.

    Lets the same filler serve a template with a title placeholder and a blank
    document, without an `if` in every filler.
    """
    if slide.shapes.title is not None:
        if style is None:
            slide.shapes.title.text = text
        else:
            set_text(slide.shapes.title, text, style, align=PP_ALIGN.CENTER)
        return
    if fallback_box is None:
        raise SystemExit(
            "title_of: no title placeholder on this layout and no fallback_box given."
        )
    chrome(
        slide,
        title=text,
        title_box=fallback_box,
        title_style=style or TextStyle(size=24, colour="000000"),
        rule_colour=rule_colour,
    )


# ====================================================== inline emphasis ===
#: Inline markup understood by `write_rich`. Deliberately tiny — three marks,
#: markdown-shaped, no nesting.
#:
#:     **strong**   bold, same colour
#:     __accent__   accent colour, normal weight
#:     *stress*     italic
#:
#: Why this exists: the highest-quality reference deck in `assets/` colours
#: SINGLE WORDS inside a sentence in its accent, and that one device does more
#: for emphasis than bold ever does — it guides the eye without shouting. A
#: pipeline that can only write one run per paragraph cannot do it.
_INLINE = None


def _inline_re():
    global _INLINE
    if _INLINE is None:
        import re

        _INLINE = re.compile(r"(\*\*.+?\*\*|__.+?__|\*.+?\*)", re.DOTALL)
    return _INLINE


def write_rich(paragraph, text: str, style: TextStyle, *, accent: str | None = None):
    """Write a line as several runs, honouring inline emphasis.

    Falls back to a single run when the text carries no markup, so it is safe
    to route every line through it.
    """
    parts = [p for p in _inline_re().split(text) if p]
    if len(parts) == 1 and not _inline_re().fullmatch(parts[0] or ""):
        return write(paragraph, text, style)
    runs = []
    for part in parts:
        if part.startswith("**") and part.endswith("**"):
            runs.append(
                write(
                    paragraph,
                    part[2:-2],
                    TextStyle(style.size, style.colour, True, style.italic, style.font),
                )
            )
        elif part.startswith("__") and part.endswith("__"):
            runs.append(
                write(
                    paragraph,
                    part[2:-2],
                    TextStyle(
                        style.size,
                        accent or style.colour,
                        style.bold,
                        style.italic,
                        style.font,
                    ),
                )
            )
        elif part.startswith("*") and part.endswith("*") and len(part) > 2:
            runs.append(
                write(
                    paragraph,
                    part[1:-1],
                    TextStyle(style.size, style.colour, style.bold, True, style.font),
                )
            )
        else:
            runs.append(write(paragraph, part, style))
    return runs


def strip_markup(text: str) -> str:
    """The text without its inline marks — for word counts and validation."""
    import re

    return re.sub(r"\*\*|__|\*", "", text)


# ========================================================== slide ground ===
def set_background(slide, colour: str):
    """Paint the whole slide one colour, behind everything.

    The strongest single coherence device in a designed deck: when the slide
    ground and the ground *inside every figure* are the same value, a figure
    has no visible edge and stops reading as pasted on. Set the same hex here
    and in `figkit.use(palette=...)`, and check a full-bleed illustration for a
    seam.

    Drawn as a rectangle sent to the back rather than set as a background
    property, because a template master may already own the background and we
    do not edit masters.
    """

    w, h = (
        slide.part.package.presentation_part.presentation.slide_width,
        slide.part.package.presentation_part.presentation.slide_height,
    )
    shape = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Emu(w), Emu(h))
    shape.fill.solid()
    shape.fill.fore_color.rgb = RGBColor.from_string(colour)
    shape.line.fill.background()
    shape.shadow.inherit = False
    shape.text_frame.text = ""
    tree = shape._element.getparent()
    tree.remove(shape._element)
    tree.insert(2, shape._element)  # after nvGrpSpPr and grpSpPr
    return shape
