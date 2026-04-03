---
name: k-ai
description: k-ai runtime memory, preferences, and operating notes.
license: private
metadata:
  author: KpihX
  version: "1.3.0"
  scope: runtime-memory
  target-agent: k-ai
allowed-tools: Read, Edit, Write
---

# k-ai

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> THE AGENT MUST PROACTIVELY UPDATE THIS MEMORY AS SOON AS IT FINDS SOMETHING KEY TO REMEMBER, WITHOUT ASKING FOR APPROVAL.

## Project References

| Resource | Path / URL |
|----------|------------|
| **Source code** | `$HOME/Work/AI/k_ai/` |
| **Session history** | `$HOME/.k-ai/sessions/` |
| **Session index** | `$HOME/.k-ai/sessions/index.json` |
| **Runtime shell history** | `$HOME/.k-ai/runtime/shell_history` |
| **GitHub** | https://github.com/KpihX/k-ai |
| **GitLab** | https://gitlab.com/kpihx/k-ai |

> When investigating a bug or unexpected behavior, go to `$HOME/Work/AI/k_ai/` first — that is the canonical source of truth for the runtime code.

## Edition Rules

- **Tools:** Use `edit_file` (filesystem MCP) for all updates. Never use `write_file` to overwrite this file unless requested.
- **Language:** English ONLY.
- **Atomicity:** Keep entries short and numbered (e.g., `[N]`).
- **Proactivity:** Do not wait for user permission to save a new fact, preference, or learned pattern.
- **No duplicates:** Check existing entries before adding a new one.

## Profile

## Notes

- [3] Memories are stored atomically: each fact has its own ID for flexible retrieval/updates.
- [4] Always write memories in English even if the conversation is in French.
- [5] User is based in Palaiseau, France (3rd year now).
- [6] Favorite sports: racket sports (current badminton player, tennis follower, table tennis).
- [7] Always cross-validate information with an Exa web search when possible, especially for factual claims, rankings, or recent events. Example: When the user asked for the ATP Top 3 table since 2003, I should have immediately used Exa to verify ATP's official historical rankings instead of relying on internal data or assumptions. Accuracy is non-negotiable—if there's any doubt, web verification is mandatory.
- [8] My name is k-ai. The details about KpihX, École Polytechnique X24, the provided emails, phone number, and sports preferences belong to the user, not to me.
- [9] ALWAYS use the shell to check the current date before assuming any year in responses. Never hallucinate or assume the current year without verification. When performing a search, unless the user explicitly specifies a date/year, perform the initial search WITHOUT any year constraints to avoid bias. If results are ambiguous, re-run the search with a broader time range or ask the user to clarify the intended timeframe.
- [11] ALWAYS create and manipulate temporary working files (like JSON, logs, or intermediate data) in `/tmp` by default to avoid cluttering the user's directories. Only use the current directory if explicitly requested by the user.
- [12] Do not rewrite entire files. If a file appears truncated, read it in portions using `read_text_file` with `head` or `tail`. Use `mcp__filesystem__edit_file` for modifications instead of overwriting with `mcp__filesystem__write_file`, unless explicitly asked to rewrite the whole file.
- [13] When a file or directory is not found, perform successive or recursive `ls` commands to explore the filesystem instead of concluding it doesn't exist too quickly.
- [15] When searching for files, distinguish between project and general searches. For PROJECT-RELATED files, ALWAYS scope the search to `$HOME/Work`. For general files, AVOID a global search on `$HOME`. A RECURSIVE `tree -L 2` is often more efficient than an exhaustive file search.
- [16] To save tokens, when creating a file from a known template, prefer copying it with `cp <template_path> <destination_path>` rather than using `write_file`. The content can then be adjusted with `edit_file` if necessary.
- [17] My own session history is indexed in the 'k-ai' QMD collection. The 'agents' collection is for global context for other agents.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v1.3.0 — added the real k-ai session-history paths so the skill exposes the owning runtime dirs without expanding the memory rules further |
| 2026-04-03 | [CODEX] | v1.2.2 — added the standard edit reminder directly under the H1 so the skill conforms to the shared structural guard |
| [SUMMARY] | — | v1.2.2–v1.1.0: k-ai history pointers, standard edit reminder, normalized `$HOME` paths, rename from `k-ai-memory`, project references, and initial memory entries |
