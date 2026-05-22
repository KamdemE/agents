---
name: k-zed
description: >
  Zed editor agent hub — settings.json (native agent, profiles, tool_permissions),
  context_servers MCP, agent_servers ACP bridges, AGENTS.md/rules/skills paths.
  Load when configuring Zed, profiles, MCPs, external agents, or KπX hub wiring on Zed.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
  scope: agent-runtime
  target-agent: zed
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — Zed Editor

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Editor home:** `$HOME/.local/zed.app/` (AppImage/deb install on Linux)
- **User config:** `$HOME/.config/zed/settings.json` — **source of truth** for agent, MCP, profiles, providers; treat it as **JSONC in practice** (comments/trailing commas may be present), not strict JSON
- **Skill mirror:** `$HOME/.agents/skills/k-zed/assets/settings.json` → symlink to live settings (run `scripts/sync_zed_settings.sh` after moves)
- **User data (XDG):** `$HOME/.local/share/zed/` — prompts LMDB, threads, extensions, logs
- **Global kernel:** `$HOME/.config/zed/AGENTS.md` → `$HOME/.agents/AGENTS.md` (recommended symlink)
- **Skills (user):** `$HOME/.config/zed/skills/` → `$HOME/.agents/skills/` (recommended symlink)
- **Skills (project):** `<workspace>/.agents/skills/` (when opened as project root)
- **Keymap / themes:** `$HOME/.config/zed/keymap.json`, `$HOME/.config/zed/themes/`
- **Version check:** `zed --version`

## Hub Philosophy (KπX)

Zed is a **unified agent surface**, not a replacement for Codex/Gemini/Cursor runtimes:

| Layer | Role | Config owner |
|-------|------|----------------|
| **Native Zed agent** | Fast in-editor loop; profiles, tools, Zed rules, `tool_permissions` | `settings.json` → `agent.*` |
| **ACP bridges** | Full CLI agents (Codex, Gemini, Cursor, Copilot…) in the same panel | `agent_servers` + each agent's home (`~/.codex/`, `~/.gemini/`, …) |
| **KπX kernel** | Cross-agent identity, skills, governance | `$HOME/.agents/` (symlink into Zed where supported) |

Design principles:

- **0 magic:** prefer plaintext (`AGENTS.md`, `SKILL.md`, `settings.json`) over opaque stores when possible.
- **One sovereign kernel:** never duplicate long instructions in Zed LMDB if they already live in `$HOME/.agents/`.
- **Profiles ≠ modes:** Zed profiles are tool+model+MCP bundles for the **native** agent only; they are not Plan/Ask/Agent product modes like Cursor.
- **Colab on Zed:** one native profile + strong `AGENTS.md`/skill protocol + `tool_permissions: confirm` — not a read/write profile split (see `references/profiles.md`).

Do not enumerate installed MCPs or registry agents here; read `$HOME/.config/zed/settings.json` directly.

## Path Map (Linux)

| Path | Role |
|------|------|
| `$HOME/.config/zed/settings.json` | Models, `agent`, `context_servers`, `agent_servers`, `language_models` |
| `$HOME/.local/share/zed/prompts/prompts-library-db.0.mdb/` | Rules Library (LMDB; UI-managed on older builds) |
| `$HOME/.local/share/zed/threads/` | Agent thread storage |
| `$HOME/.local/share/zed/external_agents/` | ACP-related state |
| `$HOME/.local/share/zed/extensions/` | Zed extensions (incl. legacy agent-server extensions) |

macOS often uses `$HOME/.config/zed/prompts/` for the same LMDB; always verify with `ls` on the target machine.

## Source Of Truth (quick)

| Concern | Read first |
|---------|------------|
| **First-time / re-wire setup** | `references/setup.md` |
| **settings.json** (models, favorites, Venice) | `references/settings.md` |
| Native agent, profiles, permissions | `references/profiles.md` |
| Rules, `AGENTS.md`, system prompt injection | `references/agents.md` |
| MCP (`context_servers`) | `references/mcp.md` |
| External agents (ACP) | `references/acp.md` |

## KπX Bootstrap

Full checklist: **`references/setup.md`**. Minimal commands:

```bash
ln -sfn "$HOME/.agents/AGENTS.md" "$HOME/.config/zed/AGENTS.md"
ln -sfn "$HOME/.agents/skills" "$HOME/.config/zed/skills"
"$HOME/.agents/skills/k-zed/scripts/sync_zed_settings.sh"
```

On this machine both symlinks are **active** (verify with `ls -la $HOME/.config/zed/AGENTS.md $HOME/.config/zed/skills`).

After symlink or `settings.json` edits: restart Zed or start a **new** agent thread so the system prompt reloads.

## OpenAI-Compatible Providers

Custom providers live under `language_models.openai_compatible.<ProviderName>` in `settings.json` (API URL, model list, capabilities). Agent profiles reference them via `default_model.provider` / `default_model.model`.

Example pattern (Venice): API base `https://api.venice.ai/api/v1`, env key `VENICE_API_KEY` — verify caps against the provider API; do not hardcode wrong `max_tokens` in settings.

## Maintenance Reflex

- **Rules Library LMDB:** not git-friendly; prefer `AGENTS.md` + skills for automation ([Zed #34154](https://github.com/zed-industries/zed/issues/34154)). Newer builds migrate Default rules → `~/.config/zed/AGENTS.md` and named rules → `~/.agents/skills/` (PR [#56672](https://github.com/zed-industries/zed/pull/56672)).
- **Secrets:** never commit API keys in `settings.json`; use env vars or login-shell MCP wrappers (see `references/mcp.md`).
- **ACP debugging:** Command Palette → `dev: open acp logs`.
- Cross-agent hygiene: load `k-optim` before bulk cache cleanup; load `k-code` only for VS Code/Cursor parity sync, not for everyday Zed edits.

## Project Context

When the workspace root contains `.agents/AGENTS.md`, treat it as **project rules** (takes precedence over personal `AGENTS.md` on conflicts per Zed system prompt). Template: `$HOME/.agents/skills/k-project/assets/AGENTS.md`.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-zed/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-zed/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-22 | [CURSOR] | v1.1.0 — Venice model roster + `favorite_models`; `references/settings.md` + `assets/settings.json` symlink via `scripts/sync_zed_settings.sh`. |
| 2026-05-20 | [AUTO] | v1.0.3 — insights: custom MCP must use `command`/`args` top-level, not extension-only `settings` nesting. |
| [SUMMARY] | — | v1.0.2 settings.json JSONC reality; v1.0.1 references/setup.md + host symlinks; v1.0.0 initial skill structure. |
