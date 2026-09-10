# Tool Discipline

> Cross-cutting operational rules for ALL tool usage.

## Tmux Stateful Command Execution (MANDATORY — applies to EVERY `tmux send-keys`, not sudo only)
- **Never** manually poll or loop `capture-pane` to check if a command finished — for ANY pane, ANY command, not just sudo. The shell's prompt hook (`precmd` in zsh / `PROMPT_COMMAND` in bash, in `.kshrc`) writes a return-to-prompt signal to `/tmp/tmux-pane-done.log` automatically; the `tmux-notify` OpenCode plugin (`k-opencode` `scripts/plugins/tmux-notify.js`) delivers it back into the conversation as a synthetic `<tmux-notify>` message. This is a **reflex**: you never "know" a command finished by looking — the system tells you.
- 🔴 **ANY long-running or blocking command — not just sudo/auth prompts — MUST be routed through `tmux send-keys` on an available pane, ARMED with `TMUX_TIMEOUT`/`TMUX_LINES`. NEVER background it directly in your own Bash tool (`nohup ... &`, `... &`) and then `sleep`/poll for it yourself.** Backgrounding in your own shell produces NO `<tmux-notify>` — there is nothing to arm — so the only way you'd "know" it finished is by manually sleeping/polling, which is the exact anti-pattern this whole section exists to eliminate. If no pane is free, create one (`tmux new-window`/`split-window`) — never fall back to `sleep`. (Incident 2026-08-26, server,  reaction: "connard ne t'es il pas dit de ne jmais faire sleep ?" — an agent launched a multi-minute `cmake --build` CUDA compile via `nohup cmake ... &` directly in its own Bash tool, then ran `sleep 60`/`sleep 90` twice in a row to poll it, because the previous fixes in this file only ever covered `tmux send-keys` calls and never explicitly named "backgrounding directly in the agent's own shell" as the same violation. Anti-repeat: before backgrounding ANY command that will take more than a few seconds, ask "should this be a `tmux send-keys` instead?" — the answer is almost always yes.)
- 🔴 **TECHNICALLY ENFORCED (2026-08-29, ):** the rule above was PROSE-ONLY for over 3 days across 5 documented incidents — nothing actually stopped a raw `sleep`/`wait`/`timeout` from running. `k-opencode` `scripts/plugins/hooks/raw-exec-guard.js` now `throw`s (blocks) any bash command containing bare `sleep <n>`/`wait`/`timeout <n>` UNLESS the command is already a compliant `tmux send-keys -t <target> ...` call (the quoted payload runs IN the pane, never in your own shell — explicitly exempt). Scope deliberately limited to this static, pre-execution check — a 3rd idea (detect a command running >30s and kill it) was proposed and REJECTED by the user as out of scope, and is not achievable anyway with the current plugin API (no PID access to the real subprocess).
- **Always** prepend these env vars to ANY `tmux send-keys` you expect to take real time:
  - `TMUX_TIMEOUT=<seconds>` (SECONDS — NOT milliseconds. Default `30`.) — if the pane hasn't returned to its prompt after this many seconds, you get ONE "still running" notification with a fresh capture; the real completion notification still arrives automatically afterward (registry stays armed — never re-send the command).
  - `TMUX_LINES=<n>` (alias `TMUX_MAX_LINES=<n>`, default `50`) — how many trailing lines of pane output are included in EVERY notification (the label always states the exact count actually shown, e.g. `Last 50 output lines:`).
  - Example (long build/deploy): `TMUX_TIMEOUT=300 TMUX_LINES=50 tmux send-keys -t <session>:agents.2 'make build' Enter`
  - Example (possible sudo/passphrase prompt — short timeout to catch it fast): `TMUX_TIMEOUT=20 TMUX_LINES=15 tmux send-keys -t <session>:agents.2 'sudo apt update' Enter`
