---
name: k-google
description: >
  Google stack — gcloud (GCP container) and gws (Workspace content). Drive files via
  k-rclone/k-drive. Load before Google Cloud or Workspace tasks.
license: private
metadata:
  author: 
  version: "1.0.0"
  scope: operations
allowed-tools: Bash(gws:*), Bash(gcloud:*), Bash(rclone:*)
---

#  — Google (Cloud + Workspace)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

## Cloud hub

Registry map: `$HOME/.agents/skills/k-clis/references/cloud-hub.md` · load **`k-clis`** when routing across providers.

## Two planes (mandatory)

| Plane | Tool | Scope |
|-------|------|--------|
| **Container** | `gcloud` | GCP projects, IAM, Compute, GKE, buckets, API enablement |
| **Content** | `gws` / `gws-primary` / `gws-labs` | Gmail, Drive API, Calendar, Sheets, Docs (Discovery CLI) |
| **Local files** | `rclone` | Mounted trees — **`k-rclone`**, semantics — **`k-drive`** |

**Rule:** infra → `gcloud`. User mail/calendar/docs API → `gws`. Bulk file browse → mounts, not API alone.

## Tools (verify with `!<cmd>`)

| Binary | Runbook |
|--------|---------|
| `gcloud` | Google Cloud SDK — `gcloud version` |
| `gws` | `$HOME/Work/techskills/gws-cli.md` — `npm install -g @googleworkspace/cli` |
| `rclone` | `$HOME/.agents/skills/k-rclone/SKILL.md` |

## GCP gcloud — installed state

**Version:** `google-cloud-cli` **568.0.0-0** (dpkg direct, apt source **disabled** after Ubuntu 26.04 migration)  
**Binary:** `/usr/bin/gcloud` → `/usr/lib/google-cloud-sdk/bin/gcloud`  
**Config dir:** `$HOME/.config/gcloud/`  
**Auth:** `<primary@gmail.com>` (active), `<labs@gmail.com>` (credentialed, secondary)  
**ADC:** `$HOME/.config/gcloud/application_default_credentials.json` → quota project `kpihx-489121`

## GCP projects (two profiles)

| Profile | `project_id` | Number | Billing | Lifecycle |
|---------|--------------|--------|---------|-----------|
| **** | `kpihx-489121` | `287665785458` | ✅ linked (open) | ACTIVE |
| **Labs** | `<github-user>` | `747851806672` | ✅ linked (open) | ACTIVE |

**IAM — `<primary@gmail.com>`:** owner on both projects.  
**IAM — `<labs@gmail.com>`:** `serviceusage.serviceUsageConsumer` on `<github-user>` only (read-only quota consumer).

### Service accounts (post-cleanup 2026-09-03)

| Project | Email | Display Name |
|--------|-------|-------------|
| kpihx-489121 | `firebase-adminsdk-fbsvc@kpihx-489121.iam.gserviceaccount.com` | firebase-adminsdk |
| kpihx-489121 | `ais-gemini-key-3af5c5890b784f3@287665785458.iam.gserviceaccount.com` | Default |
| <github-user> | `747851806672-compute@developer.gserviceaccount.com` | Compute Engine default |

**Deleted 2026-09-03:** `ais-gemini-key-32b3c763b7ec4cd` (OpenRouter, kpihx-489121), `ais-gemini-key-4ed8ce98a060435` (Test, <github-user>).

### GWS profiles (Workspace content)

| Command | Profile | `project_id` | Config dir | Login account |
|---------|---------|--------------|------------|---------------|
| **`gws`** | **default = ** (alias → `gws-primary`) | `kpihx-489121` | `$HOME/.config/gws/kpihx/` | `<primary@gmail.com>` |
| **`gws-primary`** |  personal | `kpihx-489121` | `$HOME/.config/gws/kpihx/` | `<primary@gmail.com>` |
| **`gws-labs`** | Labs homelab | `<github-user>` | `$HOME/.config/gws/<github-user>/` | `<labs@gmail.com>` |

**CLI wrappers (mandatory in interactive zsh):** sourced from `k-google/scripts/gws-profiles.sh` via `$HOME/.kshrc` (direct path, no symlink).

**Rule:** always use a profile wrapper (`gws-primary` / `gws-labs`) in agents/scripts — never bare npm `gws` without `GOOGLE_WORKSPACE_*` env (non-interactive shells). In interactive zsh, bare `gws` is safe (forwards to `gws-primary`); `gws-labs` targets the homelab project.

## OAuth secrets — Vaultwarden (source of truth)

**Collection path (Vaultwarden UI):** `Labs` → `Infra` → `Fluid` → `Google`

| Vault item | GCP project | Custom fields |
|------------|-------------|---------------|
| **Google Fluid Labs** | `<github-user>` | `GOAUTH_CLIENT_ID`, `GOAUTH_CLIENT_SECRET` |
| **Google Fluid ** | `kpihx-489121` | `GOAUTH_CLIENT_ID`, `GOAUTH_CLIENT_SECRET` |

