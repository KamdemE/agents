"""matplotlib primitives for slide figures.

Two rules make the difference between a figure that belongs on a slide and one
that was pasted onto it.

**1. Inches are the data unit.** `canvas(11.5, 4.9)` gives axes whose x runs
0→11.5 and y 0→4.9, aspect equal. A rounded corner stays round instead of
turning into a capsule, and a figure coordinate is reasoned in the same unit as
the slide grid in your `theme.py`.

**2. A figure is authored at the exact size of its target box.** Then
`fontsize=14` here projects as 14 pt there, and a figure slide has the same
typography as a bullet slide. This is why `save()` never passes
`bbox_inches="tight"`: tight cropping changes the PNG's dimensions and silently
breaks the 1:1 mapping.

Colours are injected, never defined here — your `theme.py` owns the palette.

    import figkit
    figkit.use(palette={"navy": "#003E5C", ...}, serif=["Georgia", ...])
"""

from __future__ import annotations

import pathlib

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch

DPI = 200
FIGS = pathlib.Path("build/figs")

#: Filled by `use()`. Keys are yours; the drawing helpers only read them.
C: dict[str, str] = {}


def use(
    *,
    palette: dict[str, str],
    serif: list[str] | None = None,
    geometric: list[str] | None = None,
    figs_dir: str | None = None,
    dpi: int | None = None,
) -> None:
    """Point figkit at your theme. Call once, at import time of your figures.

    `serif` is a font *stack*, not a weight: name the family you want first and
    real fallbacks after. Passing a weight instead (`fontweight="medium"`) is a
    classic way to break `findfont` for any string containing an arrow — the
    fallback consulted for `→ ✓ ①` may have no medium cut, and the whole lookup
    degrades.
    """
    global C, FIGS, DPI
    C = dict(palette)
    if figs_dir:
        FIGS = pathlib.Path(figs_dir)
    if dpi:
        DPI = dpi
    matplotlib.rcParams.update(
        {
            "font.family": serif or ["DejaVu Serif"],
            "figure.facecolor": C.get("white", "#FFFFFF"),
            "savefig.facecolor": C.get("white", "#FFFFFF"),
            "axes.facecolor": C.get("white", "#FFFFFF"),
            "text.color": C.get("ink", C.get("navy", "#1B1F24")),
            "savefig.dpi": DPI,
        }
    )
    if geometric:
        matplotlib.rcParams["font.sans-serif"] = geometric


def canvas(width_in: float, height_in: float):
    """Axes whose data unit IS the inch. Author at the target box's size."""
    fig = plt.figure(figsize=(width_in, height_in))
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, width_in)
    ax.set_ylim(0, height_in)
    ax.set_aspect("equal")
    ax.axis("off")
    return fig, ax


def save(fig, key: str) -> pathlib.Path:
    """Write `build/figs/<key>.png`. `key` is the string the markdown declares.

    Never `bbox_inches="tight"` — see the module docstring.
    """
    FIGS.mkdir(parents=True, exist_ok=True)
    path = FIGS / f"{key}.png"
    fig.savefig(path, dpi=DPI)
    plt.close(fig)
    print(f"[figures] {key}.png")
    return path


# ---------------------------------------------------------------- layout ---
def wrap(text: str, width_chars: int) -> list[str]:
    """matplotlib does no line breaking at all.

    Without this a label overflows its column silently, and you only find out
    after rendering. Wrap before drawing.
    """
    import textwrap

    return textwrap.wrap(text, width=width_chars) or [""]