- **Never send-keys into a pane that's already busy running a tracked command** — prefer a DEDICATED, known-empty pane per task (e.g. `agents.N` per your own agent slot) rather than reusing a pane you're unsure about. If you try anyway, `tmux-notify.js` now BLOCKS it (throws) and tells you exactly what to do: use a different empty pane (`tmux list-panes -a` to check), or create a new one if all are occupied (added 2026-08-16,  directive — closes the earlier silent "last-arm-wins" gap where a second arm on the same pane could drop the first session's notification with zero trace).
- Full mechanism: **`k-tmux/SKILL.md` → Stateful Integration** and **`### Run and get notified`**.

## tmux sudo Gate (MANDATORY)
- 🔴 **TECHNICALLY ENFORCED (2026-08-29, ):** this rule was PROSE-ONLY for over 3 days — nothing actually stopped a raw `sudo` from running directly. `k-opencode` `scripts/plugins/hooks/raw-exec-guard.js` now `throw`s (blocks) any bash command containing a bare `sudo` UNLESS it is already a compliant `tmux send-keys -t <target> 'sudo ...' Enter` call (the quoted payload runs IN the pane, never in your own shell — explicitly exempt). Same `throw`-only pattern as `make-check-guard.js` (mutating the command does not propagate — upstream opencode #31680 — so blocking is the only reliable mechanism). If you see this block, route the exact same command through tmux instead of trying to bypass it.
- **Never** run raw `sudo` in agent tool shells. Use the equipment's dedicated tmux session.
- The ops pane is always `<session>:agents.2` where `<session>` is the current equipment
  (auto-detected via Tailscale: ubuntu, pve, pve-debian, laptop, server, s25...).
- Execution cycle (uses `## Tmux Stateful Command Execution` above — sudo adds only the human-approval step):
  1. Identify session: detect current equipment via Tailscale (e.g. `ubuntu`, `pve`).
  2. Confirm session exists: `tmux ls | grep <session>`
  3. Send with a SHORT `TMUX_TIMEOUT` (15-30s) so you catch a password/passphrase/2FA prompt quickly:
     `TMUX_TIMEOUT=20 TMUX_LINES=15 tmux send-keys -t <session>:agents.2 'sudo apt update' Enter`
  4. Right after `send-keys` executes you get a `<tmux-armed>` reminder appended to that SAME tool call's result (not a block — `capture-pane` is NEVER intercepted,  2026-08-16, kept available as a manual fallback if the plugin itself malfunctions). **Prefer waiting for the automatic `<tmux-notify>` message over checking yourself.** If its final capture is empty, incomplete, or cannot establish the command result, immediately run one larger diagnostic capture: `tmux capture-pane -p -t <pane> -S -100`; use its result, never a polling loop. If the notification's captured lines show a password/passphrase/2FA prompt, message  directly (never type the secret yourself, never re-send the command) and wait for  to act in the pane. If they show real work already progressing, no human action is needed — the real completion notification is already armed and will arrive on its own.
  5. Never kill pane `<session>:agents.2` (permanent for the session).
- **Never** create temp windows/panes for sudo
- **Never** run `sudo` in agent tool shells
- Full protocol: **`k-tmux/SKILL.md` → Shared interactive gate**

## Browser (Edge Agent)
- Edge in tmux `default`, window `browser` (CDP 9222, profile `~/.config/kpihx-edge-automation`)
- Run `edge-agent-status` before CDP attach

## File Operations (GRAVÉ)
- **NEVER, EVER use shell redirection (`cat ... > ...`, `echo >`, `sed`, `awk`) to edit or create files.**
- **Always use the native `Edit` tool** for existing files. This is an absolute rule.
- **NEVER rewrite a file wholesale if not explicitly requested.** Prefer precise `Edit` patches on exactly the lines that change. If similar/near-duplicate content already exists elsewhere, `cp` it as a base (shell `cp`, never `sed`) then `Edit` the differences — never regenerate from scratch.
- **`Write` tool reserved for genuinely necessary cases only:** a new file that does not exist anywhere (verify via `plocate`/Glob first — if you suspect something similar might exist, `cp` + `Edit` instead), or an explicitly requested full rewrite/refactor. Not for "I'll just redo this file cleaner."
- **Token efficiency — verbatim copies go through `cp`, never `Write` ( 2026-09-08):** NEVER use the `Write` tool to duplicate an existing file's content (backups, snapshots) — `Write` resends the whole file as tokens while shell `cp` costs one line. (Incident: 374-line `openclaw.json` backup via `Write` ≈ 8 KB of tokens vs `cp openclaw.json /tmp/openclaw-20260908.bak`.) `Write` stays reserved for genuinely new content, `Edit` for modifications, `cp` (+ `chmod 600` when secrets ride along) for copies. Modifying files through shell redirection (`>`, `sed`, `awk`) stays forbidden.
- Read before Edit — you must use the `Read` tool to read the file contents first to ensure you patch it correctly.
- No shell file ops (`cat`/`awk`/`echo >` for file creation/edits).
- No real IPs, tokens, full legal names; use placeholders.

## Shell Security
- API keys/TOKENS: `env | grep -E "API\|TOKEN" | cut -d= -f1` — NEVER output values

## `/dev/null` Redirection Policy (GRAVÉ — 100% Transparency Mantra,  2026-08-24)
- 🔴 **Use `/dev/null` redirections (`> /dev/null`, `2>/dev/null`, `&>/dev/null`) ONLY when STRICTLY necessary.** Every silenced output is information lost — the mantra is **0 Magic · 100% Transparency**.
- ✅ **AUTHORIZED (strictly necessary only):**
  1. **Exit-code probes** where ONLY the status is consumed: `command -v X >/dev/null 2>&1`, `pgrep/has-session/dpkg -s … >/dev/null 2>&1`.
  2. **Physical-noise probes**: connectivity waits (`ping -c1 >/dev/null 2>&1`), health checks (`curl -sf -o /dev/null`).
  3. **Interactive shell rc idioms** (`.kshrc`): a login shell must not spew stderr (fnm env, compdef guards, has-session).
  4. **Idempotent purge/cleanup of possibly-absent state**: `systemctl stop <absent-unit> … || true`.
  5. **Background GUI relaunch**: `nohup <gui-app> >/dev/null 2>&1 &` (app logs to its own files).
- ❌ **FORBIDDEN — transparency violations:**
  1. Diagnostics/check scripts silencing the very signal they exist to show (`dig … 2>/dev/null`, `systemctl status … 2>/dev/null` in a `status` target).
  2. Installers/bootstrap hiding sub-step failures (`bash install.sh 2>/dev/null || true`).
  3. Backup/restore best-effort collection whose failure silently degrades restore fidelity (`dconf dump … 2>/dev/null || true`).
  4. API responses discarded without failure surfacing (`curl api… > /dev/null` WITHOUT `-f` + explicit warning on error).
  5. Deletions with hidden errors + fake success message (`find … -exec rm -rf {} + 2>/dev/null; echo SUCCESS`).
- 📐 **Pattern when discarding stdout is legitimate but failure must surface:** `cmd > /dev/null || echo "⚠️ cmd failed" >&2`.
- Reference audit: 2026-08-24 full sweep of `.agents` (~390 occurrences → ~215 necessary, ~120 gray, ~55 violations fixed/flagged).

## Zero-Deletion Policy (MANDATORY)
- NEVER delete logs/historical entries from `k-context/SKILL.md` or any skill
- If a section reaches its limit → rotate to dedicated archive BEFORE compaction
- Archive rows are append-only forever — never modify archive lines

## Permanent Directive Capture (MANDATORY)
When  gives a permanent directive ("from now on", "always", "never again", "tu dois tjrs", "you must always", etc.):
1. **Identify the correct location** in `~/.agents/` — `rules/*.md`, `AGENTS.md`, or the relevant `k-*` skill.
2. **Write it immediately** — persist the rule before finishing your response.
3. **Never just acknowledge** — "ok I'll remember" without writing = violation.
4. **Uncertain? Ask.** Propose the location, wait for confirmation.

###  code-suppression consent (2026-08-24)
- Never add an in-code lint, type, or static-analysis suppression (for example `# noqa`) without the user's explicit request for that exact suppression.

## Propose ≠ Act (MANDATORY, GRAVÉ —  2026-08-27)
- **Proposing is not acting.** Analysis, research, and "I noticed X" NEVER justify writing, editing, or executing anything  did not explicitly request for the current turn.
- **Never perform an action  did not explicitly say, or that does not directly follow from an action the user explicitly requested.** Discovering something interesting mid-task (doc drift, a nice-to-have fix, a new pattern) is NOT authorization to act on it — surface it in the fitting free-expression section (Comments = opinion, Remarks = encountered problem, Insights = tutor/learning) plus Suggestions, and wait.
- **The only exception: the user explicitly grants "carte blanche"/"feu vert" for the current task** — only then decide and execute without asking further.
- Does **NOT** override the `ABSOLUTE PROACTIVE FIX MANDATE` (root `AGENTS.md`) for problems blocking an **already explicitly requested** task, nor the session-log/issues-log record-keeping duties (`k-context-hygiene.md`) that document work already authorized and completed within the current turn — those stay automatic.
- Applies to every "proactively [do/update/fix] X" mandate below unless stated otherwise: replace silent auto-action with **propose, then wait for go-ahead**.

## Proactive Skill Update (MANDATORY) — propose, never auto-write (see `## Propose ≠ Act` above)
After discovering a new pattern, fixing a bug, learning a configuration quirk, or gaining any durable knowledge:
1. **Identify the owning skill** — find the relevant `k-*` skill in `~/.agents/skills/`.
2. **Propose the update** — present exactly what you'd add/change and WAIT for the user's explicit go-ahead before writing (exception:  granted "carte blanche"/"feu vert" for this task).
3. **Never keep knowledge only in conversation context** — if approved but not yet written, re-flag it before the session ends.
4. **Once approved:** bump version + changelog, cross-reference affected skills.

## Context Save Proposal Gate
Signal when new context should be saved, then WAIT for `approve`/`reject`/`adjust`.

## Sub-Agent Economy (PERMANENT DIRECTIVE — , 2026-08-12)
- **Do NOT delegate to sub-agents unless strictly necessary.**  has no time to re-read
  sub-agent output, and delegation burns tokens.
- Acceptable uses ONLY:
  1. **Long tasks** — refactors, long code adjustments, `.agents` kernel changes.
  2. **Critical parallel exploration** — launch agents in PARALLEL instead of linearly,
     especially when they cannot realistically step on each other's work.
- Default behavior: execute the work yourself, directly, with your own tools.
- Before delegating, ask: "is this long enough / parallel-safe enough to justify the cost?"
  If the task can be done in a few direct edits, do it yourself.

## Solo End-to-End Execution (PERMANENT DIRECTIVE — , 2026-08-12)
- Complete every explicitly requested task yourself: inspect, implement, execute, verify, and clean
  up. Never hand validation or testing back to .
- Before declaring a task complete, run every applicable real check, lint, type-check, test, smoke
  execution, and—when the feature writes to a real service—a real end-to-end lifecycle.
- HITL is the sole interaction exception: launch the real approved flow in tmux using the stateful
  `TMUX_TIMEOUT`/`TMUX_LINES` pattern (see `## Tmux Stateful Command Execution` above) — **do NOT
  manually poll the pane**; wait for the automatic `<tmux-notify>`/`<tmux-armed>` messages, then
  resume the lifecycle and verify the persisted result yourself. Do not substitute a request for
   to test it. (Fixed 2026-08-16: this line used to say "keep polling its pane" — a live agent
  cited it verbatim as its justification for a manual `capture-pane` right after a correct stateful
  `send-keys`, proving this PERMANENT DIRECTIVE, dated 2026-08-12 and never updated during the
  tmux-notify work, was a residual source of the very anti-pattern being eliminated elsewhere in
  this file. See `references` cross-links in `k-tmux`/`k-opencode` insights, same date.)
- A stale installed binary is a failed deployment: after a versioned CLI change, install/link it and
  verify the globally invoked executable reports and exercises the new version.
- Never fabricate or programmatically submit a HITL approval for a real external write. When 
  explicitly approves the displayed review, complete the remote read-back and cleanup yourself;
  otherwise keep the flow fail-closed and verify that no write occurred.
- Fix every task-related failure discovered during execution at its root cause, including
  pre-existing hygiene/check failures. Keep iterating until the objective is demonstrably complete.
- **Standing operator authority:** carry an explicitly requested objective through its complete
  lifecycle without asking  to perform implementation, testing, or cleanup. For an explicitly
  authorized external test write, execute the write, read it back, and remove the test artifact.
  This authority never permits silently broadening the requested scope or exposing secrets.

## Troubleshooting
- Unknown error → check if k-context is already in context (auto-injected for Colab/Build); if absent, load `skills/k-context/SKILL.md`
- New tool/skill detected → propose updating the corresponding `k-*` skill

## curls — Secure API Calls (GRAVÉ —  2026-09-04)

**Agents MUST use `curls --provider <name>` (or `-p <name>`) for any API call that requires authentication.** Never use raw `curl -H "Authorization: $TOKEN"` — shell variable expansion in headers leaks secrets into `ps`, history, and tmux panes.

**Pattern:** `with-env curls --provider <name> URL [curl options...]`

- `with-env` sets secrets as env vars (from Vault)
- `curls` reads the provider manifest (`k-clis/assets/providers.json`) and injects the right headers
- Secret values exist ONLY inside the `with-env` subshell — never in the command line

**Adding a provider:** edit `k-clis/assets/providers.json`.

**The `raw-exec-guard.js` hook blocks** any `curl`/`curls` command with `-H` containing `$VAR` and tells the agent to use `curls --provider <name>` instead.

**Compliant (never blocked):**
- `with-env curls --provider cloudflare https://...`
- `with-env curls -p github https://...`
- `curls https://api.public.com/...` (no auth)

**Blocked (raw-exec-guard throws):**
- `curl -H "Authorization: Bearer $CF_API_TOKEN" https://...`
- `curl -H 'Authorization: Bearer $TOKEN' https://...`

## Help & Question Reflexes

**🔴 Two escape routes when stuck** — the agent has exactly 2 tools to break out of a loop:

**`question` tool reflex (GRAVÉ):** At the **slightest doubt, concern, or need for clarification** — **USE THE `question` TOOL TO ASK  IMMEDIATELY**. Do NOT guess, do NOT assume, do NOT proceed on uncertain ground. Specifically:

- **Ambiguous instruction** → question before acting
- **Multiple valid paths** → question to confirm which one
- **Missing context** (file not found, unclear scope, conflicting info) → question
- **External service uncertain** (API unclear, rate limit hit, auth questionable) → question
- **Scope expansion temptation** ("I noticed X while doing Y") → question before touching X

The question tool is the SOVEREIGN escalation path when the user is available. It is the first reflex — always try `question` first when  is reachable.

**`help_open` tool reflex (GRAVÉ):** When the agent needs a **second opinion, fresh perspective, or architectural review from a SEPARATE agent context** — **OPEN A HELP PEER via `help_open()` IMMEDIATELY**. Do NOT spin alone. Specifically:

- After **2 consecutive failures** on the same subtask → open a help peer before the 3rd attempt
- When the approach **does not converge** (repeated errors, same file edited back and forth) → open a help peer
- Before **committing to a major architectural decision** → open a help peer for a second opinion
- When you believe the task is done but **are not 100% certain** → open a help peer for review
- **Never** spin more than 3 turns on a single problem without consulting a help peer

The help peer is a **separate OpenCode root session** with its own context window, agent, and model. It reads the same codebase but starts from a clean slate — no shared assumptions, no confirmation bias. Use `help_list` to see open peers, `help_read` to inspect their work, `help_close` when done. The help peer gives strategy AND can explore; it is not read-only.

> **🔴 `help_open` = COMMUNICATION, NOT DELEGATION (GRAVÉ —  2026-09-02)**
> `help_open` is a **communication tool** — it opens a dialogue with another agent to get a second opinion, a fresh perspective, or an architectural review. It is **NEVER** a delegation tool. You do NOT use `help_open` to hand off a task to an executor sub-agent with a long prompt and expect it to do the work for you. That is task delegation, not communication.
> - ✅ **CORRECT:** "I'm stuck on X — let me ask a peer for their perspective" → `help_open` with a focused question
> - ✅ **CORRECT:** "I want to validate this architecture before committing" → `help_open` for review
> - ❌ **WRONG:** "Fix this code for me" + handing off the entire task → that's `task` (executor), not `help_open`
> - ❌ **WRONG:** Sending a 500-word prompt to `help_open` expecting it to do all the work → that's delegation, not communication
> **The test:** If your `help_open` prompt could be rewritten as "What do you think about X?" → it's communication. If it could be rewritten as "Do X for me" → it's delegation (use `task` instead).

**Decision flow:**
1.  available? → `question` first
2.  unavailable or question would take too long? → `help_open` with a focused peer for a second opinion
3. Neither available? → proceed with the safest conservative choice and document the uncertainty
