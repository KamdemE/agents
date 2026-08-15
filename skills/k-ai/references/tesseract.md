# Tesseract OCR — Reference

Local OCR engine (system package, not a Python wrapper). Simple CLI, no sovereign wrapper needed — use `tesseract` directly.

## Install (from scratch)

```bash
# Engine + languages
sudo apt-get install -y tesseract-ocr tesseract-ocr-eng tesseract-ocr-fra

# Verify
tesseract --version        # engine version
tesseract --list-langs     # available languages
```

Useful packs: `-eng` (en), `-fra` (fr), `-deu` (de), `-spa` (es), `-all` (every language).

## Usage (CLI)

```bash
tesseract image.png stdout              # text to stdout (default lang)
tesseract image.png stdout -l fra       # force French
tesseract image.png stdout -l fra+eng   # multiple languages
tesseract image.png out_base -l fra     # → out_base.txt
tesseract image.png stdout -l fra --psm 6   # page-segmentation mode
```

## On this workstation (kpihx-ubuntu)

| Property | Value |
|----------|-------|
| Binary | `/usr/bin/tesseract` (v5.5.0, leptonica 1.86.0) |
| Languages | `eng`, `fra`, `osd` (installed in `/usr/share/tesseract-ocr/5/tessdata/`) |
| Added | `tesseract-ocr-fra` installed 2026-08-14 (apt) |

## Tesseract Models (`.traineddata`)

Location: `/usr/share/tesseract-ocr/5/tessdata/` (total ~16 MB). Format: **`.traineddata`** — Tesseract's native binary format (LSTM OCR model per language), data version 4.1.0, engine Tesseract 5.5.0.

| File | Size | Language |
|------|------|----------|
| `eng.traineddata` | 4.0 MB | English |
| `fra.traineddata` | 1.1 MB | French |
| `osd.traineddata` | 11 MB | Orientation & script detection |
| `pdf.ttf` | 572 B | Font for PDF output |

Note: these OCR `.traineddata` models (1-4 MB) are tiny vs. QMD's GGUF embedding/LLM models (314 MB - 1.2 GB) — OCR is a simpler, older problem.

## Text Extractor GNOME extension (consumer)

The `text-extractor@aditya190803` GNOME extension uses a Python helper (`text-extractor-ocr`) that wraps tesseract via `pytesseract` and returns JSON (text + bounding boxes + confidence).

- Helper: `~/.local/bin/text-extractor-ocr` (copied from the extension repo `build/ocr_helper.py`)
- Helper venv: `~/.local/share/uv/text-extractor-ocr-venv` (pytesseract + pillow, 100% uv)
- Helper shebang: points to the uv venv python (system python lacks pytesseract)
- Extension language: `ocr-language = 'fra'` (dconf)
- Shortcut: `Super + Shift + T`
