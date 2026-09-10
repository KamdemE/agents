# k-node Insights

## 2026-07-25 (v2)

- **CORRECTION MAJEURE V1 :** fnm est **déjà actif** via `.kshrc`. Le skill V1 disait "nvm encore actif" — c'était faux, basé sur un shell agent non-interactif qui ne source pas `.kshrc`.
  - Dans un shell normal : `which node` → fnm multishell → v24.18.0 ✅
  - nvm est legacy, installé mais pas sourcé, n'interfère pas.
- **Le piège agent shell :** les shells agents (non-interactifs, sans `.kshrc`) voient nvm comme "node actif". Ça peut induire en erreur. Toujours vérifier avec `source ~/.kshrc && which node` pour le vrai état.
- npm global (13 packages, 20 binaires) domine le paysage global ; bun global est vide (server-filesystem purgé).
- `.npmrc` avait `prefix=` commenté "for nvm compatibility" — mais nvm n'est plus sourcé ! Le commentaire était un vestige mort. Fixé : `prefix=` actif maintenant.
- Le pattern `.npmrc prefix=` est critique pour les auto-updaters (Codex, Gemini) — `NPM_CONFIG_PREFIX` seul ne couvre pas les subprocess systemd/cron.
- `whats-mcp` est linked vers `~/Work/AI/MCPs/whats_mcp` — dev mode.
- Bun est le choix souverain pour les projets  ; npm global pour les CLIs tiers.
- PATH resolution: `~/.bun/bin` → `~/.npm-global/bin` → fnm multishell.
