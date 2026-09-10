---
name: k-x
description: >
  X (Twitter) API v2 — OAuth 1.0a user context, Vault X Dev, x_cli smoke/post.
  Load before any X API or @KPIHX7 automation. Registry in k-clis.
license: private
metadata:
  author: 
  version: "1.0.0"
  scope: operations
allowed-tools: Bash(*)
---

#  — X (Twitter)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

## Role

X API operational memory — **not** duplicated in `k-clis` (registry only) or `k-media` (routes here).

| Need | Location |
|------|----------|
| Vault **X Dev**, credits, JSON optional | `references/x-dev-setup.md` |
| CLI `me` / `tweet` / `tweets` | `scripts/x_cli.py` · `scripts/sync_creds_from_env.py` · `scripts/README.md` |
| Deps | `scripts/pyproject.toml` · `scripts/uv.lock` |
| JSON template | `assets/credentials.json.example` |
| Multi-platform vision | `k-context/references/vision/social-media-apis.md` |
| Hub registry | `k-clis/references/social-dev-platforms.md` |

## Live status (2026-05-25)

| Item | Value |
|------|--------|
| Handle | **@KPIHX7** |
| User id | `1643990993983926280` |
| Auth | OAuth **1.0a** — `$HOME/.config/kpihx/x/credentials.json` (or Vaultwarden when stable) |
| Posting | Blocked until **API credits** (402) |
| JSON creds | `$HOME/.config/kpihx/x/credentials.json` — **`me` OK** (2026-05-25) |

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial X API work.
- Update `references/insights.md` after durable lessons.

