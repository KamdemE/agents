# OpenCode Hooks & Plugins Standards

This document defines the standards and guidelines for creating, modifying, and maintaining OpenCode JavaScript hooks and plugins within the `.agents` repository.

## 1. File Structure

All hook and plugin scripts must be stored in the skill's scripts/plugins/hooks folder:
`skills/k-opencode/scripts/plugins/hooks/`

Shared helper libraries (logic helpers that do not subscribe directly to events) must be isolated in the `libs` sub-folder:
`skills/k-opencode/scripts/plugins/libs/`

The associated hook prompts must be stored directly in the skill's assets/plugins/hooks folder:
`skills/k-opencode/assets/plugins/hooks/`

## 2. Mandatory Targeting Rule: `TARGET_AGENTS`

Every JS hook/plugin script located in `scripts/plugins/hooks/` must declare a global constant named `TARGET_AGENTS` at the top of the file to make explicit the agents concerned.

- **Format:** `const TARGET_AGENTS = [...];`
- **Default behavior:** If no specific instruction is provided when creating or updating a hook, the default value of `TARGET_AGENTS` must be `["*"]` (all agents).
- **Filtering:** The hook callback must use `currentAgentIs(messages, TARGET_AGENTS)` imported from `../libs/agent-scope.js` to decide whether to execute.

Example:
```javascript
import { currentAgentIs } from "../libs/agent-scope.js";

const TARGET_AGENTS = ["Colab", "Agent"];

export default async function() {
  return {
    "experimental.chat.messages.transform": async (input, output) => {
      const messages = output.messages || [];
      if (!currentAgentIs(messages, TARGET_AGENTS)) return output;
      // ... hook logic ...
      return output;
    }
  };
}
```

## 3. Prompt Name Matching

To maintain total flexibility and perfect correspondence, each prompt file under `assets/plugins/hooks/` must carry **exactly the same name** as the corresponding hook JS file under `scripts/plugins/hooks/` (with the `.txt` extension instead of `.js`).

| Hook JS Path | Prompt Path | Name in `loadPrompt()` |
|---|---|---|
| `scripts/plugins/hooks/suggestions-check.js` | `assets/plugins/hooks/suggestions-check.txt` | `"suggestions-check"` |
| `scripts/plugins/hooks/prompt-enforcer-strict.js` | `assets/plugins/hooks/prompt-enforcer-strict.txt` | `"prompt-enforcer-strict"` |
| `scripts/plugins/hooks/prompt-enforcer-lite.js` | `assets/plugins/hooks/prompt-enforcer-lite.txt` | `"prompt-enforcer-lite"` |
| `scripts/plugins/hooks/math-enforcer.js` | `assets/plugins/hooks/math-enforcer.txt` | `"math-enforcer"` |
| `scripts/plugins/hooks/stop-enforcer.js` | `assets/plugins/hooks/stop-enforcer.txt` | `"stop-enforcer"` |
| `scripts/plugins/hooks/startup-context.js` | `assets/plugins/hooks/startup-context.txt` | `"startup-context"` |

There must no longer be disparate or generic names that hide the concerned agent or break homogeneity.

## 4. Using the Library Helpers (`libs/`)

- To load a prompt, use `loadPrompt("hook-name")` imported from `./libs/prompt-loader.js` (or `../../libs/prompt-loader.js` depending on the tree).
- To check for the prior presence of a prompt in the history to avoid duplicate injections, use `promptMarker("hook-name")` to extract its first signature line.
- To manipulate messages or extract text robustly, import the functions from `./libs/message-utils.js`.
- To strip JSONC comments from `.agents` config assets (e.g. `infras_skills.jsonc`), import `stripJsonc` from the shared `libs/jsonc_lib.js` (the JS twin of `libs/jsonc_lib.sh` / `libs/jsonc_lib.py`) — **not** a local inline `stripJsoncComments`. `startup-context.js` switched to this shared import on 2026-08-15 (single source of truth; no duplicated JSONC stripper in hooks).

## 5. Ordering Rule (MANDATORY — real bug found 2026-08-09)

The order of the `"plugin"` array in `opencode.jsonc` **IS NOT cosmetic** — each `messages.transform` hook receives `output.messages` **already modified** by all the previous hooks in the array.

**Strict rule:** any hook that inspects `messages.at(-1)` (the last message) to decide whether to run (e.g., "is the last message a fresh user text?") **MUST be placed BEFORE** any hook that unconditionally adds a message at the end of the array (`appendMessage`/`push` without a condition on the last message).

**Real incident (2026-08-09):** `suggestions-check.js` (adds a `system` message with no condition, for all agents) was placed **first** in `"plugin"`. `prompt-enforcer-lite.js` (which checks `messages.at(-1)`) was placed **after** it. Result: `prompt-enforcer-lite.js` always saw `suggestions-check.js`'s `system` message as the "last message" instead of the real user message — its guard failed **systematically**, on every session, since the hook was created. Confirmed by a Node test reproducing the exact execution order (`node --input-type=module`).

**Fix applied:** `suggestions-check.js` moved to **last position** in the `"plugin"` array — its role (format reminder) must always run after all other hooks have had the chance to inspect the "real" last message.

**Current correct order:**
```
startup-context.js → prompt-enforcer-lite.js → prompt-enforcer-strict.js → stop-enforcer.js → math-enforcer.js → suggestions-check.js
```

**Recommendation for any new hook:** if a hook only adds a message unconditionally (without inspecting the position/content of the last message), it must be placed at the end of the array, next to `suggestions-check.js`. If it inspects `messages.at(-1)`, it must be placed before all "unconditional append" hooks.

## 6. Injected Message `synthetic:true` Rule (MANDATORY — real bug found 2026-08-11)

Any message **injected** by a hook (`appendMessage`, `unshift`, `push`, injection via API) **MUST carry `synthetic: true` on each of its parts**.

**Reason — OpenCode title-generation gate:** the auto-generated OpenCode session title (`SessionPrompt.ensureTitle`) only fires if the history contains **exactly ONE non-synthetic user message**:

```js
let O = Y => Y.info.role === "user" && !Y.parts.every(p => "synthetic" in p && p.synthetic);
if (t.history.filter(O).length !== 1) return;   // ⚠️ requires EXACTLY ONE non-synthetic user msg
```

A hook that injects a `role:"user"` message **without** `synthetic:true` adds a "real" user message to the history → the count becomes 2+ → the gate does `return` → **the title is never generated, silently** (sessions stay stuck on `"New session - <timestamp>"`).

**Real incident (2026-08-11):** the lifecycle hooks injected `user` messages without the `synthetic` flag — `startup-context.js` (unshift of the startup context) and `appendMessage(output, "user", …)` used by `prompt-enforcer-lite.js`, `prompt-enforcer-strict.js`, `math-enforcer.js`. Regression ~2026-08-10 09:44 (hooks re-enabled 08-09), sessions were no longer renamed. The `small_model` was NOT the cause (valid and active). Confirmed by gate simulation: BEFORE=2 messages → skip, AFTER=1 message → fire.

**Fix applied:** added `synthetic: true` on the injected parts in `libs/message-utils.js` (`appendMessage`) and `startup-context.js` (unshift). The content stays visible to the model; only the title-gate "real user message" count is exempted from it.

**Strict rule for any hook injecting messages:**
- Add `synthetic: true` on **each** injected part (`{ type:"text", text, synthetic:true }`).
- **Never** inject a `role:"user"` message without `synthetic:true` — this would break title generation and skew any logic that counts real user messages.
- When in doubt, check via the gate: `messages.filter(O).length` must remain `=== 1` for the first message of a session.
