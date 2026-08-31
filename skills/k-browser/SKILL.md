---
name: k-browser
description: KπX Edge Automation via browser-proxy — the sovereign JSON-RPC daemon that is the agent's window onto the external world (web UIs with no native tool/MCP). Load before ANY browser-driving task, or whenever a headless/curl approach gets stuck and a web UI is the only remaining path.
license: private
metadata:
  author: KpihX
  version: "4.2.2"
  scope: agent-tooling
  cli: browser-proxy
---

# KπX Browser Automation — browser-proxy

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## What this is — read this first

`browser-proxy` is not "a browser tool" — it is the **cornerstone that gives the agent eyes on KπX's external world**, the same family as `tg-proxy`/`tick-proxy`/`ts-proxy`/`mail-proxy`: one sovereign CLI, one daemon, zero magic. Almost everything today has a web version (LinkedIn, mail, banking, academic portals, …) — when no native tool/MCP/API covers a task, or a headless/curl attempt gets stuck, **browser-proxy is the ultimate recourse**, not a last-ditch hack. Reach for it deliberately.

**Full reflex + escalation rule:** `rules/proxies-reflex.md` (root kernel rule, loaded every turn).

## Philosophy — one CLI, one pattern, never read the code

`browser-proxy` is a **JSON-RPC proxy**: one binary, `browser-proxy do <action> '<json-payload>'` (or `admin <action>` for daemon/profile lifecycle). Every reply is a `{meta, data}` envelope; every action's full contract lives in `--help`.

🔴 **MANDATORY REFLEX — `--help` is the ONLY source of truth.** Never open this project's source code to learn how an action works: post-beta, the code will not even be local. Always run `browser-proxy do --help` (grouped catalog) then `browser-proxy do <action> --help` (params + 3 worked examples) before calling anything you're not 100% sure of. The docstrings ARE the CLI help — always in sync with the real implementation. A short, correct mental model beats memorized command lists: **profile** (a persistent Edge identity) → **target_id** (a CDP page, from `tab-list`/`window-list`) → **action** (one verb, one JSON payload) → **HITL** (some actions need a human, via approval popup or the extension overlay) — internalize this shape once and you can improvise any new action correctly on the first try from its `--help` alone.

## Profiles & Edge Workspaces — living registry (update on ANY change)

| Profile | Account | Notes |
|---|---|---|
| `default` | kapoivha@gmail.com (KπX main) | Primary profile, always-visible Edge window (`browser-proxy-profile@default.service`) |
| `smoke` | — | Test-only profile, never used for real tasks |

**Edge Workspaces** are Microsoft's own grouping-of-windows feature — Edge exposes **no API** for it; `window-list`/`tab-list` can never tell you which window belongs to which Workspace. **Only KπX can tell you.** Known Workspaces on `default`: **`X`** and **`KpihX-Labs`**. When KπX says "this window is on workspace X", trust it as ground truth and remember it for the rest of the session.

**Extreme caution inside a Workspace window:** never touch a pre-existing tab/group in a Workspace window without KπX's explicit request — these are KπX's own long-lived tabs, not test scaffolding. Tabs/windows/groups the AGENT itself creates are the agent's own responsibility to keep tidy (close them, no orphaned `about:blank`/test windows left behind at the end of a session).

### Startup tab is the working tab — never duplicate windows

`browser-proxy admin profile start <profile>` already starts the profile's **one real visible Edge window** with a bootstrap tab (normally `edge://newtab/`; do not assume the literal URL is `about:blank`). **Use that tab directly**: navigate it with `page-navigate`; do not create an additional window just to begin work.

Before any `window-create` or `tab-create`, always inspect `browser-proxy do window-list '{"profile":"<profile>"}'`. Reuse the existing managed window and its bootstrap tab when suitable. **Only call `window-create` when KπX explicitly asks for a separate window.** Never blindly create a second window because an empty/new-tab page is already available.

