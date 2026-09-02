---
name: k-meta
description: >
  Meta Graph API + WhatsApp Cloud credentials — Meta Dev Vault, meta_cli smoke,
  JSON creds at $HOME/.config/kpihx/meta/. Messaging via k-whats. Load before Meta Graph work.
license: private
metadata:
  author: KpihX
  version: "1.0.2"
  scope: operations
allowed-tools: Bash(*)
---

# KπX — Meta (Graph / WA Cloud)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-14 | [COLAB] | v1.0.2 — **MCP purge annotation**: `whats-mcp` purged (2026-08-14) → WhatsApp row updated to `whats-proxy` (ex-`whats-mcp`). See `k-node/references/purged.md`. |
| 2026-05-25 | [CURSOR] | v1.0.1 — Tiered smoke; JSON filled; core LIVE; System User optional keys. |
| [SUMMARY] | — | v1.0.0 bootstrap → `references/smoke-status.md` |