def text_block(
    ax,
    x,
    y,
    text,
    *,
    width_chars: int,
    size: float,
    colour: str | None = None,
    bold=False,
    italic=False,
    ha="center",
    leading: float | None = None,
    va="top",
) -> float:
    """A wrapped paragraph drawn line by line.

    Returns the y reached below the last line, so the next element stacks
    without a magic coordinate.
    """
    lines = wrap(text, width_chars)
    lead = leading if leading is not None else size / 72 * 1.30
    if va == "center":
        y = y + (len(lines) - 1) * lead / 2
    for i, line in enumerate(lines):
        ax.text(
            x,
            y - i * lead,
            line,
            ha=ha,
            va="center",
            fontsize=size,
            color=colour or C.get("navy", "#000000"),
            fontweight="bold" if bold else "normal",
            style="italic" if italic else "normal",
            zorder=3,
        )
    return y - (len(lines) - 1) * lead - lead


# ---------------------------------------------------------------- shapes ---
def box(
    ax,
    x,
    y,
    w,
    h,
    lines,
    *,
    fill=None,
    edge=None,
    text=None,
    sizes=(14, 11),
    pad=0.10,
    lw=1.4,
):
    """A rounded block carrying one to three lines: label, then qualifiers."""
    ax.add_patch(
        FancyBboxPatch(
            (x + pad, y + pad),
            w - 2 * pad,
            h - 2 * pad,
            boxstyle=f"round,pad={pad},rounding_size=0.10",
            facecolor=fill or C.get("white", "#FFFFFF"),
            edgecolor=edge or C.get("grey_light", "#CCCCCC"),
            linewidth=lw,
            zorder=2,
        )
    )
    lines = [ln for ln in lines if ln]
    gap = 0.235
    y0 = y + h / 2 + (len(lines) - 1) * gap / 2
    for i, line in enumerate(lines):
        ax.text(
            x + w / 2,
            y0 - i * gap,
            line,
            ha="center",
            va="center",
            fontsize=sizes[0] if i == 0 else sizes[1],
            color=(text or C.get("navy", "#000000"))
            if i == 0
            else C.get("grey_dark", "#444444"),
            fontweight="bold" if i == 0 else "normal",
            zorder=3,
        )


def arrow(
    ax,
    start,
    end,
    *,
    colour=None,
    lw=1.8,
    rad=0.0,
    label=None,
    label_offset=(0, 0.18),
    size=11,
    style="-|>",
):
    ax.add_patch(
        FancyArrowPatch(
            start,
            end,
            arrowstyle=style,
            mutation_scale=15,
            connectionstyle=f"arc3,rad={rad}",
            color=colour or C.get("gold", "#888888"),
            linewidth=lw,
            shrinkA=2,
            shrinkB=2,
            zorder=1,
        )
    )
    if label:
        ax.text(
            (start[0] + end[0]) / 2 + label_offset[0],
            (start[1] + end[1]) / 2 + label_offset[1],
            label,
            ha="center",
            va="center",
            fontsize=size,
            color=C.get("grey_dark", "#444444"),
            zorder=3,
            bbox={
                "boxstyle": "round,pad=0.18",
                "facecolor": C.get("white", "#FFFFFF"),
                "edgecolor": "none",
            },
        )


def return_path(ax, start, end, drop, *, colour=None, lw=1.8, label=None, size=12):
    """A feedback arrow that goes down, across, and back up.

    Use this instead of an `arc3` with a large `rad` when the arrow must clear
    a row of boxes. `arc3` computes its curvature from the chord, so a wide
    return arc passes BEHIND the very boxes it was meant to go around — and
    since boxes are drawn at a higher zorder, the arrow simply disappears. An
    explicit three-segment path goes where you put it.
    """
    colour = colour or C.get("teal", "#0E9384")
    ax.plot(
        [start[0], start[0]],
        [start[1], drop],
        color=colour,
        lw=lw,
        zorder=1,
        solid_capstyle="round",
    )
    ax.plot(
        [start[0], end[0]],
        [drop, drop],
        color=colour,
        lw=lw,
        zorder=1,
        solid_capstyle="round",
    )
    ax.add_patch(
        FancyArrowPatch(
            (end[0], drop),
            (end[0], end[1]),
            arrowstyle="-|>",
            mutation_scale=15,
            color=colour,
            linewidth=lw,
            shrinkA=0,
            shrinkB=2,
            zorder=1,
        )
    )
    if label:
        ax.text(
            (start[0] + end[0]) / 2,
            drop,
            label,
            ha="center",
            va="center",
            fontsize=size,
            color=colour,
            style="italic",
            zorder=3,
            bbox={
                "boxstyle": "round,pad=0.28",
                "facecolor": C.get("white", "#FFFFFF"),
                "edgecolor": "none",
            },
        )


