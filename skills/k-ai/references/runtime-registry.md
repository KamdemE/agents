# k-ai — Agent Runtime Registry (Full Details)

> **Purpose:** Complete agent runtime registry absorbed from `k-agents` (merged 2026-08-14) and preserved here in full detail so the compact `k-ai/SKILL.md` stays lean (GRAVÉ: no information loss). This is the **source of truth for the Curator daemon** (runtime status, configs, symlinks, injection, ACP, monitoring). Corrections applied 2026-08-14: **OpenClaw = opérationnel** (plus "purged") · Claude Code = extension-auth opencode · Continue purgé.

## Status Legend

- 🟢 Active — in daily use
- 🟡 Standby — installed, occasional use
- 🔴 Deactive — not used, kept for reference

## Runtime Registry

| # | Runtime | Status | Config path | AGENTS.md symlink | Skills source | ACP | Sub-agents | Hooks | Injection | Curator monitor |
|---|---------|--------|-------------|-------------------|---------------|-----|------------|-------|-----------|-----------------|
| 1 | **OpenCode** | 🟢 | `~/.config/opencode/opencode.jsonc` | `AGENTS.md` → kernel | `skills/` symlink | `opencode acp` (stdio) | ✅ via `task` + `agents/` | Plugin system | AGENTS.md + skills | every session |
| 2 | **Hermes** | 🟢 | `~/.hermes/config.yaml` | `SOUL.md` → kernel | `skills/` isolated sandbox | `hermes acp` | ✅ profiles + delegation | Hooks system | SOUL.md + external_dirs | every 6h (cron) |
| 3 | **Cursor** | 🟢 | `~/.cursor/settings.json` | `.cursorrules` → kernel | `.cursor/agents/` | ✅ native | ✅ Task tool | Rule-based | `.cursorrules` | daily |
| 4 | **OpenClaw** | 🟢 | `~/.openclaw/openclaw.json` | `AGENTS.md` → kernel | gateway skills | ✅ | ✅ agents | Hooks | AGENTS.md | ✅ |
| 5 | **Claude Code** | 🔴 | `~/.claude.json` | `CLAUDE.md` → kernel | `skills/` symlink | ❌ | ❌ | 6 events | CLAUDE.md + memory | ❌ |
| 6 | **AGY (Antigravity)** | 🔴 | purged 2026-08-14 | — | — | ❌ | ❌ | ❌ | — | ❌ |
| 7 | **Codex** | 🔴 | purged 2026-08-14 | — | — | ❌ | ❌ | ❌ | — | ❌ |
| 8 | **Gemini** | 🔴 | purged 2026-08-14 | — | — | ❌ | ❌ | ❌ | — | ❌ |
| 9 | **Copilot CLI** | 🔴 | purged 2026-08-14 | — | — | ❌ | ❌ | ❌ | — | ❌ |
| 10 | **VIBE** | 🔴 | purged 2026-08-14 | — | — | ❌ | ❌ | ❌ | — | ❌ |
| 11 | **Cline** | 🔴 | purged 2026-08-14 | — | — | ❌ | ❌ | ❌ | — | ❌ |
| 12 | **Zed** | 🔴 | purged 2026-08-14 | — | — | ❌ | ❌ | ❌ | — | ❌ |
| 13 | **Continue** | 🔴 | purged 2026-08-14 (`~/.continue/` supprimé) | — | — | ❌ | ❌ | ❌ | — | ❌ |

## Per-Runtime Details (actifs)

**OpenCode** — Config `~/.config/opencode/opencode.jsonc` (JSONC) · Injection `AGENTS.md` symlink → kernel + `skills/` + `agents/` · ACP `opencode acp` stdio (session/list, resume, prompt) · Sub-agents via `agents/` + `task` · Permissions 3-tier · Modèle par défaut `opencode-go/mimo-v2.5` · Skills `~/.config/opencode/skills/` → `~/.agents/skills/` · Curator via `opencode acp`. Voir **k-opencode**.

**Hermes** — Config `~/.hermes/config.yaml` · Injection `SOUL.md` → kernel + `external_dirs` · ACP `hermes acp` (delegate_task) · Sub-agents profiles + delegation · Skills `~/.hermes/skills/` (sandbox isolé, PAS symlink kernel) · Cron `hermes --profile cron` · Curator via `hermes sessions list`. Voir **k-hermes**.

