# `/context` Plugin — Context Usage Analysis (IgorWarzocha)

Reference for the OpenCode `/context` slash command plugin. Shows a detailed
token-usage breakdown per component (system prompt, tools, user messages,
assistant responses, tool outputs, reasoning traces) for the current session.

## Repository

- **Upstream repo:** `https://github.com/IgorWarzocha/Opencode-Context-Analysis-Plugin`
- **Name:** `opencode-context-analysis-plugin`
- **License / status:** open source, ~171 stars, 12 commits, community-maintained
- **Dependencies:**
  - `js-tiktoken` — official OpenAI tokenizer (GPT models)
  - `@huggingface/transformers` — Hugging Face tokenizers (Claude, Llama, Mistral, …)
  - `@opencode-ai/plugin` — the OpenCode plugin SDK (`tool`, `Plugin` types). **Not** provided at load time from `.agents`; vendored via symlink into the plugin's `node_modules/` (ANCESTOR of `context-usage.ts` — see install below).

## What it does

The command is a **markdown slash command** (`command/context.md`) whose body tells
the agent to call the `context_usage` tool. The tool itself is implemented by the
**plugin** `plugin/context-usage.ts`, which computes the per-component token
breakdown using the local `vendor` tokenizers (everything runs locally, no data
leaves the machine).

> **Critical:** the command and the plugin are **two separate pieces**. The slash
> command is useless without the plugin — if `context-usage.ts` is missing, typing
> `/context` only echoes "call the `context_usage` tool" with no tool available.

## Installation (global, following the upstream repo)

The repo ships a `.opencode/` folder with `command/` + `plugin/` + an automatic
vendor bootstrap. The upstream global install method is:

```bash
git clone https://github.com/IgorWarzocha/Opencode-Context-Analysis-Plugin.git
cp -r Opencode-Context-Analysis-Plugin/.opencode ~/.config/opencode/
# then install tokenizer deps into the plugin's vendor dir:
cd ~/.config/opencode/.opencode/plugin && npm install \
  js-tiktoken@latest @huggingface/transformers@^3.3.3 \
  --prefix vendor
# restart OpenCode → /context available everywhere
```

## KπX source-of-truth install (`.agents` + symlinks)

Per KπX governance, the plugin source lives in `.agents` (versioned) and is
symlinked into the runtime discovery paths.

**Source of truth:** `skills/k-opencode/scripts/plugins/opencode-context/`

```
opencode-context/
├── index.ts              ← package entry (re-exports ContextUsagePlugin as default)
├── context-usage.ts      ← registers the context_usage tool
├── tokenizer-registry.mjs / .d.ts
├── tokenizer-aliases.json
├── node_modules/@opencode-ai/plugin  ← ANCESTOR symlink → ~/.config/opencode/node_modules/@opencode-ai/plugin
└── vendor/node_modules/  ← js-tiktoken + @huggingface/transformers
```

**Runtime symlinks** (the paths OpenCode actually scans — verified against the
official OpenCode docs, updated 2026-08-15):

| Runtime path | → points to | Purpose |
|---|---|---|
| `~/.config/opencode/commands/context.md` | `.agents/.../assets/plugins/context/context.md` | slash command discovery |
| (None) | (Loaded via `opencode.jsonc` `"plugin"` array) | The plugin `context-usage.ts` is explicitly loaded via `file://` URL |

> **`@opencode-ai/plugin` resolution (2026-08-15, corrected):** the plugin imports
> `@opencode-ai/plugin` (`tool`, `Plugin`). OpenCode does **not** make it resolvable
> from `.agents` (the runtime install lives at `~/.config/opencode/node_modules/`).
> Fix: symlink at **`context/node_modules/@opencode-ai/plugin`** (an ANCESTOR of
> `context-usage.ts`) → `~/.config/opencode/node_modules/@opencode-ai/plugin`.
> Node/Bun resolve bare imports by walking UP the directory tree, so the symlink
> MUST sit in `node_modules/` at or above the plugin file — `vendor/node_modules/`
> is a *sibling*, NOT an ancestor, and is invisible to resolution. Registered in
> `assets/links.jsonc` as `opencode-context-plugin-deps` (node_modules is
> gitignored, so the link entry is what makes the fix durable). Without it, the
> plugin fails to import and the `context_usage` tool is never registered.

> **Note on discovery paths:** official OpenCode docs say local plugins are
> auto-loaded from `.opencode/plugins/` (project) and `~/.config/opencode/plugins/`
> (global); commands from `.opencode/commands/` (project) and
> `~/.config/opencode/commands/` (global) — all **plural**. The upstream repo
> structure uses singular `command/`/`plugin/` inside `.opencode/`. When installing
> for OpenCode 1.18.x, put the files in the **plural** discovery paths listed above.

## Commands

```
/context                    # standard analysis
/context detailed           # more detailed
/context short              # quick summary
/context verbose            # everything
/context "extremely detailed"  # custom verbosity
/context sessionID:<id>     # a specific session
/context limitMessages:5    # last N messages only
```

## Updating

```bash
git -C /tmp/opencode/opencode-context-plugin pull   # refresh upstream clone
# re-copy command/ + plugin/ into .agents source of truth (respecting plural paths),
# then re-run the vendor npm install if versions bumped.
```

## Troubleshooting

- `/context` only echoes "call the `context_usage` tool" → `context-usage.ts` is not
  loaded. Check `~/.config/opencode/plugins/` → `scripts/plugins/` (parent), that
  `context/index.ts` exists, and that `context/node_modules/@opencode-ai/plugin`
  symlink resolves (see install note above). Restart OpenCode after changes (plugins
  load at startup, not hot-reloaded).
- `Context usage dependencies missing. Run ./install.sh ...` → `vendor/node_modules`
  not installed. Run the npm install above.
- Command not found → check `~/.config/opencode/commands/context.md` symlink.
