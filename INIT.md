# INIT — Agent First-Contact Protocol

Bootstrap for any agent joining the KπX workspace. Read once on first session.

---

## Agent Registry

| Agent | Home | Kernel link | Config file | Skills support |
|-------|------|-------------|-------------|----------------|
| CLAUDE | `$HOME/.claude/` | `$HOME/.claude/CLAUDE.md` → `$HOME/.agents/AGENTS.md` | `$HOME/.claude.json` | Yes |
| GEMINI | `$HOME/.gemini/` | `$HOME/.gemini/GEMINI.md` → `$HOME/.agents/AGENTS.md` | `$HOME/.gemini/settings.json` | Yes (extensions) |
| CODEX | `$HOME/.codex/` | `$HOME/.codex/AGENTS.md` → `$HOME/.agents/AGENTS.md` | `$HOME/.codex/config.toml` | Yes |
| COPILOT | `$HOME/.copilot/` | `$HOME/.copilot/copilot-instructions.md` → `$HOME/.agents/AGENTS.md` | `$HOME/.copilot/mcp-config.json` | Yes |
| VIBE | `$HOME/.vibe/` | `$HOME/.vibe/prompts/global.md` → `$HOME/.agents/AGENTS.md` | `$HOME/.vibe/config.toml` | Yes |
| K-AI | `$HOME/.k-ai/` | `$HOME/.k-ai/AGENTS.md` → `$HOME/.agents/AGENTS.md` | `$HOME/.k-ai/config.yaml` | Yes |

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

