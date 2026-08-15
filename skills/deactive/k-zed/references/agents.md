# Zed — AGENTS.md, Rules, and System Prompt Injection

How instructions reach the **native** Zed agent. External ACP agents are covered in `acp.md`.

## Instruction Sources (priority)

Zed compiles a single **system prompt** (Handlebars template `system_prompt.hbs`; public reference: [zed.dev/leaked-prompts](https://zed.dev/leaked-prompts)).

| Source | Typical path | Auto-included? | Notes |
|--------|--------------|----------------|-------|
| Zed built-in agent instructions | (shipped) | Always | Tools, autonomy defaults, plan tool when enabled |
| **Personal AGENTS.md** | `$HOME/.config/zed/AGENTS.md` | Every native thread | KπX: symlink → `$HOME/.agents/AGENTS.md` |
| **Project rules** | First match at workspace root | Per worktree | See file order below |
| **Default Rules Library** | LMDB (legacy) or migrated sections | Default 📎 rules | UI: `agent: open rules library` (`Ctrl+Alt+L`) |
| **@-mentioned rule** | Same library / skills | On demand | Adds to message context |
| **Skills** | `~/.config/zed/skills/`, project `.agents/skills/` | Metadata in system; body on `skill` tool | Same layout as KπX `SKILL.md` |

**Conflict rule (documented in template):** project rules take precedence over personal `AGENTS.md` when they conflict.

## Project Rules File Order

First existing file at project root wins (one file only):

1. `.rules`
2. `.cursorrules`
3. `.windsurfrules`
4. `.clinerules`
5. `.github/copilot-instructions.md`
6. `AGENT.md`
7. `AGENTS.md`
8. `CLAUDE.md`
9. `GEMINI.md`

Opening `$HOME/KpihX-Labs` (or any repo with root `AGENTS.md`) is required for project kernel injection.

## Rules Library (LMDB)

| Platform | Observed path |
|----------|----------------|
| Linux (KπX) | `$HOME/.local/share/zed/prompts/prompts-library-db.0.mdb/` |
| macOS (docs) | `$HOME/.config/zed/prompts/prompts-library-db.0.mdb/` |

- Binary key-value store (`data.mdb`, `lock.mdb`) — **not** editable as plain markdown.
- Rationale (historical): fast CRUD + autosave for UI ([PR #12468](https://github.com/zed-industries/zed/pull/12468)).
- Limitation: no git, no scripted edit without tools ([issue #34154](https://github.com/zed-industries/zed/issues/34154)).
- Export option: community [zed-prompts](https://github.com/rubiojr/zed-prompts) (LMDB → JSON).

### Migration (newer Zed builds, `skills` flag)

[PR #56672](https://github.com/zed-industries/zed/pull/56672) one-time migration:

| Old Rules Library | New location |
|-------------------|--------------|
| Default 📎 rules | Append to `$HOME/.config/zed/AGENTS.md` as `## <title>` sections |
| Non-default rules | `$HOME/.agents/skills/<slug>/SKILL.md` (`disable-model-invocation: true`) |

LMDB rows may remain for downgrade safety; prefer editing plaintext targets after migration.

## When Injection Happens

| Event | Effect |
|-------|--------|
| **New native agent thread** | Full system prompt built |
| **Rules Library save** | Prompt reload on supported builds (`PromptsUpdated`) |
| **@-mention rule/skill** | Adds to current turn context |
| **Each user message** | System prompt generally stable; rules not re-read from disk every turn unless reload |
| **Skills** | Description in system; full `SKILL.md` via `skill` or `read_file` tool |

## API Shape (what the model receives)

Not a JSON `{ "rules": [...] }` payload. Typical chat API:

```json
[
  { "role": "system", "content": "<compiled markdown from template + rules + skills metadata>" },
  { "role": "user", "content": "..." }
]
```

Tool definitions are separate from rules text (profile `tools` + MCP capabilities).

## KπX Wiring Checklist

```bash
ln -sfn "$HOME/.agents/AGENTS.md" "$HOME/.config/zed/AGENTS.md"
ln -sfn "$HOME/.agents/skills" "$HOME/.config/zed/skills"
```

- **Do not** duplicate the full kernel inside Rules Library LMDB.
- For Colab behavior: put protocol in `AGENTS.md` or a dedicated skill (e.g. `k-colab`), not only in LMDB.

## Personal AGENTS.md vs Other Agents

| Runtime | Global instructions file |
|---------|---------------------------|
| Zed native | `$HOME/.config/zed/AGENTS.md` |
| Codex | `$HOME/.codex/AGENTS.md` → kernel |
| Gemini | `$HOME/.gemini/GEMINI.md` → kernel |
| Cursor | User rules + `.cursor/rules` |
| Copilot | `$HOME/.copilot/copilot-instructions.md` → kernel |

Zed ACP threads for Codex/Gemini/Cursor **do not** read Zed Rules Library; they read their own config homes.
