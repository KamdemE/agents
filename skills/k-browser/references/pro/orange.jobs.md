# orange.jobs (Orange Careers)

**Category:** Telecom careers portal. **Account:** public. **Profile:** `default`.

> Reference sheet for the 3A internship hunt: Orange openings access.

## Login

None — public.

## Structure / navigation

- **Main portal:** `orange.jobs/` → redirects to `orange.jobs/gb/en` (UK/global English default)
- **Search results:** `orange.jobs/gb/search-results`
- **France/FR locale:** not directly reachable from the GB redirect; the dedicated France portal `jobs.orange.com/` was unreachable on 2026-09-09 (ERR_CONNECTION_TIMED_OUT).

## Key status (2026-09-09)

- **Orange France portal unreachable** (network timeout), LinkedIn company page `linkedin.com/company/orange/jobs/` renders SSR with zero job cards (lazy render).
- → Manual navigation or another channel (orange.jobs locale selector, recruiter pages) required; documented, not automated further.

## Known quirks

- The `orange.jobs` root always redirects to `/gb/en` — use explicit locale paths for other countries (e.g. `/fr/...` paths are not served).
- LinkedIn company jobs page list requires in-page scrolling/loading to populate; SSR returns empty.

