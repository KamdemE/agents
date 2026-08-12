# Tool Discipline

> Cross-cutting operational rules for ALL tool usage.

## tmux sudo Gate (MANDATORY)
- **Never** run raw `sudo` in agent tool shells. Use the equipment's dedicated tmux session.
- The ops pane is always `<session>:agents.2` where `<session>` is the current equipment
  (auto-detected via Tailscale: ubuntu, pve, pve-debian, blglaptop139, deep-pc6, s25...).
- Execution cycle:
  1. Identify session: detect current equipment via Tailscale (e.g. `ubuntu`, `pve`).
  2. Confirm session exists: `tmux ls | grep <session>`
  3. Send to ops pane: `tmux send-keys -t <session>:agents.2 '<cmd>' Enter`
  4. Poll every 3–5s: `tmux capture-pane -t <session>:agents.2 -p | tail -10`
  5. Shell prompt = done. Password prompt = keep polling (≥15s before chat handoff)
  6. Wait for completion — keep polling until shell prompt
  7. Never kill pane `<session>:agents.2` (permanent for the session)
- **Never** create temp windows/panes for sudo
- **Never** run `sudo` in agent tool shells
- **Never** stop polling before 15s for password
- Full protocol: **`k-tmux/SKILL.md` → Shared interactive gate**

## Browser (Edge Agent)
- Edge in tmux `default`, window `browser` (CDP 9222, profile `~/.config/kpihx-edge-automation`)
- Run `edge-agent-status` before CDP attach

## File Operations (GRAVÉ)
- **NEVER, EVER use shell redirection (`cat ... > ...`, `echo >`, `sed`, `awk`) to edit or create files.** 
- **Always use the native `Edit` tool** (or `Write` tool for new files) provided by your environment. This is an absolute rule.
- Read before Edit — you must use the `Read` tool to read the file contents first to ensure you patch it correctly.
- No shell file ops (`cat`/`awk`/`echo >` for file creation/edits).
- No real IPs, tokens, full legal names; use placeholders.

## Shell Security
- API keys/TOKENS: `env | grep -E "API\|TOKEN" | cut -d= -f1` — NEVER output values

## Zero-Deletion Policy (MANDATORY)
- NEVER delete logs/historical entries from `k-context/SKILL.md` or any skill
- If a section reaches its limit → rotate to dedicated archive BEFORE compaction
- Archive rows are append-only forever — never modify archive lines

## Permanent Directive Capture (MANDATORY)
When KπX gives a permanent directive ("from now on", "always", "never again", "tu dois tjrs", "you must always", etc.):
1. **Identify the correct location** in `~/.agents/` — `rules/*.md`, `AGENTS.md`, or the relevant `k-*` skill.
2. **Write it immediately** — persist the rule before finishing your response.
3. **Never just acknowledge** — "ok I'll remember" without writing = violation.
4. **Uncertain? Ask.** Propose the location, wait for confirmation.

## Proactive Skill Update (MANDATORY)
After discovering a new pattern, fixing a bug, learning a configuration quirk, or gaining any durable knowledge:
1. **Identify the owning skill** — find the relevant `k-*` skill in `~/.agents/skills/`.
2. **Update it immediately** — extend the SKILL.md with the new knowledge, pattern, or fix.
3. **Never keep knowledge only in conversation context** — if it's not in a skill, it doesn't exist for future sessions.
4. **Bump version + changelog** — every skill edit must increment version and add a changelog entry.
5. **Cross-reference** — if the pattern affects multiple skills, add pointers between them.

## Context Save Proposal Gate
Signal when new context should be saved, then WAIT for `approve`/`reject`/`adjust`.

## Sub-Agent Economy (PERMANENT DIRECTIVE — KπX, 2026-08-12)
- **Do NOT delegate to sub-agents unless strictly necessary.** KπX has no time to re-read
  sub-agent output, and delegation burns tokens.
- Acceptable uses ONLY:
  1. **Long tasks** — refactors, long code adjustments, `.agents` kernel changes.
  2. **Critical parallel exploration** — launch agents in PARALLEL instead of linearly,
     especially when they cannot realistically step on each other's work.
- Default behavior: execute the work yourself, directly, with your own tools.
- Before delegating, ask: "is this long enough / parallel-safe enough to justify the cost?"
  If the task can be done in a few direct edits, do it yourself.

## Solo End-to-End Execution (PERMANENT DIRECTIVE — KπX, 2026-08-12)
- Complete every explicitly requested task yourself: inspect, implement, execute, verify, and clean
  up. Never hand validation or testing back to KπX.
- Before declaring a task complete, run every applicable real check, lint, type-check, test, smoke
  execution, and—when the feature writes to a real service—a real end-to-end lifecycle.
- HITL is the sole interaction exception: launch the real approved flow in tmux, keep polling its
  pane, then resume the lifecycle and verify the persisted result yourself. Do not substitute a
  request for KπX to test it.
- A stale installed binary is a failed deployment: after a versioned CLI change, install/link it and
  verify the globally invoked executable reports and exercises the new version.
- Never fabricate or programmatically submit a HITL approval for a real external write. When KπX
  explicitly approves the displayed review, complete the remote read-back and cleanup yourself;
  otherwise keep the flow fail-closed and verify that no write occurred.
- Fix every task-related failure discovered during execution at its root cause, including
  pre-existing hygiene/check failures. Keep iterating until the objective is demonstrably complete.
- **Standing operator authority:** carry an explicitly requested objective through its complete
  lifecycle without asking KπX to perform implementation, testing, or cleanup. For an explicitly
  authorized external test write, execute the write, read it back, and remove the test artifact.
  This authority never permits silently broadening the requested scope or exposing secrets.

## Troubleshooting
- Unknown error → check if k-context is already in context (auto-injected for Colab/Build); if absent, load `skills/k-context/SKILL.md`
- New tool/skill detected → propose updating the corresponding `k-*` skill
