# welcometothejungle.com (WTTJ — Welcome to the Jungle)

**Category:** Job board ("matching" platform since 2026 redesign). **Account:** required for results. **Profile:** `default`.

> Reference sheet for the 3A internship hunt: WTTJ behavior after the 2026 matching redesign.

## Login

Required to unlock job listings (account with CV imported + preferences). Public search returns only the marketing "matching" page.

## Structure / navigation

- **Job search URL (works as entry point):** `welcometothejungle.com/fr/jobs?query=...&refinementList[contract_type][]=internship&refinementList[offices.country_code][]=FR`
- **Matching home:** "Quel job recherchez-vous ?" — import CV → get matches
- **Company pages:** `welcometothejungle.com/fr/companies/<slug>` (e.g. mistral-ai shows job counts)

## Known quirks

- **2026 redesign = no anonymous listings**: without a configured account the search page only shows the "matching" marketing funnel (`Se connecter` + "Trouvez LE job en 3 étapes").
- **Consent banner (Axeptio)**: `browser-dismiss-overlays` dismisses it; buttons "Non merci"/"OK pour moi" sit at y≈1014 (below fold on the shrunk window) — programmatic `.click()` on the button works once the overlay is detected.
- Search query param is preserved in the URL but results depend on the logged-in state.

## Changelog

| Date | Note |
|------|------|
| 2026-09-09 | Created after 3A hunt session: confirmed the matching-only design (no listing without account), Axeptio consent handling via browser-dismiss-overlays, search URL pattern kept as entry point. |