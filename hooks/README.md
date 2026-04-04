# KπX Hooks Map

This directory contains the KπX hook stack:

- `core/` owns the reusable policy and validation logic
- `gemini/`, `claude/`, and `codex/` only bind that core to each runtime's real hook surface

Use this file to answer 2 questions quickly:

1. Which checker exists in `core/` and what does it do concretely?
2. For each agent, where is it actually wired, or why is it not wired?

## Core Checkers

| Checker | Role | Example the agent sees |
|------|------|----------------|
| `context_injector.py` | Inject startup context from the configured startup skills list | `Session date: 2026-04-03 (Friday)` + `k-context` + `k-workspace` |
| `prompt_injector.py` | Inject lightweight per-turn runtime context | `<dynamic-context> ... Current directory: /home/kpihx ... </dynamic-context>` |
| `skill_watcher.py` | Inject a compact reminder that points back to `AGENTS.md` | `AGENTS CHECK:` then 3 short lines pointing to `$HOME/.agents/AGENTS.md` |
| `path_guard.py` | Reject literal home paths or bare `~` in `.agents/` file edits | `Literal home-directory path or bare ~ detected in .agents content...` |
| `skill_edit_guard.py` | Reject incomplete edits to KπX-owned `SKILL.md` files | `edited SKILL.md without bumping metadata.version` |
| `response_validator.py` | Reject malformed final answers against the AGENTS response contract | `Missing mandatory TODOs table...` |
| `session_guard.py` | Surface delayed finalization once `.agents/` stayed dirty past the grace window | `SESSION FINALIZATION REQUIRED` |
| `skill_structure_guard.py` | Validate `SKILL.md` structure for KπX-owned skills | `missing ## Changelog footer table` |
| `skill_content_guard.py` | Validate that bundled files are surfaced in the matching skill | `bundled file scripts/foo.py is not mentioned in SKILL.md` |
| `audit.py` | Recheck the whole hook/skill/runtime wiring | `ALL_OK` |

## Concrete Examples

### Startup Context

```text
Session date: 2026-04-03 (Friday)

MANDATORY STARTUP CONTEXT:

--- SKILL.md ---
[k-context]

--- SKILL.md ---
[k-workspace]
```

### Dynamic Context

```xml
<dynamic-context>
Date: 2026-04-03 (Friday)
Time: 22:23
Prompt: ─[kpihx@KpihX-Ubuntu]
Current directory: /home/kpihx
</dynamic-context>
```

### Governance Reminder

```xml
<agent-governance-reminder>
AGENTS CHECK:
- If $HOME/.agents/AGENTS.md is not already in working context, read it now.
- Use $HOME/.agents/AGENTS.md as the single source of truth for response rules and .agents maintenance.
- If your work changes $HOME/.agents/, update $HOME/.agents/skills/k-context/SKILL.md and any affected k-* skills per AGENTS.md.
</agent-governance-reminder>
```

### Path Guard

```text
CRITICAL: Tool `Edit` cannot write $HOME/.agents/skills/k-hook/SKILL.md until the skill update is complete.
- Literal home-directory path or bare `~` detected in `.agents/` content. Use `$HOME` and `$USER` per $HOME/.agents/AGENTS.md → `### Style`.
```

### Skill Edit Guard

```text
CRITICAL: Tool `Write` cannot write $HOME/.agents/skills/k-context/SKILL.md until the skill update is complete.
- $HOME/.agents/skills/k-context/SKILL.md: edited `SKILL.md` without bumping `metadata.version`
- $HOME/.agents/skills/k-context/SKILL.md: edited `SKILL.md` without updating `## Changelog`
- $HOME/.agents/skills/k-context/SKILL.md: edited `k-context` without updating `## Session Log`

Notes:
- Also review `## Active Projects` if this work changed project scope, status, or introduced a new project.
```

### Response Validator

```text
CRITICAL: Your last response violates AGENTS.md rules:
- Missing mandatory TODOs table [Task|Tache | Urgent | Important] inside the `TODOs` section.
- Found only 2 proactive suggestion(s) inside the suggestions section. At least 3 required.
```

### Session Guard

```text
SESSION FINALIZATION REQUIRED

