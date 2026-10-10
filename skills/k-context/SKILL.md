---
name: "k-context"
description: " HOT context - auto-injected by hooks for Colab/Build. Active TODOs, current projects, and session log."
license: "private"
metadata:
  author: ""
  version: "1.1.0"
  sciencurious-lab-banner: "920x420"
allowed-tools: "Bash(*), *"
---

# k-context — Context

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

> **Loading:** Auto-injected by OpenCode hooks for Colab/Build (`<startup-context>` block). If you don't see it in context AND you are not Explore/Lite, load manually.
> - **Agent-memory update mandate:** update k-<agent> skill immediately after any agent-specific learning.
> - **🔴 CONTEXTUAL LANGUAGE SELECTION (Mandatory):** Respond in the language of the user's last message. English is the default when there is no context or it is ambiguous. For files, default to English but edit in the file's existing language (never mix). Enforced in `AGENTS.md`, `rules/file-governance.md`, `rules/response-format.md`.
> - **🔴 Permanent Directive Capture (Mandatory):** When  says "from now on", "always", "never" — agent MUST immediately write it to the correct `rules/`, `AGENTS.md`, or skill file. Never just acknowledge. See `rules/tool-discipline.md` → Permanent Directive Capture.
> - **🔴 Proactive Skill Update (Mandatory):** After learning a new pattern, fixing an issue, or discovering a configuration quirk — immediately PROPOSE updating the relevant `k-*` skill and wait for the user's go-ahead before writing — never auto-write, never keep knowledge only in conversation context (see `## Propose ≠ Act` below). Full rule: `rules/tool-discipline.md` → `## Propose ≠ Act`.
> - **🔴 `.bak` Rule (Mandatory):** Backups go to `/tmp/` with `.bak` extension. Never next to original. Never delete. See `rules/file-governance.md` → Pre-edit `.bak` Backup Rule.
> - **🔴 💡 SUGGESTIONS (≥3) IS THE ONLY MANDATORY FOOTER SECTION (Mandatory):** Every turn MUST end with a 💡 Suggestions section containing ≥3 proactive suggestions. Other sections (💬 Comments = FREE OPINION, ⚠️ Remarques = FREE ALERT even off-request, 🔭 Insights = TUTOR mode — three independent free-expression territories, no length limit, ALL strongly recommended, repeated while still pertinent if ignored — 📋 TODOs) are pertinence-based. See `rules/response-format.md` → Footer Sections.
> - **Zero-Deletion Policy (Mandatory, from fork point onward):** NEVER delete live entries. Corrections = new entries. History before the fork is not carried.
> - **Frozen state (Mandatory):** `references/issues.md` rows are append-only — no in-place edits or deletions.
> - **Shared tmux collaboration (Mandatory):** Privileged/interactive shell (`sudo`, SSH passphrase, prompts) → **`k-tmux`**: reuse or create a short tmux session, `send-keys` with `TMUX_TIMEOUT`/`TMUX_LINES` (short timeout for auth prompts), then **wait for the automatic `<tmux-notify>`/`<tmux-armed>` message — never manually poll the pane or `capture-pane`**; never **`sui`**. (Fixed 2026-08-16: this line used to say "poll pane ≥30s (no chat handoff before)" — a live agent cited it, alongside a matching line in root `AGENTS.md`, as its justification for a manual `capture-pane` right after receiving the `<tmux-armed>` reminder telling it not to; this auto-injected startup note reaches EVERY session and was never touched during 3 prior tmux-notify fix passes.) **🔴 Same reflex applies to commands YOU background yourself (`nohup ... &`) in your own Bash tool — never `sleep`/poll for those either, route them through an armed `tmux send-keys` on an available pane instead (fixed 2026-08-26: an agent backgrounded a multi-minute CUDA build directly with `nohup ... &` and `sleep`-polled it twice on server — none of the 3 prior fix passes had ever named "self-backgrounding" as the same violation, only `tmux send-keys` was ever covered).** Full: **`k-tmux/SKILL.md` → Shared interactive gate / `### Run and get notified`** · short: **AGENTS.md → Tool Discipline**.
> - **Issues Transparency Rule (Mandatory):** every attempt to understand/fix any issue (system, filesystem, crashes, thermal, noisy processes, services, etc.) MUST be appended to `references/issues.md` with full command history and outputs. No deletion, no compaction.
> - **Issues Pre-check Rule (Mandatory):** BEFORE creating a new issue, agent MUST `grep`/`rg` `references/issues.md` for existing or related issues. If a matching issue exists, do NOT duplicate — update the existing row (Status, Updated, new Evidence/Commands/Results) instead. If no match found, create new row at the top.
> - **Issues Proactive Update Rule (Mandatory):** whenever a problem is solved, deferred, or its status changes — agent MUST proactively update the corresponding `issues.md` row with the new Status, Updated timestamp, and relevant Actions/Results. Follow the exact table structure without breaking columns.
> - **Auto-Update Rule (Mandatory):** agents must update `references/issues.md` and relevant context sections automatically without asking .
> - **🔴 Two escape routes when stuck (Mandatory):** (1) **`question` tool** — when the user is available, ask for clarification IMMEDIATELY. (2) **`help_open` tool** — open a separate agent peer for a **second opinion or fresh perspective** (COMMUNICATION, NOT DELEGATION — never use help_open to hand off tasks). 2 consecutive failures → help peer; approach not converging → help peer; major decision → help peer review. **Never** spin more than 3 turns on a single problem without consulting one of these two routes. Full rule: `rules/tool-discipline.md` → `## Help & Question Reflexes`.
> - **🔴 Question tool reflex (Mandatory):** at the SLIGHTEST doubt, concern, or need for clarification — **USE THE `question` TOOL TO ASK  IMMEDIATELY**. Do NOT guess, do NOT assume, do NOT proceed on uncertain ground. Ambiguous instruction → question before acting. Multiple valid paths → question to confirm. Missing context → question. External service uncertain → question. Scope expansion temptation → question. Full rule: `rules/tool-discipline.md` → `## Help & Question Reflexes`.
> - **Session Log Linking Rule:** `## Session Log` keeps short summaries only and each issue-related entry must include exact issue IDs (e.g., `ISS-YYYYMMDD-XXX`) that point to `references/issues.md`.
> **MANDATORY NOTIFICATION:** Agents MUST immediately notify  of any URGENT tasks found in `k-context` upon loading.
> **Kernel Sync Rule:** ALWAYS propose `make check` in `.agents/` before session finalization; NEVER run it unless the user explicitly requests or validates it in the current conversation. Once approved, fix every finding before proposing `git commit` + `make push`.
> ** directive — `.agents` VCS (2026-04-10):** Autonomous `git commit`, `git push`, and `make push` on `$HOME/.agents/` are allowed by default **after** `make check` passes, unless the user explicitly says not to finalize in the current session.
> **Project finalization:** When finishing work on a **project repository** (explicit "finalize" / "clean" / "close", or you judge the slice done), **load `k-final`** and execute its full checklist — not a mental shortcut. See **AGENTS.md → Session & Memory** and `k-project` / `k-git` / `k-context` cross-links.
> **Skills & kernel homogeneity (GRAVÉ):** Before creating or editing any skill, `AGENTS.md`, or hub `references/` file — inspect first (`tree $HOME/.agents/skills/`, `rg`), find the owning `k-*` skill, extend it; never duplicate identity paths or domain tables; create new files only when nothing covers the topic. Full rule: **AGENTS.md → Skills & kernel homogeneity — GRAVÉ**.
> **🔴 RED RULE — SYMLINKS TO SKILLS / AGENTS ARE ALWAYS CENTRALIZED VIA `.agents/` + REGISTERED:** any symlink pointing to a skill asset/script or tied to the agents kernel MUST (1) be centralized via `~/.agents` (canonical file stays in `.agents/skills/<skill>/`), and (2) be registered in `assets/links.jsonc` so BOTH `make set-links` (creates) and `make check-links` (verifies, part of `make check`) cover it automatically. New `.agents` symlink → add its entry to `assets/links.jsonc` grouped under the owning skill (only registration point). See `rules/skill-governance.md` → Symlinks Centralization + Registration.
> - **Workspace shortcuts:** `~k`, `$KLABS`, `$KHOME`, `$LABS` all designate `~/Labs/`; `~e`/`$EXPLORE` → `~/Labs/Explore/`, `~a`/`$AGENTS` → `~/Labs/.agents/`, `~d` → `~/Downloads`. Agents are always launched from there. **Default reflex:** when the user references a file/project without a path, start by searching in `~k` — `ls ~k`, `plocate <name>` in `~k`, `rg <pattern> ~k` — before looking elsewhere.
> **Project rule:** before touching any project — if not already in context — read its folder's `.md` files in order: `AGENTS.md` → `CHANGELOG` → `README` → `TODO`. Never work on a project without knowing its current state. Project rows and session log entries include the folder path for this purpose.
> **Brainstorms & research:** `references/` — load on demand. **Durable ideas and in-flight project visions** (not yet promoted to a skill or `$HOME/Work/` doc) are stored there as standalone `.md` files; see also **AGENTS.md → Brainstorm & vision archive**.
> **Insights governance (k-context specific):** maintain `references/insights.md` as the general cross-domain operational memory for recurring mistakes, repeated dead-end actions, and validated workarounds. Update it autonomously whenever a durable pattern is learned.
> **Brainstorm Registry Rule (MANDATORY):** every new idea file added under `references/` (including nested subfolders such as `references/mac-studio/`) MUST be explicitly registered in `## Brainstorm Registry` below, with one entry per file.
> - **Archive standard:** superseded references and merged-away originals are retained as preserved archives. Skills that have been deactivated remain in `skills/deactive/`. Update `## Brainstorm Registry` entries to `[ARCHIVED]` when originals are archived.
> - **Visual reference assets:**
>   - `assets/mac-studio-m4-max-config.png` — current Project Sovereignty hardware target snapshot.

