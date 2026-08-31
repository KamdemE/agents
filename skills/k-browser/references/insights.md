# Insights — browser-proxy operational memory

General, cross-site durable lessons. Site-specific insights live in `references/sites/<domain>.md` instead (see `SKILL.md` → Site Memory Registry).

## `--help` is the ONLY source of truth

Never read `browser-proxy`'s source code to learn an action's parameters — after the beta, the code will not even be local. `browser-proxy do <action> --help` (and the grouped `browser-proxy do --help` catalog) is always in sync with the real implementation (docstrings ARE the CLI help, generated from the same source the daemon runs). If `--help` doesn't answer the question, the action likely doesn't do what you assumed — don't guess, don't improvise a workaround from memory of an old MCP.

## Extension-mediated ("active tab") actions need `tab-activate` first

`browser-set-date`, `browser-set-combobox`, `browser-dismiss-overlays`, `browser-solve-captcha` act on whichever tab the EXTENSION considers "active" (`chrome.tabs.query({active:true})`), never the `target_id` you last navigated via CDP. If you navigated tab A via `page-navigate` but tab B is visually focused, these actions hit tab B. Always call `tab-activate` on your intended target immediately before any of these 4 actions — live-verified footgun (2026-08-30).

## `data:` URLs never get content-script injection

Chrome/Edge deliberately never run extension content scripts on `data:`/`file:` schemes, regardless of `matches: ["<all_urls>"]` in the manifest — this is a hard browser security boundary, not a browser-proxy limitation. Any extension-mediated action (`browser-set-date`, `browser-set-combobox`, `browser-solve-captcha`, `browser-dismiss-overlays`, `browser-drop-file`) silently fails (`applied:false`/`matched:false`) on a `data:` page. For deterministic, dependency-free test fixtures, spin up a tiny local HTTP server (`python3 -m http.server <port> --directory /tmp/... --bind 127.0.0.1`) and navigate to `http://127.0.0.1:<port>/...` instead — real `http://` origin, content scripts inject normally (live-verified 2026-08-30).

## `page-evaluate` and non-serializable results

An expression evaluating to a value CDP cannot JSON-serialize (`window.open(...)` returns a circular-reference `Window`, any raw DOM node) is automatically retried without `returnByValue`, returning a safe `description`/`type` string (e.g. `"Window"`) instead of raising `CDP_ERROR: Object reference chain is too long`. If you need the ACTUAL value, end the expression with something serializable (`window.open(url); "opened"`, `element.outerHTML`, …) rather than letting it return the live object.

## CAPTCHA solving — real capability, real limit

`browser-solve-captcha`'s `click_checkbox` dispatches a REAL compositor-level CDP click (`Input.dispatchMouseEvent`, same primitive as `page-click-coordinates`) at the checkbox's computed position — this genuinely reaches cross-origin reCAPTCHA/hCaptcha checkboxes (live-verified against the official Google demo, real green checkmark). What remains genuinely unsolvable: **image-grid challenges** (`click_grid`, explicitly not implemented — needs real image analysis) and **Canvas-based CAPTCHAs** (no pixel access). For testing this action, `recaptcha-demo.appspot.com` is Google's own official demo — reliable, always available, no real-world consequences.

## Heuristic actions are heuristics, not omniscient

`browser-dismiss-overlays` and `browser-set-combobox` scan the DOM by pattern (accept-text regex, `[role=option]`/`li` elements) — they are NOT guaranteed to click the element you mean. Verify the actual outcome (`page-evaluate`/`page-screenshot`) rather than trusting the boolean `dismissed`/`matched` result blindly, especially on unfamiliar sites. `browser-set-combobox` specifically targets ARIA-pattern widgets (`[role=option]`, `li`) — it does **not** work on a native `<select><option>` (use `page-select-option` for that instead).

## File upload — two genuinely different mechanisms

A page's `<input type=file>` CANNOT have its `.files` property populated by a synthetic `DragEvent` — this is a hard browser security restriction, no workaround exists via any dispatched event. `browser-drop-file` targets real JS drop-zone widgets (Dropzone.js, react-dropzone, and similar) that read `event.dataTransfer.files` themselves in their own `drop` handler — always verify the TARGET is such a widget (often a `<div class="dropzone">`-style element, sometimes alongside a decoy native `<input type=file>` the widget itself manages internally) before assuming the action can apply to a given upload UI.

## Cookies/downloads — browser-level vs page-level CDP domains

`Storage.getCookies`/`Storage.setCookies` are BROWSER-level (flat websocket, no `target_id`); cookie DELETION (`Network.deleteCookies`) is PAGE-level (needs an attached page session) — Chromium simply has no equivalent browser-level deletion method. The same page-vs-browser split applies elsewhere in CDP; when an action behaves unexpectedly, check whether the CDP method it uses is genuinely available at the level being called, don't assume symmetry between read/write/delete.

## Window/group creation already handles the classic `chrome.tabs.group` window-context quirk

