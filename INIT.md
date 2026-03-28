# INIT — Agent First-Contact Protocol

Bootstrap for any agent joining the KπX workspace. Read once on first session.

---

## Agent Registry

| Agent | Home | Kernel link | Config file | Skills support |
|-------|------|-------------|-------------|----------------|
| CLAUDE | `~/.claude/` | `~/.claude/CLAUDE.md` → `~/.agents/KERNEL.md` | `~/.claude.json` | Yes |
| GEMINI | `~/.gemini/` | `~/.gemini/GEMINI.md` → `~/.agents/KERNEL.md` | `~/.gemini/settings.json` | Yes (extensions) |
| CODEX | `~/.codex/` | `~/.codex/AGENTS.md` → `~/.agents/KERNEL.md` | `~/.codex/config.toml` | Yes |
| COPILOT | `~/.copilot/` | `~/.copilot/copilot-instructions.md` → `~/.agents/KERNEL.md` | `~/.copilot/mcp-config.json` | Yes |
| VIBE | `~/.vibe/` | `~/.vibe/prompts/global.md` → `~/.agents/KERNEL.md` | `~/.vibe/config.toml` | Yes |
| OPENCLAW | `~/.openclaw/` | `~/.openclaw/workspace/AGENTS.md` → `~/.agents/KERNEL.md` | `~/.openclaw/openclaw.json` | Yes (workspace/skills/) |

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

## ② Create Your Runtime Skill

This step is mandatory for all agents. Create `~/.agents/skills/agents/<name>/SKILL.md` with YAML frontmatter:
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
The body must document:
1.  The path to your configuration file(s).
2.  The procedure for installing/configuring new MCPs.
3.  Any agent-specific rules or constraints.

**Do NOT list installed MCPs** — the config file is the source of truth.

---

## ③ Link the Global Kernel

Find the correct approach for your architecture and add your entry if missing.

### Approach 1: Symlink to `<AGENT_HOME>/<kernel_link_name>`

This is the most common approach. The target filename inside the agent's home directory (`~/.<agent_name>/`) can vary.

**Known Configurations:**
- **Claude:** `ln -sf ~/.agents/KERNEL.md ~/.claude/CLAUDE.md`
- **Codex:** `ln -sf ~/.agents/KERNEL.md ~/.codex/AGENTS.md`
- **Copilot:** `ln -sf ~/.agents/KERNEL.md ~/.copilot/copilot-instructions.md`
- **Gemini:** `ln -sf ~/.agents/KERNEL.md ~/.gemini/GEMINI.md`
- **OpenClaw:** `ln -sf ~/.agents/KERNEL.md ~/.openclaw/workspace/AGENTS.md`

### Approach 2: Symlink with `config.toml` modification

This approach is for agents that require both a symlink and a corresponding change in their main configuration file.

**Known Configurations:**
- **Vibe (Mistral):** Vibe loads its system prompt based on the `system_prompt_id` key. The procedure is to first create a symlink for the kernel to a file named `global.md` in the prompts directory, and then edit `config.toml` to point to it.
  ```bash
  # Step 1: Create the symlink
  ln -sf ~/.agents/KERNEL.md ~/.vibe/prompts/global.md
  # Step 2: Edit ~/.vibe/config.toml to set system_prompt_id = "global"
  ```

---

## ④ Configure Skills Path

Find the correct approach for your architecture and add your entry if missing.

### Approach 1: Native Discovery from `~/.agents/skills/` (1 level deep)

These agents scan `~/.agents/skills/` directly with no config. Only 1 level deep — all KπX skills use flat `k-` prefixed names to match this constraint.

**Known Configurations:**
- **Gemini:** Natively scans `~/.agents/skills/` — all `k-*`, `qmd`, `microsoft-foundry` discovered directly.

### Approach 2: Symlink agent's private skills directory → `~/.agents/skills/`

These agents scan their own `~/.<agent>/skills/`. Point it at `~/.agents/skills/` via symlink.

**Standard procedure** (for agents whose skills dir can be replaced wholesale):
```bash
ln -sf ~/.agents/skills ~/.<agent>/skills
```

**Loop procedure** (for agents with a pre-existing managed dir — e.g. Codex has `.system/`):
```bash
for d in ~/.agents/skills/*/; do
  ln -sf "$d" <agent_home_skills_dir>/"$(basename $d)"
done
```

**Known Configurations:**
- **Claude:** `ln -sf ~/.agents/skills ~/.claude/skills` *(direct replacement)*
- **Codex:** loop into `~/.codex/skills/` *(has `.system/` managed by Codex — cannot replace wholesale)*
- **Copilot:** `ln -sf ~/.agents/skills ~/.copilot/skills` *(create if absent)*
- **OpenClaw:** loop into `~/.openclaw/workspace/skills/` *(workspace-native dir)*

### Approach 3: Configuration via `skill_paths` key

This approach is for agents that support a `skill_paths` key in their configuration file to explicitly define skill directories.

**Known Configurations:**
- **Vibe (Mistral):** Edit `~/.vibe/config.toml` and set `skill_paths = ["$HOME/.agents/skills"]`.

---

## ⑤ Post-Init: Agent Self-Adaptation

After a successful init, **do this proactively** without waiting to be asked:

1. **Audit & Update:** For each setup step above (§III, §IV, §V), add your agent's specific configuration command/path to the appropriate "Approach" list. If your mechanism represents a new approach, create a new "Approach X" section for it.
2. **Propose Adjustments:** Suggest edits to your own runtime skill at `skills/agents/<name>/SKILL.md` to capture any other specifics about your runtime.
3. **Log & Push:** Update `~/.agents/memory/dailylog.md` with an entry for the init session, then propose a `git commit` and `make push` to save the updated `INIT.md`.

---

## ⑥ Deprecated Procedures

The following sections are kept for historical reference but should no longer be used for new agent onboarding.

### Fallback Procedure — Agents without skills support

Use **only** when an agent does not support `agentskills.io`.

**Setup (4 steps):**
1. Link global kernel: `ln -sf ~/.agents/KERNEL.md <AGENT_HOME>/<KERNEL_LINK_NAME>`
2. Create runtime shortcut: `ln -sf ~/.agents/skills/k-<name>/SKILL.md ~/<AGENT_NAME>.md`
3. Symlink skills dirs: `for folder in ~/.agents/skills/*/; do ln -sf "$folder" <AGENT_HOME>/skills/"$(basename "$folder")"; done`

