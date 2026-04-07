---
name: k-linkedin
description: linkedin-mcp operational memory — KπX LinkedIn identity, OAuth scopes, API capabilities/limitations table, and publishing style. Load before any linkedin-mcp tool call.
license: private
metadata:
  author: KpihX
  version: "2.0.4"
allowed-tools: mcp__linkedin-mcp__*, mcp__linkedin-mcp--stdio__*
---

# Tool Memory — LinkedIn (linkedin-mcp)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Identity & Auth

- **LinkedIn name:** Ivann Harold KAMDEM POUOKAM
- **Email:** `ivann.kamdem@hotmail.com`
- **Member ID:** `isT9VE994v`
- **Token expiry:** ~2026-05-21 — renew with `linkedin-admin auth` before then
- **Scopes:** `openid`, `profile`, `email`, `w_member_social`
- **Missing:** `r_member_social` — cannot read others' posts or own post history (requires LinkedIn partner approval)

## API Capabilities & Limitations

| Tool | Can | Cannot |
|------|-----|--------|
| `linkedin_get_profile` | name, email, picture | posts, connections |
| `linkedin_create_post` | text post | — |
| `linkedin_create_image_post` | image post | — |
| `linkedin_like_post` | by URN | — |
| `linkedin_create_comment` | by URN | — |
| `linkedin_delete_post` | own posts by URN | — |
| list own past posts | requires `r_member_social` | post URN must be provided manually by KπX |

## Publishing Style

- **Language:** French predominantly (fr_FR) with English technical terms
- **Tone:** Professional but approachable; engaged and passionate about tech/AI
- **Emojis:** Moderate, purposeful — structure and highlight key points
- **Structure:** Hook (question or bold statement) → short paragraphs → call to action or reflection
- **Topics:** AI/ML, systems architecture, hackathons, student life at X, tech projects, career insights, African tech ecosystem

## MCP Setup Reference

- Generic setup (HTTP + stdio): `$HOME/.agents/skills/k-linkedin/references/mcp.md`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-07 | [CODEX] | v2.0.4 — aligned LinkedIn MCP setup reference with stdio-only command mode (`--fallback` removed) and updated allowed tool suffix. |
| 2026-04-06 | [CLAUDE] | v2.0.2–v2.0.1 — switched MCP install/reference to Bun-first ownership, then added the MCP setup reference pointer (`references/mcp.md`) |
| [SUMMARY] | — | v2.0.0 refonte/migration to `skills/kpihx/linkedin/`; prior: profile fetched, post history inaccessible (missing scope), style inferred |
