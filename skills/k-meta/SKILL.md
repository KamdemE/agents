---
name: k-meta
description: >
  Meta Graph API + WhatsApp Cloud credentials — Meta Dev Vault, meta_cli smoke,
  JSON creds at $HOME/.config/kpihx/meta/. Messaging via k-whats. Load before Meta Graph work.
license: private
metadata:
  author: 
  version: "1.0.0"
  scope: operations
allowed-tools: Bash(*)
---

#  — Meta (Graph / WA Cloud)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

## Role

| Need | Where |
|------|--------|
| JSON creds + Graph smoke | `references/meta-dev-setup.md` · `scripts/meta_cli.py` |
| WhatsApp send/receive | **`k-whats`** (whats-proxy) |
| Registry | **`k-clis`** · **`k-media`** hub |

**Creds file:** `$HOME/.config/kpihx/meta/credentials.json`

**Smoke status:** `references/smoke-status.md` — core ✅ after JSON fill; extended needs System User token.

## Scripts

| Path | Role |
|------|------|
| `scripts/meta_cli.py` | Graph smoke (core + extended tiers) |
| `scripts/sync_creds_from_env.py` | JSON ← `META_*` env |
| `scripts/README.md` | `uv sync` + runbook |
| `scripts/pyproject.toml` · `scripts/uv.lock` | uv deps |
| `assets/credentials.json.example` | JSON template |

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial Meta Graph work.
- Update `references/insights.md` after durable lessons.

