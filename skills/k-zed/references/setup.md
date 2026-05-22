# Zed — KπX Setup

One-time (or re-run safe) wiring so Zed’s **native agent** uses the same kernel and skills as Codex, Gemini, and Copilot.

## Prerequisites

- Zed installed (`zed --version`)
- KπX kernel present: `$HOME/.agents/AGENTS.md` (symlink to `$HOME/KpihX-Labs/.agents/`)
- Skills tree: `$HOME/.agents/skills/` (includes `k-zed`, `k-context`, …)

## 1. Symlink global kernel and skills

```bash
ln -sfn "$HOME/.agents/AGENTS.md" "$HOME/.config/zed/AGENTS.md"
ln -sfn "$HOME/.agents/skills" "$HOME/.config/zed/skills"
```

Verify:

```bash
ls -la "$HOME/.config/zed/AGENTS.md" "$HOME/.config/zed/skills"
# AGENTS.md -> .../.agents/AGENTS.md
# skills     -> .../.agents/skills
```

| Zed path | Points to | Effect |
|----------|-----------|--------|
| `$HOME/.config/zed/AGENTS.md` | `$HOME/.agents/AGENTS.md` | Personal instructions in every **native** agent thread |
| `$HOME/.config/zed/skills/` | `$HOME/.agents/skills/` | All `k-*` skills available (`/skill-name`, agent `skill` tool) |

**Applied on this machine:** 2026-05-20 (symlinks confirmed).

## 2. Open the right workspace

Project-level rules load from the **workspace root** (first match among `.rules`, `AGENTS.md`, …).

For the full KπX project kernel, open a folder that contains project `AGENTS.md`, e.g.:

- `$HOME/KpihX-Labs` (repo with `.agents/AGENTS.md` at root via symlink layout), or
- Any `$HOME/Work/<project>/` with `.agents/AGENTS.md`

## 3. Agent settings (manual)

Edit `$HOME/.config/zed/settings.json` for:

- `agent.default_model` / `agent.profiles` — see `profiles.md`
- `context_servers` — MCP; see `mcp.md`
- `agent_servers` — ACP bridges (Codex, Gemini, Cursor…); see `acp.md`
- `language_models.openai_compatible.*` — custom providers (e.g. Venice)

Mirror for agents/skills (symlink, not a copy):

```bash
"$HOME/.agents/skills/k-zed/scripts/sync_zed_settings.sh"
# -> assets/settings.json -> $HOME/.config/zed/settings.json
```

Model roster and Venice caps: **`settings.md`**.

Do not store API keys in git-tracked copies of `settings.json`; prefer env vars or login-shell MCP commands (`mcp.md`).

## 4. Reload Zed agent context

After symlinks or settings changes:

1. Quit and reopen Zed **or**
2. Start a **new** native agent thread (existing threads may keep the old system prompt)

Optional: Command Palette → `agent: open rules library` — prefer editing kernel via `AGENTS.md` / skills, not LMDB-only rules (`agents.md`).

## 5. External agents (ACP)

Symlinks above affect the **native** Zed agent only.

| Agent panel choice | Config home (unchanged) |
|--------------------|-------------------------|
| Codex | `$HOME/.codex/` → `k-codex` |
| Gemini | `$HOME/.gemini/` → `k-gemini` |
| Cursor | `$HOME/.cursor/` → `k-code` / `cursor.md` |

Zed forwards `context_servers` MCPs to ACP where supported; each CLI still reads its own `AGENTS.md` / `GEMINI.md` / etc.

## 6. Quick health check

```bash
# Symlinks
test -L "$HOME/.config/zed/AGENTS.md" && readlink -f "$HOME/.config/zed/AGENTS.md"
test -L "$HOME/.config/zed/skills" && readlink -f "$HOME/.config/zed/skills"

# Zed version
zed --version
```

In Zed: new native thread → agent should list skills under `$HOME/.config/zed/skills/` (same as `k-zed`, `k-context`, …).

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Kernel not in system prompt | Confirm symlinks; new thread; check `readlink` targets |
| Skills missing | `ls "$HOME/.config/zed/skills/k-zed/SKILL.md"` |
| Project rules ignored | Open correct workspace root with `AGENTS.md` |
| ACP agent ignores Zed rules | Expected — use that runtime’s home (`acp.md`) |

## Related references

- `agents.md` — rules, LMDB library, prompt injection
- `profiles.md` — Colab profile, `tool_permissions`
- `mcp.md` — `context_servers`
- `acp.md` — `agent_servers` registry
