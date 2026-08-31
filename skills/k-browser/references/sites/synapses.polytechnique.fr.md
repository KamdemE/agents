# synapses.polytechnique.fr (SynapseS — Polytechnique ENT)

**Category:** Academic ENT (cursus, inscriptions pédagogiques, catalogue). **Account:** X24 student account. **Profile:** `default`.

## Login — Egide SSO chain

SynapseS delegates authentication to **Egide** (`egide.polytechnique.fr`), a Shibboleth IDP shared across the whole Polytechnique/IP-Paris ecosystem (`gargantua.polytechnique.fr`, `moodle.ip-paris.fr`, `mediaserver.ip-paris.fr` all reuse the SAME SSO session once Egide is authenticated).

1. Navigate to `synapses.polytechnique.fr` — if not authenticated, redirects to Egide login.
2. Egide login form needs KπX's Polytechnique credentials. **Never use `browser-ask-user` for the password** (KπX, GRAVÉ — 2026-08-30: "je ne vais jamais mettre mon password dedans, browser-ask c'est pour des infos autre que password/clés"). Non-secret fields (username/X-number) live in `kpihx` skill — fill those. For the password itself, notify KπX (system/Telegram notification) that the field is waiting, then wait; re-notify if KπX takes time. Never collect the secret value through any overlay.
3. On success, cookies are set: `ENT-SESSION`/`TPTauth` (synapses.polytechnique.fr), `__Host-JSESSIONID`/`__Host-shib_idp_session` (egide.polytechnique.fr) — these two cookie sets together represent "logged into the whole ecosystem."
4. If KπX has Bitwarden autofill available in the profile, a popup may appear during the Egide form — this is expected, let it resolve via HITL, do not dismiss it as an "overlay."

## Structure / navigation

- Course catalogue: `inscriptions-pedagogiques/...`
- Enrollment documents: `inscriptions-pedagogiques/demandes/<id>` (numeric id per academic year/cycle — the id is NOT predictable, must be discovered by navigating the catalogue UI first, never guessed)
- Cycle/year navigation is nested (cycle → year → semester → UE) — expect several clicks to reach a specific document, budget `page-snapshot` calls generously to map the tree before targeting a click.

## Known quirks

- The Shibboleth SSO session (Egide) is shared with `gargantua.polytechnique.fr` and `moodle.ip-paris.fr` — if already logged into one, navigating to another Polytechnique/IP-Paris service usually skips the login form entirely (silent SSO redirect).
- Downloads (PDFs of enrollment letters, etc.) — the historical `page-set-download-behavior` action is no longer public. Use `scripts/presets/pdf-download-sequence.sh` on the resolved PDF URL: it drives documented `raw`/`page-navigate`/`page-evaluate` actions visibly through Edge and targets `$HOME/Downloads`. An unusual path such as `/tmp` was observed to fail in a past session; verify the downloaded file is really a PDF, not just that Edge opened its viewer.

## Changelog

| Date | Note |
|------|------|
| 2026-08-30 | Replaced the retired `page-set-download-behavior` reference with the current public transparent PDF preset, validated against official Polytechnique/SIATEL documents. |
| 2026-08-30 | Created after a live 3A enrollment exploration (Egide SSO login via Vaultwarden HITL popup, catalogue navigation, `inscriptions-pedagogiques/demandes/35576` reached, PA-AI courses confirmed, PDF `X-Lettre-explicative-cursus.pdf` downloaded after correcting the download path from `/tmp` to `~/Downloads`). |
