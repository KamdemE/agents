# Agent & Subagent System

OpenCode discovers agents from two sources that merge:

## 1. Config file (`opencode.jsonc` → `agent.*` or `agents.*`)

Primary agents are defined under the `agent` key:
```jsonc
"Colab": {
  "mode": "primary",                      // Tab-visible primary agent
  "prompt": "{file:~/.agents/agents/Colab/prompt.txt}"  // Prompt from raw text file
}
```
- `{file:path}` loads ANY text file (`.md`, `.txt`, etc.) — extension does not matter for prompt injection.
- Agents defined ONLY in config (no `.md` file) must have `mode: "primary"`.

## 2. Markdown files (`~/.config/opencode/agents/<path>/<name>.md`)

All `.md` files under the agents directory are auto-discovered. The file path becomes the agent ID:
```
agents/executor/agent.md   →   agent "executor/agent"
agents/Colab/prompt.md     →   agent "Colab/Prompt"
```

## Agent Modes

| Mode | Tab-visible? | Invocable via `task`? | Invocable via `@`? |
|------|-------------|----------------------|-------------------|
| `primary` | ✅ Yes | ❌ No | ❌ No |
| `subagent` | ❌ No | ✅ Yes | ✅ Yes (unless `hidden`) |
| `all` | ✅ Yes | ✅ Yes | ✅ Yes |

## Hide from UI

`hidden: true` hides a `mode: subagent` from the `@` autocomplete menu and Tab selector. The agent remains invocable via the `task` tool by parent agents.

## Permission format (V1 — still accepted in v1.18.x)

```yaml
permission:
  edit: allow           # "allow" | "ask" | "deny"
  bash: deny
  task: allow
  read: allow
  skill: allow
```

Extra fields (`id`, `scope`, `role`) are passed through as metadata — harmless.

## ⚠️ Critical: YAML frontmatter pitfalls (learned 2026-07-22)

gray-matter silently drops the **entire frontmatter** if YAML is malformed. No error, no warning — OpenCode loads the agent with `mode: all` default, making it Tab-visible.

**Known failures:**

| Error | Broken YAML | Effect |
|-------|------------|--------|
| Wrong indentation | `name: curator\n  version: "2.0.0"` | `version` becomes child of `name` → frontmatter silently dropped → `mode: subagent` lost → agent appears in Tab |
| Unquoted colon in value | `description: Reviews: returns verdict.` | YAML interprets `:` as mapping separator → frontmatter truncated |

**Rules:**
- All fields must be at the **same indentation level** (0 spaces for root keys)
- If a description contains `:`, quote it: `description: "Reviews code: quality check"`
- After editing frontmatter, **restart OpenCode** — old parse is cached per session
- Verify YAML with `python3 -c "import yaml; yaml.safe_load(open('file.md').read().split('---')[1])"`

##  Setup

| Agent | Definition | Mode | File |
|-------|-----------|------|------|
| `Colab` 🟢 | `opencode.jsonc` + `{file:.../Colab/prompt.txt}` | primary | `agents/Colab/prompt.txt` |
| `Explore` 🔵 | `opencode.jsonc` + `{file:.../Explore/prompt.txt}` | primary | `agents/Explore/prompt.txt` |
| `Build` | `opencode.jsonc` (`{}` — inherits global) | primary | `opencode.jsonc` only |
| `Lite` 🟠 | `opencode.jsonc` — Ollama local, no skills/MCPs | primary | `opencode.jsonc` only |
| `Auto` 🔴 | `opencode.jsonc` — `*: allow`, future-proof | primary | `opencode.jsonc` only |
| `Agent` 🟣 | `opencode.jsonc` + `{file:.../Agent/prompt.txt}` — end-to-end solo, all sub-agents | primary | `agents/Agent/prompt.txt` |
| `Plan` | `opencode.jsonc` — read-only | primary | `opencode.jsonc` only |
| `executor/agent` 🛠️ | `agents/executor/agent.md` | subagent | `agents/executor/agent.md` |
| `curator/agent` 🧹 | `agents/curator/agent.md` | subagent | `agents/curator/agent.md` |
| `intent-guardian/agent` 👁️ | `agents/intent-guardian/agent.md` | subagent | `agents/intent-guardian/agent.md` |
| `pragmatic-checker/agent` ✅ | `agents/pragmatic-checker/agent.md` | subagent | `agents/pragmatic-checker/agent.md` |
| `fact-verifier/agent` 🔍 | `agents/fact-verifier/agent.md` | subagent | `agents/fact-verifier/agent.md` |

**Key rule:** Only agents with `mode: primary` or `mode: all` appear in Tab. Subagents with `mode: subagent` + `hidden: true` are invisible but usable via `task` tool delegation.
