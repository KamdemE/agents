# linkedin.com/jobs (LinkedIn Jobs — 3A internship hunting)

**Category:** Social network / job board. **Account:** ivann.kamdem@hotmail.com (KπX main, see `sites/linkedin.com.md`). **Profile:** `default`.

> Reference sheet for the 3A internship hunt via LinkedIn Jobs search. General LinkedIn profile/messaging knowledge lives in `sites/linkedin.com.md`; this is the jobs-side companion.

## Login

Same as LinkedIn profile (`ivann.kamdem@hotmail.com`, Google SSO fallback). The `default` Edge profile is authenticated.

## Structure / navigation

- **Jobs search:** `linkedin.com/jobs/search/?f_JT=I&f_TPR=r2592000&keywords=<kw>&location=France`
  - `f_JT=I` = internships only; `f_TPR=r2592000` = last 30 days
- **Job page:** `linkedin.com/jobs/view/<id>` — title, company, location, type, candidates count, description
- **Company jobs:** `linkedin.com/company/<name>/jobs/` (often lazy/SSR-empty — see quirks)

## Search & triage patterns (2026-09-09)

- Keyword queries return **only ~7 job cards per page** (SSR) — the same generic results repeat across different keywords unless the page is fully scrolled (infinite load).
- `f_C=<companyId>` URL filter is **ignored at SSR** — company targeting must go through careers pages or user-driven filters instead.
- Compatible-3A query set used successfully: "AI research", "stage machine learning recherche", "stage computer vision", "research internship AI OR computer vision OR LLM", per-domain variants.

## Known quirks

- **Job cards = `[data-job-id]`** divs — extract with `document.querySelectorAll('[data-job-id]')`; title via the inner `<a aria-label>`.
- **Description is collapsed** ("En voir plus") — the top 500 chars (title/company/location/type/candidates) are enough for the first triage; deep details need a click.
- **Company jobs page SSR is empty** (0 cards) until in-page lazy load; not reliable for automation.
- Candidate counts + posting age are the freshness signal: prefer offers < 1 week, < 50 applicants (e.g. Dassault CAD 2 days/9 applicants, Scality 1 day/34).
- "Promue par un recruteur" = promoted job (sponsored) — not a relevance signal.

## Changelog

| Date | Note |
|------|------|
| 2026-09-09 | Created after 3A hunt session: search URL filters (f_JT/f_TPR), 7-card SSR limit + infinite scroll, f_C ignored, per-offer triage fields (type/date/candidates), company-page SSR empty. |