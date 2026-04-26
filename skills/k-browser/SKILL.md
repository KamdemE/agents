---
name: k-browser
description: KπX Browser Automation — Standardized MCP interfaces (Playwright & Browser MCP) for Edge/Chromium. Persistent sessions, accessibility-tree focus, and profile-aware automation.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
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
- **Management:** Any major reorganization should be done via Markdown transformation scripts and audited against the baseline.

## Operational Rules

1. **SINGLE SESSION:** Never open multiple windows in bursts. Maintain a single persistent session when possible.
2. **SEMANTIC FIRST:** Use `get_accessibility_tree` (or equivalent) before performing clicks to ensure the target is correct.
3. **NO BRICOLAGE:** Do not write custom Playwright Python/Node scripts in the workspace for general navigation. Use the MCP tools.
4. **CONSENT BYPASS:** Use specialized patterns to handle common cookie/consent banners instead of manual clicks.
5. **INSIGHTS:** Read `references/insights.md` before non-trivial bookmark or automation work.

## Key Tools

| Server | Primary Action | Use Case |
|--------|----------------|----------|
| `playwright` | `navigate`, `click`, `type` | General high-level tasks. |
| `browser` | `attach`, `list_tabs` | Interacting with user's live windows & sessions. |

## Insights

- **Session Lock:** If the profile is locked, ensure no other Edge instance is using the same data directory.
- **CDP Port:** Default is `9222`. Ensure Edge is launched with `--remote-debugging-port=9222` for live attachment.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-26 | [ANTIGRAVITY] | v1.1.0 — Added Sovereign Bookmarks management. Integrated `bookmark.html` (new) and `bookmark.old.html` (old) in assets. Linked `references/insights.md`. |
| 2026-04-20 | [ANTIGRAVITY] | v1.0.0 — Created k-browser skill. Purged ad-hoc scripts. Standardized on Playwright/Browser MCP servers. |
| [SUMMARY] | — | Initial version |
