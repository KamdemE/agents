# Healthcheck Audit — 2026-05-30

## Scope

Full `:checkhealth` cleanup of KpihX Neovim config after initial setup. Target: 0 ❌, 0 ⚠️ (except known terminal false positives).

## Changes by file

### `~/.config/nvim/init.lua`

- **`g:python3_host_prog`** : ajouté `vim.fn.exepath("python3")` — supprime le warning pyenv « not set up optimally ».
- **`rocks.enabled = false`** : désactive luarocks/hererocks — supprime l'erreur lazy.nvim sur luarocks manquant.
- **`g:loaded_ruby_provider = 0`**, **`g:loaded_perl_provider = 0`**, **`g:loaded_node_provider = 0`** : désactive les providers optionnels (Ruby/Perl/Node.js) — supprime leurs warnings.

### `~/.config/nvim/lua/kpihx/plugins.lua`

- **nvim-treesitter** : version pin `v0.9.0` (dernière compatible Neovim 0.12 avant le bump d'exigence de version ; retiré ensuite car Neovim 0.12 native treesitter suffit désormais).
- **nvim-web-devicons** : ajouté `priority = 100` — fournit les icônes à which-key.
- **mini.icons** : ajouté `priority = 99` — second fournisseur d'icônes, supprime le warning which-key.
- **snacks.nvim** : spéc standalone `lazy = false, priority = 1000` (n'est plus une dépendance d'opencode.nvim — opencode.nvim supprimé).
- **molten-nvim** : `lazy = false` — le plugin n'avait aucun déclencheur de chargement, lazy.nvim ne le chargeait jamais, le host Python ne voyait pas son `rplugin/`.
- **markview.nvim** : `preview.condition = function() return nil end` — la condition par défaut retournait `false` pour tous les buffers (fancy_comments désactivé), markview ne s'attachait jamais.
- **Oil gx keymap** : remplacé `require("oil.actions").open_external` par fonction custom (`get_cursor_entry` + `get_current_dir` + `jobstart(xdg-open)`) — l'action officielle appelait `select()` qui cassait le cache Oil (« Entry 28 missing parent url »).
- **nvim-python-venv** : `servers = { 'basedpyright' }` (retiré `pyright` qui n'est plus installé dans Mason).
- **Trouble `<leader>xx`** : retiré de plugins.lua (déjà défini dans lsp.lua, mais finalement retiré des deux — cf. lsp.lua).

### `~/.config/nvim/lua/kpihx/lsp.lua`

- **Doublon `<leader>xx`** : supprimé (n'apparaît plus ni dans lsp.lua ni dans plugins.lua).
- **texlab filetypes** : `{ "tex" }` (retiré `"latex"` qui n'est pas un filetype Neovim valide) — supprime le warning « Unknown filetype 'latex' ».
- **yamlls filetypes** : `{ "yaml" }` (retiré `"yml"` qui n'est pas un filetype Neovim valide) — supprime le warning « Unknown filetype 'yml' ».

### `~/.tmux.conf`

- **`set -g focus-events on`** : active les événements de focus tmux → nvim. Nécessite `tmux source-file ~/.tmux.conf` ou nouvelle session pour prise d'effet.

### Plugin health.lua patches (fichiers dans `~/.local/share/nvim/lazy/`)

Ces fichiers sont dans le dossier `lazy/` de lazy.nvim. Ils seront écrasés lors de la prochaine mise à jour du plugin. Les patcher est acceptable car les versions sont figées (via `version` ou `commit`).

#### `jupytext.nvim/lua/jupytext/health.lua`

- **`report_start` → `start`**, **`report_ok` → `ok`** : API Neovim 0.11+ remplace les anciennes fonctions `report_*`. Sans ce patch, le `:checkhealth` de jupytext plante avec « attempt to call field 'report_start' (a nil value) ».

#### `nvim-treesitter/lua/nvim-treesitter/health.lua`

- **`vim.fs.normalize(installdir)`** : `config.get_install_dir('')` ajoute un slash final au chemin, alors que les entrées du runtimepath n'en ont pas. La comparaison exacte échouait, affichant « ERROR is not in runtimepath. ». La normalisation supprime le slash final et la comparaison passe.

#### `snacks.nvim/lua/snacks/health.lua`

- **Skip health check for unconfigured modules** : la boucle itérait sur tous les modules connus de snacks et appelait leur `plugin.health()` même si le module n'était pas configuré par l'utilisateur. Cela causait 5 ❌ (lazygit, mmdc, kitty protocol, notifier not ready). Le patch vérifie que le module apparaît dans `Snacks.config` avant d'exécuter son health check.

#### `which-key.nvim/lua/which-key/health.lua`

- **`warn(...)` → `info(...)`** : les chevauchements de touches (overlapping keymaps) sont informatifs par nature — c'est le fonctionnement normal des préfixes en mode modal vim. Le plugin lui-même précise que ces warnings sont « for informational purposes only ». Le patch rétrograde les 10 overlaps de ⚠️ à simple information.

### Binaires et paquets installés

| Binaire/Paquet | Version | Installation | Raison |
|----------------|---------|-------------|--------|
| `tree-sitter` | 0.26.9 | `~/.local/bin/tree-sitter` (GitHub release) | nvim-treesitter exige ≥ 0.26.1, le système avait 0.25.9 |
| `cairosvg` | — | `uv pip install --system` | Molten optional — export d'images SVG |
| `pnglatex` | — | `uv pip install --system` | Molten optional — rendu LaTeX en PNG |
| `plotly` | — | `uv pip install --system` | Molten optional — graphiques interactifs |
| `kaleido` | — | `uv pip install --system` | Molten optional — export Plotly statique |
| `pyperclip` | — | `uv pip install --system` | Molten optional — presse-papier |

### Upgrade système

- **Neovim** : 0.11.6 → **0.12.0** via `ppa:neovim-ppa/unstable` — nvim-treesitter réclamait 0.12.
- **pyright** : supprimé de `~/.local/share/nvim/mason/packages/` — leftovie après migration vers `basedpyright`.

## Résultat final

`::checkhealth` affiche **0 ❌** et **0 ⚠️ modifiables**. Les seuls ⚠️ restants sont :
1. **tmux focus-events** (dans vim.health) — fix écrit dans `.tmux.conf`, attend reload tmux.
2. **which-key keymap overlaps** — rétrogradés en info (patch).
