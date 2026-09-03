---
name: k-browser
description: KπX Edge Automation via browser-proxy — the sovereign JSON-RPC daemon that is the agent's window onto the external world (web UIs with no native tool/MCP). Load before ANY browser-driving task, or whenever a headless/curl approach gets stuck and a web UI is the only remaining path.
license: private
metadata:
  author: KpihX
  version: "5.4.0"
  scope: agent-tooling
  cli: browser-proxy
---

# KπX Browser Automation — browser-proxy

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

**⚠️ EDIT SOURCE — not generated.** Update header version + footer changelog on every edit.

**Source code:** `$HOME/KpihX-Labs/Proxies/browser-proxy/src/browser_proxy/` — key files: `actions.py` (all action handlers), `cdp.py` (CDP protocol), `cli.py` (CLI entry), `models.py` (envelope/response models). Service: `services/browser-proxy-profile@.service`.

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
| `sites/gemini.google.com.md` | Gemini chat UI: DataTransfer upload pattern, canvas→base64 image extraction, Enter-key send, INFINITE-SCROLLER navigation, conversation management, prompt patterns |
| `sites/aistudio.google.com.md` | Attachment-readiness gate, code-exec/grounding conflicts, model catalog, history cleanup |
| `sites/synapses.polytechnique.fr.md` | Egide/Shibboleth SSO chain (shared with Gargantua/Moodle), catalogue navigation, download-path gotcha |
| `sites/webmail.polytechnique.fr.md` | Zimbra auth internals (CSRF-in-localStorage, not a cookie), DOM-scrape pattern for the inbox |
| `sites/moodle.ip-paris.fr.md` | X SSO entry, course-dashboard filters, Moodle resource taxonomy, and the MIE course navigation validated live |
| `sites/mediaserver.ip-paris.fr.md` | Nudgis/Ubicast iframe-to-HLS recovery: inspect the live player state, then download/mux its separate tracks |
| `sites/www.polytechnique.edu.md` | Official student space: authenticated Cycle ingénieur → 3ème année → Planning des cours navigation |
| `sites/gargantua.polytechnique.fr.md` | SIATEL document links: shared Egide SSO, inline-PDF behavior, and the transparent same-origin download sequence |
| `sites/linkedin.com.md` | Primary account ivann.kamdem@hotmail.com (not the Google SSO), feed/infinite-scroll parsing, messaging UI, InMail vs Message distinction, LinkedIn notification emails in Outlook |
| `sites/outlook.live.com.md` | Passwordless Authenticator login (cross-origin iframe gotcha), Focused/Other inbox split, coordinate-click-only for login form |

**Imposed structure for a new site file:** `Category`/`Account`/`Profile` header line → `## Login` → `## Structure / navigation` → `## Known quirks` → `## Changelog` (site-level). Keep it free of long inline commands — extract those into `scripts/presets/` and link them instead (see below). **MANDATORY:** You MUST list the known critical DOM selectors and their fallbacks for each site; update them immediately when one breaks.

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
| `scripts/presets/gemini-upload.py` | Upload a local image to Gemini via DataTransfer pattern (`TARGET_ID`, `IMAGE_PATH`, optional `FILENAME`) |
| `scripts/presets/gemini-extract-images.py` | Extract all generated blob images from a Gemini conversation via canvas→base64→file (`TARGET_ID`, `OUTPUT_DIR`) |
| `scripts/presets/gemini-batch-upload.sh` | Upload multiple images to Gemini in sequence — handles Importation menu cycle per file (`TARGET_ID`, `IMAGE1 [IMAGE2 ...]`) |

## InPrivate / Incognito

A tab's privacy status is determined by its **window**, not by any per-tab parameter. This is a direct consequence of how CDP isolates browser contexts.

### Mental model: browserContextId = privacy boundary

Every tab lives inside a **browser context** (`browserContextId`). The default profile uses one shared context. InPrivate windows each get a **separate disposable context** — cookies, localStorage, session storage, service workers are all isolated. `window-create` with `"incognito": true` calls `Target.createBrowserContext` with `{"private": true}` to spin up a fresh disposable context, then places all layout tabs inside it.

```mermaid
┌─ Default context ─────────────────────┐  ┌─ InPrivate context ─────────────┐
│  Tab A  (normal)                      │  │  Tab B  (incognito)             │
│  Tab C  (normal)                      │  │  Tab D  (incognito)             │
│  Tab E  (normal)                      │  │                                 │
│  Cookies: real logins                 │  │  Cookies: isolated, disposable  │
│  localStorage: real app state         │  │  localStorage: empty            │
└───────────────────────────────────────┘  └─────────────────────────────────┘
```

### Create an InPrivate window

`window-create` with `"incognito": true` — all layout tabs share the SAME incognito context.

```bash
browser-proxy do window-create '{"profile":"default","incognito":true,"layout":[{"type":"tab","url":"https://example.com"}]}'
```

### Add tabs to an InPrivate window

`tab-create` with just `window_id` — the tab automatically inherits the window's `browserContextId`. No extra flag needed.

```bash
browser-proxy do tab-create '{"profile":"default","window_id":<INPRIVATE_WINDOW_ID>,"url":"https://example.com"}'
```

### Close windows and tabs

- **`window-close`** takes `window_id` — closes all tabs, Edge auto-closes the window.
- **`tab-close`** takes `target_ids` — closes specific tabs; if last tab in a window, the window auto-closes.

