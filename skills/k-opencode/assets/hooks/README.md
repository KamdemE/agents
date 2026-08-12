# Hook Prompt Assets

Canonical text assets shared by OpenCode JavaScript hooks and Python core hooks.

## Rules

- Prompt prose belongs here, never in a hook source file.
- `{{UPPER_SNAKE_CASE}}` placeholders are rendered by the shared loaders.
- JavaScript consumers use `scripts/hooks/libs/prompt-loader.js`.
- Hook code owns only lifecycle timing, agent scope, and dynamic data.
- **Naming rule (mandatory, see `references/hooks-standard.md`):** each `.txt` prompt file here MUST have exactly the same name (minus extension) as the hook `.js` file in `scripts/hooks/` that loads it via `loadPrompt("<name>")`.
- **Injected `synthetic:true` rule (mandatory, see `references/hooks-standard.md` §6):** any message injected by a hook (`appendMessage` / `unshift` / `push`) MUST mark each part `synthetic: true`. OpenCode's title-gen gate (`SessionPrompt.ensureTitle`) only fires when history contains **exactly ONE non-synthetic user message**; an injected `role:"user"` part without the flag breaks session title auto-renaming silently.

## Assets

| File | Consumer intent |
|---|---|
| `prompt-enforcer-strict.txt` | Colab per-turn enforcement (loaded by `prompt-enforcer-strict.js`). |
| `prompt-enforcer-lite.txt` | Agent-only enforcement after a real user message (loaded by `prompt-enforcer-lite.js`). |
| `stop-enforcer.txt` | Agent idle-time completion check; receives `{{MISSION_CONTEXT}}` (loaded by `stop-enforcer.js`). |
| `startup-context.txt` | Startup presentation directive after injected context (loaded by `startup-context.js`). |
| `suggestions-check.txt` | Universal final-response suggestions format rule (loaded by `suggestions-check.js`). |
| `math-enforcer.txt` | Explore-only OpenCode-web math formatting rule (loaded by `math-enforcer.js`). |
