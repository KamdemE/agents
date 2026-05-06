# k-drive Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- For large rclone-mounted trees, broad root-level `rg --files` or unconstrained recursive scans are fragile; `ls` the node first, then descend only into narrowed branches.
- Treat `$HOME/Gdrive_X/Identity/` as the primary root for identity/admin work and `$HOME/Gdrive_X/Academic/X/K𝜋X/` as a secondary X-era evidence root; do not start with the whole drive.
- If `pdftotext` returns little or nothing on an identity/official PDF, assume the file may be scanned and switch immediately to `pdftoppm` + visual inspection.
- Keep provenance explicit between official docs, authored notes, and public web references when aggregating personal information from Drive.
- Handwritten or low-contrast score sheets can defeat OCR even after rasterization; when the rendered image is readable, trust direct visual inspection over noisy OCR output.
- For full-drive reorganization work, separate three maps explicitly: current physical state, target taxonomy, and migration diff. Merging them into one note creates architectural ambiguity and bad execution plans.
- Before trusting a Drive skill map, verify whether it describes the physical mount or only the intended future structure; this drift happened on `Gdrive_X`.
- For bank-related reclassification, never trust a generic `RIB/` folder name alone; OCR the actual document and identify the bank from the BIC or bank code before assigning it to an institution branch.
- When a course folder mixes period-specific and non-period-specific material, split only the proven `P1`/`P2`/`P3` leaves and route the unresolved remainder into an explicit `Period_To_Confirm/` node instead of guessing.
- In target tree design, avoid folders that exist only for a single file or a single child folder; collapse them into the parent until a second real sibling appears.
- Current `$HOME/Gdrive_X/` rclone mount does not support the requested filesystem symlink workflow: `ln -s` returned `Input/output error` during the 2026-05-03 preflight. Stop any symlink-dependent migration until an alternate link mechanism is chosen.
- For large `Gdrive_X` reorganizations, FUSE `shutil.move` is not a viable executor: it can drop into uninterruptible FUSE waits and progresses too slowly. Use a validated manifest, then Drive API `files.update(addParents/removeParents/name)` with conservative backoff; reserve `rclone moveto` for targeted fallback and residual root moves.
- Final anti-singleton flattening changes some planned target paths after migration. Validate the real Drive state by scanning paths after flattening, not by expecting every pre-flatten plan target to still exist verbatim.
- A clean structural validation is not enough after a generated migration: explicitly scan final main roots for visible `_DUP*`, `..`, `.pdf.pdf`, and browser-download suffix residues. Move duplicate suffix residues to duplicate review and only keep clean canonical names in main roots.