def elbow(ax, top, bottom, bus_y, *, colour=None, lw=1.2):
    """A parent → child connector via a horizontal bus. Three explicit
    segments: the geometry is predictable, therefore checkable."""
    colour = colour or C.get("grey_light", "#CCCCCC")
    ax.plot([top[0], top[0]], [top[1], bus_y], color=colour, lw=lw, zorder=1)
    ax.plot([top[0], bottom[0]], [bus_y, bus_y], color=colour, lw=lw, zorder=1)
    ax.plot([bottom[0], bottom[0]], [bus_y, bottom[1]], color=colour, lw=lw, zorder=1)


def band(
    ax,
    x,
    y,
    w,
    h,
    text,
    *,
    fill=None,
    colour=None,
    size=14,
    bold=False,
    italic=False,
    align="center",
):
    """A pale strip carrying one sentence — the takeaway of a figure."""
    ax.add_patch(
        FancyBboxPatch(
            (x, y),
            w,
            h,
            boxstyle="round,pad=0.02,rounding_size=0.06",
            facecolor=fill or C.get("pale", "#EEEEEE"),
            edgecolor="none",
            zorder=1,
        )
    )
    tx = x + w / 2 if align == "center" else x + 0.18
    ax.text(
        tx,
        y + h / 2,
        text,
        ha="center" if align == "center" else "left",
        va="center",
        fontsize=size,
        color=colour or C.get("navy", "#000000"),
        fontweight="bold" if bold else "normal",
        style="italic" if italic else "normal",
        zorder=3,
    )


def rule(ax, x, y0, y1, *, colour=None, lw=1.2):
    ax.plot(
        [x, x],
        [y0, y1],
        color=colour or C.get("grey_light", "#CCCCCC"),
        lw=lw,
        zorder=1,
        solid_capstyle="round",
    )


def disc(ax, x, y, r, label, colour, *, size=17, ring=False):
    """A filled disc with a numeral or a two-letter monogram.

    Prefer this to a decorative icon when a rule demands unambiguous
    pictograms: a monogram with the role written under it cannot be
    misread, a hand-drawn metaphor can.
    """
    if ring:
        ax.add_patch(
            plt.Circle(
                (x, y),
                r * 1.16,
                facecolor="none",
                edgecolor=colour,
                linewidth=1.0,
                alpha=0.35,
                zorder=2,
            )
        )
    ax.add_patch(plt.Circle((x, y), r, facecolor=colour, edgecolor="none", zorder=3))
    ax.text(
        x,
        y,
        label,
        ha="center",
        va="center",
        color=C.get("white", "#FFFFFF"),
        fontsize=size,
        fontweight="bold",
        zorder=4,
    )


def tag(ax, x, y, text, *, colour=None, size=11, ha="left"):
    """A small caps label — a zone heading inside a figure."""
    ax.text(
        x,
        y,
        text.upper(),
        ha=ha,
        va="center",
        fontsize=size,
        color=colour or C.get("gold", "#888888"),
        fontweight="bold",
        zorder=3,
    )


def note(ax, x, y, text, *, size=11, colour=None, ha="left", italic=True):
    ax.text(
        x,
        y,
        text,
        ha=ha,
        va="center",
        fontsize=size,
        color=colour or C.get("grey_dark", "#444444"),
        style="italic" if italic else "normal",
        zorder=3,
    )