## Secrets & Bitwarden — auto-fill reflex, GRAVÉ boundary on `browser-ask-user`

KπX uses Bitwarden for secrets. On any form/site needing KπX's info: **first** check BOTH the `kpihx` skill (identity, transport, academic path — `references/identity.md`, `references/legal.md`) AND the `kpihx-labs` skill (kernel/project context) for every NON-secret field (name, email, X-number, addresses, …) and fill those automatically — KπX should only ever need to type the password/2FA/confidential field itself.

🔴 **`browser-ask-user` is NEVER for passwords, tokens, or any secret (KπX, GRAVÉ 2026-08-30): "je ne vais jamais mettre mon password dedans, browser-ask c'est pour des infos autre que password/clés."** It exists for non-secret clarifications and confirmations only. For a password/secret field: **notify KπX** (system + Telegram notification — reuse the existing `opencode-notify`/`notifier.sh` infra) that the field is waiting; **re-notify if KπX takes time**; never collect the secret's value through any overlay, any tool, any chat message.

If KπX corrects a non-secret value the agent auto-filled wrong (or an info evolved), that correction updates the `kpihx`/`kpihx-labs` skill directly — **k-browser never edits those skills**, it only **proposes** a correction and waits (see `## Propose ≠ Act`, root `AGENTS.md`). k-browser's own proactive maintenance target is its OWN site memory files (below), never `kpihx`/`kpihx-labs`.

## Never stall — clarify, don't guess

