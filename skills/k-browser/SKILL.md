---
name: k-browser
description: KπX Edge Automation — chrome-agent-mcp (CDP) + browser-mcp (extension) + Edge Tab Groups Explorer extension
license: private
metadata:
  author: KpihX
  version: "3.2.0"
  scope: agent-tooling
  mcp-servers:
    - chrome-agent (chrome-agent-mcp)
    - browser (@agent360/browser-mcp)
  edge-extension:
    - Edge Tab Groups Explorer (gkcifcdcmloogpddjlcbbbaicnpmajao)
---

> **OS references:** `references/windows.md` (Windows Chrome/Edge CDP setup, WSL forwarding)

# KπX Browser Automation

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Architecture — Two MCPs

| MCP | Transport | Scope | Use |
|-----|-----------|-------|-----|
| **chrome-agent-mcp** | CDP :9222 | Navigation, click, evaluate, devtools, tabs, windows | 90% of tasks |
| **browser-mcp** (`@agent360/browser-mcp`) | WebSocket :9876 + Chrome extension | `ask_user`, `solve_captcha`, `dismiss_overlays`, `set_date`, `set_combobox`, `drop_file` | 10% (CAPTCHA/2FA/special forms) |

### chrome-agent-mcp — Tools

| Tool | Action |
|------|--------|
| `browser_tabs` | List/create/close/switch tabs |
| `chrome_windows` | List windows and their tabs |
| `browser_navigate` | Navigate to URL |
| `browser_click` | Click element by ref |
| `browser_snapshot` | Accessibility tree |
| `browser_evaluate` | Run arbitrary JS |
| `browser_type` / `fill_form` / `select_option` | Form interaction |
| `browser_take_screenshot` | Screenshot |
| `devtools_console` / `network` / `elements` / `storage` | DevTools inspection |
| `chrome_extensions` / `chrome_focus` | Extension list / focus tab |

### browser-mcp — Tools (extension only)

| Tool | Use case |
|------|----------|
| `browser_ask_user` | Credentials/2FA overlay (user sees popup) |
| `browser_solve_captcha` | reCAPTCHA/hCaptcha/Turnstile |
| `browser_dismiss_overlays` | Cookie banners, modals |
| `browser_set_date` | Native + MUI/AntD date pickers |
| `browser_set_combobox` | Autocomplete multi-select |
| `browser_drop_file` | Drag-drop zones without file input |
| `browser_handle_dialog` | JS alert/confirm/prompt |
| `browser_get_new_tab` | OAuth popup interceptor |

## CRITICAL RULES — Before ANY action

### 1. NEVER create a tab without checking if it already exists
```javascript
// ❌ WRONG: creates a blind duplicate without checking

// ✅ CORRECT: first check if the tab already exists in any window

  // Determine the correct window (academic → X, personal → KpihX-Labs)

// ❌ WRONG: creates in the current window (may be the wrong one)

// ✅ CORRECT: explicit target window

// Before creating or moving, always identify the correct window first
const all = await chrome.tabs.query({});
const xWin = all.find(t => t.url.includes('moodle.ip-paris'))?.windowId || X_WIN_ID;
const labWin = all.find(t => t.url.includes('opencode.ai'))?.windowId || LAB_WIN_ID;
```

