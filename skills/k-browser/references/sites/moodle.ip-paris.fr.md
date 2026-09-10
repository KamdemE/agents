# moodle.ip-paris.fr (Moodle IP Paris)

**Category:** Academic course platform. **Account:** student account. **Profile:** `default`.

## Login

1. `https://moodle.ip-paris.fr/my/` may redirect a guest to `/?redirect=0`; use `login/index.php` if the dashboard does not load.
2. Select **X - Ecole Polytechnique**. The shared Egide SSO session normally returns directly to `my/courses.php`.
3. If Egide asks for a password, follow `synapses.polytechnique.fr.md` exactly:  handles the secret in the visible browser; never request it through `browser-ask-user`.

## Structure / navigation

- Course dashboard: `/my/courses.php`; filters include `Tout`, `En cours`, `À venir`, `Passés`, and `Favoris`. Use **Passés** to surface completed 2A material.
- Course pages: `/course/view.php?id=<numeric-id>`. Query section headings and `.activity` elements with `page-evaluate` to build an inventory without opening every resource.
- Moodle activity taxonomy is visible in the card label/link: `resource` (file/PDF), `ubicast` (Nudgis video), `quiz`, `assign`, `forum`, `folder`, `questionnaire`, and `hvp` (interactive content).
- A video resource opens at `/mod/ubicast/view.php?id=<activity-id>`; follow its iframe/launch URL into `mediaserver.ip-paris.fr` rather than treating the Moodle wrapper as the video player.

## Known quirks

- The dashboard can initially show only current courses; switching the filter is a client-side action, so confirm the rendered course cards changed before searching them.
- The first live 2A MIE recovery validated `IME_43031_EP - Fondamentaux des Organisations (2025-2026)`: eight sessions, course files, quizzes, assignments, and eight Nudgis resources. This is a navigation reference, not a permission to alter old course content.
- Keep resource discovery read-only. Downloading a file/video is a separate explicit action and should use the browser-visible flow or the documented MediaServer preset.

