# polytechnique.jobteaser.com (JobTeaser X — X job board)

**Category:** Job board (X careers). **Account:** Polytechnique student session (X SSO, already signed in on `default`). **Profile:** `default`.

> Reference sheet for the 3A internship hunt (AI research, ~6 months, end of March 2027).

## Login

Signed in via Polytechnique SSO in the `default` Edge profile (persistent session). No separate login.

## Structure / navigation

- **Job offers home:** `polytechnique.jobteaser.com/fr/job-offers` — partner offers list
- **Keyword search:** `#job-ads-autocomplete-keyword-search` field (Algolia autocomplete)
- **Offer page:** `polytechnique.jobteaser.com/fr/job-offers/<id-slug>` — title, type (`Stage 6 mois` = 6-month internship), location, salary (e.g. BNP "1050-2500 EUR/mois"), start date, remote policy
- **Experience profile:** `polytechnique.jobteaser.com/fr/dashboard/...`

## Search & keywords (Algolia)

- Engine: **Algolia**, app id `WS3ZUW0BOJ`, suggestion index `job_ads_search_query_suggestions` (public).
- ⚠️ The URL `?query=` parameter is **ignored at SSR** — search only applies through the UI autocomplete field or a client re-render.
- Captured suggestions (2026-09-09) for "machine learning":
  - `machine learning` (13,307 offers)
  - `machine learning / ai / data science` (8,851)
  - `machine learning engineer` (4,559)
  - `machine learning; ai; deep learning; ai research intern` (**389** — exact AI research internship niche)
  - `machine learning; ai; deep learning; ai researcher` (58)

## Known quirks

- **UI search mandatory:** SSR ignores `?query=`; `page-type` fills the field but the React autocomplete menu does not open via CDP (no observable XHR endpoint beyond the Algolia suggestions call). → manual typing required from the user (type keyword, click the suggestion).
- **Default list:** shows "recommended for you" offers (the same ~20) until a search is executed.
- **Check offer type on the page:** some internships start outside the target window (e.g. BNP Data Scientist = starts October 2026, excluded from the 3A March 2027 filter).
- "Offre partenaire / Offre ciblée" (partner / targeted offers) are flagged on the offer page.

