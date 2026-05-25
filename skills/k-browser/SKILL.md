---
name: k-browser
description: KπX Browser Automation — Standardized MCP interfaces (Playwright & Browser MCP) for Edge/Chromium. Persistent sessions, accessibility-tree focus, and profile-aware automation.
license: private
metadata:
  author: KpihX
  version: "1.3.0"
  scope: agent-tooling
  mcp-servers:
    - playwright (@playwright/mcp)
    - browser (@agent-infra/mcp-server-browser)
---

# KπX Browser — Standardized Automation

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

**⚠️ USE STANDARDIZED MCP SERVERS INSTEAD OF AD-HOC SCRIPTS (PLAYWRIGHT/BROWSER-USE) UNLESS EXPLICITLY ASKED.**

## Architecture

This skill governs the interaction with web browsers via MCP servers. It prioritizes semantic understanding (Accessibility Tree) over visual guessing.

- **Playwright MCP:** Best for high-reliability, isolated, or testing tasks. Uses accessibility snapshots.
- **Browser MCP:** Best for authenticated sessions (Google, Microsoft, LinkedIn) as it attaches to the active user profile.

## Sovereign Bookmarks

The browser's bookmarks are managed as sovereign assets within this skill.

- **Current Baseline:** `assets/bookmark.html` (Sovereign hierarchy).
- **Legacy Reference:** `assets/bookmark.old.html` (Original dump).
- **Source of Truth:** `assets/bookmark.md` (Markdown hierarchy).
- **Recent Export:** `assets/favorites_5_2_26.html` (Dump from 2026-05-02).
- **Management:** Any major reorganization should be done via Markdown transformation scripts and audited against the baseline.

## Operational Rules

1. **SINGLE SESSION:** Never open multiple windows in bursts. Maintain a single persistent session when possible.
2. **SEMANTIC FIRST:** Use accessibility snapshots before clicks; Playwright MCP uses **`target`** refs from `browser_snapshot`, not `ref`.
3. **NO BRICOLAGE:** Do not write custom Playwright Python/Node scripts in the workspace for general navigation. Use the MCP tools.
4. **CONSENT BYPASS:** Use specialized patterns to handle common cookie/consent banners instead of manual clicks.
5. **INSIGHTS:** Read `references/insights.md` before non-trivial bookmark or automation work.

### Leave no trace (mandatory — production default)

**Default:** one deliberate action → verify outcome → **clean up in the same workstream** before ending the turn. Do not leave test tabs, `edge://` utility pages, stray workspaces, or bookmark folders behind.

| Mode | When | Behavior |
|------|------|----------|
| **Production** | Any real KπX workflow unless KπX explicitly allows a sandbox | Reuse **one** CDP page + `goto`; close every tab you opened; remove test favorites/workspaces; end on a sensible user tab (e.g. prior Gmail). **No** bulk `context.newPage()` / tab storms. |
| **Authorized test** | KπX explicitly allows exploration (e.g. live Edge capability pass) | Still **manual** cleanup after: close debris highest index first; verify with `browser_tabs` list + `edge://spaceworks/` counts. **No** cleanup shell scripts — step-by-step MCP only. |

**Post-session checklist (Edge agent / Playwright CDP):**

1. `browser_tabs` **list** — grep mentally for: `example.com`, `httpbin`, `wikipedia`, `copilot.microsoft`, `edge://tab-search`, `edge://copilot-ntp`, `edge://favorites`, `edge://spaceworks` (close if only opened for the task).
2. `edge://spaceworks/` — only expected workspaces (e.g. **KpihX-Labs**, **X**); no **Agent-Sandbox-*** left behind.
3. `edge://favorites/` — delete test folders under **Favorites bar** (`fake`, `agent-sandbox-bookmarks`, etc.); if Fluent context menu is not in the a11y tree, **stop and ask KπX** for a 10s manual delete (documented limitation).
4. Re-select the tab KπX was using before automation (often Gmail).
5. Patch **`k-browser`** + **`references/insights.md`** + **`$HOME/Work/techskills/edge-agent-cdp-setup.md`** with anything new — never leave learnings only in chat.

**Runbooks:** `$HOME/Work/techskills/edge-agent-cdp-setup.md` (live test + cleanup) · `$HOME/.agents/skills/k-browser/references/edge-cdp-setup.md`.

## Key Tools

| Server | Primary Action | Use Case |
|--------|----------------|----------|
| `playwright` | `navigate`, `click`, `type` | General high-level tasks. |
| `browser` | `attach`, `list_tabs` | Interacting with user's live windows & sessions. |

## Edge agent (visible profile + CDP)

**Runbook:** `$HOME/.agents/skills/k-browser/references/edge-cdp-setup.md` · user guide: `$HOME/Work/techskills/edge-agent-cdp-setup.md`

| Step | Command / config |
|------|------------------|
| Start Edge | `edge-agent` (from `.kshrc` → `assets/edge-agent.ksh`) |
| Check CDP | `edge-agent-status` |
| Vaultwarden + BW ext | `scripts/bw-prelogin-check.sh` (404 = upgrade server to 1.36.0+) |
| Cursor MCP | `browser-mcp-stdio`, `playwright-mcp-stdio` in `$HOME/.cursor/mcp.json` (attach :9222) |
| Profile | `$HOME/.config/kpihx-edge-automation` — sign in once; not Default |

Vision: `$HOME/.agents/skills/k-context/references/edge-agent-automation-vision.md`.

## Insights

- **Session Lock:** If the profile is locked, ensure no other Edge instance is using the same data directory.
- **CDP Port:** Default is `9222`. Run `edge-agent.sh` (or equivalent flags) before `browser` MCP attach.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-25 | [CURSOR] | v1.3.0 — **Leave no trace** operational rules + post-session Edge cleanup checklist; production vs authorized-test modes. |
| 2026-05-25 | [CURSOR] | v1.2.2 — Live-test runbook: workspaces, tab-search, favorites, Copilot cookie gate; TabGroups CDP absent on Edge 148. |
| [SUMMARY] | — | v1.2.1–v1.0.0 edge-agent CDP setup, bw-prelogin, techskills; v1.1.x bookmarks baseline; Playwright/Browser MCP standardization |
