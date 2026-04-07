# Social Media APIs — Automated Content Distribution

> Status: REFERENCE · Last updated: 2026-04-07 · [CLAUDE]

## Platform Matrix

| Platform | API | Capabilities | Auth | Approval Time | Cost |
|----------|-----|-------------|------|---------------|------|
| YouTube | Data API v3 | Upload video, title, description, tags, thumbnail | OAuth 2.0 | 2-4 weeks (verification) | Free (quota 10k units/day) |
| LinkedIn | Posts API | Text, images, videos (15-30 min), links | OAuth 2.0 | 1-2 weeks | Free (100 calls/day) |
| X (Twitter) | API v2 | Tweets, images, videos (chunked upload) | OAuth 2.0 | Variable | Free tier = 1500 tweets/month |
| Facebook | Graph API | Posts, images, videos on pages | OAuth 2.0 | 2-4 weeks | Free |
| Instagram | Graph API (Meta) | Posts, reels, stories | OAuth 2.0 | 2-4 weeks | Free |

## YouTube Data API v3

### Upload Flow

```
1. OAuth2 consent (one-time)
2. POST /upload/youtube/v3/videos
   - part: snippet,status
   - Body: video file (resumable upload)
3. Set thumbnail: POST /youtube/v3/thumbnails/set
4. Add to playlist: POST /youtube/v3/playlistItems
```

### Quota

- 10,000 units/day (free)
- Video upload = 1600 units
- ~6 uploads/day on free tier

### Key Libraries

- `google-api-python-client` (official)
- `yt-dlp` (download only, no upload)

## LinkedIn Posts API

### Post Flow

```
1. OAuth2 with scope: w_member_social
2. POST /v2/ugcPosts (or /v2/posts for new API)
   - Body: { author, lifecycleState, specificContent }
3. Image: register upload → upload binary → reference in post
4. Video: similar register → upload → post
```

### Limits

- 100 API calls/day (organization pages)
- Videos up to 15 min (personal) / 30 min (page)
- No scheduling API — use timestamp + cron

## X (Twitter) API v2

### Tweet Flow

```
1. OAuth2 or OAuth1.0a
2. POST /2/tweets
   - Body: { text, media: { media_ids } }
3. Media upload: chunked upload to /1.1/media/upload
   - INIT → APPEND (chunks) → FINALIZE → STATUS
```

### Tiers (April 2026)

| Tier | Tweets/month | Price |
|------|-------------|-------|
| Free | 1,500 | $0 |
| Basic | 3,000 | $100/month |
| Pro | 300,000 | $5,000/month |

## Facebook / Instagram Graph API

### Post Flow (Facebook Page)

```
1. Page Access Token (long-lived)
2. POST /{page-id}/feed (text)
3. POST /{page-id}/photos (image)
4. POST /{page-id}/videos (video — resumable)
```

### Instagram via Graph API

```
1. POST /{ig-user-id}/media (create container)
   - image_url or video_url
2. POST /{ig-user-id}/media_publish (publish container)
```

### Reels

- Same flow as video but with `media_type: REELS`
- Max 90 seconds

## Automation Architecture (k-publish)

```
k-publish/
├── auth/           ← OAuth tokens (Vaultwarden-managed)
│   ├── youtube.json
│   ├── linkedin.json
│   ├── twitter.json
│   └── meta.json
├── templates/      ← Post templates per platform
│   ├── youtube-description.md
│   ├── linkedin-post.md
│   └── tweet.md
└── scripts/
    ├── upload-youtube.py
    ├── post-linkedin.py
    ├── tweet.py
    └── post-meta.py
```

### Scheduling

- No native scheduling API on most platforms
- Use: cron / systemd timer / n8n workflow
- Store schedule in `config.yaml` per content piece

### Content Adaptation

Each platform has different optimal formats:

| Platform | Video | Image | Text | Best Format |
|----------|-------|-------|------|-------------|
| YouTube | 16:9, 1080p+ | Thumbnail 1280x720 | Title + description | Long-form educational |
| LinkedIn | 16:9, max 10 min | 1200x627 | Professional tone | 1-3 min clips + article |
| X | 16:9, max 2:20 | 1200x675 | 280 chars | Thread + clip |
| Instagram | 9:16 reels, 1:1 feed | 1080x1080 | Caption | 15-60s vertical |
| Facebook | 16:9 | 1200x630 | Casual | 1-3 min clips |

## MCP / CLI Tools for Social Media

| Tool | Type | Platforms |
|------|------|-----------|
| `buffer` / `hootsuite` | SaaS (no MCP) | All |
| `n8n` (self-hosted) | Workflow | All via HTTP nodes |
| Direct API calls | Scripts | All |
| `social-poster` npm | CLI | Twitter, LinkedIn |

**Recommendation:** direct API calls wrapped in k-publish scripts, with n8n as a secondary scheduler on the homelab. No SaaS dependency.
