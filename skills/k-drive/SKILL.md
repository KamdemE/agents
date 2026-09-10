---
name: k-drive
description: >
  Google Drive tree memory — Gdrive/Gdrive paths and retrieval rules on rclone mounts.
  Part of k-google file layer (k-rclone → k-drive). Load for folder semantics and discovery.
license: private
metadata:
  author: 
  version: "1.0.0"
allowed-tools: Bash(*), Read(*), Glob(*), rg(*)
---

#  — Drive (local tree memory)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

## Cloud hub

Google **file layer** on FUSE mounts: **`k-google`** → **`k-rclone`** → **this skill** · Workspace API → **`gws`** · map: `$HOME/.agents/skills/k-clis/references/cloud-hub.md`

> **Mount services:** The Gdrive mounts are managed by systemd user services sourced from `k-rclone/assets/`. See `k-rclone` for service management, troubleshooting, or adding new mounts.

## Runtime Discipline (mandatory)

- Keep path references generalized with `$HOME`.
- Prefer targeted folder scans over broad full-drive traversals to avoid mount/index timeouts.
- On large mounted trees, start with iterative `ls` and then descend subtree by subtree; avoid root-level `rg --files` / deep glob sweeps unless the branch is already narrowed.
- For sensitive identity retrieval (matricule/certificates), prioritize known high-signal paths in `Gdrive`.
- For PDFs, try text extraction first; when the document is scanned, switch to page rendering plus visual inspection instead of assuming the field is unavailable.
- Always use `tree -d -L 4` before creating any new directory to identify the most appropriate existing location; never create a root-level or redundant directory if a suitable parent exists.
- After each non-trivial drive investigation, update this file if the structure map or retrieval workflow changed.

## Drives

### Gdrive (mapped)

Source root: `$HOME/Gdrive/`

Current physical roots (post-migration, 2026-05-03):
- `.Trash-1000/` — Ubuntu trash exception; preserve at root.
- `Google AI Studio/` — application-managed exception; preserve at root.
- `/` — personal identity/admin/France/Cameroon/banks/health/family/academic personal records.
- `X/` — Ecole polytechnique material (`1A/FH`, `1A/TC`, `2A/P1`, `2A/P2`, `2A/P3`, `2A/Stage`, plus annual 2A blocks directly under `2A`).
- `ENSPY/` — ENSPY life/admin/student-life context; personal diplomas/transcripts remain centralized in `/Academic/`.
- `Pro/` — CV, certifications, internships/jobs organized by target.
- `Labs/` — labs/dev/homelab only.
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
- `$HOME/Gdrive//Cam/` (Cameroon identity records: passport, CNI, birth certificate, driving permit)
- `$HOME/Gdrive//Fr/` (France records: visa, residence permit, Navigo, CVEC, taxes, civil liability, health)
- `$HOME/Gdrive//Bank/` (bank-specific flat folders such as SG, BoursoBank, UBA)
- `$HOME/Gdrive//Family/` (family documents)

High-signal academic roots:
- `$HOME/Gdrive/X/` (Ecole polytechnique material)
- `$HOME/Gdrive/X/Integration/` (X integration and registration records)
- `$HOME/Gdrive/X/2A/` (current 2A: P1, P2, P3, Stage, PSC, Engineering Sustainability, LinguaSkill, Sport, Career Center)
- `$HOME/Gdrive//Academic/` (personal diplomas, transcripts, certificates)
- `$HOME/Gdrive//Scholarships/` (scholarship records)
- `$HOME/Gdrive/ENSPY/` (ENSPY context, not personal diploma centralization)

### Gdrive (TODO)

Source root: `$HOME/Gdrive/`

TODO:
- Map top-level tree.
- Identify high-signal academic/professional subfolders.
- Add retrieval shortcuts and risk notes (large mounts, timeout-prone branches).

## Retrieval Notes

- Preferred exploration order for deep identity/admin work:
  1. `$HOME/Gdrive//Cam/` or `$HOME/Gdrive//Fr/` depending on country context
  2. `$HOME/Gdrive//Bank/`, `$HOME/Gdrive//Fr/Health/`, `$HOME/Gdrive//Family/`, or `$HOME/Gdrive//Academic/` depending on semantic owner
  3. Only then broader `Gdrive` branches if the high-signal roots do not resolve the question
- Mount-safe traversal pattern:
  1. `ls` the current node
  2. descend only into promising subfolders
  3. use `find`/`rg` inside that narrowed subtree, not at the drive root
- PDF extraction pattern:
  1. `pdfinfo` for page count / metadata
  2. `pdftotext` when the PDF has a text layer
  3. `pdftoppm` + image inspection when `pdftotext` is empty or incomplete
- Symlink preflight:
  - Do not rely on filesystem symlinks inside `$HOME/Gdrive/` until the mount behavior changes.
  - Any photo-unification plan requiring symlinks must stop before migration or use another link mechanism.

## Runtime Memory Files

- `references/insights.md` — durable behavioral memory and extracted patterns

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-drive/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-drive/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

