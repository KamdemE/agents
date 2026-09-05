"""Proof-read the .pptx without opening PowerPoint.

Converts the deliverable to PDF, then to one PNG per slide, and assembles 3x2
contact sheets so you can judge the RHYTHM of the talk and not just one page in
isolation. Looking at the images is the only way most defects surface: text
floating in a void, text over a watermark, a caption colliding with page
furniture, a connector hidden behind a box, a doubled page number.

Two limits to keep in mind, both real:

* **Font substitution.** If the render host lacks the template's fonts it
  substitutes them, so line lengths and line breaks can differ from PowerPoint.
  The final check happens on the machine you will present from.
* **Missing glyphs in the substitute.** A substituted face may lack characters
  the original has — accented lowercase like `û`/`ù`, and accented capitals like
  `È`/`Û`/`Ô` — and render them as a letter followed by a floating accent, so
  "août" appears as "aou^t". That is an APPEARANCE bug, not a file bug: check
  the run text in the XML before changing a single word. A fontconfig alias may
  not help, because some renderers use their own substitution table.

Hidden slides (`show="0"`) are excluded from PDF export. To proof-read them,
regenerate a visible copy — see `make_help_slides.py --visible`.
"""

from __future__ import annotations

import pathlib
import shutil
import subprocess


def _run(cmd) -> str:
    res = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if res.returncode != 0:
        raise SystemExit(f"failed: {' '.join(map(str, cmd))}\n{res.stderr[-1500:]}")
    return res.stdout


def main(
    pptx: str | pathlib.Path | None = None,
    *,
    out_dir="build/preview",
    dpi=110,
    sheets=True,
    cols=3,
    per_sheet=6,
):
    build = pathlib.Path("build")
    pptx = pathlib.Path(pptx) if pptx else next(build.glob("*.pptx"))
    out = pathlib.Path(out_dir)

    if shutil.which("soffice") is None:
        raise SystemExit(
            "`soffice` not found: cannot render a preview. Open "
            "the .pptx directly, or install LibreOffice."
        )
    out.mkdir(parents=True, exist_ok=True)
    # Old PNGs are overwritten, not deleted: depending on where the repo is
    # mounted, unlink can be refused while rewriting succeeds. Leftovers from a
    # longer previous run are reported instead of removed.
    before = {p.name for p in out.glob("slide-*.png")}

    _run(
        [
            "soffice",
            "--headless",
            "--convert-to",
            "pdf",
            "--outdir",
            str(build),
            str(pptx),
        ]
    )
    pdf = build / (pptx.stem + ".pdf")
    _run(["pdftoppm", "-png", "-r", str(dpi), str(pdf), str(out / "slide")])

    pages = sorted(out.glob("slide-*.png"))
    print(f"[preview] {len(pages)} slide(s) -> {out}")
    orphans = before - {p.name for p in pages}
    if orphans:
        print(f"[preview] leftovers from a previous run, ignore: {sorted(orphans)}")

    if sheets and pages:
        try:
            from PIL import Image
        except ImportError:
            return pages
        for start in range(0, len(pages), per_sheet):
            chunk = pages[start : start + per_sheet]
            ims = [Image.open(p) for p in chunk]
            w, h = ims[0].size
            rows = (len(chunk) + cols - 1) // cols
            sheet = Image.new("RGB", (w * cols, h * rows), "white")
            for i, im in enumerate(ims):
                sheet.paste(im, ((i % cols) * w, (i // cols) * h))
            name = out / f"contact_{start // per_sheet + 1}.png"
            sheet.save(name)
            print(f"[preview] {name.name}")
    return pages


if __name__ == "__main__":
    main()
