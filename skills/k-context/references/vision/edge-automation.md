# Microsoft Edge Automation — Practical Architecture (2026)

> Status: REFERENCE · Last updated: 2026-04-07 · [CLAUDE]

## Goal

Design a robust and fast automation stack for Microsoft Edge that:

- uses structured APIs first (fast and reliable),
- handles non-API UI cases (tab groups/workspaces) with controlled fallbacks,
- avoids screenshot-heavy loops unless strictly necessary.

---

## Capability Matrix

| Area | What works well | Limits |
|------|------------------|--------|
| DOM navigation/actions | Playwright/CDP (open tabs, click, fill, submit, scrape, download/upload) | UI-specific Edge features may not be exposed |
| Favorites (bookmarks) | Chromium extension API `chrome.bookmarks` (CRUD) | Requires extension permission and bridge |
| Edge tab groups/workspaces | Partial via UI automation only | No clean public API surface for full control |
| Human-like mouse/keyboard | Accessibility API + OS event injection | More brittle than DOM/API |
| Screenshot/VLM control | Works as universal fallback | Slower, costlier, less deterministic |

---

## Four-Layer Architecture

```
Layer A — Fast Path (default)
  Playwright/CDP + extension APIs
  -> deterministic, low latency, auditable

Layer B — UI Path (non-API features)
  Accessibility tree + targeted keyboard/mouse actions
  -> for tab groups/workspaces/system dialogs

Layer C — Vision Path (last resort)
  Screenshot + VLM + action proposal
  -> only when A/B cannot resolve state

Layer D — Safety Envelope (always on)
  allowlist, dry-run, replay logs, rollback checkpoints
```

---

## Favorites Management Options

### Option 1 (Recommended): Extension bridge + `chrome.bookmarks`

- Build or use a lightweight extension exposing bookmark operations.
- Connect it to local MCP/CLI bridge.
- Operations: create folder, move bookmark, rename, delete, search tree.
- Best balance of speed + reliability.

### Option 2: Local profile JSON editing

- File: Edge profile `Bookmarks` JSON.
- Suitable for batch transforms and migration scripts.
- Run with Edge closed (or at least profile idle) to avoid race/sync issues.

### Option 3: MCP community servers

- Useful for quick start.
- Quality varies; validate auth model, failure semantics, and latency.

---

## Non-API UI Automation (tab groups, workspaces, special dialogs)

### Preferred strategy

1. Try DOM/API path first.
2. If unavailable, switch to accessibility-driven UI automation.
3. Use vision only when both fail.

### Why this matters

- Accessibility actions are typically much faster than screenshot-VLM loops.
- Structured state reduces retries and avoids "guess-click" behavior.

---

## Performance Guidance

| Mode | Typical speed profile | Reliability |
|------|------------------------|-------------|
| DOM/API | Fastest | Highest |
| Accessibility UI | Fast/medium | Medium-high |
| Screenshot VLM | Slowest | Medium/low (layout-sensitive) |

Target policy for fluid interaction:

- **90%** actions through DOM/API + bookmarks API
- **9%** through accessibility UI path
- **1%** vision fallback

---

## Mac Studio (M4 Max 128GB) Feasibility

Yes — this machine can host a fluid local automation controller, including:

- browser control runtime (Playwright/CDP),
- local policy/orchestration layer,
- optional local vision model for rare fallback steps.

The key is architecture, not raw model size:

- if every step is screenshot+VLM, it stays slow;
- if structured APIs are primary, interaction can feel near-instant.

---

## Controlled Execution Pattern

For production-grade agent execution, enforce:

1. **Action allowlist** (domains, operation classes, destructive actions gated)
2. **Dry-run preview** (show planned actions before execute)
3. **Step logs + replay**
4. **Checkpoint/rollback hooks** (especially before destructive UI actions)
5. **Timeout + recovery policy** (fallback escalation A -> B -> C)

---

## Recommended Next Build

1. Create a minimal `k-edge` capability:
   - `bookmarks.list`
   - `bookmarks.create_folder`
   - `bookmarks.add`
   - `bookmarks.move`
2. Add Playwright controller actions for tab/session primitives.
3. Add a small accessibility fallback module for tab groups/workspaces.
4. Keep screenshot/VLM disabled by default; enable only on explicit fallback.
