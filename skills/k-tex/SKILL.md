---
name: k-tex
description: >
  KπX LaTeX architecture & compilation workflows — latexmk multi-pass, pdfunite merging,
  two canonical report archetypes (envision-copilot-rapport & culling-rapport),
  and a dense revision-sheet template (template-revision/).
  Load when creating, editing, structuring, or building any LaTeX project or report —
  and ALWAYS when the task is making revision sheets (fiches de révision).
metadata:
  author: KpihX
  version: "2.4.0"
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
| **`libs/humanize`** | Centralized PROSE dash gate (single source of truth) — `libs/humanize/humanize_lib.sh` / `.js` / `.py` twins + `scripts/check-dashes.sh` + `skills/k-opencode/scripts/plugins/hooks/humanize-guard.js` (hard `tool.execute.before` gate) | Sourced by `scripts/check-dashes.sh`; JS twin used by `humanize-guard.js` at write-time |

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

### Archetype 3: Modular Report Template (`assets/template-report/`)

- **Use Case**: General-purpose modular report template (10–30 pages) — works for any institution, project type, or language. Use as-is for generic reports.
- **Structure**:
  - `main.tex` entry point with `\include{}` for each sub-file.
  - `preambule.tex` — packages, geometry, graphics path (`assets/bgs/`), bibliography.
  - `titlepage.tex` — wallpaper background + title block.
  - `introduction.tex`, `conclusion.tex` — content placeholders.
  - `biblio.tex` / `biblio.bib` — bibliography.
  - `assets/bgs/` — background images (Bg.png … Bg9.webp + Enspy.png).
- **Compilation**: `latexmk` via `make build` → `build/main.pdf`.
- **Asset**: `skills/k-tex/assets/template-report/`
- **Polytechnique X adaptation**: for École Polytechnique projects/reports, do NOT use this template directly. Instead, adapt `culling-rapport` (Archetype 2) as the starting point — it carries `polytechnique.sty`, the official Poly logo paths (`assets/x/`), and the X typography stack (Arial via `helvet`, specific spacing). See `culling-rapport` for the Poly-specific Preambule, geometry, and `\subtitle` pattern.

---

## Canonical Live Example: `cv` (CI/CD reference project)

The single-file CV is the live reference for a LaTeX project with full CI/CD —
read its `AGENTS.md` (style guide + tag/release lessons) before scaffolding:

- **Local**: `$HOME/KpihX-Labs/cv`
- **GitHub**: `https://github.com/KpihX/cv` (default: `master`)
- **GitLab**: `https://gitlab.com/kpihx/cv` (default: `master`)
- **CI/CD**: GitHub Actions (build + preview commit + Release on date tag
  `YYYY-MM-DD`) + GitLab CI (PDF + preview artifacts, 1 year).
- **Checks**: `make check` = `check-dashes` (em-dash gate, FIRST — never build
  on failure) → build → 1-page gate; `check` gates `make push`.

---

## Revision Sheets (`assets/template-revision/`)

Dense fiches de révision that pack a whole course onto minimal pages: 8pt
landscape, page split in **3 columns** (`multicol`), 0.5cm margins, compact
lists, grayscale `mybox` highlights — every square centimeter earns its place.

- **Asset**: `skills/k-tex/assets/template-revision/`
  (`main.tex` + `1.tex` content + `Makefile` + `.gitignore` + `AGENTS.md`).
- **Content flow**: write Markdown → `pandoc revision.md -o 1.tex`
  (or write `1.tex` directly) → `make build` (single command, always rebuilds,
  double pdflatex pass into internal `build/`, PDF copied to root).
- **Academic workflow**: after exploring a course's material, copy the template
  into `~/KpihX-Labs/Explore/` (`~e`) adjusted per course.

---

## Mandatory `check-dashes` (NEVER forget)
Canonical copy now lives at `scripts/check-dashes.sh` (global, single source
of truth, sources `libs/humanize/humanize_lib.sh`). Every KπX TeX-family
project MUST wire `scripts/check-dashes.sh` as the FIRST step of `make build`
(via `check:` target, before any compilation) — it scans tracked
`*.tex` + `*.md` + `*.txt` + `*.rst` + `*.adoc` for 4 blocked patterns:
`---`, `—` (U+2014), ` -- `, and spaced ` – ` (U+2013). Exemptions: TeX
`%` comments (full-line `^[[:space:]]*%` in `.tex`), `^---$` HR/frontmatter
(standalone `---` line, allowed), and interval `2024–2025` (`alnum–alnum`
collé, allowed — only spaced ` – ` is blocked). The file is **copied** (not
symlinked) into `scripts/check-dashes.sh` of every new project at creation
from the central `scripts/check-dashes.sh`. The hook
`skills/k-opencode/scripts/plugins/hooks/humanize-guard.js` (hard,
`tool.execute.before`) provides the write-time gate using the same
`libs/humanize/humanize_lib.js` lib (same 4 patterns, code-extension
whitelist via `isCodeFile`).

---

## Standard Makefile & `.gitignore`

Centralized in `skills/k-tex/assets/Makefile` and `skills/k-tex/assets/.gitignore`
(copied into every new project at creation, not symlinked).
Both templates (`template-revision/`, `template-report/`) symlink to these.

**Makefile** — `check` gates `build` (calls copied central script FIRST, must pass before build), `push` is standalone:
```makefile
SHELL := /bin/zsh
.PHONY: check build push

check:  ## Dashes gate — copy of central scripts/check-dashes.sh (must pass before build)
	sh scripts/check-dashes.sh

build: check  ## Build (runs dashes check first) → build/main.pdf
	latexmk -pdf -f -interaction=nonstopmode -output-directory=build main.tex || true

push:  ## Push to remotes
	git push github main
	git push gitlab main
```

For projects requiring external PDF appending (e.g. `culling-rapport` style),
extend `build:` with `pdfunite` + `mv` after `latexmk`.

**`.gitignore`** — build debris ignored, final PDF always committed:
```gitignore
build/*
!build/*.pdf
```
🔴 **Renders rule:** `build/*` (not bare `build/`), and `!build/*.pdf` stays
so the final PDF is ALWAYS committed.

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
- Full operational memory (recurring mistakes, validated fixes) → `references/insights.md`.

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-10 | [LIVE] | v2.4.0 — humanize centralization: check-dashes moved to `scripts/check-dashes.sh` (global, extended to md/txt + unicode, HR + interval exemptions), lib `libs/humanize/humanize_lib.*` single source, hook `humanize-guard.js` hard gate at write-time, docs updated. |
| 2026-09-07 | [LIVE] | v2.3.0 — `assets/template-report/` normalized: files lowercase (Main→main, Biblio→biblio, Preambule→preambule, TitlePage→titlepage, Introduction→introduction, Conclusion→conclusion), image paths fixed (`assets/bgs/`), build debris cleaned, added Makefile + `.gitignore` + `AGENTS.md` + `build/`, documented as Archetype 3 (general template, X projects → adapt culling-rapport instead). |
| [SUMMARY] | -- | v2.2.0 . v2.1.0 . v2.0.0 full rewrite (latexmk, pdfunite, 2 archetypes) · v1.0.0 revision template init · older → `references/log.md` |

