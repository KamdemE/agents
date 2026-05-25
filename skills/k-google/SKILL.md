---
name: k-google
description: >
  KπX Google stack — gcloud (GCP container) and gws (Workspace content). Drive files via
  k-rclone/k-drive. Load before Google Cloud or Workspace tasks.
license: private
metadata:
  author: KpihX
  version: "1.3.5"
  scope: operations
allowed-tools: Bash(gws:*), Bash(gcloud:*), Bash(rclone:*)
---

# KπX — Google (Cloud + Workspace)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Cloud hub

Registry map: `$HOME/.agents/skills/k-cloud-tools/references/cloud-hub.md` · load **`k-cloud-tools`** when routing across providers.

## Two planes (mandatory)

| Plane | Tool | Scope |
|-------|------|--------|
| **Container** | `gcloud` | GCP projects, IAM, Compute, GKE, buckets, API enablement |
| **Content** | `gws` / `gws-kpihx` / `gws-labs` | Gmail, Drive API, Calendar, Sheets, Docs (Discovery CLI) |
| **Local files** | `rclone` | Mounted trees — **`k-rclone`**, semantics — **`k-drive`** |

**Rule:** infra → `gcloud`. User mail/calendar/docs API → `gws`. Bulk file browse → mounts, not API alone.

## Tools (verify with `!<cmd>`)

| Binary | Runbook |
|--------|---------|
| `gcloud` | Google Cloud SDK — `gcloud version` |
| `gws` | `$HOME/Work/techskills/gws-cli.md` — `npm install -g @googleworkspace/cli` |
| `rclone` | `$HOME/.agents/skills/k-rclone/SKILL.md` |

## GCP projects (two profiles)

| Profile | `project_id` | `gws` config dir | Login account (content) |
|---------|--------------|------------------|-------------------------|
| **KpihX-Labs** | `kpihx-labs` | `$HOME/.config/gws/kpihx-labs/` | `kpihx.labs@gmail.com` |
| **KpihX** | `kpihx-489121` | `$HOME/.config/gws/kpihx/` | KπX org Google account |

**CLI wrappers (mandatory in interactive zsh):** sourced from `$HOME/.config/gws/gws-profiles.zsh` (symlink: `k-google/assets/gws-profiles.zsh`) via `$HOME/.kshrc`.

| Command | Profile | `project_id` | Config dir |
|---------|---------|--------------|------------|
| **`gws`** | **default = KpihX** (alias → `gws-kpihx`) | `kpihx-489121` | `$HOME/.config/gws/kpihx/` |
| **`gws-kpihx`** | KpihX personal | `kpihx-489121` | `$HOME/.config/gws/kpihx/` |
| **`gws-labs`** | KpihX-Labs homelab | `kpihx-labs` | `$HOME/.config/gws/kpihx-labs/` |

**Rule:** always use a profile wrapper in agents/scripts — never bare npm `gws` without `GOOGLE_WORKSPACE_*` env (non-interactive shells). In interactive zsh, bare `gws` is safe (forwards to `gws-kpihx`). Legacy env files: `gws-labs.env` / `gws-kpihx.env` (prefer wrappers).

## OAuth secrets — Vaultwarden (source of truth)

**Collection path (Vaultwarden UI):** `KpihX-Labs` → `Infra` → `Fluid` → `Google`

| Vault item | GCP project | Custom fields |
|------------|-------------|---------------|
| **Google Fluid KpihX-Labs** | `kpihx-labs` | `GOAUTH_CLIENT_ID`, `GOAUTH_CLIENT_SECRET` |
| **Google Fluid KpihX** | `kpihx-489121` | `GOAUTH_CLIENT_ID`, `GOAUTH_CLIENT_SECRET` |

- **Agents:** load **`k-bw`** before reading secrets; use `bw-proxy` / `bw-mcp` — never print values in chat.
- **Runtime copy for `gws`:** `$HOME/.config/gws/<profile>/client_secret.json` (mode `600`). Refresh from Vault after Console rotation; OAuth client must match project (`287665785458-*` = KpihX, `747851806672-*` = Labs).
- **Console test users:** both projects — add every account used in `gws auth login` (see `$HOME/.config/gws/FINALIZE.md`).
- **Labs API quota IAM:** after first `gws-labs` login, grant `roles/serviceusage.serviceUsageConsumer` on project `kpihx-labs` to `user:kpihx.labs@gmail.com` if APIs return 403 `serviceusage.services.use` (fixed 2026-05-25 via `gcloud`).

Auth: `gws auth setup` / `gws auth login` — **KπX-owned** (browser). Prefer `gws auth login -s drive,gmail,calendar,…` (≤ ~25 scopes in testing mode; avoid full 86-scope picker).

**Read-only default** until KπX approves send/upload.

```bash
gws-kpihx gmail users messages list --params '{"userId":"me","maxResults":5}'
gws-labs drive files list --params '{"pageSize":10}'
# bare `gws` == gws-kpihx in interactive zsh only
```

## Mail exception

| Account | Tool | Skill |
|---------|------|-------|
| Poly Zimbra | mail-mcp | **`k-mail`** (canonical) |
| Gmail (`kapoivha`, Labs) | `gws-kpihx` / `gws-labs` | **`k-mail`** + inbound E2E → **`k-cloudflare/references/inbound-email-e2e.md`** · kapoivha hygiene → **`references/kapoivha-gmail-hygiene.md`** + **`scripts/gws_gmail_deep_cleanup.py`** |

**GWS agent shells:** use profile wrappers or `$HOME/.npm-global/bin/gws` with `GOOGLE_WORKSPACE_*` env; strip `Using keyring…` line before `jq` (`awk '/^\{/{p=1} p'`). Send: `--params '{"userId":"me"}'` + `--json '{"raw":…}'`.

## YouTube Data API v3

**Project:** `kpihx-labs` · **Profile:** `gws-labs` · **Runbook:** **`k-media/references/youtube-kpihx-labs.md`** · **Bootstrap:** `k-media/scripts/youtube_gcp_bootstrap.sh`.  
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

**Inventory + examples:** `scripts/README.md` (same workstream as any new script).

**Agent ownership (mandatory):** the agent that adds or changes a script is responsible for **cleanliness and order** in `scripts/` — one concern per file, shared helpers only in `_gws_common.py`, update `README.md` + this table + Changelog in the **same** edit. Do not leave orphan `/tmp` variants; merge into an existing script or add a documented row here.

```bash
python3 "$HOME/.agents/skills/k-google/scripts/gws_inspect_recent_mail.py" --profile both --count 15
```

## Cross-skills

| Task | Load |
|------|------|
| Mount / remote | `k-rclone` |
| `Gdrive_X` paths | `k-drive` |
| Poly mail | `k-mail` |
| Cloudflare | `k-cloudflare` |
| Tailscale | `k-cloud-tools` |
| GCP data pipelines | GCP skills + `gcloud` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-google/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-google/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-25 | [CURSOR] | v1.3.5 — kapoivha Gmail deep cleanup script + `references/kapoivha-gmail-hygiene.md`. |
| 2026-05-25 | [CURSOR] | v1.3.4 — YouTube SOT → **`k-media`** only (no duplicate publish skill). |
| [SUMMARY] | — | v1.3.2 inbound Gmail E2E; v1.3.0–v1.3.3 scripts kit, gws profiles, wrappers; v1.0.x gcloud+gws. |
