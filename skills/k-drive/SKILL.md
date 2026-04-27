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

Sovereign 01-05 Structure:
- `01_Identity/`: Legal, Professional, Admin, Vault.
- `02_Academic/`: X, ENSPY, Prepa, History, Subjects.
- `03_Labs/`: Homelab, AI, Development, Knowledge.
- `04_Library/`: Books, Spirituality, Tech, Science, Travel, Notes.
- `05_Media/`: Photos, Videos, Recordings.

High-signal identity roots:
- `$HOME/Gdrive_X/01_Identity/Legal/` (Passport, ID, Birth Cert)
- `$HOME/Gdrive_X/01_Identity/Vault/` (Recovery codes, Secrets)

High-signal academic roots:
- `$HOME/Gdrive_X/02_Academic/X/` (Current 2A studies)
- `$HOME/Gdrive_X/02_Academic/History/Diplomas/` (Historical transcripts/certificates)

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
| 2026-04-26 | [ANTIGRAVITY] | v1.2.0 — Implemented Sovereign 01-05 structure; cleaned Gdrive_X root, deduplicated media (ongoing), and consolidated Identity/Academic folders. |
| 2026-04-18 | [CODEX] | v1.1.0 — Added mount-safe traversal rules, prioritized official-doc roots, and documented the scanned-PDF fallback workflow (`pdftotext` → `pdftoppm` + visual inspection). |
| [SUMMARY] | — | v1.0.1 insights discipline; v1.0.0 initial map; v0.0.0 skill initialized |