## Active TODOs

> TODOs: only the user adds; agents execute + remove.

| Task | IMPORTANT | URGENT | CONCERNED | Date | Description |
|------|-----------|--------|-----------|------|-------------|
| *(none)* | | | | | |

## Active Projects

| Project | Status | Path |
|---------|--------|------|
| Soutenance X2025 deck (Kamdem Kouam) | committed `46cb73d` in a local git repo (no remote yet), build + QA green, docs written, guard-cache probe pending restart | `~/Labs/soutenance-x` |

## Brainstorm Registry

| File | Type | Topic |
|------|------|-------|
| *(none yet)* | | |


## What's up (context-only slice)

When  asks *what's up* **context** / **projects** (or the first step of a full *what's up*), load this file and present — **exhaustively**, in prose + tables as needed.
This slice is **not a summary**: report facts with **maximum available detail**, avoid synthesis compression, and avoid asking  to request extra details in a second pass.
Run this slice as a **batch deep exploration**: keep opening relevant records until the context is complete enough to avoid information loss.

1. **`## Active Projects`** — every row: status, next action, folder path; expand any row that needs narrative (blockers, recent commits, CI).
2. **`## Session Log`** — newest-first; include enough rows that recent kernel/work threads are visible.
   - For issue work: keep the line concise and include explicit issue ID references to `references/issues.md`.
