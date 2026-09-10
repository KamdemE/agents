---
name: k-pdf
description: >
  PDF toolkit — classic tools (pdftotext, pdftoppm, pdfinfo, pdffonts),
  Docling (JSON/MD/images), font audit, and structural analysis scripts.
  Load when touching any PDF: understand, extract, audit, compare.
metadata:
  author: 
  version: "1.0.0"
  scope: operations
---

#  — PDF Toolkit

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

> **Reflex:** When an agent touches a PDF, load k-pdf FIRST. Choose the right tool for the job.

## Decision Tree

```
Working with a PDF?
├── Raw content (text, metadata)                   → Classic tools (pdftotext, pdfinfo)
├── Structure (pages, layout, bbox)                → Docling JSON
├── Extracted images/figures                       → Docling --image-export-mode referenced
├── Visual rendering                               → pdftoppm → PNG pages
├── Font audit                                     → pdf-fonts.py (scripts/)
├── Structural analysis                            → pdf-structure.py (scripts/)
└── OCR (scanned PDF)                              → tesseract on rendered PNG
```

## Decision Table

| Situation | Tool | Why |
|-----------|------|-----|
| "What text is in this PDF?" | `pdftotext` | 0.1s, 100% native text |
| "How many pages? Format?" | `pdfinfo` | 0.01s, full metadata |
| "What fonts and sizes?" | `pdf-fonts.py` | complete font/size/occurrence audit |
| "Page-by-page structure?" | `pdf-structure.py` | JSON→page tree with labels, bbox |
| "Extracted images" | `docling --image-export-mode referenced` | separate PNGs + bounding boxes |
| "Markdown tables" | `docling --to md` | structured pipe tables |
| "Everything: structure+images+text" | `docling --to json --to md --image-export-mode referenced` | all 3 in 1 run |
| "Scanned PDF" | `pdftoppm` → `tesseract` | render PNG then OCR |
| "Visual page view" | `pdftoppm -png -r 150` | 1 PNG per page |

---

## Classic Tools (poppler-utils + tesseract)

System tools, zero install, zero GPU.

| Command | Output | Usage |
|---------|--------|-------|
| `pdftotext input.pdf output.txt` | Raw text | Full extraction, 0.1s |
| `pdfinfo input.pdf` | Metadata | Pages, size, author |
| `pdftoppm -png -r 150 input.pdf page` | PNG per page | Visual render |
| `pdffonts input.pdf` | Font list | Names only (no sizes) |
| `pdfunite a.pdf b.pdf out.pdf` | Merged PDF | Concatenate PDFs |

### tesseract (OCR)

```bash
pdftoppm -png -r 300 input.pdf page
tesseract page-1.png output -l fra+eng
```

⚠️ **USELESS on native text PDFs.** Scans only.

---

## Docling — Structured Parser (IBM, MIT)

Best tool for deep PDF understanding. 3 formats in 1 run.

### Command

```bash
docling --from pdf --to md --to json --image-export-mode referenced \
  --output /tmp/output/ input.pdf
```

### The 3 Key Options

| Option | Output | When to use |
|--------|--------|-------------|
| `--to md` | Markdown with tables | Human reading, structured text extraction |
| `--to json` | JSON DoclingDocument (~15K lines) | Programmatic analysis, bbox, labels, pages |
| `--image-export-mode referenced` | Separate PNGs in `*_artifacts/` | Extract figures, logos, diagrams |

### Always redirect to an output subfolder

```
output/
├── document.md              ← Readable Markdown
├── document.json            ← Structured JSON (15K+ lines)
└── document_artifacts/
    ├── page_000001.png      ← Per-page render
    └── image_000001.png     ← Extracted figures
```

### JSON Docling — per-block data

- `page_no` → page number
- `label` → block type
- `bbox` → `(left, top, right, bottom)` in PDF points
- `text` → text content

| Label | Meaning |
|-------|---------|
| `section_header` | Section/subsection title |
| `text` | Body paragraph |
| `table` | Structured table |
| `picture` | Figure, logo, diagram |
| `footnote` | Footnote |
| `page_footer` | Page number |
| `page_header` | Section number (top) |
| `caption` | Figure/table caption |
| `document_index` | Table of contents |
| `list_item` | Bullet point |

### MD vs JSON

| Criterion | MD | JSON |
|-----------|:---:|:---:|
| Human-readable | ✅ | ❌ |
| Pagination | ❌ | ✅ |
| Bounding boxes | ❌ | ✅ |
| Semantic labels | ❌ | ✅ |
| Token cost | ~18K | ~130K |
| Page boundaries | ❌ | ✅ |

### Known Errors

| Error | Impact | Fix |
|-------|--------|-----|
| `L'` → `L '` (spurious space) | ~20/doc | `sed "s/L '/L'/g"` post-processing |
| `R&D` → `R&D` (HTML entity) | non-bug | ignore in Markdown viewer |
| TOC corrupted | words scattered in cells | use pdftotext for TOC |
| Figures = raw text in MD | diagram labels unreadable | use JSON for bbox |

---

## Scripts k-pdf

