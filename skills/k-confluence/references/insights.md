# k-confluence Insights

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- The skill was wiped once already by a `.agents` re-clone because it had never been committed. If you materially improve this skill mid-task, commit it before moving on — do not leave it only on disk.
- **Never judge a page from the `markdown` rendering.** `getConfluencePage` with `contentFormat: "markdown"` silently drops `ac:structured-macro` nodes — a `multimedia` macro (an embedded MP4) renders as *nothing*, so a correctly-embedded video looks exactly like an orphan caption with a missing image. Cost on 2026-08-26: nearly "repairing" two videos on `Deep — Per-Region Measurement` that were already correctly placed. Read `html` or `storage` before concluding anything is missing.
- **Storage format is the safe transport for surgical edits.** `GET /rest/api/content/<id>?expand=body.storage` returns clean XHTML (`<ac:image>`, `<ac:structured-macro>`) that round-trips byte-for-byte through a `PUT`. Fetch → exact-string patch in Python → PUT, with every anchor asserted to occur exactly once, so a stale anchor aborts before the page is touched instead of half-patching it. Far safer than retyping a 40 KB body into a tool call.
- **Update an attachment in place, never as a new upload.** `POST /content/<id>/child/attachment/<attId>/data` creates a new *version* of the same attachment, so the `attXXXX` id — and therefore every `<img src>` already in the body — stays valid. Posting to `/child/attachment` instead creates a duplicate and silently orphans nothing, which is worse: the page keeps showing the stale image. Compare byte size first and skip when unchanged; on 2026-08-25's audit re-run exactly one of three plots had actually changed.
- **Check inline comments before any body rewrite** (`/child/comment?location=inline`): a destructive body replacement can leave reviewer anchors dangling. Zero on the blur hub pages as of 2026-08-26, but verify per page rather than assuming.
- A companion memory (`feedback_confluence_narrative_style`, KπX memory system) captured the required writing style for Confluence pages under `blur/` — intuitive-then-formal, problem-first narrative, rendered formulas. That memory was lost with a Claude Code history purge and only a short fragment survived search. If you recreate or extend that guidance, keep it as a linked memory (`[[feedback_confluence_narrative_style]]`) rather than folding it into this file, so it stays scoped to the project that needs it rather than every Confluence task.
