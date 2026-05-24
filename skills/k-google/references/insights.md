# k-google — insights

## 2026-05-25 — [CURSOR]

- **Uniform stack:** route via `k-cloud-tools/references/cloud-hub.md`; file layer = `k-rclone` + `k-drive`.
- **`gws` installed** globally via `npm install -g @googleworkspace/cli` → `gws 0.22.5` at `$HOME/.npm-global/bin/gws`.
- **`gcloud` already present** — Google Cloud SDK 568.0.0 (`/usr/bin/gcloud`).
- **Auth not run in agent session** — KπX must run `gws auth setup` once before agents rely on Gmail/Drive API reads.
- **Split reminder:** `gcloud` ≠ Gmail; poly academic mail stays on **mail-mcp** (`k-mail`), not `gws`.
