---
name: k-drive
description: Google Drive operational memory — `Gdrive_X` mapped structure and `Gdrive` TODO baseline for discovery and retrieval workflows.
license: private
metadata:
  author: KpihX
  version: "1.2.6"
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

Current physical roots (post-migration, 2026-05-03):
- `.Trash-1000/` — Ubuntu trash exception; preserve at root.
- `Google AI Studio/` — application-managed exception; preserve at root.
- `KpihX/` — personal identity/admin/France/Cameroon/banks/health/family/academic personal records.
- `X/` — Ecole polytechnique material (`1A/FH`, `1A/TC`, `2A/P1`, `2A/P2`, `2A/P3`, `2A/Stage`, plus annual 2A blocks directly under `2A`).
- `ENSPY/` — ENSPY life/admin/student-life context; personal diplomas/transcripts remain centralized in `KpihX/Academic/`.
- `Pro/` — CV, certifications, internships/jobs organized by target.
- `KpihX-Labs/` — labs/dev/homelab only.
- `Photos/` — souvenir/photo collections physically separated from document records.
- `ToPrint/` — root-level print queue.
- `_Purge_Review_2026-05-03/` and `_Review_Duplicates_2026-05-03/` — quarantine/review roots; never delete contents without explicit review.

Historical planning documents:
- `$HOME/.agents/skills/k-drive/references/gdrive_x-state-2026-05-02.md`
- `$HOME/.agents/skills/k-drive/references/gdrive_x-reorg-proposal-2026-05-02.md`
- `$HOME/.agents/skills/k-drive/references/gdrive_x-target-tree-2026-05-02.md`

Execution artifacts:
- `$HOME/Work/Others/gdrive_x_reorg_2026-05-03/manifest.jsonl`
- `$HOME/Work/Others/gdrive_x_reorg_2026-05-03/plan.jsonl`
- `$HOME/Work/Others/gdrive_x_reorg_2026-05-03/gdrive_x_drive_api.py`
- `$HOME/Work/Others/gdrive_x_reorg_2026-05-03/gdrive_x_residue_cleanup_api.py`

High-signal identity roots:
- `$HOME/Gdrive_X/KpihX/Cam/` (Cameroon identity records: passport, CNI, birth certificate, driving permit)
- `$HOME/Gdrive_X/KpihX/Fr/` (France records: visa, residence permit, Navigo, CVEC, taxes, civil liability, health)
- `$HOME/Gdrive_X/KpihX/Bank/` (bank-specific flat folders such as SG, BoursoBank, UBA)
- `$HOME/Gdrive_X/KpihX/Family/` (family documents)

High-signal academic roots:
- `$HOME/Gdrive_X/X/` (Ecole polytechnique material)
- `$HOME/Gdrive_X/X/Integration/` (X integration and registration records)
- `$HOME/Gdrive_X/X/2A/` (current 2A: P1, P2, P3, Stage, PSC, Engineering Sustainability, LinguaSkill, Sport, Career Center)
- `$HOME/Gdrive_X/KpihX/Academic/` (personal diplomas, transcripts, certificates)
- `$HOME/Gdrive_X/KpihX/Scholarships/` (scholarship records)
- `$HOME/Gdrive_X/ENSPY/` (ENSPY context, not personal diploma centralization)

### Gdrive (TODO)

Source root: `$HOME/Gdrive/`

TODO:
- Map top-level tree.
- Identify high-signal academic/professional subfolders.
- Add retrieval shortcuts and risk notes (large mounts, timeout-prone branches).

## Retrieval Notes

- Preferred exploration order for deep identity/admin work:
  1. `$HOME/Gdrive_X/KpihX/Cam/` or `$HOME/Gdrive_X/KpihX/Fr/` depending on country context
  2. `$HOME/Gdrive_X/KpihX/Bank/`, `$HOME/Gdrive_X/KpihX/Fr/Health/`, `$HOME/Gdrive_X/KpihX/Family/`, or `$HOME/Gdrive_X/KpihX/Academic/` depending on semantic owner
  3. Only then broader `Gdrive_X` branches if the high-signal roots do not resolve the question
- Mount-safe traversal pattern:
  1. `ls` the current node
  2. descend only into promising subfolders
  3. use `find`/`rg` inside that narrowed subtree, not at the drive root
- PDF extraction pattern:
  1. `pdfinfo` for page count / metadata
  2. `pdftotext` when the PDF has a text layer
  3. `pdftoppm` + image inspection when `pdftotext` is empty or incomplete
- Symlink preflight:
  - Do not rely on filesystem symlinks inside `$HOME/Gdrive_X/` until the mount behavior changes.
  - 2026-05-03 preflight `ln -s` inside `$HOME/Gdrive_X/` failed with `Input/output error`; any photo-unification plan requiring symlinks must stop before migration or use another link mechanism.
- Matricule evidence (`EX240207`) was confirmed in:
  - `$HOME/Gdrive_X/X/Integration/Attestation_Inscription_X_KAMDEM_Ivann2.pdf`
  - `$HOME/Gdrive_X/X/1A/TC/Administratifs/X_Certificat_de_scolarite_annee_en_cours_FR_I. kamdem pouokam.pdf`

## Runtime Memory Files

- `references/log.md` — historical changelog entries and session log archive
- `references/insights.md` — durable behavioral memory and extracted patterns

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-drive/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-drive/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-04 | [ANTIGRAVITY] | v1.2.6 — Recorded the move of `LinguaSkill/` from `X/2A/` to `KpihX/Academic/` for personal record centralization. |
| 2026-05-03 | [CODEX] | v1.2.5 — Updated the `Gdrive_X` physical map after the completed migration and residual duplicate cleanup. |
| [SUMMARY] | — | v1.2.4 symlink preflight failure; v1.2.3 target tree-view document registration; v1.2.2 high-signal root correction; v1.2.1 physical map correction + linked state/proposal docs; v1.2.0 Sovereign 01-05 target model; v1.1.0 scanned-PDF fallback + mount-safe traversal; v1.0.1 insights discipline; v1.0.0 initial map; v0.0.0 skill initialized |
