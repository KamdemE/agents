---
name: k-linkedin
description: >
  LinkedIn via linkedin-mcp — profile, posts, OAuth limits. Cloud hub social channel.
  Load before any linkedin-mcp call.
license: private
metadata:
  author: KpihX
  version: "2.0.8"
allowed-tools: mcp__linkedin-mcp__*, mcp__linkedin-mcp--stdio__*
---

# KπX — LinkedIn (linkedin-mcp)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Cloud hub

Social **content** channel · map: `$HOME/.agents/skills/k-cloud-tools/references/cloud-hub.md` · registry: **`k-cloud-tools`**.

## Identity & Auth

Inspect live token state before posting — do not rely on stale expiry dates in chat.

- **Scopes:** `openid`, `profile`, `email`, `w_member_social`
- **Gap:** no `r_member_social` — cannot read others' posts or own history without partner scope
- **Renew:** `linkedin-admin auth` when token near expiry

## API surface

| Tool | Can | Cannot |
|------|-----|--------|
| `linkedin_get_profile` | name, email, picture | posts, connections |
| `linkedin_create_post` | text post | — |
| `linkedin_create_image_post` | image post | — |
| `linkedin_like_post` | by URN | — |
| `linkedin_create_comment` | by URN | — |
| `linkedin_delete_post` | own posts by URN | — |
| list own past posts | — | needs `r_member_social`; URN from KπX |

## Publishing style

- **Language:** French (fr_FR) + English technical terms
- **Tone:** Professional, approachable; AI / architecture / student life at X
- **Structure:** Hook → short paragraphs → CTA or reflection

## MCP setup

- `$HOME/.agents/skills/k-linkedin/references/mcp.md`
- Missing tool: add **`linkedin-mcp-http`** / **`linkedin-mcp-stdio`** per `mcp.md` before continuing.

## Cross-skills

| Task | Load |
|------|------|
| Cloud registry | `k-cloud-tools` |
| Mail-derived professional follow-up | `k-mail` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-linkedin/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-linkedin/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-25 | [CURSOR] | v2.0.8 — Cloud-hub block; compact layout; removed stale hardcoded token date from operational truth. |
| [SUMMARY] | — | v2.0.7 insights discipline; API limits table; MCP naming; publishing style. |
