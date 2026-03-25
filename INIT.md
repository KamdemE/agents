# INIT — Agent First-Contact Protocol

Bootstrap for any agent joining the KπX workspace. Read once on first session.

---

## Agent Registry

| Agent | Home | Kernel link | Config file | Skills support |
|-------|------|-------------|-------------|----------------|
| CLAUDE | `~/.claude/` | `~/.claude/CLAUDE.md` → `~/.agents/KERNEL.md` | `~/.claude.json` | Yes |
| GEMINI | `~/.gemini/` | `~/.gemini/GEMINI.md` → `~/.agents/KERNEL.md` | `~/.gemini/settings.json` | Yes (extensions) |
| CODEX | `~/.codex/` | `~/.codex/AGENTS.md` → `~/.agents/KERNEL.md` | `~/.codex/config.toml` | Yes |
| COPILOT | `~/.copilot/` | `~/.copilot/COPILOT.md` → `~/.agents/KERNEL.md` | `~/.copilot/mcp-config.json` | Yes |
| VIBE | `~/.vibe/` | `~/.vibe/prompts/global.md` → `~/.agents/KERNEL.md` | `~/.vibe/config.toml` | No ? see §IV |

---

## ① Self-Verification (do this FIRST — before any setup action)

Before touching any file or config, verify that this protocol is consistent with your actual capabilities.

### Step 1 — Use your introspection tools if available

If the agent has a help command, self-documentation tool, or built-in docs:
- Run it to understand your own capabilities, config format, and supported features
- Cross-check: does INIT describe your setup steps correctly?

### Step 2 — Challenge with web search if available

If the agent has web search access:
- Search for your own name + "skills" / "MCP config" / "system prompt" / "agentskills"
- Verify that the steps in §II match how your agent actually works

### Step 3 — Handle divergences

If you detect **any divergence** between this protocol and your actual capabilities:
- **STOP immediately** — do not begin any setup step
- **Alert KπX explicitly**: name the divergence, quote the conflicting step
- **Propose proactively**: a corrected procedure or config workaround
- Wait for KπX to confirm before proceeding

> No divergence found → proceed to the appropriate section below.

---

## ② Standard Procedure — Skills-capable agents

