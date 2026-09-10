---
name: k-link
description: >
  LinkedIn via link-proxy CLI (10 actions: posts, like, comments, raw) — the only LinkedIn transport. Load before any LinkedIn work. Deep LinkedIn analysis (profile, skills, posts, messages, community, trends, offers) → k-browser + its references/sites/linkedin.com.md.
license: private
metadata:
  author: 
  version: "1.0.0"
allowed-tools: Bash(*), *
---

#  — LinkedIn (link-proxy)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

## Cloud hub

Social **content** channel · map: `$HOME/.agents/skills/k-clis/references/cloud-hub.md` · registry: **`k-clis`**.

## Transport (only)

**`link-proxy`** — CLI, `$HOME/Labs/Proxies/link-proxy/`, contract: `CONTRACT.md` (authoritative).

## Identity & Auth

Inspect live token state before posting — do not rely on stale expiry dates in chat.

- **Scopes:** `openid`, `profile`, `email`, `w_member_social`
- **Gap:** no `r_member_social` — reads (own history, others' posts, lists) are 403; typed reacts + deletes also blocked. Full matrix: `CONTRACT.md` § Known Limitations.
- **Auth:** `link-proxy admin auth status` (live token, days remaining) · renew: `link-proxy admin auth login`

## `--help` first (mandatory)

**Never read `link-proxy` source to learn usage.** The CLI is docstring-driven:

- `link-proxy do --help` — full catalog (10 actions)
- `link-proxy do <action> --help` (or `-h`, `-f json` for machine-readable) — per-action payload schema + ≥2 examples
- Payload = inline JSON or `./payload.json` file; long texts → file, never inline
- Missing/unclear `--help` → fix the docstring in code (`CONTRACT.md`: docstring IS the doc), never work around it

## Actions

### `do` — RPC (10)

| Action | Role | HITL |
|--------|------|:----:|
| `post-create` | text post (`PUBLIC`/`CONNECTIONS`) | ✅ |
| `post-create-image` | 1 local/HTTP image + post | ✅ |
| `post-create-article` | URL share + OG card (NOT a native LinkedIn article — no such API) | ✅ |
| `post-create-full` | **default for posts**: multi-image/video carousel + optional URL | ✅ |
| `post-like` | LIKE on any known URN (own or third-party — no discovery endpoint) | ✅ |
| `comment-create` | comment on a post | ✅ |
| `comment-reply` | nested reply to a comment | ✅ |
| `profile-get` | own profile via OIDC (name, email, picture, locale) | ❌ |
| `profile-status` | token presence, validity, member info | ❌ |
| `raw` | direct REST gateway (`GET`/`POST`/`DELETE`/`PUT`) | ✅ |

Disabled (commented, code kept — personal-token scope blocks): `post-delete`, `post-get`, `post-list`, `post-react`, `comment-list`, `comment-delete`.

### `admin` — lifecycle (ALWAYS JSON, refuses `-f`/`-o`)

`auth login` (OAuth HITL form) · `auth status` (token + member) · `auth logout` · `status` · `doctor` · `purge`.

## Posting rule

- **Default: `post-create-full`.** Almost every  post carries images and/or a link — `full` covers text-only too (`media: []`, no `url`). `post-create-image` only for exactly 1 image, `post-create` only for pure text.
- **LinkedIn text = plain text.** No markdown: titles/bold/italic via unicode (𝐛𝐨𝐥𝐝, 𝑖𝑡𝑎𝑙𝑖𝑞𝑢𝑒), structure via emojis/paragraphs/`•`/`→`, hashtags at end. Max ~3000 chars/post — longer → thread via `comment-create`/`comment-reply`, or long-form elsewhere + URL share.
- **Images = `media[]`** (local paths or http), each with `alt_text` (+ `title`). No OMoBlur faces, no internal paths/data (DxO rule).
- **Visibility:** `CONNECTIONS` = max privacy via API (no "only me" exists). Default per  instruction unless told otherwise.
- **HITL:** every post opens the full editor — review, edit inline, Approve. Envelope `edited` flag tells if touched.
- **Reference post:** `urn:li:share:7502087590259367936` (PUBLIC, 2 images + URL in text) — the canonical  style specimen. Re-read its payload before drafting any post.
- **Style rules (learned 2026-09-05):** title = universal hook (a problem or need everyone feels, zero jargon, named subjects — never ambiguous pronouns); body opens with the title line; story before terms (technical words only after their plain presentation); keep mystery (`…`, no revealing numbers) to drive article reads; domain order eye status before blur; the article link is a closing PS, never the subject.
- **Incompatible combo:** `post-create-full` with `url` + `media[]` together → LinkedIn 400 (`IMAGE` ignores `originalUrl`, `ARTICLE` rejects asset URNs). Either link-card (`url` only, no media) or images + URL written in the text (no `url` key).

## Publishing style

- **Language:** French (fr_FR) + English technical terms
- **Tone:** Professional, approachable; AI / architecture / student life at X
- **Structure:** Hook → short paragraphs → CTA or reflection

## Scope limits → k-browser

`link-proxy` writes (posts, LIKE, comments) + reads its own account basics. **Everything else goes to `k-browser`** (visible Edge automation) with its runbook `k-browser/references/sites/linkedin.com.md`:

- analyze my profile / adjust my skills
- analyze my posts (performance, stats the API doesn't expose)
- read/analyze my messages, InMail, follow-ups
- my community's posts, trends, job/internship offers
- any API-refused read (403): history, lists, feed

Rule: if the answer needs a logged-in page (feed, messaging, profile stats, search) → `k-browser`, never `raw` probing.

## Archive

- `$HOME/.agents/skills/k-link/references/mcp.md` (legacy transport archive — never use; kept so nothing is lost).

## Cross-skills — when to use what

| Need | Use |
|------|-----|
| Publish a post (`post-create-full` default), like, comment/reply on a known URN | **`link-proxy`** (this skill, `--help` first) |
| Quick facts about my account (OIDC profile, token, days remaining) | **`link-proxy`** (`profile-get`, `profile-status`, `admin auth status`) |
| Analyze my profile / adjust my skills | **`k-browser`** + `references/sites/linkedin.com.md` (runbook: login, navigation, SPA quirks) |
| Analyze my posts (performance, stats) | **`k-browser`** + runbook (the API exposes no stats) |
| Read/analyze my messages, InMail, follow-ups | **`k-browser`** + runbook (messaging vs InMail structure) |
| My community's posts, trends, job/internship offers | **`k-browser`** + runbook (infinite-scroll feed, search) |
| Any API-refused read (403: history, lists, feed, search) | **`k-browser`**, never `raw` probing |
| Cloud registry | `k-clis` |
| Mail-derived professional follow-up | `k-mail` |

Single rule: if the answer needs a logged-in page (feed, messaging, profile, stats, search) → `k-browser`; if it is writing (post, LIKE, comment) or a quick account fact → `link-proxy`.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-link/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-link/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

