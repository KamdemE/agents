# ax.polytechnique.org (AX — alumni job board)

**Category:** Alumni job board. **Account:** AX session (signed in on `default`). **Profile:** `default`.

> Reference sheet for the 3A internship hunt (AI research, ~6 months, end of March 2027).

## Login

AX session / Polytechnique SSO already active in the `default` Edge profile.

## Structure / navigation

- **Job board:** `ax.polytechnique.org/fr/jobboard/index/index` — ~576 offers (12/page, 48 pages), mostly alumni CDI
- **Search:** `#input-214` field (placeholder "Poste, entreprise, mot-clé ...") + magnifier button on the right
- **Offer card:** title, company, type (`CDI` / `CDD` / `Stage` / `Thèse`), country, city, posting date, "Résumé Voir" (summary/view) link
- **Counter:** "N offres trouvées" (N offers found) below the list

## Known quirks

- **Vuetify / AlumnForce:** the search field is a v-autocomplete **whose suggestion menu does not open via CDP automation** (typing fills the value but Enter / ArrowDown / magnifier click do not submit).
- **URL parameter ignored:** `?search=IA` and `?keywords=IA` do not filter (SPA SSR).
- → Manual search required from KπX (type keyword, click a suggestion).
- **Recent offers on the home page** are mostly CDI (e.g. Développeur foncier Nice, Lead Génie Civil Lyon) — the AI internships are found via the keyword filter.
- Pagination `?page=N` works (48 pages).

## Changelog

| Date | Note |
|------|------|
| 2026-09-09 | Created after 3A hunt session: job board structure (576 offers, 48 pages), AlumnForce v-autocomplete automation block, ignored URL parameters, compatibility triage (CDI vs internship). |