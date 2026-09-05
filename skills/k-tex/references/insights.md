# k-tex — insights

- 2026-09-05: skill renamed `k-latex` → `k-tex` (all refs updated, frozen
  k-context history untouched); canonical live example `cv` registered
  (local + github + gitlab); `scripts/check-dashes.sh` created as the single
  canonical em-dash gate (symlinked into k-presentation, FIRST in every
  `make check`); renders rule fixed (`build/*` + `!build/*.pdf` — bare
  `build/` cannot be re-included by `!` negations, renders always committed).
