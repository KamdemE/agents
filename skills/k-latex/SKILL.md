---
name: k-latex
description: >
  KπX LaTeX architecture & compilation workflows — latexmk multi-pass, pdfunite merging,
  and two canonical report archetypes (envision-copilot-rapport & culling-rapport).
  Load when creating, editing, structuring, or building any LaTeX project or report.
metadata:
  author: KpihX
  version: "2.0.0"
  scope: templates-workflow
  target-agent: all
allowed-tools: Bash, Read, Write, Edit
---

# KπX — LaTeX Architecture & Workflows

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Mandatory Agent Reflex:** Before creating, editing, or configuring ANY LaTeX project, agents MUST inspect the reference structures of KπX's canonical LaTeX repos (`Makefile`, `main.tex`, `assets/`, `polytechnique.sty`, `build/`). If absent on disk, clone temporarily to `/tmp/` to inspect structure and build patterns.

---

## Tooling & Core Commands

| Tool | Role | Command / Usage |
|------|------|-----------------|
| **`latexmk`** | Automated multi-pass build (handles `pdflatex`, `bibtex`, cross-refs, and ToC until convergence) | `latexmk -pdf -f -interaction=nonstopmode -output-directory=build main.tex \|\| true` |
| **`pdflatex`** | Underlying TeX compiler (called by `latexmk`) | Driven via `latexmk`; standalone only for single-pass dry runs |
| **`pdfunite`** | Lossless PDF concatenation (`poppler-utils`) — appends external PDFs (form fields, signatures) without re-encoding | `pdfunite build/main.pdf assets/Fiche_Evaluation.pdf build/main_final.pdf && mv build/main_final.pdf build/main.pdf` |
| **`pdfminer.six`** | Font audit (family, size, occurrences) via `k-pdf` | `uv run --with pdfminer.six python $HOME/.agents/skills/k-pdf/scripts/pdf-fonts.py build/main.pdf output.txt` |

---

## Project Directory Standard

Every KπX LaTeX project MUST obey this directory structure:

```
<project-name>/
├── main.tex                   ← Entry point (root)
├── polytechnique.sty          ← Style / template class (or custom .sty)
├── Makefile                   ← Standard build & push interface
├── .gitignore                 ← Ignore build/* except !build/*.pdf
├── README.md                  ← Project documentation & build instructions
├── assets/                    ← Non-code visual assets & external PDFs
│   ├── figures/               ← Diagrams, PNG/JPG figures
│   └── x/                     ← Official logo PDFs (polytechnique-*.pdf)
└── build/                     ← Build outputs & LaTeX debris (tracked: build/main.pdf)
```

---

## Canonical Report Archetypes

KπX maintains two canonical reference archetypes for LaTeX documents:

### Archetype 1: Modular Long-Form Report (`envision-copilot-rapport`)

- **Use Case**: Long R&D / PSC internship reports (30+ pages), heavy literature reviews, split chapters, full bibliography.
- **Structure**:
  - Split into sub-`.tex` files (`01_Introduction.tex`, `02_Etat_Art.tex`, `03_Architecture_Technique.tex`, `08_Bibliographie.tex`).
  - `main.tex` at root acts as orchestrator (`\input{01_Introduction.tex}`, etc.).
  - Full BibTeX bibliography at the end (`08_Bibliographie.tex`).
  - Assets organized in `assets/x/` (official logos) and `assets/figures/`.
- **Compilation**: `latexmk` multi-pass with BibTeX integration -> `build/main.pdf`.
- **Reference Locations**:
  - **Local**: `$HOME/KpihX-Labs/AI/envision/envision-copilot-rapport`
  - **GitHub**: `https://github.com/KpihX/envision-copilot-rapport` (default: `main`)
  - **GitLab**: `https://gitlab.com/kpihx-labs/ai/envision/envision-copilot-rapport` (default: `main`)

### Archetype 2: Compact Single-File Report (`culling-rapport`)

- **Use Case**: Short to medium reports (15–20 pages), single-file prose, in-page reference footers, external PDF attachment.
- **Structure**:
  - Single `main.tex` file (400+ lines, no sub-`.tex` split).
  - References placed in-page / footnotes.
  - External PDF attachment (e.g. evaluation form) merged post-compilation.
