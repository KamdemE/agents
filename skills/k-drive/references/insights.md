# k-drive Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- For large rclone-mounted trees, broad root-level `rg --files` or unconstrained recursive scans are fragile; `ls` the node first, then descend only into narrowed branches.
- Treat `$HOME/Gdrive/Identity/` as the primary root for identity/admin work and `$HOME/Gdrive/Academic/X/K𝜋X/` as a secondary X-era evidence root; do not start with the whole drive.
- If `pdftotext` returns little or nothing on an identity/official PDF, assume the file may be scanned and switch immediately to `pdftoppm` + visual inspection.
- Keep provenance explicit between official docs, authored notes, and public web references when aggregating personal information from Drive.
- Handwritten or low-contrast score sheets can defeat OCR even after rasterization; when the rendered image is readable, trust direct visual inspection over noisy OCR output.
- For full-drive reorganization work, separate three maps explicitly: current physical state, target taxonomy, and migration diff. Merging them into one note creates architectural ambiguity and bad execution plans.
- Before trusting a Drive skill map, verify whether it describes the physical mount or only the intended future structure; this drift happened on `Gdrive`.
- For bank-related reclassification, never trust a generic `RIB/` folder name alone; OCR the actual document and identify the bank from the BIC or bank code before assigning it to an institution branch.
- When a course folder mixes period-specific and non-period-specific material, split only the proven `P1`/`P2`/`P3` leaves and route the unresolved remainder into an explicit `Period_To_Confirm/` node instead of guessing.
- In target tree design, avoid folders that exist only for a single file or a single child folder; collapse them into the parent until a second real sibling appears.
- Current `$HOME/Gdrive/` rclone mount does not support the requested filesystem symlink workflow: `ln -s` returned `Input/output error` during the 2026-05-03 preflight. Stop any symlink-dependent migration until an alternate link mechanism is chosen.
- For large `Gdrive` reorganizations, FUSE `shutil.move` is not a viable executor: it can drop into uninterruptible FUSE waits and progresses too slowly. Use a validated manifest, then Drive API `files.update(addParents/removeParents/name)` with conservative backoff; reserve `rclone moveto` for targeted fallback and residual root moves.
- Final anti-singleton flattening changes some planned target paths after migration. Validate the real Drive state by scanning paths after flattening, not by expecting every pre-flatten plan target to still exist verbatim.
- A clean structural validation is not enough after a generated migration: explicitly scan final main roots for visible `_DUP*`, `..`, `.pdf.pdf`, and browser-download suffix residues. Move duplicate suffix residues to duplicate review and only keep clean canonical names in main roots.
- **CSC43042EP hand-ins:** keep the existing naming pattern `PC1_CSC43042EP_tdN_..._handin` under `X/2A/P3/Data_Analysis_Python/` so course ZIPs like `CSC43042EP-td8-1-handin.zip` remain trivially discoverable next to `PC1_CSC43042EP_td1_1_handin`.
- **`/Fr/Health/` naming (2026-05-24):** drop redundant `Health_FR_` prefix — parent folders already encode `Fr` + `Health`. Pattern: `{Type}_{Detail}_{YYYY-MM-DD?}_KAMDEM_Ivann.ext`. Inside semantic subfolders (`GHNE/`, etc.), drop repeated domain tokens from filenames (e.g. `GHNE/Resultat_Medical_2024-09-06_…`, not `Resultat_Medical_GHNE_…`).
- **`/Fr/Health/` topology:** flat root is forbidden once ≥2 siblings exist — use `Assurance_Maladie/`, `Certificates/`, `Dental/`, `GHNE/`, plus `_Review/` for orphan metadata (CamScanner `.collection` with missing Android JPEG paths).
- **Lebara mobile (`/Phone_Lebara/`):** eSIM activation PDFs, SIM cards, and help docs live together (e.g. `Sim_Lebara.pdf`, `eSIM_Lebara_<orderRef>_KAMDEM_Ivann_YYYYMMDD.pdf`). Do not store telecom credentials in skills or chat — file on Drive only.
- **Lebara eSIM canon (2026-05-26):** Active QR PDF SOT = `/Phone_Lebara/eSIM_Lebara_ML045066180_KAMDEM_Ivann_20260525.pdf` (hash `b76f1627…`). Agent index = `$HOME/Downloads/lebara-esim/CANONICAL-PDF.md`. Cancelled order PDFs stay off Drive main folder.
- **“Attestation sur l’honneur” (non revenu):** if it is CAF/`Fr` evidence rather than bourse dossier material, prefer a dedicated `/Fr/...` subtree; `Scholarships/Bourse_Eiffel/` is reasonable when the attestation is part of an aid/scholarship file set.