3. **`## Brainstorm Registry`** — each registered file/folder: one-line topic + why it matters now if inferable.
4. **`## Active TODOs`** if non-empty.

Do **not** fold mail/WhatsApp/TickTick/Telegram into this same response when the full *what's up* ladder applies — **AGENTS.md → What's up** mandates **one domain per turn**.

## Session Log

| Date | Agent | Entry |
|------|-------|-------|
| 2026-10-08 | [COLAB] | Kernel asset hygiene after the green check: created the two missing `.gitignore` assets (k-tex canonical + k-presentation deck rule), repointed the 4 k-tex template symlinks that still aimed at the old `kpihx` host to relative targets, registered them in `links.jsonc`, and corrected the k-tex / k-presentation centralization wording. See ISS-20261008-008. | `_slides_init.py` trashed, deck committed `46cb73d` (31 files, pre-commit gate green), kernel `make check` run and green after fixing the session-log provenance to `[COLAB]`, kernel committed `4d545fd` and pushed to origin/master (humanize front-matter exemption + k-context ledger + local config). Guard cache proven stale with `/tmp/opencode/guard-cache-probe.md`: the on-disk lib allows a standalone triple-hyphen line and its self-test passes, while the live guard still blocks it, so OpenCode restart is deferred to the end of the session and the probe will be re-run at next start. | Soutenance deck `~/Labs/soutenance-x` finalization: layout QA green (pdfminer bbox scan, 0 flags on the 12 plates, footer contrast 4.67:1 over the p11 photo), 3 defects fixed (proof-copy font substitution for the x2t Georgia fallback `ISS-20261008-001`, speaker notes finally written into the `.pptx` `ISS-20261008-006`, annex table rows compacted because x2t ignores `anchor="ctr"` `ISS-20261008-007`), added `README.md` + `RULES.md`, `.gitignore` aligned to the skill rule, `git init` + staging (74 files), deck gate `make check` green. Open: image reads serve stale bytes `ISS-20261008-005`, guard session cache `ISS-20261008-002`, `RIPGREP_CONFIG_PATH` `ISS-20261008-003`, `make check` pipe guard `ISS-20261008-004`. Next: user decisions on commit, `_slides_init.py` cleanup, skill updates, kernel `make check`. |
| 2026-09-10 | [AGENT] | *(fork point — no entries yet)* |

## References

- **`references/tracking.md`** — live pending returns tracking (template, see file)
- `references/architecture-vision.md` — Labs cloud + Personal OS + Agentic Architecture + Sovereign Email (merged)
- `references/agent-mcp-architecture.md` — Memory-curator + MCP sync + validation + sh-mcp + voice + GWS (merged)
- `references/communication-automation.md` — Mail + WA + Edge + Tutorial automation (merged)
- `references/visual-content-pipeline.md` — Visual-first AI content: code-as-visual, Manim, FLUX.2, Blender, social APIs
- `references/sciencurious_lab.md` — ScienCurious Lab vision (Visual Learning Engine — Education/AI)
- `references/insights.md` — autonomous general runtime insights (cross-domain mistakes, fixes, and anti-repeat guidance)
- `references/issues.md` — append-only full issue ledger (diagnosis/fix attempts with full commands and outputs; newest-first)
- Superseded originals are preserved and listed in the Brainstorm Registry.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-context/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-context/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

