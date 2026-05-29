# Insights — Browser & Bookmarks

- **Bookmark Source of Truth:** The current sovereign bookmark hierarchy is stored in `assets/bookmark.html`.
- **Legacy Audit:** `assets/bookmark.old.html` contains the original unorganized dump for historical reference.
- **Reorganization Logic:** The transition from `old` to `new` involved merging duplicates, shortening titles (e.g., "Kaggle" instead of full page title), and categorizing into `KpihX-Labs`, `X`, `Fr`, `E-Tools`, etc.
- **MCP Integration:** When using `browser` or `playwright` MCPs, prioritize navigating via these bookmarks if the task involves frequent access to the homelab or academic portals.
- **Edge CDP (2026-05-29):** Edge always on :9222 via wrapper + .desktop patches. No separate agent profile. `edge-agent.ksh` removed, `kpihx-edge-automation` profile deleted.
- **tmux video watch (2026-05-26):** `run_watch_pane.sh` = background writer + `tail -f` log — avoid `watch`+`clear` (frozen display).
- **Browser MCP does NOT support CDP (2026-05-28):** `@agent360/browser-mcp` = WebSocket :9876-9895 + Chrome extension only. No `--cdp-endpoint` option. The extension creates an isolated session — cannot see user's existing Edge tabs/windows. Source: `index.js` (WebSocketServer, no CDP code).
- **Playwright MCP supports CDP natively (2026-05-28):** `@playwright/mcp` accepts `--cdp-endpoint http://127.0.0.1:9222`. Sees ALL existing Edge tabs, shares cookies/sessions/extensions. No extension required.
- **Edge default CDP (2026-05-28):** `.desktop` file patched with `--remote-debugging-port=9222` on all Exec lines. Edge always available on CDP :9222 without `edge-agent`.
- **Cursor MCP config (2026-05-28):** `playwright` uses `playwright-mcp --cdp-endpoint http://127.0.0.1:9222`. `browser` kept as `browser-mcp` (no `-stdio` suffix — non-existent binary).
- **Cline MCP config (2026-05-28):** Same as Cursor. Fixed broken `browser-mcp-stdio` / `playwright-mcp-stdio` references.
- **Browser MCP known limitations (2026-05-28):** (1) `copilot.microsoft.com` blocked (Edge privileged page — "cannot be scripted"). (2) Gmail requires JS click workarounds (SPA). (3) File download triggers native Save As (no MCP interaction). (4) Only session isolation — can't see user's existing tabs.
- **AI Studio Code execution (2026-05-28):** Gemini 3.5 Flash → "permission denied" with Code execution + Grounding ON. Fix: switch to Gemini 3 Flash Preview, turn Grounding OFF. Submit via `button[aria-label="Run the prompt"]` or `button:text(Run keyboard_return)`. Download image: JS anchor `a.download` from blob URL, or lightbox Download button.
- **Vibe/Mistral AI (2026-05-28):** No file/image upload in chat interface. Upload via "+" button → "Upload Files" menu → hidden `input[type="file"]` (accepts .png). `browser_drop_file` works with `input[type="file"]` selector. File must be base64'd for JS injection (blob URL blocked).

# === FINAL STACK (2026-05-29) ===
# Clean k-browser stack:
# - chrome-agent-mcp (CDP :9222) → 90% : navigation, click, evaluate, devtools, tabs
# - browser-mcp (@agent360 extension) → 10% : CAPTCHA, 2FA, ask_user, date/combobox
# - Playwright MCP removed (redundant with chrome-agent)
# - Extension Edge Tab Groups Explorer → tabGroups + scripting for structure + content
# - edge-agent.sh / synapses-agenda / bw-preglog → deleted
# - assets bookmarks → deleted
# - sexemodel-insights / workflows-academic-portals → deleted
# Unified agent configs: opencode.jsonc / .cursor/mcp.json / .cline/mcp_settings.json
# Edge --remote-debugging-port=9222 via patched wrapper script + .desktop files

# 🔴 CAPTCHA SOLVING LIMITS (2026-05-29)
# browser-mcp's `browser_solve_captcha` is the only tool that can detect + click
# reCAPTCHA/hCaptcha checkbox AND grid images automatically.
# chrome-agent-mcp can click reCAPTCHA checkbox if iframe is accessible
# (works on google.com/demo but may fail on cross-origin restrictions).
#
# Barriers that NO tool can cross:
# - Canvas-based CAPTCHAs (GoCaptcha, etc.) — need image analysis + mouse events
# - React synthetic events (Latcha widget) — need real user click
# - Shadow DOM closed components (Edge spaceworks, extensions page)
#
# browser-mcp extension was NOT connected during testing — its WebSocket
# was lost during Edge restarts. To fix: reload extension via edge://extensions/.

# 🔴 SAVE AS DIALOG (2026-05-29)
# Edge native "Save As" dialog cannot be clicked via CDP or browser MCP.
# SOLUTION: use CDP Browser.setDownloadBehavior to bypass the dialog:
#   Browser.setDownloadBehavior → behavior: "allow", downloadPath: "/tmp"
# This is a CDP command sent to the BROWSER-level WebSocket (/json/version),
# NOT to a page target. After setting, any download goes directly to path.
#
# Alternative: extract cookie from Edge profile (sqlite3 ~/.config/microsoft-edge/Default/Cookies)
# and use curl to download files directly. But this requires knowing the exact download URL.

# 🔴 TAB GROUP CRITICAL RULES (2026-05-29)
# 1. chrome.tabs.group creates the group in the CALLING extension's window context.
#    Grouping tabs from window 2 while extension is in window 1 MOVES them to window 1.
#    FIX: move the extension tab to the target window BEFORE grouping.
# 2. NEVER group tabs without checking windowId. Filter by windowId first.
# 3. Classify by CONTENT (innerText), not by tab title alone.
#    "Zimbra" title → content shows webmail.polytechnique.fr → must be in X workspace.
# 4. ALWAYS verify after every action: re-read wins + groups + tabs, compare.
# 5. chrome.tabs.move does NOT preserve groups → regroup after move.
# 6. Always clean up: close test tabs, popups, extension pages, blank tabs.
# 7. Edge Workspaces cannot be created via API — guide user to edge://spaceworks/
