---
name: k-media
description: >
  media publish ops — YouTube, Meta (non-WA), X. Routes GCP/YouTube to k-google (<github-user>);
  social registry to k-clis. Load for video/social API setup, upload, or cross-post prep.
license: private
metadata:
  author: 
  version: "1.0.0"
  scope: operations
allowed-tools: Bash(gcloud:*), Bash(gws:*)
---

#  — Media (YouTube · Meta · X)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

## Role

Operational hub for **video + social API setup** — routes to domain skills; **no `k-publish` skill** (vision-only in `k-context/references/vision/`).

| Need | Load |
|------|------|
| **YouTube** (GCP `<github-user>`, OAuth, upload) | This skill → `references/youtube-<github-user>.md` |
| `gcloud`, `gws-labs`, GCP auth | **`k-google`** |
| Vault items Meta Dev / X Dev, program order | **`k-clis`** → `references/social-dev-platforms.md` |
| WhatsApp Cloud API | **`k-whats`** |
| Long-term multi-platform architecture | **`k-context/references/vision/social-media-apis.md`** |

## YouTube (default project: `<github-user>`)

| Item | Value |
|------|--------|
| GCP project | `<github-user>` (`747851806672`) |
| API | `youtube.googleapis.com` (Data API v3) |
| OAuth | Desktop client in `$HOME/.config/gws/<github-user>/client_secret.json` |
| CLI profile | `gws-labs` |

**Bootstrap:** `scripts/youtube_gcp_bootstrap.sh`  
**OAuth + API:** `scripts/youtube_cli.py` (`auth` · `channels` · `upload`) — see `scripts/README.md`  
**Deps:** `scripts/pyproject.toml` · `scripts/uv.lock` (`uv sync` in `scripts/`)  
**Runbook:** `references/youtube-channel.md` (LIVE — channel `@<your-channel>`)

## Meta / X

| Platform | Status | Doc |
|----------|--------|-----|
| Meta Graph + WA Cloud | **`k-meta`** core ✅ JSON · extended → System User token | `k-meta/references/smoke-status.md` |
| **X** | **`k-x`** `me` ✅ JSON · tweet → credits | `k-x/references/x-dev-setup.md` |

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial work in this skill domain.
- Update `references/insights.md` at the end of the task with durable lessons.
- Keep insights autonomous and evolutionary.