$HOME/.agents/ is still dirty and the oldest pending change is older than 10 minute(s).

Changed skill files:
  $HOME/.agents/skills/k-context/SKILL.md

Next:
- Re-read $HOME/.agents/AGENTS.md and finalize the pending .agents changes per its rules.
- Update $HOME/.agents/skills/k-context/SKILL.md for this work.
- Update any touched k-* skills and other affected .md files.
- Commit and run `make -C $HOME/.agents push`.
```

## Runtime Map

| Checker | Gemini | Claude | Codex |
|------|--------|--------|-------|
| `context_injector.py` | `SessionStart` | `SessionStart` | `SessionStart` |
| `prompt_injector.py` | `BeforeAgent` | `UserPromptSubmit` | `UserPromptSubmit` |
| `skill_watcher.py` | `BeforeAgent` | `UserPromptSubmit` | `UserPromptSubmit` |
| `path_guard.py` | `BeforeTool` for `write_file` and `replace` | `PreToolUse` for `Write` and `Edit` | not wired — current Codex hook surface in this setup does not expose structured file-edit events here |
| `skill_edit_guard.py` (structure + content) | `BeforeTool` for `write_file` and `replace` | `PreToolUse` for `Write` and `Edit` — structure/content blocking only | not wired — same Codex limitation as `path_guard.py` |
| `skill_edit_guard.py` (header/footer) | `BeforeTool` for `write_file` and `replace` — full blocking | `PostToolUse` for `Edit` — advisory only; agent sees warning, session_guard enforces at Stop | not wired |
| `response_validator.py` | `AfterAgent` | `Stop` | `Stop` |
| `session_guard.py` | `SessionEnd` advisory | `Stop` block + `SessionEnd` advisory | `Stop` block |

## Why Some Checkers Are Missing

### Codex Write Guards

Current deployed Codex setup does not expose a usable structured file-edit hook surface for this guard layer.

Practical consequence:

- `path_guard.py` and `skill_edit_guard.py` are fully active on Gemini and Claude
- they are intentionally not wired on Codex instead of pretending to protect `Bash`
- `hooks/codex/pre_tool_use.py` is kept only as a no-op compatibility shim for already-running Codex sessions or stale copied hook configs

### Gemini — No AfterTool Event

Gemini CLI does not publish an `AfterTool` hook event. The registered surface is:
`SessionStart`, `BeforeAgent`, `AfterAgent`, `BeforeTool`, `SessionEnd` — no post-write event.

Practical consequence:

- The `skill_edit_guard.py` header/footer check **cannot be moved to a PostToolUse-style advisory** on Gemini
- Full blocking on `BeforeTool` is therefore permanent for Gemini — not a policy choice but a platform constraint
- Do not add an `after_tool.py` for Gemini: the event does not exist

## At What Moment The Agent Sees Each Thing

| Moment | Gemini | Claude | Codex |
|------|--------|--------|-------|
| Session starts | startup context | startup context | startup context |
| User sends prompt | dynamic context + AGENTS reminder before planning | dynamic context + AGENTS reminder before processing | dynamic context + AGENTS reminder before model call |
| Agent tries to edit `.agents/` | hard deny if path/skill edit is invalid | hard deny if path/skill edit is invalid | nothing in practice with current `Bash`-only matcher |
| Agent finishes answer | answer validated | answer validated | answer validated |
| Session/turn ends with stale `.agents/` dirty state | advisory finalization reminder | block on `Stop`, advisory on `SessionEnd` | block on `Stop` |

## Recheck

- run `python3 $HOME/.agents/hooks/audit.py`
- read `$HOME/.agents/AGENTS.md` for the normative rule text
- read `$HOME/.agents/skills/k-hook/SKILL.md` for the architectural source-of-truth map
