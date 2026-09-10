# AGENTS.md — template-revision (k-tex asset)

You are inside the canonical  revision-sheet template:
`~/.agents/skills/k-tex/assets/template-revision/`
(canonical source of truth — full doc → `k-tex` SKILL.md § Revision Sheets).

## What this is

Dense fiches de révision / cheat sheets: 8pt landscape A4, page split in
**3 columns** (`multicol`), 0.5cm margins, zero-waste spacing, grayscale
`mybox` highlights for definitions/theorems. Packs a whole course onto
minimal pages. Robust build (`|| true`) — a PDF always comes out.

## What to do with it (course workflow)

1. **Copy** this whole folder to `~/Labs/Explore/<course>/revision/`
   (`~e`) — one copy per course, adjusted as needed. Never build here.
2. **Content**: Markdown → `pandoc revision.md -o 1.tex`, or write `1.tex`
   directly (`\section`, `\subsection`, `mybox`, short bullets, bold key terms).
3. **Build**: `make build` — always rebuilds, double pdflatex pass into
   internal `build/`, PDF copied to root. Runs `check-dashes` first.
4. **Renders rule**: `build/` debris ignored except the final PDF
   (`.gitignore`: `build/*` + `!build/*.pdf`) — always commit the final PDF.

## Files

- `main.tex` — formatting + `\input{1}` (3-column layout, placeholder content)
- `1.tex` — content file (replace with the course material)
- `Makefile` — `make check` (dashes gate), `make build` (check + compile), `make push`
- `scripts/check-dashes.sh` — symlink → k-tex canonical em-dash gate
- `.gitignore` — build debris except final PDF
