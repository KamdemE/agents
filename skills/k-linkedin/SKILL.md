---
name: k-linkedin
description: linkedin-mcp operational memory — KπX LinkedIn identity, OAuth scopes, API capabilities/limitations table, and publishing style. Load before any linkedin-mcp tool call.
license: private
metadata:
  author: KpihX
  version: "2.0.7"
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
- **Missing Tool / MCP Action:** If KπX asks to use linkedin-mcp and the agent doesn't already see it in its activated tools, the agent MUST look at `references/mcp.md` for the process of adding it, and proactively add it as an MCP before attempting to continue the task. Use the naming convention **`linkedin-mcp-http`** and **`linkedin-mcp-stdio`**.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-linkedin/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-linkedin/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-13 | [CODEX] | v2.0.7 — Standardized insights discipline and autonomous maintenance hooks for this skill. |
| 2026-04-13 | [CODEX] | v2.0.6 — Compacted changelog rows to comply with kernel audit row-cap policy. |
| [SUMMARY] | — | +1 older changelog entries kept in file history; condensed for table limits |