# music.youtube.com (YouTube Music — Music streaming)

**Category:** Entertainment/Music. **Account:** <primary@gmail.com> ( main). **Profile:** `default`.

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
- Each card shows: playlist title, owner (Your Name), track count ("XX titres")
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
   - `page-click-coordinates` at (640, 400) — clicks the center of the video player area (preferred)
   - `page-evaluate` → click the player bar button with `aria-label="Lire"` (or `"Mettre en pause"` when playing)
4. Verify playback: check player bar button label — `"Mettre en pause"` = playing, `"Lire"` = paused

**Player bar buttons (French labels — always check `aria-label` dynamically):**
- `Précédent` — previous track
- `Revenir en arrière de 10 secondes` — rewind 10s
- `Mettre en pause` / `Lire` — pause/play toggle
- `Avancer de 30 secondes` — forward 30s
- `Suivant` — next track
- `J'aime` / `Je n'aime pas` — like/dislike
- `Menu d'actions` — three-dot menu (add to playlist, share, etc.)
- `Couper le son` — mute
- `Vitesse de lecture` — playback speed
- `Lecture en boucle désactivée` / `Tout lire en boucle` — loop toggle
- `Lecture aléatoire` — shuffle

**Loop mode:** click the loop button to toggle. States: `"Lecture en boucle désactivée"` → `"Tout lire en boucle"` (loop all). Button is inside `ytmusic-player-bar`.

**Add to playlist flow:**
1. Click `Menu d'actions` (three-dot) in player bar
2. Click `Enregistrer dans une playlist` in the popup menu
3. Dialog `ytmusic-add-to-playlist-renderer` opens with `.scroller` containing `ytmusic-playlist-add-to-option-renderer` items
4. 🔴 **CRITICAL:** each item has an inner `<button>` — clicking the outer `ytmusic-playlist-add-to-option-renderer` element does NOT register. Must click the `<button>` inside it.
5. Toast confirms: `"Enregistrée dans <name>"` (success) or `"Ce titre figure déjà dans la playlist"` (duplicate)
6. Dialog stays open after each click — can add to multiple playlists in one session
7. Close with `.close-icon button`

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

## Known playlists ( — as of 2026-08-31)

| Playlist | Tracks | Theme |
|----------|--------|-------|
| **o** | 61 | Emotional ballads — acoustic covers, Zaho, Black M, SARA'H French versions, Forest Blakk, Ed Sheeran |
| **.** | 38 | Motivational/energy — Black M, Sia, Imagine Dragons, David Guetta, Youssoupha, cinematic epic |
| **1** | 28 | Piano/instrumental — Hans Zimmer, Gibran Alcocer, Atlantic Notes, Jacob's Piano, Interstellar, Amélie |
| **Mix** | 49 | — |
| **0** | 22 | — |
| **->** | 23 | — |
| **Move** | 18 | — |
| **#** | 10 | — |
| **My Way** | 30 | — |
| **Zaho** | 24 | — |
| **Jurrivh** | 14 | — |
| **Life** | 20 | — |