- **Agents:** secrets are no longer injected via `bw`/`k-bw` (purged 2026-08-14) — read credentials from local OAuth/client config only; never print secret values in chat.
- **Runtime copy for `gws`:** `$HOME/.config/gws/<profile>/client_secret.json` (mode `600`). Refresh from Vault after Console rotation; OAuth client must match project (`287665785458-*` = , `747851806672-*` = Labs).
- **Console test users:** both projects — add every account used in `gws auth login` (see `references/gws-setup.md`).
- **Labs API quota IAM:** `user:<labs@gmail.com>` has `roles/serviceusage.serviceUsageConsumer` on `<github-user>` (granted 2026-05-25 via `gcloud`). This is the minimum role for API consumption — no IAM management, no service account creation.

Auth: `gws auth setup` / `gws auth login` — **-owned** (browser).

### Full login procedure (all scopes, validated 2026-09-04)

Both profiles use the same login flow — one command per profile:

```bash
#  personal (<primary@gmail.com>)
gws-primary auth login -s gmail,drive,calendar,contacts,sheets,docs,slides,tasks,people,chat,forms,keep,meet,classroom

# Labs homelab (<labs@gmail.com>)
gws-labs auth login -s gmail,drive,calendar,contacts,sheets,docs,slides,tasks,people,chat,forms,keep,meet,classroom
```

Expected output — full scope list + browser URL:

```
⚠️  Warning: 31 scopes selected. Unverified OAuth apps may fail with this many scopes.
Open this URL in your browser to authenticate:

  https://accounts.google.com/o/oauth2/auth?scope=...&client_id=287665785458-bdt1p5n4mt6tiakukvlpllkuq8sgaa98.apps.googleusercontent.com&access_type=offline...

Using keyring backend: keyring
Authentication successful. Encrypted credentials saved.
```

The 31 scopes map to: Gmail (readonly, compose, insert, modify, send, labels, settings.basic, settings.sharing, addons ×4), Calendar, Drive, Docs, Sheets, Slides, Tasks, Contacts, Chat (delete, messages, customemojis, memberships, spaces, users.readstate, users.spacesettings, users.availability, users.sections), Forms, Cloud Platform, openid + userinfo.email + userinfo.profile.

**Note:** `keep`, `meet`, `classroom` in the `-s` list are **accepted but not added** — the gws CLI has no discovery for these services; the returned scope set stays at 31. Keep has no public API.

**Read-only default** until  approves send/upload.

```bash
gws-primary gmail users messages list --params '{"userId":"me","maxResults":5}'
gws-labs drive files list --params '{"pageSize":10}'
# bare `gws` == gws-primary in interactive zsh only
```

## Mail exception

| Account | Tool | Skill |
|---------|------|-------|
| Poly Zimbra | mail-proxy (ex-`mail-mcp`) | **`k-mail`** (canonical) |
| Gmail (`kapoivha`, Labs) | `gws-primary` / `gws-labs` | **`k-mail`** + inbound E2E → **`k-cloudflare/references/inbound-email-e2e.md`** · kapoivha hygiene → **`references/gmail-hygiene.md`** |

**GWS agent shells:** use profile wrappers or `$HOME/.npm-global/bin/gws` with `GOOGLE_WORKSPACE_*` env; strip `Using keyring…` line before `jq` (`awk '/^\{/{p=1} p'`). Send: `--params '{"userId":"me"}'` + `--json '{"raw":…}'`.

## Workspace state dump (`scripts/gws_dump_state.sh`)

Dumps the complete Google Workspace state into `assets/dumps-<profile>/*.json` — Gmail (profile, labels, messages, send-as, filters, forwarding, vacation, POP, IMAP, delegates, auto-forwarding), Calendar (list + owned), Drive (files + about/quota), Tasks, Sheets/Docs/Slides/Forms/Keep (via Drive mimeType), **Contacts (People API)**.

```bash
#  personal (kapoivha) → assets/dumps-kpihx/
$HOME/.agents/skills/k-google/scripts/gws_dump_state.sh kpihx

# Labs homelab (kpihx.labs) → assets/dumps-labs/
$HOME/.agents/skills/k-google/scripts/gws_dump_state.sh labs
```

**Contacts:** `gws people people connections list` — native People API subcommand (≠ `people connections list`, which fails). Dumps up to 200 connections per page (pageSize=200).

**Scripting note:** `gws-primary` and `gws-labs` are **shell** functions (`gws-profiles.sh`) — not available in a bash subshell. The script sets `GOOGLE_WORKSPACE_CLI_CONFIG_DIR` + `GOOGLE_WORKSPACE_PROJECT_ID` itself (kpihx default, `labs` arg for the homelab profile) and calls the bare `gws` binary.

