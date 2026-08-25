"""Map a .pptx / .potx template before building anything on it.

This is phase 1 of the k-pptx skill, and skipping it is how hours get lost. It
answers, in one run, the four questions you cannot guess:

1. What is the palette? (theme1.xml <a:clrScheme> — the only legitimate source
   of a "brand colour", never a screenshot eyedropper.)
2. What does the master do to body text? Sizes, fonts, and crucially `marL`
   and the bullet char per level. Most templates leave `marL=0` on every level
   and carry hierarchy by size alone — which is why so many decks have
   invisible indentation.
3. What layouts exist, and for each one, every placeholder's `idx`, type and
   geometry in inches. Placeholder `idx` values are NOT in reading order; you
   pair them by coordinates, and this prints the coordinates.
4. What is baked into a layout as a plain shape rather than a placeholder.
   Those decorations ("p.", a coat of arms, a rule) cannot be removed per
   slide. You either use them or cover them.

Usage
-----
    uv run --with python-pptx python inspect_template.py deck.pptx
    uv run --with python-pptx python inspect_template.py deck.pptx --layout "Bloc de texte"
    uv run --with python-pptx python inspect_template.py deck.pptx --slides
    uv run --with python-pptx python inspect_template.py deck.pptx --json > map.json

`--slides` also dumps the existing slides: their layout, their paragraph
levels and their notes. Use it to learn from a deck that already works — and to
find out whether its author expressed hierarchy with real levels or by typing
dashes into level-0 text (see references/typography.md).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import zipfile

EMU_PER_INCH = 914400


def inches(value) -> float | None:
    return None if value is None else round(value / EMU_PER_INCH, 2)


# --------------------------------------------------------------- theme ---
def theme(path: str) -> dict:
    """Palette and font scheme, read from the package rather than guessed."""
    with zipfile.ZipFile(path) as z:
        names = [n for n in z.namelist() if re.match(r"ppt/theme/theme\d+\.xml", n)]
        if not names:
            return {}
        xml = z.read(min(names)).decode("utf-8", "replace")

    out: dict = {"colours": {}, "fonts": []}
    scheme = re.search(r"<a:clrScheme.*?</a:clrScheme>", xml, re.DOTALL)
    if scheme:
        pattern = (
            r'<a:(\w+)>\s*<a:(?:srgbClr val="([0-9A-Fa-f]{6})"'
            r'|sysClr[^>]*lastClr="([0-9A-Fa-f]{6})")'
        )
        for m in re.finditer(pattern, scheme.group(0)):
            out["colours"][m.group(1)] = (m.group(2) or m.group(3)).upper()
    fonts = re.search(r"<a:fontScheme.*?</a:fontScheme>", xml, re.DOTALL)
    if fonts:
        seen: list[str] = []
        for face in re.findall(r'typeface="([^"]+)"', fonts.group(0)):
            if face and face not in seen:
                seen.append(face)
        out["fonts"] = seen[:6]
    return out


# ---------------------------------------------------------- text styles ---
def body_levels(master) -> list[dict]:
    """The master's bodyStyle, level by level.

    `marL` is the one to read. If every level shows `marL=0`, the template
    expresses hierarchy by size only: you must set the indent yourself, or the
    jury sees a flat list. See references/typography.md.
    """
    from pptx.oxml.ns import qn

    styles = master._element.find(qn("p:txStyles"))
    if styles is None:
        return []
    body = styles.find(qn("p:bodyStyle"))
    if body is None:
        return []

    rows = []
    for level in body:
        rpr = level.find(qn("a:defRPr"))
        latin = rpr.find(qn("a:latin")) if rpr is not None else None
        bullet_char = level.find(qn("a:buChar"))
        none_bullet = level.find(qn("a:buNone"))
        size = rpr.get("sz") if rpr is not None else None
        rows.append(
            {
                "level": level.tag.split("}")[1],
                "size_pt": int(size) / 100 if size else None,
                "bold": (rpr.get("b") == "1") if rpr is not None else None,
                "font": latin.get("typeface") if latin is not None else None,
                "marL": level.get("marL"),
                "indent": level.get("indent"),
                "bullet": (
                    bullet_char.get("char")
                    if bullet_char is not None
                    else ("none" if none_bullet is not None else None)
                ),
            }
        )
    return rows


# -------------------------------------------------------------- layouts ---
def describe(shape) -> dict:
    text = ""
    if shape.has_text_frame:
        text = " | ".join(
            p.text for p in shape.text_frame.paragraphs if p.text.strip()
        )[:80]
    row = {
        "name": shape.name,
        "left": inches(shape.left),
        "top": inches(shape.top),
        "width": inches(shape.width),
        "height": inches(shape.height),
        "text": text,
    }
    if shape.is_placeholder:
        row["idx"] = shape.placeholder_format.idx
        row["ph_type"] = str(shape.placeholder_format.type)
    else:
        row["idx"] = None
        row["ph_type"] = f"DECORATION/{shape.shape_type}"
    return row


def layouts(master, only: str | None) -> list[dict]:
    out = []
    for layout in master.slide_layouts:
        if only and layout.name != only:
            continue
        shapes = [describe(s) for s in layout.shapes]
        out.append(
            {
                "name": layout.name,
                "placeholders": [s for s in shapes if s["idx"] is not None],
                "decorations": [s for s in shapes if s["idx"] is None],
            }
        )
    return out


def existing_slides(prs) -> list[dict]:
    out = []
    for i, slide in enumerate(prs.slides, start=1):
        paragraphs = []
        for shape in slide.shapes:
            if not shape.has_text_frame:
                continue
            idx = shape.placeholder_format.idx if shape.is_placeholder else None
            for para in shape.text_frame.paragraphs:
                text = "".join(r.text for r in para.runs)
                if text.strip():
                    paragraphs.append(
                        {"idx": idx, "level": para.level, "text": text[:100]}
                    )
        out.append(
            {
                "n": i,
                "layout": slide.slide_layout.name,
                # show="0" means: in the file, out of the running order. Templates
                # often ship instruction slides this way, and some authors keep
                # them on purpose. Never delete them without asking.
                "hidden": slide._element.get("show") == "0",
                "paragraphs": paragraphs,
                "notes": (
                    slide.notes_slide.notes_text_frame.text[:400]
                    if slide.has_notes_slide
                    else ""
                ),
            }
        )
    return out


# ----------------------------------------------------------------- main ---
def report(data: dict) -> None:
    print(f"# {data['path']}")
    print(f"slide size : {data['slide_size'][0]} x {data['slide_size'][1]} in")
    print(f"slides     : {data['n_slides']}   layouts : {data['n_layouts']}")

    if data["theme"].get("colours"):
        print("\n## theme palette (ppt/theme/*.xml) — the only legitimate source")
        for name, hexval in data["theme"]["colours"].items():
            print(f"   {name:<10} #{hexval}")
        print(f"   fonts: {', '.join(data['theme']['fonts'])}")

    if data["body_levels"]:
        print("\n## master bodyStyle — check the marL column")
        print(
            f"   {'level':<10}{'size':>6}{'bold':>6}  {'font':<18}"
            f"{'marL':>9}{'indent':>9}  bullet"
        )
        flat = True
        for row in data["body_levels"]:
            marL = row["marL"] or "0"
            if marL not in ("0", None):
                flat = False
            print(
                f"   {row['level']:<10}{row['size_pt']!s:>6}"
                f"{row['bold']!s:>6}  {row['font'] or ''!s:<18}"
                f"{marL:>9}{row['indent'] or '0'!s:>9}  "
                f"{row['bullet']}"
            )
        if flat:
            print("   !! every marL is 0 : this template carries hierarchy by")
            print("      SIZE ONLY. Set marL/indent yourself and add a bullet")
            print("      glyph, or indentation will be invisible on a screen.")

    print("\n## layouts")
    for layout in data["layouts"]:
        print(f"\n### {layout['name']!r}")
        if layout["placeholders"]:
            print(
                f"   {'idx':>4}  {'type':<20}{'L':>7}{'T':>7}{'W':>7}{'H':>7}  prompt"
            )
            for p in sorted(
                layout["placeholders"], key=lambda r: (r["top"] or 0, r["left"] or 0)
            ):
                print(
                    f"   {p['idx']:>4}  {p['ph_type']:<20}"
                    f"{p['left']:>7}{p['top']:>7}{p['width']:>7}"
                    f"{p['height']:>7}  {p['text'][:32]!r}"
                )
        for d in layout["decorations"]:
            print(
                f"   [baked] {d['ph_type']:<26}"
                f"L={d['left']} T={d['top']} W={d['width']} H={d['height']}"
                + (f"  text={d['text'][:28]!r}" if d["text"] else "")
            )
        if layout["decorations"]:
            print("   note: baked shapes live in the LAYOUT. You cannot remove")
            print("         them per slide — use them, or cover them with a")
            print("         background-coloured rectangle.")

    for slide in data.get("slides", []):
        flag = " [hidden]" if slide["hidden"] else ""
        print(f"\n## slide {slide['n']}{flag} — {slide['layout']!r}")
        for p in slide["paragraphs"]:
            print(f"   idx={p['idx']!s:<5} level={p['level']}  {p['text']}")
        if slide["notes"]:
            print(f"   notes: {slide['notes'][:160]}…")


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("path")
    ap.add_argument("--layout", help="restrict to one layout name")
    ap.add_argument(
        "--slides",
        action="store_true",
        help="also dump the existing slides and their notes",
    )
    ap.add_argument("--json", action="store_true", help="machine-readable")
    args = ap.parse_args(argv)

    try:
        from pptx import Presentation
    except ImportError:
        print(
            "python-pptx missing. Try:\n"
            "  uv run --with python-pptx python inspect_template.py …",
            file=sys.stderr,
        )
        return 2

    prs = Presentation(args.path)
    master = prs.slide_masters[0]
    data = {
        "path": args.path,
        "slide_size": [inches(prs.slide_width), inches(prs.slide_height)],
        "n_slides": len(prs.slides._sldIdLst),
        "n_layouts": len(master.slide_layouts),
        "theme": theme(args.path),
        "body_levels": body_levels(master),
        "layouts": layouts(master, args.layout),
    }
    if args.slides:
        data["slides"] = existing_slides(prs)

    if args.json:
        json.dump(data, sys.stdout, indent=2, ensure_ascii=False)
        print()
    else:
        report(data)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
