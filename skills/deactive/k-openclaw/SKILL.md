---
name: k-openclaw
description: >
  Archived OpenClaw retrospective — deactivated runtime notes, failure modes, and KπX-specific
  return of experience after full local purge on 2026-04-04.
license: private
metadata:
  author: KpihX
  version: "2.1.0"
  scope: agent-runtime
  target-agent: openclaw
allowed-tools: Bash, Read, Write, Edit
---

# Archived Runtime — OpenClaw

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Status

- **State:** deactivated and fully purged from the workstation on 2026-04-04
- **Only allowed trace:** this archived skill under `$HOME/.agents/skills/deactive/k-openclaw/`
- **Do not recreate lightly:** any future reintroduction must start as a fresh evaluation, not from old local assumptions

## Why It Was Retired

- the runtime added too much orchestration fragility on top of otherwise-usable local Ollama models
- short local interactions regularly degraded into hallucination, false tool JSON, or polluted system-message loops
- compaction safeguards and system metadata leaked into the user-visible conversation too often to be acceptable
- the only promising free external fallback tested here (`mistral-small-latest`) reached the provider but failed through the runtime with `422 status code (no body)`
- the maintenance cost became higher than the value compared with direct `ollama run` and the planned `k-ai` path

## KπX Return Of Experience

- local model quality must be judged inside the target runtime, not in isolation; a decent model can become poor inside an unstable orchestrator
- hidden system prompts, compaction messages, and advisory-only tool surfaces are enough to ruin a CLI agent UX even when the base model is acceptable
- external-provider compatibility through a generic OpenAI-style adapter is not guaranteed; a reachable API key does not mean the runtime/provider pair is usable
- for KπX on this Ubuntu machine, the pragmatic split is: `ollama run` for direct/simple work, `k-ai` for the sovereign agent stack, no OpenClaw in the active toolchain
- OpenClaw is not just the main binary — it ships a full ecosystem: `clawhub`/`clawdhub` (pnpm, package registry at `clawhub.ai`), `mcporter` (pnpm, MCP config manager), and `nanoclaw` (MCP filesystem server with `mount-allowlist.json`); all four must be purged together
- pnpm interdependency trap: removing `clawhub` caused pnpm to auto-install `mcporter 0.7.3` — always verify `pnpm list -g` after partial uninstall, then explicitly `pnpm remove -g mcporter`

## References

- `references/retrospective-2026-04-04.md` — detailed benchmark and failure-mode notes captured at retirement time

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CLAUDE] | v2.1.0 — completed full purge: clawhub/clawdhub + mcporter (pnpm) + nanoclaw config dirs; documented pnpm interdependency trap and full ecosystem map |
| 2026-04-04 | [CODEX] | v2.0.0 — archived runtime after full local purge; distilled failure modes and retirement rationale |
| [SUMMARY] | — | v1.12.2–v1.0.0: active-runtime era (external-secret loading, exa-only MCP posture, lean local defaults, CLI-only QMD, compact hook guidance, history pointers, hook discovery, workspace-root, provider, approvals) |
