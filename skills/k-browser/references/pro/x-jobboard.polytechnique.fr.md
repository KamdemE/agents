# x-jobboard.polytechnique.fr (X-Job Board — X internship job board)

**Category:** X student/partners internship board (DataTables). **Account:** X SSO session required. **Profile:** `default`.

> Reference sheet for the 3A internship hunt: partner & department internship listings for X students.

## Login

X (Polytechnique) SSO — session can expire (`login/index.php?err=3`); reauthenticate through the X SSO flow on `default`.

## Structure / navigation

- **Offers list:** `x-jobboard.polytechnique.fr/Etudiant/offres.php?s` — table: Logo/Entreprise, Titre offre, Type offre, Pays, Ville, Posté le, Action (Résumé/Voir)
- **Search:** DataTables global search field `#dt-search-0` (filters the table client-side, no navigation needed)
- Filter buttons: offers, departments, labs.

## Key status (2026-09-09 — session restored)

- **72 offers total, all dated ≤ 2023** (most recent: 2× BNP Paribas 12/12/2023; most 2021-2022). Site no longer actively fed.
- Search "machine learning" → 2 results (Amadeus Data Engineer/ML 4A 2021 ⚠️ outdated; Safran thesis); "data" → BNP Quant Data AI Lab + BNP Data Engineer 6 months (2023, 4A/M2), Amadeus Data/ML (2021), SG Graduate Quant HK (2021), OVH DevOps (2021).
- Offers typed e.g. `Stage-Fin d'étude(4A/M2/GD2)`, `Stage-Recherche(3A/M1/GD1)`, `Thèse`.

## Known quirks

- SSO session expires without warning (err=3 on login redirect) — re-auth needed when the list won't load.
- DataTables search is client-side and instant; column sort by clicking header (e.g. "Posté le").
- Age of the base makes it non-priority for 2026/2027 offers — recruiters use LinkedIn/JobTeaser/AX.

## Changelog

| Date | Note |
|------|------|
| 2026-09-09 | Created after 3A hunt session: SSO auth requirement, DataTables search/triage, base audit (72 offers ≤2023, mostly 4A/M2), verdict non-priority. |