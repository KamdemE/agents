# k-rclone Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.
- On Google Drive remotes, `rclone moveto` may report "source is a directory and destination is a file" when a path visually looks like a file but is actually a Drive folder named with a file extension. Inspect with `rclone lsjson` before forcing a file-style move.
- For high-volume Drive metadata reorganizations, `rclone`/FUSE operations are useful for targeted residual moves and root checks, but bulk execution should use the Drive API with explicit backoff and final `rclone lsd/size` verification.
- Even targeted Google Drive `rclone moveto` cleanup can hang on individual files after a large metadata migration. If repeated moves stall, switch to Drive API moves by file ID and use `rclone` only for independent verification counts.