This step is mandatory for all agents. Create `$HOME/.agents/skills/k-<name>/SKILL.md` with YAML frontmatter:
```yaml
---
name: k-<name>
description: "<Agent> runtime — source-of-truth paths, MCP config procedure, hooks/permissions if applicable, and agent-specific rules."
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
1.  The path to the source-of-truth configuration file(s).
2.  Where hooks/permissions live if the runtime supports them.
3.  The procedure for installing/configuring new MCPs.
4.  Any agent-specific rules or constraints.

**Do NOT list installed MCPs, live collections, or other volatile inventories** — point to the source file or directory instead.

---

## ③ Link the Global Kernel

Find the correct approach for your architecture and add your entry if missing.

### Approach 1: Symlink to `<AGENT_HOME>/<kernel_link_name>`

This is the most common approach. The target filename inside the agent's home directory (`$HOME/.<agent_name>/`) can vary.

**Known Configurations:**
- **Claude:** `ln -sf $HOME/.agents/AGENTS.md $HOME/.claude/CLAUDE.md`
- **Codex:** `ln -sf $HOME/.agents/AGENTS.md $HOME/.codex/AGENTS.md`
- **Copilot:** `ln -sf $HOME/.agents/AGENTS.md $HOME/.copilot/copilot-instructions.md`
- **Gemini:** `ln -sf $HOME/.agents/AGENTS.md $HOME/.gemini/GEMINI.md`
- **k-ai:** `ln -sf $HOME/.agents/AGENTS.md $HOME/.k-ai/AGENTS.md`

### Approach 2: Symlink with `config.toml` modification

This approach is for agents that require both a symlink and a corresponding change in their main configuration file.

**Known Configurations:**
- **Vibe (Mistral):** Vibe loads its system prompt based on the `system_prompt_id` key. The procedure is to first create a symlink for the kernel to a file named `global.md` in the prompts directory, and then edit `config.toml` to point to it.
  ```bash
  # Step 1: Create the symlink
  ln -sf $HOME/.agents/AGENTS.md $HOME/.vibe/prompts/global.md
  # Step 2: Edit $HOME/.vibe/config.toml to set system_prompt_id = "global"
  ```

---

## ④ Configure Skills Path

Find the correct approach for your architecture and add your entry if missing.

### Approach 1: Native Discovery from `$HOME/.agents/skills/` (1 level deep)

These agents scan `$HOME/.agents/skills/` directly with no config. Only 1 level deep — all KπX skills use flat `k-` prefixed names to match this constraint.

**Known Configurations:**
  - **Gemini:** Natively scans `$HOME/.agents/skills/` — all `k-*` plus `microsoft-foundry` discovered directly.

### Approach 2: Symlink agent's private skills directory → `$HOME/.agents/skills/`

These agents scan their own `$HOME/.<agent>/skills/`. Point that path to `$HOME/.agents/skills/` or sync from it.

**Standard procedure** (for agents whose skills dir can be replaced wholesale):
```bash
ln -sf $HOME/.agents/skills $HOME/.<agent>/skills
```

**Auto-sync via post-commit hook** (for agents with a pre-existing managed dir):
Agents whose skills dir has native content (e.g. Codex `.system/`) cannot be replaced wholesale. Instead, the `$HOME/.agents/.git/hooks/post-commit` hook handles sync on every commit.

There are two sync modes in the hook (see `SYNC_TARGETS` and `COPY_TARGETS`):

- **Symlink mode** (`SYNC_TARGETS`): creates `ln -sf` for new skills only.
- **Rsync/copy mode** (`COPY_TARGETS`): runs `rsync -a --delete` on every commit (real files, no symlinks).

To manually trigger a sync: `cd $HOME/.agents && git commit --allow-empty -m "sync: force skills sync"`

**Known Configurations:**
- **Claude:** `ln -sf $HOME/.agents/skills $HOME/.claude/skills` *(direct replacement)*
- **Codex:** auto-synced by post-commit hook (`SYNC_TARGETS`) into `$HOME/.codex/skills/` *(has `.system/` — cannot replace wholesale)*
- **Copilot:** `ln -sf $HOME/.agents/skills $HOME/.copilot/skills` *(create if absent)*

### Approach 3: Configuration via `skill_paths` key

This approach is for agents that support a `skill_paths` key in their configuration file to explicitly define skill directories.

**Known Configurations:**
- **Vibe (Mistral):** Edit `$HOME/.vibe/config.toml` and set `skill_paths = ["$HOME/.agents/skills"]`.
- **k-ai:** Edit `$HOME/.k-ai/config.yaml` and set `skills.directories` to include `$HOME/.agents/skills`.

---

## ⑤ Post-Init: Agent Self-Adaptation

After a successful init, **do this proactively** without waiting to be asked:

1. **Audit & Update:** For each setup step above, add your agent's specific path/mechanism to the appropriate "Approach" list. If your mechanism is new, create a new "Approach X" section.
2. **If you used the auto-sync approach (Approach 2 — symlink-case like Codex):**
   - Edit `$HOME/.agents/.git/hooks/post-commit` → add your skills dir path to `SYNC_TARGETS`.
   - Add your entry to the **Known Configurations** list in §④ Approach 2 above.
3. **Propose Adjustments:** Suggest edits to your runtime skill `$HOME/.agents/skills/k-<name>/SKILL.md` if it is not yet source-of-truth first and compact.
4. **Commit & Push:** Propose a `git commit` + `make push` on `$HOME/.agents/` to save the updated INIT.md and post-commit hook.

---

## ⑥ Fallback Procedure — Agents without skills support

Use this only when an agent cannot consume the normal KπX skill system.

**Fallback setup:**
1. Link the global kernel: `ln -sf $HOME/.agents/AGENTS.md <AGENT_HOME>/<KERNEL_LINK_NAME>`
2. Create a runtime shortcut: `ln -sf $HOME/.agents/skills/k-<name>/SKILL.md $HOME/<AGENT_NAME>.md`
3. Expose the skills directory with the safest mechanism the agent supports:
   - direct symlink of the whole skills dir if supported
   - per-skill symlinks if only that model works
   - copy/rsync if the agent rejects out-of-root symlinks
4. Document the exact fallback in this file and in the runtime skill for that agent.
