"""Markdown → Slide objects. Parses only: draws nothing, decides nothing.

Generic version of the parsers used by `assets/presentation/` and
`assets/presentation_x_v2/`. Copy it into a deck folder and keep it boring:
every decision about *where* something goes belongs to `deck.py`, every
decision about *how it looks* belongs to `theme.py`.

The grammar
-----------
    ---
    layout: Double bloc de texte      # required: a layout name in the template
    part: III · The mission           # free metadata, consumed by deck.py
    title: What the deck says here
    figure: value_loop                # shared key → build/figs/value_loop.png
    image: ../report/figures/x.png    # or a path, relative to the deck root
    caption: Source, method note
    quote: a pull quote
    ---

    - A main idea                     level 0
      - a qualifier                   level 1  (two spaces = one level)

    ## Named block

    - date | label                    cells, split on " | "

    ## Notes

    Everything here is speaker notes. Never projected.

Three deliberate departures from the older parser in `assets/presentation/`:

1. **Real YAML** (`yaml.safe_load`) delimited by `---` at line start. The older
   `text.split("---", 2)` shifted silently as soon as a `---` appeared inside
   speaker notes.
2. **Bullets exist, with real levels.** Their absence was the costliest gap:
   without levels, hierarchy has to be faked inside the text (`-   `,
   `   -> `), which is exactly the invisible indentation this skill exists to
   prevent.
3. **Too deep is a fatal error, not a degraded render.** Three bullet levels on
   a projected slide means the slide carries two ideas and must be split.
"""

from __future__ import annotations

import pathlib
import re
from dataclasses import dataclass, field

import yaml

#: Deepest level that survives projection. Override from your `theme.py`:
#: `slides.MAX_LEVEL = len(theme.LEVELS) - 1`. Keep it at 1 unless you have
#: measured otherwise — see references/typography.md.
MAX_LEVEL = 1

#: Two spaces per level. Tabs are expanded, so a mis-configured editor cannot
#: silently change the rendering.
INDENT_UNIT = 2

_FRONT = re.compile(r"\A---[ \t]*\n(.*?)\n---[ \t]*\n", re.DOTALL)
_COMMENT = re.compile(r"<!--.*?-->", re.DOTALL)
_BULLET = re.compile(r"^(?P<pad>[ \t]*)-[ \t]+(?P<text>.*\S)[ \t]*$")
_SECTION = re.compile(r"^##[ \t]+(?P<name>.*\S)[ \t]*$")


@dataclass(frozen=True)
class Bullet:
    """One projected line.

    `cells` is the split on " | ". Some template layouts want several fields
    per entry (a timeline entry is `date | label`; a table row is one cell per
    column). Rather than inventing a syntax per layout, a bullet carries cells
    and the filler decides what they mean.
    """

    text: str
    level: int
    cells: tuple[str, ...]


@dataclass
class Section:
    """A block of the body. `name` is None for the opening, unnamed block."""

    name: str | None
    bullets: list[Bullet] = field(default_factory=list)
    lines: list[str] = field(default_factory=list)

    @property
    def depth(self) -> int:
        return max((b.level for b in self.bullets), default=-1)


@dataclass
class Slide:
    path: pathlib.Path
    meta: dict
    sections: list[Section]
    notes: str
    label: str = ""  # "3" for a talk slide, "A2" for an annexe

    # -- front-matter accessors -------------------------------------------
    @property
    def layout(self) -> str:
        return self.meta["layout"]

    def get(self, key: str, default: str = "") -> str:
        return self.meta.get(key, default)

    @property
    def title(self) -> str:
        return self.meta.get("title", "")

    @property
    def figure(self) -> str:
        return self.meta.get("figure", "")

    @property
    def image(self) -> str:
        return self.meta.get("image", "")

    @property
    def is_annexe(self) -> bool:
        """Annexes follow the conclusion and are numbered separately.

        Many presentation rules allow back-up slides after the closing slide
        without counting them in the slide budget — and they are read on
        demand, not grasped at a glance, so density caps do not apply to them.
        """
        return self.path.name.startswith("A")

    # -- body accessors ---------------------------------------------------
    @property
    def body(self) -> Section:
        for s in self.sections:
            if s.name is None:
                return s
        return Section(None)

    @property
    def columns(self) -> list[Section]:
        return [s for s in self.sections if s.name is not None]

    def column(self, name: str) -> Section:
        for s in self.sections:
            if s.name == name:
                return s
        raise SystemExit(
            f"{self.path.name}: block `## {name}` missing. "
            f"Present: {[s.name for s in self.columns]}"
        )

    @property
    def depth(self) -> int:
        return max((s.depth for s in self.sections), default=-1)

    @property
    def line_count(self) -> int:
        """Projected text lines, section headings included.

        This is the quantity most presentation rules cap ("fewer than six
        lines per slide"). Figures, tables and timelines are governed by other
        sentences and should be exempted by layout — see deck.py.
        """
        n = sum(len(s.bullets) for s in self.sections)
        n += sum(1 for s in self.columns)
        n += 1 if self.meta.get("quote") else 0
        return n


