# k-drive Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- For large rclone-mounted trees, broad root-level `rg --files` or unconstrained recursive scans are fragile; `ls` the node first, then descend only into narrowed branches.
- Treat `$HOME/Gdrive_X/OneDrive - Ecole Polytechnique/Documents/` and `$HOME/Gdrive_X/X/K𝜋X/` as the two primary roots for Ivann/KπX identity work; do not start with the whole drive.
- If `pdftotext` returns little or nothing on an identity/official PDF, assume the file may be scanned and switch immediately to `pdftoppm` + visual inspection.
- Keep provenance explicit between official docs, authored notes, and public web references when aggregating personal information from Drive.
- Handwritten or low-contrast score sheets can defeat OCR even after rasterization; when the rendered image is readable, trust direct visual inspection over noisy OCR output.
