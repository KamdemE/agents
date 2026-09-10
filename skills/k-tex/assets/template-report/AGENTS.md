# AGENTS.md — template-report (k-tex asset)

You are inside the canonical KπX report template:
`~/.agents/skills/k-tex/assets/template-report/`
(source of truth — full doc → `k-tex` SKILL.md § Canonical Report Archetypes).

## What this is

A modular long-form report template (`book` class, split sub-files, full
BibTeX bibliography, wallpaper title page). Designed for medium-length
reports (10–30 pages): intro, conclusion, bibliography as separate `.tex`
files, background image assets in `assets/bgs/`.

## What to do with it (workflow)

1. **Copy** this whole folder to your project directory.
2. **Content**: edit `introduction.tex`, `conclusion.tex`, add chapter files
   as needed and `\include{}` them in `main.tex`.
3. **Title page**: edit `titlepage.tex` (title, authors, supervisor, BG image).
4. **Background**: pick a background from `assets/bgs/` (Bg.png through
   Bg9.webp + Enspy.png) — update `titlepage.tex` accordingly.
5. **Bibliography**: add entries to `biblio.bib`, cite with `\cite{}`.
6. **Build**: `make build` → `build/main.pdf`. Runs `check-dashes` first.
7. **Renders rule**: `.gitignore` covers `build/*` except `!build/*.pdf` —
   always commit the final PDF.

## Files

- `main.tex` — entry point, orchestrates `\include{}` of all sub-files
- `preambule.tex` — packages, geometry, bibliography, graphics path
- `titlepage.tex` — wallpaper background + title block
- `introduction.tex` — introduction content (placeholder)
- `conclusion.tex` — conclusion content (placeholder)
- `biblio.tex` — `\printbibliography` + `\nocite{*}`
- `biblio.bib` — BibTeX entries
- `Makefile` — `make check` (dashes gate), `make build` (check + latexmk), `make push`
- `scripts/check-dashes.sh` — symlink → k-tex canonical em-dash gate
- `.gitignore` — build debris except final PDF
- `assets/bgs/` — background images (Bg.png … Bg9.webp + Enspy.png)
