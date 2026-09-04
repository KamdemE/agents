# k-google — insights

## 2026-09-04 — [LIVE] Gmail filter management lesson

- **Root cause of inbound email failure (2026-09-03):** 3 duplicate trash filters (`subject:(OUT-E2E OR E2E-)`) + 1 INBOX-strip filter (`to:@kpihx-labs.com` → remove UNREAD,INBOX) on kapoivha Gmail silently destroyed ALL forwarded CF mail.
- **Gmail query pitfall:** `E2E-` with trailing hyphen matches `E2E` broadly in Gmail search. `subject:(OUT-E2E OR E2E-)` trash-traps any mail with "E2E" in subject.
- **`removeLabelIds: ["INBOX"]`** strips mails from inbox but leaves them in All Mail — invisible but not deleted.
- **Idempotency:** `apply-inbound-antispam-filters.sh` created 3 duplicate trash filters on repeated runs. Always `list` → check duplicate → `create` (not blindly `create`).
- **Fix applied:** deleted 3 trash E2E filters + 1 INBOX-strip filter via `gws-kpihx gmail users settings filters delete --params '{"userId":"me","id":"<ID>"}'`.
- **Diagnostics:** `wrangler tail` proved CF forwarded successfully (`forward ok: kapoivha@gmail.com`). The problem was Gmail-side, not Cloudflare.
- **Current filters kapoivha (19):** 3 anti-spam (to:@kpihx-labs.com → remove SPAM) + 16 newsletter filters (remove UNREAD+INBOX for ticktick/linkedin/github/deliveroo/etc).
- **Current filters Labs (3):** 3 anti-spam (to:@kpihx-labs.com → remove SPAM).

## 2026-09-03 — [LIVE] gws cleanup

- **Purged:** `~/.config/gws/gws-kpihx.env` + `gws-labs.env` (legacy, unused — wrappers did everything).
- **Moved:** `FINALIZE.md` → `k-google/references/gws-setup.md` (updated content, removed .env refs).
- **Moved:** `k-google/assets/gws-profiles.zsh` → `k-google/scripts/gws-profiles.zsh`.
- **Deleted symlink:** `~/.config/gws/gws-profiles.zsh` (was → `k-google/assets/gws-profiles.zsh`). No more symlink in `~/.config/gws/`.
- **Removed from links.jsonc:** gws-profiles entry deleted (no symlink to manage).
- **Updated all 8 kshrc:** `[ -f "$HOME/.agents/skills/k-google/scripts/gws-profiles.zsh" ] && source "$HOME/.agents/skills/k-google/scripts/gws-profiles.zsh"` — direct path, no symlink indirection.

## 2026-09-03 — [LIVE] gcloud audit + cleanup

- **gcloud state:** `google-cloud-cli` v568.0.0-0 (dpkg, apt source **disabled** after Ubuntu 26.04 migration). Binary `/usr/bin/gcloud`. Auth: `kapoivha@gmail.com` (active), `kpihx.labs@gmail.com` (credentialed, secondary).
- **ADC fixed:** `$HOME/.config/gcloud/application_default_credentials.json` → quota project `kpihx-489121`. Previous state: quota project was `kpihx-labs` with `kpihx.labs@gmail.com` credentials (set accidentally during `kpihx.labs@gmail.com` check).
- **Service accounts deleted:** `ais-gemini-key-32b3c763b7ec4cd` (OpenRouter, kpihx-489121), `ais-gemini-key-4ed8ce98a060435` (Test, kpihx-labs).
- **Service accounts remaining:** `firebase-adminsdk-fbsvc` (kpihx-489121), `ais-gemini-key-3af5c5890b784f3` Default (kpihx-489121), `747851806672-compute` (kpihx-labs).
- **kpihx.labs@gmail.com:** `serviceusage.serviceUsageConsumer` on kpihx-labs only. Cannot manage IAM, create SAs, or access kpihx-489121.
- **Both projects billing linked:** `019864-FC909B-AB04B4` (open). 2 other billing accounts closed (Revolut Test, Mon compte de facturation).

## 2026-05-25 — [CURSOR] kapoivha Gmail hygiene

- **Deep cleanup executed:** INBOX/UNREAD → 0 via `gws_gmail_deep_cleanup.py` + final sweeps; ~12k messages archived, ~1.2k trashed then **emptied in Gmail UI** (API `batchDelete` lacks scope on current OAuth token).
- **Long-term:** 18+ Gmail filters (TickTick, LinkedIn, GitHub, Homelab `@kpihx-labs.com`, promos, E2E→trash). Labels under `KpihX/*`.
- **SOT:** `references/kapoivha-gmail-hygiene.md` — re-run script is idempotent.
- **TickTick email bomb:** disable in TickTick account settings (web requires login); filter already skips inbox for new mail.

## 2026-05-25 — [CURSOR] scripts

- **Pre-Fluid scripts:** `$HOME/.agents/skills/k-google/scripts/` — run `gws_inspect_contacts.py`, `gws_inspect_recent_mail.py`, `gws_auth_status.py` instead of `/tmp` one-offs; inventory in `scripts/README.md`.
- **People API path:** `gws people people connections list` (not `people connections list`).

## 2026-05-25 — [CURSOR]

- **Uniform stack:** route via `k-clis/references/cloud-hub.md`; file layer = `k-rclone` + `k-drive`.
- **`gws` installed** globally via `npm install -g @googleworkspace/cli` → `gws 0.22.5` at `$HOME/.npm-global/bin/gws`.
- **`gcloud` already present** — Google Cloud SDK 568.0.0 (`/usr/bin/gcloud`).
- **Auth not run in agent session** — KπX must run `gws auth setup` once before agents rely on Gmail/Drive API reads.
- **2026-05-25 pre-flight:** APIs enabled both projects (labs ~50, kpihx-489121 ~61); billing linked on kpihx-489121; config dirs `~/.config/gws/{kpihx-labs,kpihx}` + `FINALIZE.md`; `gws auth setup` labs blocked at manual OAuth Client ID in tmux `default` (Console Desktop client required).
- **Vault OAuth SOT:** `KpihX-Labs/Infra/Fluid/Google` — items **Google Fluid KpihX-Labs** + **Google Fluid KpihX** (`GOAUTH_CLIENT_ID` / `GOAUTH_CLIENT_SECRET`). Local `client_secret.json` per profile must match project number in client id (`747851806672` = labs, `287665785458` = kpihx).
- **Scope pitfall:** unverified OAuth app ~25 scopes max — use `gws auth login -s …`, not 52+ scope TUI selection.
- **Wrappers:** `gws-labs` / `gws-kpihx` in `k-google/scripts/gws-profiles.sh` (sourced directly by `~/.kshrc`). Bare **`gws`** shell function aliases **`gws-kpihx`** (2026-05-25, renamed `.zsh`→`.sh` 2026-09-04).
- **Live check (2026-05-25):** `gws-kpihx` + `gws-labs` both return Drive API JSON; agents in non-interactive shells must call wrappers explicitly.
- **Labs API 403:** OAuth works but APIs need `roles/serviceusage.serviceUsageConsumer` on project `kpihx-labs` for the login Google account (`kpihx.labs@gmail.com`).
- **Profile note (2026-05-25):** `gws-kpihx` token inspected as **kapoivha@gmail.com** (15.9k messages, Drive shared X24 docs). Re-login `gws-labs` with `kpihx.labs@gmail.com` if Labs mailbox intended.
- **Split reminder:** `gcloud` ≠ Gmail; poly academic mail stays on **mail-mcp** (`k-mail`), not `gws`.