**Cursor** — Config `~/.cursor/settings.json` · Injection `.cursorrules` (copie manuelle, pas symlink) · ACP natif · Sub-agents `.cursor/agents/*.md` + Task · Skills `.cursor/agents/` (par projet) · Curator via ACP + inspection. **IDE seul** (CLI `cursor-agent` purgé 2026-08-14). Voir **k-code**.

**OpenClaw** — ✅ **OPÉRATIONNEL** (ne plus le marquer "purged") · Config `~/.openclaw/openclaw.json` · Gateways multi-agents + serve · Voir **k-openclaw**.

**Claude Code** — 🔴 skill deactive (`skills/deactive/k-claude/`) mais **binaire `~/.local/bin/claude` CONSERVÉ** : il sert **uniquement** à l'authentification de l'**extension Claude d'opencode** (utilisation de l'abonnement Claude). Sessions Claude totalement vides. Config `~/.claude.json` · Injection `CLAUDE.md` → kernel.

## Per-Runtime Details (purgés 2026-08-14 — archive)

**AGY (Antigravity)** — Config `~/.agy/config.json` (supprimé) · purgé : bins + dirs + caches + launchers. **Codex** — `~/.codex/config.toml` (supprimé). **Gemini** — `~/.gemini/settings.json` (supprimé). **Copilot CLI** — `~/.copilot/` (supprimé). **VIBE** — `~/.vibe/config.toml` (supprimé). **Cline** — `~/.cline/` (supprimé). **Zed** — `~/.config/zed/` + `~/.local/zed.app` (supprimés). **Continue** — `~/.continue/` + extension VS Code/Cursor/Antigravity (supprimés). Détails complets → `k-uv/references/purged.md`, `k-node/references/purged.md`, `k-clis/references/purged.md`, `k-ai/references/purged.md`.

## Injection Matrix — What Each Agent Auto-Loads

| File | OpenCode | Hermes | Cursor | Claude | (purgés) |
|------|----------|--------|--------|--------|----------|
| **AGENTS.md** | ✅ | via SOUL.md | ⚠️ manual | ✅ | ❌ |
| **SOUL.md** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **USER.md** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **k-context** | hooks auto-inject | external_dirs | ❌ | ❌ | ❌ |
| **k-infras** | hooks auto-inject | external_dirs | ❌ | ❌ | ❌ |
| **skills/** | ✅ symlink | isolated | per-project | ✅ symlink | ❌ |

## Cross-References

| This skill | References | Is referenced by |
|------------|-----------|-----------------|
| **k-ai** (hub + registry) | k-context, <github-user>, k-opencode, k-hermes, k-clis, k-optim, k-final | k-context, AGENTS.md, every agent |
| **k-context** | k-ai, <github-user>, k-opencode | AGENTS.md (auto-injected for Colab/Build), every agent |
| **k-infras** | k-ai, k-project, k-git | AGENTS.md (auto-injected for Colab/Build), every agent |
| **k-opencode** | k-ai, `scripts/plugins/hooks/` | AGENTS.md (mandatory rules) |
| **k-hermes** | k-ai, k-opencode | Hermes config, k-context |
| **k-clis** | k-ai, all runtime skills | k-ubuntu |
| **k-optim** | k-ai, k-context | k-context |
| **k-final** | k-ai, k-context, k-git | k-context (project finalization) |

## Curator Usage

The Curator daemon (`agents/curator/agent.md`) reads this skill to know:
1. Which runtimes are active and should be monitored
2. How to connect to each runtime (ACP, file system, etc.)
3. What each runtime auto-loads (to verify injection works)
4. What known issues to watch for

```bash
# Curator loops through each ACTIVE runtime and verifies:
# 1. AGENTS.md symlink exists and points to kernel
# 2. Skills path exists and is accessible
# 3. Config file exists and is parseable
# 4. ACP (if supported) can list sessions
# 5. Any known issues have workarounds applied
```

## Kernel File Layout

The agent kernel lives at `$HOME/.agents/`:
| Path | Role |
|------|------|
| `$HOME/.agents/` | Symlink → `$HOME/Labs/.agents/` (git root for the global agent kernel) |
| `$HOME/.agents/AGENTS.md` | Canonical AGENTS kernel — always edit this file |
| `$HOME/Labs/AGENTS.md` | Symlink → `.agents/AGENTS.md` (workspace-root convenience) |
| `$HOME/.openclaw/workspace/AGENTS.md` | Symlink → `.agents/AGENTS.md` (legacy OpenClaw template dir) |

**Do not** hard-link or maintain a second copy of `AGENTS.md`. Full routing: `$HOME/.agents/AGENTS.md`.
