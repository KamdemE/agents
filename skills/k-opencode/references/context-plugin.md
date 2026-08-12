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
  - `@opencode-ai/plugin` — provided by the OpenCode runtime at load time

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

**Source of truth:** `skills/k-opencode/scripts/plugins/context-plugin/`

```
context-plugin/
├── command/context.md          ← the /context slash command
└── plugin/
    ├── context-usage.ts        ← registers the context_usage tool
    ├── tokenizer-registry.mjs / .d.ts
    ├── tokenizer-aliases.json
    └── vendor/node_modules/    ← js-tiktoken + @huggingface/transformers
```

**Runtime symlinks** (the paths OpenCode actually scans — verified against the
official OpenCode docs, updated 2026-08-07):

| Runtime path | → points to | Purpose |
|---|---|---|
| `~/.config/opencode/commands/context.md` | `.agents/.../context-plugin/command/context.md` | slash command discovery |
| `~/.config/opencode/plugins/` | `.agents/.../context-plugin/plugin` | plugin (tool) discovery |

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
  loaded. Check `~/.config/opencode/plugins/` exists and contains `context-usage.ts`.
- `Context usage dependencies missing. Run ./install.sh ...` → `vendor/node_modules`
  not installed. Run the npm install above.
- Command not found → check `~/.config/opencode/commands/context.md` symlink.
