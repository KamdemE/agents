# k-zed — Runtime Insights

Durable lessons for Zed agent hub work. Newest entries at the top.

## 2026-05-22 — Archived agent threads: where they live + permanent purge

- **Archive is a flag, not a move:** `sidebar_threads.archived = 1` in `$HOME/.local/share/zed/db/0-stable/db.sqlite`. Active sidebar rows use `archived = 0`.
- **Message bodies:** `$HOME/.local/share/zed/threads/threads.db` (`threads` table, `data_type = zstd`, JSON inside). Session id = `threads.id` = `sidebar_threads.session_id`.
- **Permanent purge:** `DELETE FROM sidebar_threads WHERE archived = 1` + `DELETE FROM threads WHERE id IN (...)` for those session ids, then `VACUUM` each DB (outside a transaction). Backup first to `$HOME/.local/share/zed/backups/`.
- **External/ACP threads:** May exist only in `sidebar_threads` (no `threads.db` row) — still delete the sidebar row.
- **Reload Zed** after manual purge so the Thread History / sidebar UI refreshes.

## 2026-05-22 — Venice model caps from live `/v1/models`

- Source of truth for `max_tokens` / `max_completion_tokens` / tool+reasoning flags: `GET https://api.venice.ai/api/v1/models` with `VENICE_API_KEY`.
- **Aion 2.0** (`aion-labs-aion-2-0`): `supportsFunctionCalling: false` → Zed `capabilities.tools: false` (agent tools will not work on this model).
- Reasoning models (GLM 5 Turbo, Heretic, Qwen 3.6 Plus): prefer `interleaved_reasoning: true` in Zed when Venice reports `supportsReasoning: true`.
- Skill mirror: `k-zed/assets/settings.json` symlink via `scripts/sync_zed_settings.sh` — same pattern as `k-code` Cursor → Code settings link.

## 2026-05-20 — Custom MCP vs extension schema (mail/tick silent skip)

- **Symptom:** Native agent only sees extension MCPs (e.g. Exa); custom `mail-mcp` / `tick-mcp` never appear; **no log lines** for those server ids in `Zed.log`.
- **Cause:** Manual stdio servers were declared with extension shape (`enabled`, `remote`, nested `settings.command` / `settings.args`) but **no Zed extension** is installed for those ids.
- **Fix:** Use Zed custom-server shape per [MCP docs](https://zed.dev/docs/ai/mcp): top-level `command`, `args`, `env` (and often `"source": "custom"`). Ensure the binary is on `PATH` or provide the full path to `"$HOME/.local/bin/<mcp> serve"`.
- **Profile trap:** `enable_all_context_servers: false` + whitelist only Exa → agent sees Exa only even when globals are fixed.
- **Verify:** Agent Panel → MCP settings → green dot “Server is active”; new thread after edit.

## 2026-05-20 — Zed `settings.json` is JSONC in practice

- The live file may contain `//` comments and trailing commas, so strict JSON parsers will fail.
- For scripted edits, treat it as text/JSONC and preserve formatting instead of `json.loads()` round-trips.
- In this workspace, `edit_file` cannot reach `$HOME/.config/zed/settings.json` because the editable root is `KpihX-Labs/`; host-level Zed config changes require a terminal-based patch.


## 2026-05-20 — KπX symlinks applied on host

```bash
$HOME/.config/zed/AGENTS.md -> $HOME/.agents/AGENTS.md
$HOME/.config/zed/skills     -> $HOME/.agents/skills
```

Documented in `references/setup.md`. Re-run `ln -sfn` after moving `.agents` git root.

## 2026-05-20 — Rules Library is LMDB, not markdown

- **Path (Linux):** `$HOME/.local/share/zed/prompts/prompts-library-db.0.mdb/` (not always `$HOME/.config/zed/prompts/`).
- **Why:** Historical `PromptStore` choice (PR #12468) for UI autosave + metadata; community issue #34154 tracks plaintext migration.
- **KπX workaround:** Automate via `$HOME/.config/zed/AGENTS.md` + `$HOME/.agents/skills/`, not LMDB edits.
- **Future:** PR #56672 migrates Default rules → global `AGENTS.md`, non-default → global skills.

## 2026-05-20 — ACP agents ignore Zed profiles and Rules Library

- `agent.profiles` and Rules Library apply only to the **native** Zed agent.
- Codex/Gemini/Cursor threads read their own homes (`~/.codex/config.toml`, `GEMINI.md`, etc.).
- Zed forwards `context_servers` MCPs to ACP but not Zed rules files.

## 2026-05-20 — System prompt injection is compiled text

- No separate `rules` JSON field to the LLM: Handlebars template → `system` message (see zed.dev/leaked-prompts `system_prompt.hbs`).
- Reload: new thread, or library update events on supported builds.

## 2026-05-20 — Colab anti-pattern on Zed

- Do not split `colab` + `colab-write` profiles (recreates plan/execute).
- Use one profile with full read tools + `tool_permissions.default: confirm` + Colab protocol in `AGENTS.md` or `k-colab` skill.
