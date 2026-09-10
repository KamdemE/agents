# google.com/about/careers/applications (Google Careers)

**Category:** Tech careers portal. **Account:** none needed (public). **Profile:** `default`.

> Reference sheet for the 3A internship hunt: Google intern programs accessible at BS/MS level (3A X = "penultimate year").

## Login

None — public.

## Structure / navigation

- **Jobs search:** `google.com/about/careers/applications/jobs/results/?q=<keywords>&hl=en_US` (optionally `&target_level=INTERN`)
- **Job page:** `.../jobs/results/<id-slug>?hl=en_US` — title, location, Minimum qualifications, Preferred qualifications
- **Filter by level:** the results list includes degree tags — `PhD` vs `BS/MS` vs `BS`/`MS` summer programs.

## Key offers (2026-09-09)

- **SWE/SRE BS/MS Intern, 2027 (EMEA)** — `142747733357142726-software-engineering-site-reliability-engineering-bsms-intern-2027` — eligible: "currently enrolled in Bachelor's or Master's in EMEA", penultimate/final year → **fits 3A X**.
- **Part-Time SWE BS/MS Intern, 2027 (EMEA)** — `103632882076918470-parttime-software-engineering-bsms-intern-2027`.
- **SWE BS/MS Intern, 2027 (EMEA)** — `83199557986329286-software-engineering-bsms-intern-2027`.
- ⚠️ **Summer BS/MS Intern 2027** (`...-software-engineering-intern-bs-summer-2027`, `-ms-summer-2027`) = **US-only** ("attending a degree program in the US", 12 weeks) → excluded.

## Known quirks

- Result cards are `h3` divs, not `<a>` links — extract slugs from `body.innerHTML` regex (`href="[^"]*<id>-<slug>"`) rather than anchor queries.
- PhD Interns (Research Scientist PhD, SWE PhD, Data Science PhD) dominate the "intern 2027" list — filter them out for 3A level.
- Location: BS/MS 2027 programs are EMEA-wide; the offer page's "Minimum qualifications" is the ground truth for eligibility.

## Changelog

| Date | Note |
|------|------|
| 2026-09-09 | Created after 3A hunt session: 2027 intern program taxonomy (BS/MS EMEA = eligible; Summer = US-only; PhD = out of scope), slug extraction pattern, download of 3 compatible BS/MS offers. |