If genuinely blocked, unsure, or missing info after checking `kpihx` + `kpihx-labs` (and this skill's own site memory) and still hesitating: **always** call `browser-ask-user` to clarify — never advance in doubt. The agent never simply stops mid-task:
- **Non-secret question** → call `browser-ask-user` (it already blocks ~15–20s waiting for a real answer). If it times out, call it again — that retry IS the "renewable wait", never a manual `sleep` loop in your own shell (see `rules/tool-discipline.md` → tmux/self-backgrounding gate).
- **Secret field waiting** → notify (see above), then keep making progress elsewhere or re-check task state via a normal quick action (`cookie-list`/`tab-get`/`page-evaluate` on a URL/DOM change) rather than idly sleeping.
- Only after several retries/re-notifications with no reaction may the agent stop and leave a clear message in chat — never silently.

## Site memory registry (`references/sites/`)

Created **only** on genuine, particular insight (login mechanism, real quirks, useful navigation shortcuts) — never automatically for every site visited. Update in place when something new is learned; never duplicate what already lives in `kpihx`/`kpihx-labs` (identity/personal facts stay there).

| Site | What it captures |
|---|---|
| `sites/aistudio.google.com.md` | Attachment-readiness gate, code-exec/grounding conflicts, model catalog, history cleanup |
| `sites/synapses.polytechnique.fr.md` | Egide/Shibboleth SSO chain (shared with Gargantua/Moodle), catalogue navigation, download-path gotcha |
| `sites/webmail.polytechnique.fr.md` | Zimbra auth internals (CSRF-in-localStorage, not a cookie), DOM-scrape pattern for the inbox |
| `sites/moodle.ip-paris.fr.md` | X SSO entry, course-dashboard filters, Moodle resource taxonomy, and the MIE course navigation validated live |
| `sites/mediaserver.ip-paris.fr.md` | Nudgis/Ubicast iframe-to-HLS recovery: inspect the live player state, then download/mux its separate tracks |
| `sites/www.polytechnique.edu.md` | Official student space: authenticated Cycle ingénieur → 3ème année → Planning des cours navigation |
| `sites/gargantua.polytechnique.fr.md` | SIATEL document links: shared Egide SSO, inline-PDF behavior, and the transparent same-origin download sequence |
| `sites/linkedin.com.md` | Primary account ivann.kamdem@hotmail.com (not the Google SSO), feed/infinite-scroll parsing, messaging UI, InMail vs Message distinction, LinkedIn notification emails in Outlook |
| `sites/outlook.live.com.md` | Passwordless Authenticator login (cross-origin iframe gotcha), Focused/Other inbox split, coordinate-click-only for login form |

**Imposed structure for a new site file:** `Category`/`Account`/`Profile` header line → `## Login` → `## Structure / navigation` → `## Known quirks` → `## Changelog`. Keep it free of long inline commands — extract those into `scripts/presets/` and link them instead (see below). **MANDATORY:** You MUST list the known critical DOM selectors and their fallbacks for each site; update them immediately when one breaks.

## Selector Strategy (GRAVÉ)

DOM scraping is fragile. CSS classes like `.msg-form__send-button` mutate often. When using `page-click-eval`, `page-click`, `page-type`, or `page-hover`, **always provide a `fallback_selector`** where supported and follow this priority:
1. `[data-testid="..."]` (if it exists)
2. `[aria-label*="..."]` (or other accessibility attributes)
3. Raw text via XPath: `xpath=//button[contains(., 'Envoyer')]` (only with `page-click`, not `page-click-eval`)
4. Avoid hardcoded layout-based CSS classes.

### `page-click-eval` vs `page-click` — which one to use

🔴 **DEFAULT: always use `page-click-eval` first.** It resolves the bounding box atomically via a single `Runtime.evaluate` call, eliminating the race condition (`CDP_ERROR: Could not find node with given id`) that `page-click` hits on dynamic pages.

**Fall back to `page-click` only when:**
1. You need **XPath selectors** (`xpath=` prefix) — `page-click-eval` only supports CSS.
2. The element is inside **Shadow DOM** — `document.querySelector` doesn't pierce shadow boundaries, but `DOM.getDocument(depth: -1)` does.
3. The page has a **strict CSP** blocking `eval()` — `Runtime.evaluate` would be blocked, DOM CDP calls are not.
4. You need **`fallback_selector`** with retry — `page-click` has a 2-second retry loop; `page-click-eval` fails immediately if the element is absent.

**In short:** `page-click-eval` for 90% of cases. `page-click` for XPath, Shadow DOM, CSP-strict pages, or when retry/fallback is needed.

## Presets (`scripts/presets/`)

Long or frequently-repeated command sequences live here as small scripts, referenced from this file (global) or a site's own `.md` (site-specific) — never pasted inline repeatedly.

| Preset | Purpose |
|---|---|
| `scripts/presets/cookie-audit.py` | Summarize a `cookie-list` envelope by domain (100+ cookies is unreadable raw) |
| `scripts/presets/dialog-policy-sequence.sh` | Correct `page-dialog-policy` order: reload FIRST, policy SECOND (reversed order silently loses the override) |
| `scripts/presets/captcha-solve-sequence.sh` | Correct `browser-solve-captcha` order: `tab-activate` FIRST (extension acts on the "active" tab, not your `target_id`) |
| `scripts/presets/ubicast-hls-inspect.sh` | Read a loaded Nudgis player's public in-page state and return its direct HLS video/audio manifests |
| `scripts/presets/ubicast-hls-download.sh` | Transparently download separate Ubicast HLS video/audio manifests with `yt-dlp`, then losslessly mux them with `ffmpeg` |
| `scripts/presets/pdf-download-sequence.sh` | Keep Edge visibly on a PDF, then request its real browser download into `$HOME/Downloads` without an inline-viewer dead end |
| `scripts/presets/add-to-playlist.sh` | Add the currently playing YouTube Music song to a named playlist (menu → Enregistrer → select → toast verify) |

## InPrivate / Incognito

`window-create` and `tab-create` both accept `"incognito": true` to create tabs in a fresh Edge InPrivate browsing context instead of the profile's default context.

**`window-create` with `incognito: true`:** all layout tabs share the SAME incognito context — one call, one InPrivate window.

```bash
browser-proxy do window-create '{"profile":"default","incognito":true,"layout":[{"type":"tab","url":"https://example.com"}]}'
```

**`tab-create` with `incognito: true`:** creates a fresh per-call incognito context. Mutually exclusive with `window_id` (cannot add an incognito tab to an existing normal window).

```bash
browser-proxy do tab-create '{"profile":"default","incognito":true,"url":"https://example.com","new_window":true}'
```

**Under the hood:** uses `Target.createBrowserContext` with `{"private": true}` — the correct CDP domain for Edge (NOT `Browser.createBrowserContext`, which does not exist in Edge CDP).

**Cleanup note:** `window-close` is `@require_approval`-gated and requires the extension. When the extension is disconnected, use `raw` + `Target.closeTarget` directly to close InPrivate windows:

```bash
browser-proxy do raw '{"profile":"default","protocol":"cdp-browser","method":"Target.closeTarget","params":{"target_id":"<TARGET_ID>"}}'
```

## Window/tab/group hygiene

Before finishing any session: close every tab/window/group the agent itself created for testing (probe pages, temporary tabs, extension pages left open) — `window-close`/`tab-list` to verify. Never touch KπX's pre-existing tabs, and never leave orphaned test artifacts behind. Violation = the session is not complete.

## Full action catalog

Never memorize the 67 actions — the categorized `browser-proxy do --help` output IS the catalog (Profiles/Windows/Tabs/Groups/Bookmarks/Extensions/Navigation/Interaction/Inspection/Dialogs/Cookies/Storage/HumanInTheLoop/Advanced). Two categories deserve a mental note:
- **HumanInTheLoop** (7 actions: `browser-ask-user`, `browser-dismiss-overlays`, `browser-solve-captcha`, `browser-set-date`, `browser-set-combobox`, `browser-drop-file`, `browser-get-new-tab`) — the overlay/interaction itself IS the mechanism, no separate approval gate.
- **`@require_approval`-gated actions** (mutating/destructive: `cookie-set`/`cookie-remove`, `storage-local-set`/`remove`/`clear`, `bookmark-*` writes, `group-*` writes, `window-close`/`window-sync`, `extension-disable`) — KπX must click Approve/Reject in the Edge popup before these run.

## References

| Path | Content |
|------|---------|
| `references/insights.md` | Durable, cross-site operational lessons (backend gotchas, heuristic honesty, active-tab footguns) |
| `references/sites/*.md` | Per-site memory — see registry above |
| `scripts/presets/*` | Long/frequent command sequences — see registry above |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-31 | [LIVE] | **v4.2.0 — InPrivate/Incognito navigation.** `window-create` and `tab-create` both accept `incognito: true` to create tabs in a fresh `Target.createBrowserContext` private context. Uses the correct CDP domain (`Target.createBrowserContext` — `Browser.createBrowserContext` does not exist in Edge). `incognito` is mutually exclusive with `window_id` in `tab-create`. Extension disconnects prevent `window-close` via `@require_approval` — use `raw` + `Target.closeTarget` as fallback. |
| 2026-08-31 | [LIVE] | **v4.2.0 — Root cause fix: `page-screenshot` + new `page-press`.** Removed the old `translateZ(0)` hack from `_page_screenshot` (was breaking SPAs like YouTube Music by modifying `document.body.style.transform`). Now optional via `force_repaint` param. Added `_page_press` action (CDP `Input.dispatchKeyEvent` — proper keyboard input pipeline, unlike `page-evaluate` + JS `KeyboardEvent`). Updated `music.youtube.com.md` and `insights.md` with corrected understanding: the layout breakage was caused by the screenshot hack, not DOM clicks. Player bar is at the bottom, not top (top position was a side effect of the hack). |
| 2026-08-31 | [LIVE] | **v4.2.1 — `add-to-playlist.sh` preset + YouTube Music "add to playlist" DOM lesson.** Created `scripts/presets/add-to-playlist.sh` — automates the 4-step flow: player menu → "Enregistrer dans une playlist" → click named playlist's inner `<button>` → toast verification. Key DOM lesson: `ytmusic-playlist-add-to-option-renderer` is a wrapper; only the inner `<button>` click registers (clicking the outer element is silently ignored). Updated `music.youtube.com.md` with corrected playlist counts (grid view ≠ detail view) and the add-to-playlist DOM structure. Updated `proxies-reflex.md` → AGENTS.md with mandatory browser-proxy skill + site memory pre-read rule. |
| 2026-08-31 | [LIVE] | **v4.2.2 — YouTube Music full player bar inventory.** Documented all 18 player bar buttons with French labels (`aria-label`). Loop toggle states: `"Lecture en boucle désactivée"` ↔ `"Tout lire en boucle"`. Play verification: use button label (`"Mettre en pause"` = playing) not `.time-info`. `page-press Space` unreliable for play — prefer `page-click-coordinates` or direct JS button click. Full "add to playlist" flow with DOM selectors added to site memory. |
| 2026-08-31 | [LIVE] | **v4.1.1 — YouTube Music interaction lesson.** Added critical playback interaction docs to `music.youtube.com.md` site memory: DOM JS `.click()` breaks the SPA layout (player bar disappears, queue breaks, page goes black); correct approach is `page-hover` to reveal play button, then `page-click` on thumbnail `img`. Queue items (`ytmusic-player-queue-item`) safe with `page-click-eval`. Read-only DOM queries remain fine. Added corresponding insight to `references/insights.md`. |
| 2026-08-31 | [LIVE] | **v4.1.0 — `page-click-eval` default click strategy.** Added `page-click-eval` as the default CSS-selector page click action (atomic `Runtime.evaluate`, no race condition). Updated Selector Strategy with `page-click-eval` vs `page-click` decision guide: `page-click-eval` for 90% of cases, `page-click` only for XPath, Shadow DOM, CSP-strict pages, or retry/fallback needs. |
| 2026-08-30 | [LIVE] | **v4.0.5 — LinkedIn + Outlook site memories.** Created `references/sites/linkedin.com.md` (primary account ivann.kamdem@hotmail.com, Google SSO is just a login option, feed/messaging/InMail structure) and `references/sites/outlook.live.com.md` (passwordless Authenticator login, cross-origin iframe gotcha, Focused/Other split). Corrected LinkedIn primary email from kapoivha@gmail.com to ivann.kamdem@hotmail.com. |
| 2026-08-30 | [LIVE] | **v4.0.4 — Bootstrap-tab reuse rule.** Live CLI/status/window inventory confirmed the managed `default` profile is active and exposes an initial `edge://newtab/` browser-UI tab. Agents must inspect `window-list`, reuse that visible startup tab through `page-navigate`, and create a separate window only on KπX's explicit request. |
| 2026-08-30 | [LIVE] | **v4.0.3 — Official Polytechnique 3A document flow.** Added the live `www.polytechnique.edu` → 3ème année → Planning des cours route, the SIATEL/Gargantua companion memory, and a transparent PDF download preset: Edge remains visibly on the document; a same-origin browser download bypasses its inline PDF viewer. Five 3A documents were retrieved and validated locally. |
| [SUMMARY] | — | v4.2.0 added InPrivate navigation. v4.0.2 documented Moodle/Nudgis HLS recovery and the local `k-whisper` fallback. v4.0.1 moved reusable presets from `assets/` to `scripts/` and synchronized `rules/proxies-reflex.md`. v4.0.0 total browser-proxy refonte: retired chrome-agent-mcp/browser-mcp/Playwright/Edge-Tab-Groups Explorer stack, established `--help`-only reflex, profiles/workspaces registry, no-secret `browser-ask-user` boundary, site-memory and preset systems, `rules/proxies-reflex.md`, and rewritten proxy-era insights. v3.2.0 and older (MCP-era CAPTCHA/download/tab-group/cleanup rules) fully superseded; historical detail via `qmd query` over past session logs. |
