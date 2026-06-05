---
name: k-media
description: >
  KπX media publish ops — YouTube, Meta (non-WA), X. Routes GCP/YouTube to k-google (kpihx-labs);
  social registry to k-clis. Load for video/social API setup, upload, or cross-post prep.
license: private
metadata:
  author: KpihX
  version: "1.1.1"
  scope: operations
allowed-tools: Bash(gcloud:*), Bash(gws:*)
---

# KπX — Media (YouTube · Meta · X)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Role

Operational hub for **video + social API setup** — routes to domain skills; **no `k-publish` skill** (vision-only in `k-context/references/vision/`).

| Need | Load |
|------|------|
| **YouTube** (GCP `kpihx-labs`, OAuth, upload) | This skill → `references/youtube-kpihx-labs.md` |
| `gcloud`, `gws-labs`, GCP auth | **`k-google`** |
| Vault items Meta Dev / X Dev, program order | **`k-clis`** → `references/social-dev-platforms.md` |
| WhatsApp Cloud API | **`k-whatsapp`** |
| Long-term multi-platform architecture | **`k-context/references/vision/social-media-apis.md`** |

## YouTube (default project: `kpihx-labs`)

| Item | Value |
|------|--------|
| GCP project | `kpihx-labs` (`747851806672`) |
| API | `youtube.googleapis.com` (Data API v3) |
| OAuth | Desktop client in `$HOME/.config/gws/kpihx-labs/client_secret.json` |
| CLI profile | `gws-labs` |

**Bootstrap:** `scripts/youtube_gcp_bootstrap.sh`  
**OAuth + API:** `scripts/youtube_cli.py` (`auth` · `channels` · `upload`) — see `scripts/README.md`  
**Deps:** `scripts/pyproject.toml` · `scripts/uv.lock` (`uv sync` in `scripts/`)  
**Runbook:** `references/youtube-kpihx-labs.md` (LIVE — channel `@kpihx`)

## Meta / X

| Platform | Status | Doc |
|----------|--------|-----|
| Meta Graph + WA Cloud | **`k-meta`** core ✅ JSON · extended → System User token | `k-meta/references/smoke-status.md` |
| **X** | **`k-x`** `me` ✅ JSON · tweet → credits | `k-x/references/x-dev-setup.md` |

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial work in this skill domain.
- Update `references/insights.md` at the end of the task with durable lessons.
- Keep insights autonomous and evolutionary.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-25 | [CURSOR] | v1.1.1 — Meta JSON core smoke OK; X JSON `me` OK; tweet blocked on credits. |
| 2026-05-25 | [CURSOR] | v1.1.0 — `youtube_cli.py` LIVE: OAuth token, channel `@kpihx`, unlisted smoke upload. |
| [SUMMARY] | — | v1.0.x YouTube bootstrap + consent UI notes in `references/youtube-kpihx-labs.md` |