The historical MCP-era gotcha ("`chrome.tabs.group` creates the group in the CALLING extension's window — move the extension tab first") is handled INTERNALLY by `window-create`'s `layout`/`group-create` implementation — you never need to manually relocate anything yourself; just pass the real `tab_ids`/`window_id` and the action resolves the rest.

## Verify after every mutation

After any structural change (`window-create`, `tab-update`, `group-*`), re-read the real state (`window-list`/`tab-list`) rather than assuming the mutation landed exactly as requested — CDP `target_id` and `chrome.tabs.Tab.id` are two separate identifier systems; `window-list`'s own correlation is deterministic but still worth a confirming read, especially across duplicate URLs.

## Edge start already gives you a usable tab

`browser-proxy admin profile start <profile>` starts the managed, always-visible Edge instance with a bootstrap tab; live inventory of `default` exposed `edge://newtab/` (not a guaranteed literal `about:blank`). Inspect `window-list` before creating anything, then navigate that existing tab. `window-create` is only for a separate window explicitly requested by KπX — never create one merely because the bootstrap tab is empty.

## Large files: choose native CDP input injection, not base64

For a genuine `<input type=file>`, `DOM.setFileInputFiles` is the only suitable CDP primitive for a multi-hundred-MB local file: it points Edge at the existing local path and avoids creating a giant base64 JSON payload. First identify the concrete input and then verify the application-level attachment chip; a non-empty `<input>` alone does not prove the web application accepted the file. `browser-drop-file` remains the right action only for JavaScript drop zones.

## PDF viewer is not a download

An ordinary `page-click` or `page-navigate` to a PDF may visibly open Edge's inline viewer and create no file in `$HOME/Downloads`; do not report that as a completed download. The validated transparent path is: set browser download behavior, navigate the visible target to the actual PDF, confirm `document.contentType === "application/pdf"`, then request a same-origin `<a download>` click from that PDF target. The server's `Content-Disposition` filename is authoritative. A `download` attribute initiated from a *different* origin may be ignored: for SIATEL/Gargantua links, navigate to its `?aw=1` PDF first, then trigger the anchor from the Gargantua origin. Never save a tiny HTML wait/login page with a `.pdf` extension; verify the resulting local file is a PDF. See `scripts/presets/pdf-download-sequence.sh` and `sites/gargantua.polytechnique.fr.md`.

## A `blob:` media URL is a player implementation detail

An HLS player may expose `blob:` URLs as its current resource; those are not portable download URLs. For a loaded Ubicast/Nudgis player, inspect its live HLS levels to retrieve the direct video/audio manifests instead. Separate video and audio manifests must be downloaded independently and muxed with stream copy; see `scripts/presets/ubicast-hls-inspect.sh`, `scripts/presets/ubicast-hls-download.sh`, and `sites/mediaserver.ip-paris.fr.md`.

## `page-screenshot` can break SPAs — the old `translateZ(0)` hack (fixed 2026-08-31)

The old `page-screenshot` applied `document.body.style.transform = 'translateZ(0)'` to force a repaint before capturing. On complex SPAs like YouTube Music, this modified the body's computed style, triggering layout recalculations that broke the rendering: player bar disappeared, queue became invisible, page went black. **Root cause:** the hack, not DOM clicks. `Page.captureScreenshot` already forces an internal repaint — the hack was unnecessary. Now removed; pass `force_repaint: true` only as a last resort. (Root-caused and fixed 2026-08-31.)

## `page-press` — proper keyboard input via CDP (added 2026-08-31)

`page-press` uses `Input.dispatchKeyEvent` (`keyDown` + `keyUp`), which is the real CDP input pipeline. Unlike `page-evaluate` + `new KeyboardEvent().dispatchEvent()` (which only fires in the JS event system and may be ignored by the page's internal handlers), `page-press` goes through the compositor-level input path that the browser treats as a real user keystroke. Use it for play/pause (`Space`), navigation (`ArrowDown`/`Enter`), and any keyboard shortcut on complex SPAs. (Added 2026-08-31.)

## Changelog

| Date | Note |
|------|------|
| 2026-08-31 | Root cause of YT Music layout breakage identified: `page-screenshot`'s `translateZ(0)` hack, NOT DOM clicks. Hack removed (now optional `force_repaint`). Added `page-press` action (CDP `Input.dispatchKeyEvent`). Updated `music.youtube.com.md` and `insights.md` with corrected understanding. |
| 2026-08-30 | Live Moodle/Nudgis/AI Studio pass: documented native large-file CDP injection and the `blob:`-vs-direct-HLS distinction; a cloud-model internal error became a local `k-whisper` transcript fallback rather than a dead end. |
| 2026-08-30 | Full rewrite for the browser-proxy era — purged all MCP-era content (`chrome-agent-mcp`, `browser-mcp`, Playwright, Edge Tab Groups Explorer extension — all retired 2026-08-26), migrated site-specific entries to `references/sites/`, added 8 new durable lessons from a live full-registry test sweep (cookie/storage backend splits, `data:` URL content-script restriction, page-evaluate serialization fallback, captcha CDP escalation, dismiss-overlays/combobox heuristic honesty, drop-file mechanism distinction, active-tab footgun). |
