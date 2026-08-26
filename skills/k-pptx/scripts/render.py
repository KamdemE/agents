"""Single entry point — copy this into a deck folder and adapt.

    python render.py            figures, then assemble
    python render.py figures    only the PNGs
    python render.py figures a  only module `a`
    python render.py deck       only the .pptx
    python render.py preview    one PNG per slide + contact sheets
    python render.py check      verify the contract, produce nothing
    python render.py all        figures + deck + preview

One command to remember, and it is always safe to run. `check` is the important
one: it answers "can this be rendered correctly?" rather than "does the PNG
exist?", which is the wrong question — a stale PNG exists too.

If the deck needs packages the project does not depend on, keep the relaunch
trick from `assets/presentation/render.py`: catch the ImportError and
re-exec through `uv run --with python-pptx --with … python __file__`, guarded
by an environment variable so it cannot loop.
"""

from __future__ import annotations

import importlib
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent
sys.path[:0] = [str(ROOT), str(ROOT / "figures")]

#: Figure modules, in build order. Each must expose `ALL`, a list of
#: zero-argument builders. A builder declares its key on its first line
#: (`key = "…"`), which is the same string the markdown puts in `figure:`.
FIGURE_MODULES: tuple[str, ...] = ("badges", "flows")


def figures(which: tuple[str, ...] = ()) -> None:
    for name in which or FIGURE_MODULES:
        if name not in FIGURE_MODULES:
            raise SystemExit(
                f"unknown figure module {name!r} — pick from {FIGURE_MODULES}"
            )
        module = importlib.import_module(f"figures.{name}")
        for build in module.ALL:
            build()


def check() -> int:
    import deck
    import slides as slidesmod

    all_slides = slidesmod.load()
    problems = deck.validate(all_slides)
    talk = [s for s in all_slides if not s.is_annexe]
    print(f"[check] {len(talk)} talk slide(s), {len(all_slides) - len(talk)} annexe(s)")
    for s in all_slides:
        flag = "!!" if any(s.path.name in p for p in problems) else "  "
        print(
            f"  {flag} {s.label:>3}  {s.layout:<26} "
            f"{s.line_count} line(s)  {s.path.name}"
        )
    if problems:
        print("\n[check] problems:")
        for p in problems:
            print("  - " + p)
        return 1
    print("[check] contract satisfied.")
    return 0


def main(argv: list[str]) -> None:
    cmd = argv[0] if argv else "all"
    rest = tuple(argv[1:])
    known = {"figures", "deck", "preview", "check", "all"}
    if cmd not in known:
        raise SystemExit(__doc__)
    if cmd == "check":
        raise SystemExit(check())
    if cmd in ("figures", "all"):
        figures(rest if cmd == "figures" else ())
    if cmd in ("deck", "all"):
        import deck

        deck.build()
    if cmd in ("preview", "all"):
        import preview

        preview.main()


if __name__ == "__main__":
    main(sys.argv[1:])