def parse(path: pathlib.Path) -> Slide:
    raw = path.read_text(encoding="utf-8")
    m = _FRONT.match(raw)
    if not m:
        raise SystemExit(f"{path.name}: no `---` front-matter at the top.")
    try:
        meta = yaml.safe_load(m.group(1)) or {}
    except yaml.YAMLError as exc:
        raise SystemExit(f"{path.name}: invalid YAML front-matter — {exc}")
    if not isinstance(meta, dict):
        raise SystemExit(f"{path.name}: front-matter must be a mapping.")
    if "layout" not in meta:
        raise SystemExit(f"{path.name}: `layout:` is required.")

    body = _COMMENT.sub("", raw[m.end() :])
    sections: list[Section] = [Section(None)]
    notes: list[str] = []
    in_notes = False

    for line in body.splitlines():
        sec = _SECTION.match(line)
        if sec:
            name = sec.group("name")
            if name.lower() == "notes":
                in_notes = True
                continue
            in_notes = False
            sections.append(Section(name))
            continue
        if in_notes:
            notes.append(line)
            continue
        bul = _BULLET.match(line)
        if bul:
            pad = bul.group("pad").replace("\t", " " * INDENT_UNIT)
            level, remainder = divmod(len(pad), INDENT_UNIT)
            if remainder:
                raise SystemExit(
                    f"{path.name}: {len(pad)}-space indent before "
                    f"“{bul.group('text')[:34]}”. Use multiples of "
                    f"{INDENT_UNIT}."
                )
            text = bul.group("text")
            if level > MAX_LEVEL:
                raise SystemExit(
                    f"{path.name}: bullet at level {level} "
                    f"(“{text[:40]}”). The deepest projectable level is "
                    f"{MAX_LEVEL}. Below that, template body styles drop to "
                    f"12 then 10 pt, illegible from the back of a room. Split "
                    f"the slide instead of adding a level."
                )
            cells = tuple(c.strip() for c in text.split("|"))
            sections[-1].bullets.append(
                Bullet(cells[0] if len(cells) == 1 else text, level, cells)
            )
            continue
        if line.strip():
            sections[-1].lines.append(line.strip())

    sections = [s for s in sections if s.name is not None or s.bullets or s.lines]
    return Slide(
        path=path, meta=meta, sections=sections, notes="\n".join(notes).strip()
    )


def load(folder: str | pathlib.Path = "slides") -> list[Slide]:
    """Every slide: talk first, then annexes.

    The number leading a filename is a SORT KEY, not a page number. Inserting
    a slide between 4 and 5 is `04b_….md` and renames nothing. Files starting
    with `A` are annexes, numbered separately.
    """
    folder = pathlib.Path(folder)
    paths = sorted(folder.glob("*.md"), key=lambda p: p.name)
    if not paths:
        raise SystemExit(f"no slides under {folder}")
    talk = [p for p in paths if not p.name.startswith("A")]
    annexes = [p for p in paths if p.name.startswith("A")]

    out: list[Slide] = []
    for n, p in enumerate(talk, start=1):
        s = parse(p)
        s.label = str(n)
        out.append(s)
    for n, p in enumerate(annexes, start=1):
        s = parse(p)
        s.label = f"A{n}"
        out.append(s)
    return out
