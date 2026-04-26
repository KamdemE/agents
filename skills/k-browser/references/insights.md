# Insights — Browser & Bookmarks

- **Bookmark Source of Truth:** The current sovereign bookmark hierarchy is stored in `assets/bookmark.html`.
- **Legacy Audit:** `assets/bookmark.old.html` contains the original unorganized dump for historical reference.
- **Reorganization Logic:** The transition from `old` to `new` involved merging duplicates, shortening titles (e.g., "Kaggle" instead of full page title), and categorizing into `KpihX-Labs`, `X`, `Fr`, `E-Tools`, etc.
- **MCP Integration:** When using `browser` or `playwright` MCPs, prioritize navigating via these bookmarks if the task involves frequent access to the homelab or academic portals.
