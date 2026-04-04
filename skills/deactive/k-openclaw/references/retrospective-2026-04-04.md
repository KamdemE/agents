# OpenClaw Retirement Retrospective — 2026-04-04

Timestamp: 2026-04-04 16:38 Europe/Paris

## Machine Context

- Host: KπX Ubuntu workstation
- CPU/GPU class: Intel Core Ultra 7 155H with Intel Arc iGPU (shared memory)
- Local inference stack: Ollama IPEX on `http://127.0.0.1:11434`
- Main local candidate models during evaluation:
  - `phi4-mini:latest`
  - `llama3.1:8b`
  - `qwen2.5-coder:3b`
  - `gemma3:4b` (later removed)

## What Worked

- the runtime could switch between local Ollama models
- `phi4-mini:latest` remained the least-bad local default inside the runtime
- direct local secret loading through `zsh -l -c` plus `bw-env` was enough to expose external API keys to the gateway

## What Failed Repeatedly

- short local sessions regularly degraded into:
  - system-message pollution
  - false tool JSON emitted as plain text
  - compaction loops
  - poor grounding on simple prompts
- `gemma3:4b` was rejected by the tested tool path
- `llama3.1:8b` was too heavy inside the runtime overhead
- `qwen2.5-coder:3b` was faster but less safe on tool-discipline
- the only promising free external fallback, `mistral-small-latest`, reached the provider but failed through the runtime with `422 status code (no body)`

## Main Diagnosis

The limiting factor was not only model quality.

The runtime itself added too much overhead and too many unstable behaviors:

- compaction safeguard noise
- metadata leakage into the visible conversation
- advisory-only tool surface instead of reliable hard control
- poor compatibility margin for non-local providers

## Final Decision

- retire the runtime completely from the workstation
- keep direct `ollama run` for simple local usage
- invest future agent-runtime effort into `k-ai`

## Keep In Mind If Re-Evaluating Later

- judge models inside the target runtime, not only in direct chat
- validate provider payload compatibility before trusting a generic OpenAI-style adapter
- avoid reintroducing a runtime that leaks internal control messages into user-visible chat