def photo(ax, x, y, w, h, path, *, frame=True):
    """Place a photograph in a box, centre-cropped to fill it exactly.

    Cropping rather than letterboxing is what lets a row of images from
    different sources align their captions. Check the crop visually: a centre
    crop can cut the very annotation the image was chosen for.
    """
    import matplotlib.image as mpimg

    img = mpimg.imread(str(path))
    ih, iw = img.shape[0], img.shape[1]
    want, have = w / h, iw / ih
    if have > want:
        keep = int(ih * want)
        off = (iw - keep) // 2
        img = img[:, off : off + keep]
    else:
        keep = int(iw / want)
        off = (ih - keep) // 2
        img = img[off : off + keep, :]
    ax.imshow(img, extent=(x, x + w, y, y + h), aspect="auto", zorder=2)
    if frame:
        ax.add_patch(
            FancyBboxPatch(
                (x, y),
                w,
                h,
                boxstyle="square,pad=0",
                facecolor="none",
                edgecolor=C.get("grey_light", "#CCCCCC"),
                linewidth=1.2,
                zorder=3,
            )
        )


# ============================================ making photographs belong ===
# The single most visible difference between a deck that looks designed and one
# that looks assembled is what happens when a photograph arrives. Left raw, an
# image drags its own palette, its own contrast and its own era onto the slide,
# and the eye reads it as pasted. The fix is not a better image: it is a
# TREATMENT applied identically to every image in the deck, so they become
# members of one family.
#
# Three treatments, in increasing strength. Pick ONE for the whole deck and
# never mix, or you have simply traded one inconsistency for another.


def _as_float_rgb(img):
    import numpy as np

    arr = np.asarray(img, dtype=float)
    if arr.ndim == 2:
        arr = np.dstack([arr] * 3)
    if arr.shape[2] == 4:
        arr = arr[:, :, :3]
    return arr / 255.0 if arr.max() > 1.0 else arr


def _hex_to_rgb(colour: str):
    import numpy as np

    h = colour.lstrip("#")
    return np.array([int(h[i : i + 2], 16) / 255.0 for i in (0, 2, 4)])


def duotone(img, dark: str, light: str, *, gamma: float = 1.0):
    """Map an image's luminance onto a two-colour ramp.

    This is the treatment behind most "impossibly coherent" AI-generated decks:
    a portrait, an engraving and a photograph all become the same two brand
    colours, so they read as illustrations of one book rather than three
    pictures. Applied to a portrait with a navy/gold pair, the subject stops
    being a stock photo and becomes part of the deck's language.

    `gamma` < 1 lifts the midtones (more of the light colour), > 1 deepens
    them. Keep it identical across the deck.

    How strong the effect looks depends entirely on how SATURATED the two
    endpoints are. Verified: mapping onto `#473D36` → `#F5F1EA` — a desaturated
    brown and a cream — reads as a warm greyscale, which is subtle by design.
    For an unmistakable duotone, give the dark end real chroma (a deep navy, a
    bottle green, an aubergine) and keep the light end near the paper. Render
    one image and look before committing the deck to a pair.
    """
    import numpy as np

    rgb = _as_float_rgb(img)
    lum = rgb @ np.array([0.2126, 0.7152, 0.0722])
    if gamma != 1.0:
        lum = np.clip(lum, 0, 1) ** gamma
    a, b = _hex_to_rgb(dark), _hex_to_rgb(light)
    return np.clip(a + (b - a) * lum[..., None], 0, 1)


def tint(img, colour: str, *, alpha: float = 0.35, keep_luma: bool = True):
    """A flat colour veil over an image.

    Weaker than duotone and safer when the image carries information you must
    not destroy — an annotated figure, a screenshot, a diagram with coloured
    contours. `keep_luma` multiplies rather than blends, so structure survives.
    """
    import numpy as np

    rgb = _as_float_rgb(img)
    veil = _hex_to_rgb(colour)
    if keep_luma:
        lum = (rgb @ np.array([0.2126, 0.7152, 0.0722]))[..., None]
        out = rgb * (1 - alpha) + veil * lum * alpha
    else:
        out = rgb * (1 - alpha) + veil * alpha
    return np.clip(out, 0, 1)


