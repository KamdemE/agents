# gargantua.polytechnique.fr (SIATEL academic documents)

**Category:** Academic document service. **Account:** shared X24 Egide SSO session. **Profile:** `default`.

## Login

1. SIATEL reuses the Egide/Shibboleth session described in `synapses.polytechnique.fr.md`.
2. A first visit can pass through `/siatel-web/app/auth/login?auth=1`; an active session reaches **Portail utilisateurs connectés** without collecting any credential through the agent.
3. If a visible credential form remains, notify KπX and let KπX complete it directly in Edge.

## Structure / navigation

- School pages expose SIATEL resources through `/siatel-web/app/linkto/<opaque-id>` URLs.
- A resolved document visibly loads as `application/pdf`; SIATEL appends `?aw=1` to the URL.
- The document remains inside Edge's PDF viewer until a real browser download is requested.

## Known quirks

- Cross-origin `<a download>` from `www.polytechnique.edu` can be ignored and merely navigate Edge. First navigate the target to the SIATEL PDF, then run `scripts/presets/pdf-download-sequence.sh` from the now same-origin document target.
- A small HTML SIATEL wait/login page can be saved with a `.pdf` extension if the session is not ready. Reject it: inspect the local MIME type before declaring success.
- The server supplies the canonical filename through `Content-Disposition`; do not rename blindly or assume the caller-provided name won.

## Changelog

| Date | Note |
|------|------|
| 2026-08-30 | Created from the live 3A batch: SIATEL link targets resolved to inline PDFs after shared Egide SSO, then downloaded through a same-origin visible Edge sequence. |
