# k-google — insights

## 2026-05-25 — [CURSOR] scripts

- **Pre-Fluid scripts:** `$HOME/.agents/skills/k-google/scripts/` — run `gws_inspect_contacts.py`, `gws_inspect_recent_mail.py`, `gws_auth_status.py` instead of `/tmp` one-offs; inventory in `scripts/README.md`.
- **People API path:** `gws people people connections list` (not `people connections list`).

## 2026-05-25 — [CURSOR]

- **Uniform stack:** route via `k-cloud-tools/references/cloud-hub.md`; file layer = `k-rclone` + `k-drive`.
- **`gws` installed** globally via `npm install -g @googleworkspace/cli` → `gws 0.22.5` at `$HOME/.npm-global/bin/gws`.
- **`gcloud` already present** — Google Cloud SDK 568.0.0 (`/usr/bin/gcloud`).
- **Auth not run in agent session** — KπX must run `gws auth setup` once before agents rely on Gmail/Drive API reads.
- **2026-05-25 pre-flight:** APIs enabled both projects (labs ~50, kpihx-489121 ~61); billing linked on kpihx-489121; config dirs `~/.config/gws/{kpihx-labs,kpihx}` + `FINALIZE.md`; `gws auth setup` labs blocked at manual OAuth Client ID in tmux `default` (Console Desktop client required).
- **Vault OAuth SOT:** `KpihX-Labs/Infra/Fluid/Google` — items **Google Fluid KpihX-Labs** + **Google Fluid KpihX** (`GOAUTH_CLIENT_ID` / `GOAUTH_CLIENT_SECRET`). Local `client_secret.json` per profile must match project number in client id (`747851806672` = labs, `287665785458` = kpihx).
- **Scope pitfall:** unverified OAuth app ~25 scopes max — use `gws auth login -s …`, not 52+ scope TUI selection.
- **Wrappers:** `gws-labs` / `gws-kpihx` in `$HOME/.config/gws/gws-profiles.zsh` (symlink `k-google/assets/gws-profiles.zsh`). Bare **`gws`** zsh function aliases **`gws-kpihx`** (2026-05-25).
- **Live check (2026-05-25):** `gws-kpihx` + `gws-labs` both return Drive API JSON; agents in non-interactive shells must call wrappers explicitly.
- **Labs API 403:** OAuth works but APIs need `roles/serviceusage.serviceUsageConsumer` on project `kpihx-labs` for the login Google account (`kpihx.labs@gmail.com`).
- **Profile note (2026-05-25):** `gws-kpihx` token inspected as **kapoivha@gmail.com** (15.9k messages, Drive shared X24 docs). Re-login `gws-labs` with `kpihx.labs@gmail.com` if Labs mailbox intended.
- **Split reminder:** `gcloud` ≠ Gmail; poly academic mail stays on **mail-mcp** (`k-mail`), not `gws`.