- **Compilation & PDF Merging**:
  - `latexmk` compiles `main.tex` into `build/main.pdf`.
  - `pdfunite` appends `assets/Fiche_Evaluation_*.pdf` to `build/main.pdf` without re-encoding or stripping form fields!
- **Reference Locations**:
  - **Local**: `$HOME/KpihX-Labs/Culling/culling-rapport`
  - **GitHub**: `https://github.com/KpihX/culling-rapport` (default: `main`)
  - **GitLab**: `https://gitlab.com/k-culling/culling-rapport` (default: `main`)

---

## Standard Makefile Pattern

Every KπX LaTeX repository MUST carry a `Makefile` following this exact template:

```makefile
SHELL := /bin/zsh

.PHONY: build push

build:
	latexmk -pdf -f -interaction=nonstopmode -output-directory=build main.tex || true

push:
	git push github main
	git push gitlab main
```

For projects requiring external PDF appending (e.g. `culling-rapport` style):

```makefile
SHELL := /bin/zsh

.PHONY: build push

build:
	latexmk -pdf -f -interaction=nonstopmode -output-directory=build main.tex || true
	pdfunite build/main.pdf assets/Fiche_Evaluation_*.pdf build/main_with_fiche.pdf
	mv build/main_with_fiche.pdf build/main.pdf

push:
	git push github main
	git push gitlab main
```

---

## Standard `.gitignore` Pattern

LaTeX generates heavy build debris (`.aux`, `.log`, `.fls`, `.fdb_latexmk`, `.toc`, `.out`). The `.gitignore` MUST ignore all build debris while tracking the final PDF deliverable (`build/main.pdf`):

```gitignore
.venv/
__pycache__/
*.pyc

# Ignore all build debris except final PDF deliverables
build/*
!build/*.pdf
```

---

## Asset Path Wiring & `polytechnique.sty`

When using the official Polytechnique LaTeX style (`polytechnique.sty`), logo PDF paths MUST be updated to point to `assets/x/`:

```latex
% In polytechnique.sty:
\newcommand{\polyfiletlongrouge}{assets/x/polytechnique-filetlongrouge.pdf}
\newcommand{\polyfiletcourt}{assets/x/polytechnique-filetcourt.pdf}
\newcommand{\polylogovert}{assets/x/polytechnique-logovert.pdf}
\newcommand{\polylogohori}{assets/x/polytechnique-logohori.pdf}
\newcommand{\polyarmes}{assets/x/polytechnique-armes.pdf}
```

In `main.tex`, graphics includes MUST reference `assets/figures/`:
```latex
\includegraphics[width=0.85\textwidth]{assets/figures/my_diagram.png}
```

---

## Workflow for Markdown Integration (Pandoc)

1. Copy the appropriate archetype (`main.tex`, `polytechnique.sty`, `Makefile`, `.gitignore`) to working directory.
2. Convert Markdown content to raw LaTeX: `pandoc content.md -o body.tex`.
3. Include `body.tex` in `main.tex`: `\input{body.tex}`.
4. Compile: `make build`.

---

## Insights & Lessons Learned

- **`pdfunite` over `\includepdf` for form PDFs**: `\includepdf` in pdflatex strips interactive PDF form fields (AcroForm data filled by tutors). `pdfunite` concatenates PDF streams at byte level, preserving form fields, signatures, and stamps.
- **`-output-directory=build` with `latexmk`**: Keeps repository root clean. Ensure `.gitignore` carries `build/*` + `!build/*.pdf`.
- **`latexmk` error handling**: Add `|| true` to `make build` if minor warnings occur, ensuring `build/main.pdf` is output cleanly.

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-05 | [LIVE] | v2.0.0 — Complete rewrite: latexmk multi-pass, pdfunite lossless merging, archetype 1 (envision-copilot-rapport, modular long report) and archetype 2 (culling-rapport, single-file report with pdfunite), assets/x/ wiring, standard Makefile & .gitignore patterns. |
| 2026-05-06 | [ANTIGRAVITY] | v1.0.0 — Initialized k-latex skill. Documented ultra-compact revision template. |
| [SUMMARY] | — | v1.0.0 Initial revision sheet template · older → `references/log.md` |