For agents that support the [agentskills.io](https://agentskills.io) standard
(YAML frontmatter SKILL.md, configurable skills path discovery).

### Setup (4 steps)

**1. Create your runtime skill**

Create `~/.agents/skills/agents/<name>/SKILL.md` with YAML frontmatter:
```yaml
---
name: agent-runtime-<name>
description: "<Agent> runtime — config file path + format, MCP install procedure, agent-specific rules."
license: private
metadata:
  author: KpihX
  version: "1.0.0"
  scope: agent-runtime
  target-agent: <name>
allowed-tools: Bash, Read, Write, Edit
---
```
Body must document: config file path + format (with example), MCP install procedure, agent-specific rules.
Do NOT list installed MCPs — the config file is the source of truth for what's currently installed.

**2. Link the global kernel**

```bash
ln -sf ~/.agents/KERNEL.md <AGENT_HOME>/<KERNEL_LINK_NAME>
```

**Known configurations — add your entry when onboarding:**
- **Claude:** `ln -sf ~/.agents/KERNEL.md ~/.claude/CLAUDE.md`
- **Codex:** `ln -sf ~/.agents/KERNEL.md ~/.codex/AGENTS.md`
- **Copilot:** `ln -sf ~/.agents/KERNEL.md ~/.copilot/COPILOT.md`
- **Gemini:** `ln -sf ~/.agents/KERNEL.md ~/.gemini/GEMINI.md`

**3. Configure skills path**

Point the agent's skills discovery to `~/.agents/skills/`. Method varies per agent.

**Known configurations — add your entry when onboarding:**

- **Claude:** `~/.claude/skills/` pre-existed as a directory with entries — a top-level `ln -sf` would nest a symlink *inside* it rather than replacing it, so namespace-level symlinks are required instead:
  ```bash
  ln -sf ~/.agents/skills/kpihx ~/.claude/skills/kpihx
  ln -sf ~/.agents/skills/agents ~/.claude/skills/agents
  ```
- **Codex:** `skill_paths` array in `~/.codex/config.toml`:
  ```toml
  skill_paths = ["/home/kpihx/.agents/skills"]
  ```
- **Copilot:** *(fill in when onboarding)*
- **Gemini:** *(fill in when onboarding)*

> Only create a §IV-style dedicated section if your setup is fundamentally different (e.g. no skills support at all).

**4. Inject HOT memory at boot**

Load `~/.agents/memory/context.md` at session start via the agent's available mechanism.

**Known configurations — add your entry when onboarding:**

- **Claude:** `bootstrap-extra-files` hook in `~/.claude/settings.json` → `["/home/kpihx/.agents/memory/context.md"]`
- **Codex:** *(fill in when onboarding)*
- **Copilot:** *(fill in when onboarding)*
- **Gemini:** *(fill in when onboarding)*

### What is NOT needed in the standard procedure

- No `~/AGENT_NAME.md` shortcut — the skill is discovered via the skills path directly
- No copy of KERNEL.md — symlink only

### Validation checklist

- [ ] `~/.agents/skills/agents/<name>/SKILL.md` exists with valid YAML frontmatter
- [ ] `<AGENT_HOME>/<KERNEL_LINK>` → `~/.agents/KERNEL.md` (verify: `ls -la`)
- [ ] Agent's skills path resolves to `~/.agents/skills/`
- [ ] `~/.agents/memory/context.md` loaded at session start
- [ ] File routing contract understood (see KERNEL.md)

---

## ③ Fallback Procedure — Agents without skills support (deprecated)

Use **only** when:
- The agent does not support agentskills.io (no SKILL.md discovery)
- Skills setup fails and a working session is urgently needed

> Deprecated — always prefer Standard (§II) when possible.

### Fallback setup (4 steps)

**1. Link the global kernel**
```bash
ln -sf ~/.agents/KERNEL.md <AGENT_HOME>/<KERNEL_LINK_NAME>
```

**2. Create a runtime shortcut** (only case where `~/AGENT_NAME.md` is used)
```bash
ln -sf ~/.agents/skills/agents/<name>/SKILL.md ~/<AGENT_NAME>.md
```

**3. Skills discovery via symlink**
```bash
# If agent home skills/ does not exist:
ln -sf ~/.agents/skills <AGENT_HOME>/skills
# If it already exists as a directory, add namespace-level symlinks:
ln -sf ~/.agents/skills/kpihx <AGENT_HOME>/skills/kpihx
ln -sf ~/.agents/skills/agents <AGENT_HOME>/skills/agents
```

**4. Inject HOT memory**

Inject `~/.agents/memory/context.md` via any available mechanism
(file bootstrap, session hook, or manual read at session start).

### Fallback validation checklist

- [ ] `<AGENT_HOME>/<KERNEL_LINK>` → `~/.agents/KERNEL.md`
- [ ] `~/<AGENT_NAME>.md` → `~/.agents/skills/agents/<name>/SKILL.md`
- [ ] Skills symlink resolves correctly
- [ ] `~/.agents/memory/context.md` loaded

---

## ④ VIBE — Special Case

VIBE uses a **prompts injection system**, not agentskills.io.
`skill_paths = []` in `config.toml` — no skills discovery. Uses Fallback (§III) by default,
but with a VIBE-specific kernel injection mechanism.

### How VIBE loads context

| Mechanism | File | When loaded |
|-----------|------|-------------|
| `system_prompt_id = "global"` in config.toml | `~/.vibe/prompts/global.md` | Injected as system prompt every session |
| Model instructions mandate explicit read | `~/.vibe/prompts/vibe.md` | Agent reads it at session start |

Both files are symlinks — update their **targets**, never their content.

### VIBE setup

```bash
# 1. Link global kernel as system prompt
ln -sf ~/.agents/KERNEL.md ~/.vibe/prompts/global.md

# 2. Link VIBE runtime skill as the session-start read file
ln -sf ~/.agents/skills/agents/vibe/SKILL.md ~/.vibe/prompts/vibe.md
```

No skills path configuration. No `~/VIBE.md` shortcut (VIBE reads `vibe.md` from `prompts/` directly).

### VIBE-specific constraints (from config.toml)

- **Active model:** `devstral-2` (Mistral, `mistral-vibe-cli-latest`) — temperature 0.2
- **Bash:** permission = `ask`; allowlisted safe commands only (`ls`, `cat`, `git status/diff/log`, etc.)
- **Bash denylist:** interactive shells, debuggers, editors (vim, nano, emacs...)
- **Write / search_replace:** permission = `ask`
- **Read / grep / todo / ask_user_question:** permission = `always`
- **MCP config:** `[[mcp_servers]]` TOML array in `~/.vibe/config.toml`
- **Session logging:** saved to `~/.vibe/logs/session/`

### VIBE validation checklist

- [ ] `~/.vibe/prompts/global.md` → `~/.agents/KERNEL.md`
- [ ] `~/.vibe/prompts/vibe.md` → `~/.agents/skills/agents/vibe/SKILL.md`
- [ ] `~/.vibe/config.toml` MCP stack up to date
- [ ] Model instructions in config.toml still mandate reading `vibe.md`

---

## ⑤ Post-Init — Agent-Specific Adaptation

After a successful init (all checklist items green), **do this proactively** without waiting to be asked:

1. **Audit your own capabilities** against what the standard procedure assumes:
   - How does your agent actually resolve skill paths? Any caveats?
   - Which memory injection mechanism did you use, and does it have limits?
   - Any non-obvious MCP config constraints (env vars, restart required, auth)?

2. **Complete the INIT.md example lists** (steps 2, 3, 4 of §II):
   - Add your concrete kernel link command to the step 2 list (if not already present)
   - Add your skills path configuration to the step 3 list
   - Add your HOT memory injection method to the step 4 list
   - Only create a new §IV-style section if your case is fundamentally different from existing agents

3. **Propose concrete adjustments**:
   - Suggest edits to `skills/agents/<name>/SKILL.md` to capture your specifics
   - If INIT.md has inaccuracies for your agent, propose a correction

4. **Update `~/.agents/memory/dailylog.md`** with the init session entry.

5. **Propose `git commit` + `make push`** so the registry stays versioned.

---

## Memory Architecture

```
~/.agents/                 git-versioned repo
├── KERNEL.md              slim global kernel
├── INIT.md                this file
├── Makefile               push/log/status targets
├── skills/
│   ├── kpihx/             cross-agent KπX knowledge (8 skills)
│   ├── agents/            agent runtime skills — cross-accessible by ALL agents
│   ├── microsoft-foundry/ external skill
│   └── qmd/               QMD search skill
└── memory/
    ├── context.md         HOT: TODOs + active projects (inject at boot)
    ├── dailylog.md        LOG: chronological, max 10 entries
    └── MEMORY.md          WARM: distilled cross-session facts
```
