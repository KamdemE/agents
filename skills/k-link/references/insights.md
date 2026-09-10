# k-link Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.

### URL card vs image post — mutually exclusive (2026-09-07)

`post-create-full` has 3 modes, never mix:
1. **URL card only:** `{"text":"...", "url":"https://..."}` → OG preview card, no images. Use for hook posts with link.
2. **Image(s) only:** `{"text":"...", "media":[...]}` → image carousel, no URL card. Use for visual/technical posts.
3. **Text only:** `{"text":"..."}` → pure text, no card, no images. Rare.

Mixing `url` + `media[]` in the same payload → LinkedIn 400 error (`IMAGE` ignores `originalUrl`, `ARTICLE` rejects asset URNs). This is documented in SKILL.md but was hit live.

### 2-post thread pattern (2026-09-07)

Validated pattern for longer content:
- **Post 1:** captivating hook + URL card only (no images). Short, punchy, creates curiosity.
- **Post 2:** technical deep-dive + multi-image carousel + URL in text body. References Post 1.

Benefits: Post 1 drives clicks via OG card, Post 2 drives engagement via images. Both cross-reference each other.

### HITL approval flow (2026-09-07)

`post-create-full` opens browser HITL editor. Payload keys `text`, `url`, `title`, `description`, `media`, `visibility` are all editable inline. `edited` flag in response confirms if  touched anything. Always wait for HITL before assuming sent.

### URL card + custom OG metadata pattern (2026-09-08)

Validated for news/article posts: `{"text":"...", "url":"https://...", "title":"...", "description":"..."}` → LinkedIn generates an OG preview card with custom title/description overriding the crawled OG metadata. This is the cleanest pattern for sharing external articles with editorial framing. Post published: `urn:li:share:7503200532732289024` (Navier-Stokes/OpenAI, PUBLIC, ~1600 chars body + URL card).
