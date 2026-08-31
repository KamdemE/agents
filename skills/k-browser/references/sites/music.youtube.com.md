# music.youtube.com (YouTube Music — Music streaming)

**Category:** Entertainment/Music. **Account:** kapoivha@gmail.com (KπX main). **Profile:** `default`.

## Login

Authenticated via Google SSO on the default Edge profile. Cookie consent ("Before you continue to YouTube") may appear on first visit — click "Accept all". Language may default to English after consent; the UI reverts to French once authenticated.

## Structure / navigation

- **Home:** `music.youtube.com` — "Réécouter" (Listen Again) carousel, mood/genre chips, personalized recommendations
- **Explore:** `music.youtube.com/explore` — New releases, charts, moods & genres
- **Library:** `music.youtube.com/library/playlists` — Playlists tab (filtered view), Songs, Albums, Artists, Subscriptions
- **History:** `music.youtube.com/history` — Listening history grouped by day (Aujourd'hui, Hier, La semaine dernière)
- **Search:** `music.youtube.com/search?query=...` — Titles, albums, artists, podcasts

### Library → Playlists

- Grid layout with album art thumbnails
- Each card shows: playlist title, owner (Ivann KAMDEM), track count ("XX titres")
- Sorting dropdown: "Enregistrés récemment" (Recently saved) — NO "most played" sort available
- Automatic playlists: Musique "J'aime" (Liked Music), Nouveaux épisodes, Sons issus de Shorts
- Filter chips at top: Podcasts, Énergie, Bonne humeur, Détente, Sport, Pour la route, Fête, Concentration, Romance, Triste, Sommeil

### Playlist detail view

- Click a playlist card → opens `music.youtube.com/playlist?list=PL...`
- Track list: `ytmusic-responsive-list-item-renderer` elements
- Each row: track title (`.title-column yt-formatted-string a`), artist (`.secondary-flex-columns yt-formatted-string a`), album, duration
- Scroll to load all tracks (lazy loading via infinite scroll)
- Play button (triangle overlay on thumbnail) starts playback from track 1
- Three-dot menu per track: Add to queue, Add to playlist, Go to album/artist, Share

### "Réécouter" (Listen Again) section

- On Home page, shows recently/repeatedly played content in a horizontal carousel
- Items include both playlists and individual tracks
- Order likely reflects play frequency (most played first) — best proxy for "most played" in the web UI

## Playback interaction

🔴 **`page-screenshot` used to break YT Music** — the old `translateZ(0)` hack modified `document.body.style.transform`, which broke the SPA layout (player bar disappeared, queue broke, page went black). This is now fixed: `page-screenshot` no longer applies the hack by default (pass `force_repaint: true` only as a last resort).

**Correct way to play a specific track:**
1. **Find the video ID** from the playlist/history DOM (safe read-only): `page-evaluate` → extract `href` from `.title-column yt-formatted-string a` elements
2. **Navigate directly** to the watch URL: `page-navigate` to `https://music.youtube.com/watch?v=VIDEO_ID`
3. **Play/pause** with one of:
   - `page-press` with `key: "Space"` — real CDP keyboard input, most reliable
   - `page-click-coordinates` at (640, 400) — clicks the center of the video player area
4. Verify playback: check `.time-info` text (should show progressing time like `0:40 / 3:10`)

**Extracting track lists (read-only, safe):**
- `page-evaluate` + DOM queries are SAFE for reading data (track names, counts, hrefs, etc.)
- `page-screenshot` is now safe (no more `translateZ(0)` hack)
- Always `window.scrollTo(0, document.body.scrollHeight)` before extraction to trigger lazy loading

## Known quirks

- **No play count data in web UI** — YouTube Music does NOT expose per-playlist or per-track play counts. The only proxy is the "Réécouter" carousel order on the Home page
- **Sorting is limited** — Playlists can only be sorted by "Enregistrés récemment" (Recently saved). No "Most played", "Alphabetical", or "Last played" options
- **Track counts on cards may differ from actual loaded tracks** — the library card shows a rounded number (e.g., "60 titres") but scrolling the detail view may load more (e.g., 67 tracks including variations/covers)
- **Cookie consent blocks access** — must accept cookies before any authenticated content loads
- **Language toggle** — a `<select>` element for language exists in the DOM but is for accessibility/settings, not the UI language (UI language follows the Google account locale)
- **SPA navigation** — clicking playlists uses client-side routing; `page-navigate` to the library URL is more reliable than clicking back
- **Lazy loading** — playlist detail views load tracks in batches; always `window.scrollTo(0, document.body.scrollHeight)` before extracting track lists
- **Player bar position** — player bar is fixed at the BOTTOM of the page (standard music app layout); shows current track, progress bar, play/pause, queue toggle. Note: the old `translateZ(0)` hack in `page-screenshot` used to shift it to the top — this was a side effect, not the real position.

## Known playlists (KπX — as of 2026-08-31)

| Playlist | Tracks | Theme |
|----------|--------|-------|
| **o** | 67 | Emotional ballads — acoustic covers, Zaho, Black M, SARA'H French versions, Forest Blakk, Ed Sheeran |
| **.** | 44 | Motivational/energy — Black M, Sia, Imagine Dragons, David Guetta, Youssoupha, cinematic epic |
| **1** | 34 | Piano/instrumental — Hans Zimmer, Gibran Alcocer, Atlantic Notes, Jacob's Piano, Interstellar, Amélie |
| **Mix** | 49 | — |
| **0** | 22 | — |
| **->** | 23 | — |
| **Move** | 18 | — |
| **#** | 10 | — |
| **My Way** | 30 | — |
| **Zaho** | 24 | — |
| **Jurrivh** | 14 | — |
| **Life** | 20 | — |

## Changelog

| Date | Note |
|------|------|
| 2026-08-31 | Created after full YouTube Music library exploration: cookie consent flow, playlist inventory (60+ playlists), DOM extraction of track lists for top 3 playlists (o/./1), sorting limitation documented, "Réécouter" section identified as best "most played" proxy. |
| 2026-08-31 | **Root cause identified & fixed:** the old `page-screenshot` hack (`translateZ(0)` on `document.body`) was breaking YT Music's SPA layout, NOT the DOM clicks themselves. Removed the hack (now optional via `force_repaint`). Added `page-press` action (CDP `Input.dispatchKeyEvent`) for reliable keyboard input. Corrected "player bar at top" — it was a side effect of the hack, real position is bottom. Simplified playback interaction docs. |
