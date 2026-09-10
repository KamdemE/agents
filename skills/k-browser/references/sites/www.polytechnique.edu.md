# www.polytechnique.edu (Official École polytechnique student space)

**Category:** Official student web space. **Account:** student account. **Profile:** `default`.

## Login

1. Open `https://www.polytechnique.edu/espace-etudiant`.
2. **Je suis étudiant à l'X** leads to `/user/login`. An active session redirects to an authenticated annuaire page carrying `check_logged_in=1`.
3. If the session is absent, keep the visible Edge form in front of ; never request a password through `browser-ask-user`. Shared Egide context: `synapses.polytechnique.fr.md`.

## Structure / navigation

- Student space → **Cycle ingénieur polytechnicien** → **3ème année**.
- The 3ème année landing page is intentionally sparse: its practical child is **Planning des cours** at `/espace-etudiant/cycle-ingenieur-polytechnicien/3eme-annee/planning-des-cours`.
- This planning page is the source of truth for its current 3A documents. Inspect its rendered links before assuming a historic list remains current.

## Known quirks

- A direct school-hosted PDF and a SIATEL/Gargantua link behave differently. The 3A planning page may mix both; route Gargantua links through `gargantua.polytechnique.fr.md`.
- Opening a PDF is not downloading it. Use `scripts/presets/pdf-download-sequence.sh` only after resolving the current document URL through the visible page.
- Live 2026-08-30 batch: five resources were present — the <class> Livret de PA, the 3A-MScT course-planning PDF, and PA presentations for ECO, CHI, and Energies. This is historical evidence, not a permanent inventory.

