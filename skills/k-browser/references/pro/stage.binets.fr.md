# stage.binets.fr (XStage — X alumni internship experience database)

**Category:** X internship experiences/salaries database. **Account:** public (no login). **Profile:** `default`.

> Reference sheet for the 3A internship hunt: company/salary/tutor benchmarks from X students' past internships.

## Login

None — public site. No authentication required.

## Structure / navigation

- **Index/search:** `stage.binets.fr/find?q=<keyword>` — e.g. `q=IA` returns AI/ML/CV-related experience sheets
- **Experience sheet:** `stage.binets.fr/view/<id>?q=<query>` — résumé, company, division, contact tutor (X alumnus with email!), country, salary (monthly gross approx.), dates, hours, location map, environment tags (guided/concrete/dynamic...), tutor quality
- Each sheet has an ID (e.g. 1219) used in the view URL.

## Known quirks

- **IDs are not sequential by topic** — the `find?q=` search lists relevant sheets; open each `view/<id>` to read the details (salary + tutor contact).
- **Tutor contacts are gold**: sheets expose `Contact tuteur : <Name>, X<graduation> (<email>)` — direct outreach channel.
- Salaries seen (2026-09-09, IA sheets): Lazard €1800, Storyzy €1500, Safran €1330, HRflow €800, Sanofi €1050, Engie €1460.
- The `?q=IA` query param stays in the URL when opening a sheet (used to keep the index filter context).