### pdf-structure.py — Full Structural Tree

```bash
uv run python scripts/pdf-structure.py <docling_output_dir> <output_file>
```

Produces tree: `PAGE N (title)` → blocks `key/idx label "text"` → meta (schema, version, counts).

See `assets/ex/docling/structure.txt`.

### pdf-fonts.py — Font/Size Audit

```bash
uv run --with pdfminer.six python scripts/pdf-fonts.py <input.pdf> <output_file>
```

Produces table: `Font | Size | Occurrences | Usage`.

See `assets/ex/docling/fonts.txt` and `assets/ex/classic/fonts.txt`.

⚠️ Requires `pdfminer.six` via `uv run --with pdfminer.six`.

---

## Pixel-Level Vision (when parsers fall short)

For visual content (filled forms, signatures, handwritten annotations):

1. `pdftoppm -png -r 300 input.pdf page`
2. Send PNG to a **VLM** (GPT-4o, Qwen2.5-VL, Gemini)
3. VLM sees the page like a human

Only method for capturing **visual position** of checkboxes, signatures, or handwritten notes.

---

## Quick Comparison

| Criterion | pdftotext | tesseract | Docling MD | Docling JSON | Marker |
|-----------|:---------:|:---------:|:----------:|:------------:|:------:|
| Speed | ⚡ 0.1s | 🐌 2s | 🐌 15s/p | 🐌 15s/p | 🐌 4s/p |
| Tables | ❌ | ❌ | ✅ | ✅ | ⚠️ broken |
| Images | ❌ | ❌ | base64 | base64 | JPEG |
| Pagination | ❌ | ❌ | ❌ | ✅ | ✅ |
| Bbox | ❌ | ❌ | ❌ | ✅ | ✅ |
| GPU | No | No | No | No | Recommended |

---

## Examples

### assets/ex/docling/ — LaTeX Internship Report (20 pages)

| File | Content |
|------|---------|
| `main.pdf` | Source PDF |
| `main.md` | Docling MD (73 KB) |
| `main.json` | Docling JSON (519 KB) |
| `main_artifacts/` | 20 page PNGs + 8 figure PNGs |
| `structure.txt` | Tree from `pdf-structure.py` |
| `fonts.txt` | Audit from `pdf-fonts.py` |

### assets/ex/classic/ — Native tools on same rapport (20 pages)

| File | Content |
|------|---------|
| `page-*.png` | 20 PNG renders at 150 DPI |
| `pdfinfo.txt` | PDF metadata |
| `pdftotext.txt` | Raw text extraction |
| `tesseract.txt` | OCR output |
| `fonts.txt` | Font audit (18 combos) |

---

## Pipelines

### Minimal (raw content)
```bash
pdftotext input.pdf /tmp/text.txt && pdfinfo input.pdf
```

### Structured (understand the document)
```bash
docling --from pdf --to json --to md --image-export-mode referenced \
  --output /tmp/docling/ input.pdf
uv run python scripts/pdf-structure.py /tmp/docling/ /tmp/structure.txt
uv run --with pdfminer.six python scripts/pdf-fonts.py input.pdf /tmp/fonts.txt
```

### Full Audit (form + content)
```bash
pdftotext input.pdf /tmp/text.txt
docling --from pdf --to json --output /tmp/docling/ input.pdf
docling --from pdf --image-export-mode referenced --output /tmp/images/ input.pdf
uv run --with pdfminer.six python scripts/pdf-fonts.py input.pdf /tmp/fonts.txt
pdftoppm -png -r 300 input.pdf /tmp/pages/page
```

### Compliance Check (report vs directives)
```bash
pdftotext rapport.pdf /tmp/rapport.txt
docling --from pdf --to json --output /tmp/docling/ rapport.pdf
uv run --with pdfminer.six python scripts/pdf-fonts.py rapport.pdf /tmp/fonts.txt
pdfinfo rapport.pdf | grep Pages
```

---

## Installed Instruments

| Tool | Source | Usage |
|------|--------|-------|
| `pdftotext` | poppler-utils | Raw text |
| `pdfinfo` | poppler-utils | Metadata |
| `pdftoppm` | poppler-utils | PNG per page |
| `pdffonts` | poppler-utils | Font names (no sizes) |
| `pdfunite` | poppler-utils | PDF merge |
| `tesseract` | system (eng+fra) | OCR scans |
| `docling` | `uv tool install docling` | Structured parser |
| `pdfminer.six` | `uv run --with` | Fonts + sizes |

> **Marker**: installed but not recommended — needs llama.cpp, slow on CPU, broken tables. Use Docling instead.

---

## Insights

- Docling 700× slower than pdftotext but 100× more structured info
- JSON costs ~7× more tokens than MD — MD for reading, JSON for analysis
- `pdffonts` gives font NAMES without sizes — `pdf-fonts.py` (pdfminer) for sizes
- `L '` spurious spaces = LaTeX ligature artifacts, not UTF-8 bug
- Native text PDF: `pdftotext` is the most faithful source
- Scanned PDF: `pdftoppm` + tesseract is the way

---

