---
name: k-drive
description: Google Drive operational memory — `Gdrive_X` mapped structure and `Gdrive` TODO baseline for discovery and retrieval workflows.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
allowed-tools: Bash(*), Read(*), Glob(*), rg(*)
---

# Tool Memory — Drive (k-drive)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Identity Snapshot

- **Matricule X:** `EX240207`

## Runtime Discipline (mandatory)

- Keep path references generalized with `$HOME`.
- Prefer targeted folder scans over broad full-drive traversals to avoid mount/index timeouts.
- On large mounted trees, start with iterative `ls` and then descend subtree by subtree; avoid root-level `rg --files` / deep glob sweeps unless the branch is already narrowed.
- For sensitive identity retrieval (matricule/certificates), prioritize known high-signal paths in `Gdrive_X`.
- For PDFs, try text extraction first; when the document is scanned, switch to page rendering plus visual inspection instead of assuming the field is unavailable.
- After each non-trivial drive investigation, update this file if the structure map or retrieval workflow changed.

## Drives

### Gdrive_X (mapped)

Source root: `$HOME/Gdrive_X/`

Known top-level structure discovered:
- `!ToPrint!`
- `CV_ATF`
- `Colab Notebooks`
- `Documents`
- `Google AI Studio`
- `Homelab`
- `Images`
- `OneDrive - Ecole Polytechnique`
- `Persos`
- `Work`
- `X`
- `agents-flat.md`
- `tmp`

High-signal academic subtree:
- `$HOME/Gdrive_X/X/`
  - `2A`
  - `Autres`
  - `Bourses`
  - `Dossier_Integration`
  - `FH`
  - `Généralités`
  - `K𝜋X`
  - `Modèles_Dossier_Concours`
  - `Prépas`
  - `TC`
  - `Templates`

High-signal official-doc subtree:
- `$HOME/Gdrive_X/OneDrive - Ecole Polytechnique/Documents/`
  - civil status, passport, CNI, residence permit, CPAM/CSS/Vitale, banking, housing, scholarships, transcripts, certificates, authored PDFs, notes

### Gdrive (TODO)

Source root: `$HOME/Gdrive/`

TODO:
- Map top-level tree.
- Identify high-signal academic/professional subfolders.
- Add retrieval shortcuts and risk notes (large mounts, timeout-prone branches).

## Retrieval Notes

- Preferred exploration order for deep identity work:
  1. `$HOME/Gdrive_X/OneDrive - Ecole Polytechnique/Documents/`
  2. `$HOME/Gdrive_X/X/K𝜋X/`
  3. Only then broader `Gdrive_X` branches if the two roots do not resolve the question
- Mount-safe traversal pattern:
  1. `ls` the current node
  2. descend only into promising subfolders
  3. use `find`/`rg` inside that narrowed subtree, not at the drive root
- PDF extraction pattern:
  1. `pdfinfo` for page count / metadata
  2. `pdftotext` when the PDF has a text layer
  3. `pdftoppm` + image inspection when `pdftotext` is empty or incomplete
- Matricule evidence (`EX240207`) was confirmed in:
  - `$HOME/Gdrive_X/X/K𝜋X/Dossier_Intégration/Attestation_Inscription_X_KAMDEM_Ivann2.pdf`
  - `$HOME/Gdrive_X/X/K𝜋X/TC/Administratifs/X---Certificat-de-scolarité-année-en-cours---FR_ I. KAMDEM POUOKAM.pdf`

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-drive/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-drive/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-18 | [CODEX] | v1.1.0 — Added mount-safe traversal rules, prioritized official-doc roots, and documented the scanned-PDF fallback workflow (`pdftotext` → `pdftoppm` + visual inspection). |
| 2026-04-13 | [CODEX] | v1.0.1 — Standardized insights discipline and autonomous maintenance hooks for this skill. |
| [SUMMARY] | — | v1.0.0 initial `k-drive` structure map + matricule notes; v0.0.0 skill initialized |
