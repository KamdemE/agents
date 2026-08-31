# mediaserver.ip-paris.fr (Nudgis / Ubicast)

**Category:** IP Paris academic media server. **Account:** shared Egide SSO session. **Profile:** `default`.

## Login

Moodle launches the player through its existing authenticated session. If MediaServer prompts for login, return through the Moodle resource and complete the visible Egide flow; never fabricate a direct media-server credential flow.

## Structure / navigation

1. Moodle's `/mod/ubicast/view.php?id=<activity-id>` page embeds `mod/ubicast/launch.php?id=…&mediaid=<OID>`.
2. The launch URL redirects to `https://mediaserver.ip-paris.fr/permalink/<OID>/iframe/…`.
3. Start playback once. Only then does the public in-page player state expose the real HLS rendition data.
4. Run `scripts/presets/ubicast-hls-inspect.sh <target-id> [profile]`. It reports the media OID, player modes, and direct video/audio HLS manifests.
5. Pass one video manifest and its matching audio manifest to `scripts/presets/ubicast-hls-download.sh`; it downloads both with `yt-dlp` and losslessly muxes a single MP4 with `ffmpeg`.

## Known quirks

- `window.player.modesManager.modesDicts[*].resource.url` can be a `blob:` URL. It is not a downloadable source; use `window.player.core.handler.hls.levels[*].url` for video and the non-blob audio mode URL instead.
- Ubicast serves video and audio as distinct HLS streams. Downloading the video manifest alone produces a silent MP4; both manifests must be fetched and muxed.
- The direct CDN manifests can be blocked by browser-page CORS while still being fetchable by `yt-dlp`. This is a browser CORS boundary, not proof that the stream is inaccessible.
- The validated first resource was **Correction du cas Opération Souvenir** (48m30): 720p video + audio became a 307 MB H.264/AAC MP4.

## Changelog

| Date | Note |
|------|------|
| 2026-08-30 | Created from the live MIE video recovery: Moodle wrapper → Ubicast iframe → loaded-player HLS inspection → separate 720p/audio download and lossless mux. |
