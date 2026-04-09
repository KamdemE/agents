---
name: k-drive
description: Google Drive operational memory — `Gdrive_X` mapped structure and `Gdrive` TODO baseline for discovery and retrieval workflows.
license: private
metadata:
  author: KpihX
  version: "1.0.0"
allowed-tools: Bash(*), Read(*), Glob(*), rg(*)
---

# Tool Memory — Drive (k-drive)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Identity Snapshot

- **Matricule X:** `EX240207`

## Runtime Discipline (mandatory)

- Keep path references generalized with `$HOME`.
- Prefer targeted folder scans over broad full-drive traversals to avoid mount/index timeouts.
- For sensitive identity retrieval (matricule/certificates), prioritize known high-signal paths in `Gdrive_X`.
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

### Gdrive (TODO)

Source root: `$HOME/Gdrive/`

TODO:
- Map top-level tree.
- Identify high-signal academic/professional subfolders.
- Add retrieval shortcuts and risk notes (large mounts, timeout-prone branches).

## Retrieval Notes

- Matricule evidence (`EX240207`) was confirmed in:
  - `$HOME/Gdrive_X/X/K𝜋X/Dossier_Intégration/Attestation_Inscription_X_KAMDEM_Ivann2.pdf`
  - `$HOME/Gdrive_X/X/K𝜋X/TC/Administratifs/X---Certificat-de-scolarité-année-en-cours---FR_ I. KAMDEM POUOKAM.pdf`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-09 | [CURSOR] | v1.0.0 — Created `k-drive` with initial `Gdrive_X` structure map, `Gdrive` TODO section, matricule snapshot, and retrieval notes. |
| [SUMMARY] | — | v0.0.0 skill initialized |
