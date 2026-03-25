# ~/.agents/memory/MEMORY.md — WARM Memory Tier

> Distilled cross-session architectural facts. Updated when new decisions are made.
> Agent-written prose only — newest-first. Max 20 entries before condensing.

---

## Architecture Decisions

- **`~/.agents/` is the single git-versioned agent home** (2026-03-25). `~/.agent/` is deprecated.
- **Skills follow agentskills.io standard** — SKILL.md with YAML frontmatter, 2-level depth limit, progressive disclosure.
- **Agent runtime skills in `skills/agents/`** — cross-accessible by all agents. Claude can read Gemini's config to install MCPs for it.
- **`~/.claude/skills/` → symlink → `~/.agents/skills/`** — single master skills directory, all agents share via per-agent symlinks.
- **TODOs centralized in `memory/context.md`** — not per-agent files. Stop hook enforces daily update.
- **`~/CLAUDE.md` etc. → symlink → `skills/agents/<name>/SKILL.md`** — runtime shortcut, runtime fact + skills format in one file.
- **Project local memory:** `.agents/memory/context.md` (20-50 lines) replaces the old copy of monolithic AGENT.md. Global skills auto-discovered via configured path — no copy needed.

## Confirmed Working Patterns

- **Login shell wrap for MCPs:** `{"command": "zsh", "args": ["-l", "-c", "<binary> serve"]}` — ensures bw-env secrets from ~/.kshrc visible.
- **bw-env PID guard:** `BW_ENV_LOADED=$$` — child processes reload secrets; prevents double-sourcing.
- **PyPI name != module name:** `[tool.uv.build-backend] module-name = "mail_mcp"` with `[project] name = "k-mail-mcp"`. Confirmed in mail-mcp v0.2.0.
- **node symlink after nvm upgrade:** `ln -sf ~/.nvm/versions/node/vX.Y.Z/bin/node ~/.local/bin/node`.
- **Gemini extension `version` field:** CRITICAL — absence silently blocks installation.
- **Codex `env` blocks:** Do NOT add by default — can break Codex startup.

## Active Tool Versions

- **mail-mcp:** v0.2.0 (PyPI: k-mail-mcp), homelab port 8094
- **linkedin-mcp:** v0.1.0 (npm: k-linkedin-mcp), homelab port 8095
- **bw-mcp:** v1.7.1
- **Chrome:** v146 (Claude browser extension installed)
- **OpenClaw:** v2026.3.23 (installed, onboarding in progress)
- **Homebrew:** v5.1.1 (Linuxbrew, /home/linuxbrew/.linuxbrew/, in ~/.kshrc)

## Key Pending Items

- **DXO internship:** Accepted — "Stage Image Research (Learning to Cull)", starts summer 2026
- **Edge Copilot sidebar:** blank — cause unknown (not signed in to MS account?)
- **OpenClaw hooks:** to configure (bootstrap-extra-files, session-memory, command-logger)