### 3. Clean parasitic tabs immediately
After each command, scan for and close:
- `chrome-extension://` pages (except the extension you're using)
- `about:blank`, `edge://newtab/` orphaned
- Popups and redirects

```javascript
const tabs = await chrome.tabs.query({});
for (const t of tabs) {
  const u = t.url || '';
  if ((u.startsWith('chrome-extension://') && !u.includes('gkcifcd'))
      || u === 'about:blank' || u === 'edge://newtab/') {
    await chrome.tabs.remove(t.id);
  }
}
```

### 5. Verify after every action — never assume
After any mutation (create, move, group, close):
1. Re-read full state: `chrome.windows.getAll()` + `chrome.tabs.query()`
2. Confirm: tabs in right window? no duplicates? no parasites?
3. If not clean → fix immediately before continuing

## Edge Workspace & Tab Groups

CDP exposes tabs but NOT tab groups or collapsed tabs. The **Edge Tab Groups Explorer** extension fills the gap:

```javascript
// From the extension page (chrome-extension://gkcifcd.../manifest.json)
const [wins, groups, tabs] = await Promise.all([
  chrome.windows.getAll({populate: true}),
  chrome.tabGroups.query({}),
  chrome.tabs.query({})
]);
```

### Extension ID & Path

```
ID:   gkcifcdcmloogpddjlcbbbaicnpmajao
Path: ~/.agents/skills/k-browser/scripts/edge-tabgroups-extension/
Load: edge://extensions/ → Developer mode → Load unpacked
```

### Reading tab content

```javascript
// Requires scripting permission + host_permissions for all URLs
const [result] = await chrome.scripting.executeScript({
  target: {tabId: TAB_ID},
  func: () => document.body?.innerText?.trim()?.slice(0, 5000) || ''
});
```

### Creating tab groups — WINDOW CONTEXT MATTERS

`chrome.tabs.group` creates the group in the CALLING extension's window. To group tabs in a different window:

```javascript
// 1. Move the extension tab to the target window FIRST
await chrome.tabs.move(EXTENSION_TAB_ID, {windowId: TARGET_WIN, index: -1});

// 2. Group from that window (extension is now in target window)
const g = await chrome.tabs.group({tabIds: [TAB_ID_1, TAB_ID_2]});
await chrome.tabGroups.update(g, {title: 'Group Name', color: 'blue'});

// 3. Move extension back if needed
await chrome.tabs.move(EXTENSION_TAB_ID, {windowId: ORIGIN_WIN, index: -1});
```

**Always verify windowId before grouping tabs from different windows.**

### Moving tabs between windows

`chrome.tabs.move` does NOT preserve groups — regroup after moving.

## CAPTCHA solving

| Tool | reCAPTCHA checkbox | reCAPTCHA grid images | hCaptcha | Canvas CAPTCHA | React widget |
|------|-------------------|----------------------|----------|---------------|-------------|
| **chrome-agent-mcp** | ✅ via iframe | ❌ no image analysis | ❌ | ❌ | ❌ |
| **browser-mcp** | ✅ `solve_captcha` | ✅ `solve_captcha` | ✅ | ❌ | ❌ |

**Best practice:** use browser-mcp's `browser_solve_captcha` with `action: "detect"` first, then `action: "click_checkbox"` or `action: "click_grid"` with cell indices. If browser-mcp is unavailable, chrome-agent-mcp can sometimes click the checkbox via iframe `contentDocument`.

**Limitations:**
- Canvas-based CAPTCHAs (GoCaptcha, custom) cannot be solved — no tool can read canvas pixels
- React widgets with synthetic events ignore programmatic clicks
- Most OAuth flows (Google, Microsoft) bypass CAPTCHA entirely when session is active

## Downloading files — bypass native Save As dialog

The native OS "Save As" dialog cannot be interacted with via CDP or browser MCP. Use CDP's `Browser.setDownloadBehavior`:

```python
import json, urllib.request, asyncio, websockets


async def set_download_path(path="/tmp"):
    resp = json.loads(
        urllib.request.urlopen("http://127.0.0.1:9222/json/version").read()
    )
    async with websockets.connect(resp["webSocketDebuggerUrl"]) as ws:
        await ws.send(
            json.dumps(
                {
                    "id": 1,
                    "method": "Browser.setDownloadBehavior",
                    "params": {"behavior": "allow", "downloadPath": path},
                }
            )
        )
        await asyncio.wait_for(ws.recv(), timeout=5)


# Then trigger the download (click Download button / link)
# File lands directly in path without any dialog
```

**Steps:**
1. Connect to browser-level WebSocket via `/json/version`
2. Send `Browser.setDownloadBehavior` with `behavior: "allow"` and desired path
3. Trigger download via normal click — file saved directly, no popup

## CDP Configuration

Edge is patched to always start with `--remote-debugging-port=9222`:
- `/opt/microsoft/msedge/microsoft-edge` wrapper script
- System and user `.desktop` files

### Permanent CDP Setup (survives Edge updates)

The wrapper at `/opt/microsoft/msedge/microsoft-edge` gets overwritten on each Edge update. Use a user-local wrapper instead:

**Source of truth:** `~/.agents/skills/k-browser/assets/msedge-wrapper.sh`
```bash
#!/bin/bash
exec /opt/microsoft/msedge/msedge --remote-debugging-port=9222 "$@"
```

**Symlink:** `~/.local/bin/msedge` → `~/.agents/skills/k-browser/assets/msedge-wrapper.sh`
This works because `~/.local/bin/` is in your `$PATH` before `/opt/microsoft/msedge/`.

**Desktop entry:** `~/.local/share/applications/msedge.desktop` → `~/.agents/skills/k-browser/assets/msedge.desktop`
With `Exec=msedge --remote-debugging-port=9222 %U`. Local `.desktop` files take priority over system ones, so clicking the Edge icon launches with CDP enabled.

**Why this survives updates:** Both the wrapper script and the `.desktop` file are stored in `.agents/` and only symlinked to their system locations. Edge updates only touch `/opt/microsoft/msedge/` and `/usr/share/applications/`, never `~/.local/` or `~/.agents/`.

**Reinstall steps (after fresh Edge install):**
```bash
chmod +x ~/.agents/skills/k-browser/assets/msedge-wrapper.sh
ln -sf ~/.agents/skills/k-browser/assets/msedge-wrapper.sh ~/.local/bin/msedge
ln -sf ~/.agents/skills/k-browser/assets/msedge.desktop ~/.local/share/applications/msedge.desktop

## MCP Configuration

### OpenCode (`~/.config/opencode/opencode.jsonc`)
```jsonc
"browser": { "command": ["browser-mcp"], "enabled": true, "timeout": 60000 },
"chrome-agent": { "command": ["chrome-agent-mcp"], "enabled": true, "timeout": 60000 }
```

### Cursor (`~/.cursor/mcp.json`) & Cline (`~/.cline/data/settings/cline_mcp_settings.json`)
```json
"browser": { "command": "browser-mcp" },
  "chrome-agent": { "command": "chrome-agent-mcp" }
```

## Scripts

| Path | Purpose |
|------|---------|
| `scripts/edge-tabgroups-extension/` | Edge extension for tabGroups + scripting |
| `scripts/edge-workspace-tree.py` | Display workspace/tab tree |

## References

| Path | Content |
|------|---------|
| `references/edge-cdp-setup.md` | CDP :9222 setup details |
| `references/insights.md` | Durable runtime lessons |
| `references/workflows-google-ai-studio.md` | AI Studio automation |

## Post-session cleanup — CRITICAL RULE (NEVER BYPASS)

**Before finishing any session, ALL intermediaries MUST be closed:**

1. **Test/probe tabs** → about:blank, CAPTCHA demo pages, any URL opened for testing
2. **Extension pages** → `chrome-extension://*` (except the one you're actively using)
3. **Temporary email tabs** → Outlook/Gmail test tabs opened to fetch codes
4. **Extra windows** → any window that is NOT one of the user's Edge Workspaces

**Allowed to remain:**
- Only the user's workspace windows (KpihX-Labs, X)
- Only tabs that were there before the session started (or explicitly requested by user)

**Verify after cleanup:**
```javascript
const wins = await chrome.windows.getAll({populate: true});
// If any win has <2 tabs or contains only extension/test pages → close it
```

**Violation:** leaving any intermediary tab = session considered incomplete.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-29 | [OPENCODE] | v3.2.0 — CAPTCHA limits documented. Post-session cleanup rule hardened to GRAVÉ level: ALL intermediaries (test tabs, extension pages, temp email tabs, extra windows) MUST be closed. Only workspace windows remain. insights.md updated. |
| 2026-05-29 | [OPENCODE] | v3.1.0 — Download fix: `Browser.setDownloadBehavior` bypasses native Save As dialog. Critical grouping lessons (window context, content classification, post-verify). `chrome.tabs.group` does NOT support cross-window — move extension first. |
| [SUMMARY] | — | v3.0.0 Stack: chrome-agent + browser-mcp + Tab Groups (Playwright removed); v2.x chrome-agent added, CDP architecture; v1.x legacy. |