**Known dump limitations (validated 2026-09-04):**
- `gmail-delegates` → 403 `Access restricted to service accounts...`: Gmail delegation listing is restricted to service accounts with domain-wide delegation — **not possible on a personal Gmail account** kapoivha.
- `gmail-forwarding-addresses` → empty (EXIT 0, no forwarding address configured) — legitimate, not an error.
- Gmail settings subcommands are **camelCase** (`sendAs list`, `getPop`, `getImap`, `getVacation`, `getAutoForwarding`, `forwardingAddresses list`) — not snake_case.
- Do not mix `2>&1` with `--output json`: the stderr message pollutes the JSON (parse "Extra data"). The script pipes stderr separately.

## Gmail filter & label reference (`k-mail` canonical)

> 📌 **Canonical reference:** See **`k-mail/references/gmail-folders-filters.md`** for the full inventory of active Gmail nested labels (`Labs/*`), filters, and automated inspection/setup scripts (`inspect_gmail_filters_labels.sh`, `setup_alias_folders_filters.sh`).

## Gmail filter management (`gws` CLI)

**⚠️ Gmail filters can silently destroy forwarded mail.** This was the root cause of the 2026-09-03 inbound email failure: 3 trash filters + 1 INBOX-strip filter on kapoivha prevented all CF-forwarded mails from appearing.

### Commands (camelCase subcommands)

| Command | Purpose |
|---|---|
| `gws <profile> gmail users settings filters list --params '{"userId":"me"}'` | List all filters |
| `gws <profile> gmail users settings filters get --params '{"userId":"me","id":"<ID>"}'` | Get one filter |
| `gws <profile> gmail users settings filters create --params '{"userId":"me"}' --json '{...}'` | Create a filter |
| `gws <profile> gmail users settings filters delete --params '{"userId":"me","id":"<ID>"}'` | Delete a filter |

**Profile wrappers:** `gws-primary` (<primary@gmail.com>), `gws-labs` (<labs@gmail.com>).

### Filter query syntax pitfalls

- `subject:(E2E-)` → matches **ALL mails containing "E2E"** (trailing `-` = literal or empty negation → broad match)
- `subject:(OUT-E2E OR E2E-)` → same trap: matches any mail with "E2E" in subject
- **Correct pattern for exact prefix:** `subject:E2E test` (no parentheses, no trailing `-`)

### Dangerous filter patterns to audit

| Pattern | Risk | Example |
|---|---|---|
| `removeLabelIds: ["INBOX"]` | Mails invisible in inbox but present in All Mail | `to:@<yourdomain.com>` |
| `addLabelIds: ["TRASH"]` | Mails immediately trashed | `subject:(OUT-E2E OR E2E-)` |
| `from:X` + `remove INBOX,SPAM` | OK if intentional newsletter filtering | `from:linkedin.com` |

### Idempotency guard

Before creating a filter, **list existing filters and check for duplicates**. The `apply-inbound-antispam-filters.sh` script ran multiple times and created 3 duplicate trash filters. Use `get` or `list` before `create`.

## YouTube Data API v3

**Project:** `<github-user>` · **Profile:** `gws-labs` · **Runbook:** **`k-media/references/youtube-<github-user>.md`** · **Bootstrap:** `k-media/scripts/youtube_gcp_bootstrap.sh`.  
Agent: `gcloud` + OAuth file checks only — uploads/consent → **`k-media`** (not duplicated here).

## MCP / future

| Now | Optional later |
|-----|----------------|
| CLI: `gws`, `gcloud`, shell from agents | `workspace-mcp` (PyPI) |
| | Unified CLI+MCP contract → `references/mcp-cli-vision.md` |

## Pre-Fluid scripts (until level-up)

**Until** the Fluid **ts-proxy**-style bridge (see `references/mcp-cli-vision.md`), agents **must prefer** bundled scripts under `$HOME/.agents/skills/k-google/scripts/` instead of rewriting one-off Python/shell glue in `/tmp`.

| Script | When to run |
|--------|-------------|
| `gws_auth_status.py` | Before blaming auth — checks `client_secret.json` / `credentials.json` per profile |
| `gws_inspect_contacts.py` | People connections (`--filter email\|kamdem\|poly`, `--profile kpihx\|labs\|both`) |
| `gws_inspect_recent_mail.py` | Recent Gmail metadata (`--count`, `--json`) |

**Inventory + examples:** `scripts/AGENTS.md` (same workstream as any new script).

**Agent ownership (mandatory):** the agent that adds or changes a script is responsible for **cleanliness and order** in `scripts/` — one concern per file, shared helpers only in `_gws_common.py`, update `AGENTS.md` + this table + Changelog in the **same** edit. Do not leave orphan `/tmp` variants; merge into an existing script or add a documented row here.

```bash
python3 "$HOME/.agents/skills/k-google/scripts/gws_inspect_recent_mail.py" --profile both --count 15
```

## Cross-skills

| Task | Load |
|------|------|
| Mount / remote | `k-rclone` |
| `Gdrive` paths | `k-drive` |
| Poly mail | `k-mail` |
| Cloudflare | `k-cloudflare` |
| Tailscale | `k-clis` |
| GCP data pipelines | GCP skills + `gcloud` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-google/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-google/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