Both are `@require_approval`-gated. When the extension is disconnected, use `raw` + `Target.closeTarget` directly (see fallback below).

### Detect InPrivate

`window-list` returns `incognito: true/false` per window, computed by comparing the first tab's `browserContextId` against the most common (default profile) context. `window-get` returns the same field.

### Why this matters (use cases)

| Use case | Why InPrivate | How |
|----------|--------------|-----|
| **Scraping without session bleed** | No cookies from your real logins leak into the scrape session | `window-create incognito:true` + curl/bulk download from that context |
| **Age-gated / auth-gated sites** | Fresh cookies per session, no leftover login state | InPrivate window with cookie injection (see `references/scraping.md`) |
| **Testing a site as a new user** | No localStorage, no cache, no service workers from previous visits | InPrivate window + `page-navigate` |
| **Multi-account testing** | Each window = isolated identity | Multiple InPrivate windows, each with different cookies |
| **Anti-fingerprint isolation** | Session state from one site can't leak to another | Separate context per site |

### What works / What doesn't in InPrivate

| ✅ Works | ❌ Broken (Chromium platform limitation) |
|----------|------------------------------------------|
| `tab-create` with `window_id` | `group-create` in InPrivate — "No tab with id" (use Edge UI directly) |
| `tab-close` with `target_ids` | `group-add-tabs` / `group-remove-tabs` in InPrivate |
| `tab-activate` | `tab-move` (cross-group) |
| `page-navigate` / `page-click` / `page-evaluate` | `window-sync` layout grouping |
| `window-create` / `window-close` | |
| `window-list` / `tab-list` (with `incognito` flag) | |

`group-create` now **requires `window_id`** — the target Edge window where the group will be created. This prevents accidentally grouping tabs from the wrong window. The extension passes `createProperties: { windowId }` to `chrome.tabs.group()`. Missing `window_id` raises a clear `ValueError`.

`chrome.tabs.group()` calls `GetTabById()` which fails to find tabs in InPrivate windows despite
`"incognito": "spanning"` + "Allow in incognito" being active. Edge's native drag & drop uses an
internal code path not exposed via the extension API. For InPrivate grouping, use Edge's UI directly.

### Fallback: raw CDP when extension is disconnected

```bash
browser-proxy do raw '{"profile":"default","protocol":"cdp-browser","method":"Target.closeTarget","params":{"target_id":"<TARGET_ID>"}}'
```

## Window/tab/group hygiene

Before finishing any session: close every tab/window/group the agent itself created for testing — `window-close` (by `window_id`) or `tab-close` (by `target_ids`) to verify. Never touch KπX's pre-existing tabs, and never leave orphaned test artifacts behind. Violation = the session is not complete.

## Full action catalog

Never memorize the 71 actions — the categorized `browser-proxy do --help` output IS the catalog (Profiles/Windows/Tabs/Groups/Bookmarks/Extensions/Navigation/Interaction/Inspection/Dialogs/Cookies/Storage/HumanInTheLoop/Advanced). Two categories deserve a mental note:
- **HumanInTheLoop** (7 actions: `browser-ask-user`, `browser-dismiss-overlays`, `browser-solve-captcha`, `browser-set-date`, `browser-set-combobox`, `browser-drop-file`, `browser-get-new-tab`) — the overlay/interaction itself IS the mechanism, no separate approval gate.
- **`@require_approval`-gated actions** (mutating/destructive: `cookie-set`/`cookie-remove`, `storage-local-set`/`remove`/`clear`, `bookmark-*` writes, `group-*` writes, `window-close`/`tab-close`/`window-sync`, `extension-disable`) — KπX must click Approve/Reject in the Edge popup before these run.

## References

| Path | Content |
|------|---------|
| `references/insights.md` | Durable, cross-site operational lessons (backend gotchas, heuristic honesty, active-tab footguns) |
| `references/scraping.md` | Generic scraping methodology: browser-proxy + CLI hybrid for bulk extraction (AJAX pagination, cookie management, rate-limit strategy, InPrivate sessions, URL encoding, semantic filtering) |
| `references/sites/*.md` | Per-site memory — see registry above |
| `scripts/presets/*` | Long/frequent command sequences — see registry above |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-03 | [LIVE] | v5.4.0 `group-create` now requires `window_id` — prevents wrong-window grouping; InPrivate docs clarified. browser-proxy v0.8.1 published. |
| 2026-09-03 | [LIVE] | v5.3.0 Added gemini.google.com.md site memory (DataTransfer upload, canvas extraction, conversation patterns). Added 3 Gemini presets: gemini-upload.py, gemini-extract-images.py, gemini-batch-upload.sh. |
| [SUMMARY] | — | v5.2.0 InPrivate limitation documentation · v5.1.0 InPrivate section enriched · v5.0.0 InPrivate refactoring · v4.3.0 generic scraping methodology · v4.2.x page-click-eval default, YouTube Music interaction/inventory/playlist lessons, page-screenshot root-cause fix, InPrivate/Incognito navigation · v4.1.x page-click-eval strategy + YouTube Music interaction · v4.0.5 LinkedIn + Outlook site memories · v4.0.4 Bootstrap-tab reuse rule · v4.0.3 Official Polytechnique 3A document flow · Earlier versions → `references/log.md`. |