def desaturate(img, *, amount: float = 0.85):
    """Pull an image towards grey. The most conservative unifier: it removes
    the clash without imposing a hue, and it is the right choice when the deck
    already has a strong accent colour doing the talking."""
    import numpy as np

    rgb = _as_float_rgb(img)
    lum = (rgb @ np.array([0.2126, 0.7152, 0.0722]))[..., None]
    return np.clip(rgb * (1 - amount) + lum * amount, 0, 1)


TREATMENTS = ("none", "duotone", "tint", "desaturate")


def treated_photo(
    ax,
    x,
    y,
    w,
    h,
    path,
    *,
    treatment="none",
    dark=None,
    light=None,
    colour=None,
    alpha=0.35,
    gamma=1.0,
    amount=0.85,
    frame=True,
    frame_colour=None,
):
    """`photo()` with a house treatment applied.

    Set the treatment ONCE in your `theme.py` and pass it everywhere:

        IMAGE_TREATMENT = dict(treatment="duotone",
                               dark=NAVY, light=PALE, gamma=0.9)

        figkit.treated_photo(ax, *box, path, **theme.IMAGE_TREATMENT)

    A deck where every image went through the same three lines looks art
    directed. A deck where each image was tuned to taste looks like a folder.
    """
    import matplotlib.image as mpimg
    import numpy as np

    img = mpimg.imread(str(path))
    ih, iw = img.shape[0], img.shape[1]
    want, have = w / h, iw / ih
    if have > want:  # too wide: crop the sides
        keep = int(ih * want)
        off = (iw - keep) // 2
        img = img[:, off : off + keep]
    else:  # too tall: crop top and bottom
        keep = int(iw / want)
        off = (ih - keep) // 2
        img = img[off : off + keep, :]

    if treatment == "duotone":
        img = duotone(
            img,
            dark or C.get("navy", "#000000"),
            light or C.get("white", "#FFFFFF"),
            gamma=gamma,
        )
    elif treatment == "tint":
        img = tint(img, colour or C.get("navy", "#000000"), alpha=alpha)
    elif treatment == "desaturate":
        img = desaturate(img, amount=amount)
    elif treatment != "none":
        raise SystemExit(f"unknown treatment {treatment!r} — pick from {TREATMENTS}")
    else:
        img = np.asarray(img)

    ax.imshow(img, extent=(x, x + w, y, y + h), aspect="auto", zorder=2)
    if frame:
        ax.add_patch(
            FancyBboxPatch(
                (x, y),
                w,
                h,
                boxstyle="square,pad=0",
                facecolor="none",
                edgecolor=frame_colour or C.get("grey_light", "#CCCCCC"),
                linewidth=1.2,
                zorder=3,
            )
        )


def gradient_band(ax, x, y, w, h, *, top: str, bottom: str, steps: int = 128, zorder=1):
    """A vertical gradient, drawn as stacked slivers.

    Useful for a cover or a section divider: it gives depth without an image,
    and it cannot clash because both colours are yours. matplotlib has no
    gradient fill, hence the slivers.
    """
    import numpy as np

    a, b = _hex_to_rgb(top), _hex_to_rgb(bottom)
    dy = h / steps
    for i in range(steps):
        c = a + (b - a) * (i / max(1, steps - 1))
        ax.add_patch(
            FancyBboxPatch(
                (x, y + h - (i + 1) * dy),
                w,
                dy * 1.02,
                boxstyle="square,pad=0",
                facecolor=tuple(np.clip(c, 0, 1)),
                edgecolor="none",
                zorder=zorder,
            )
        )
