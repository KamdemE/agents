---
title: Local agentic Ollama benchmark on KpihX Ubuntu
date: 2026-04-04
timestamp: "2026-04-04 15:15 Europe/Paris"
author: "[CODEX]"
---

# Local agentic Ollama benchmark on KpihX Ubuntu

## Context

- Host: KpihX Ubuntu laptop
- CPU: Intel Core Ultra 7 155H
- GPU: Intel Arc integrated GPU on shared system RAM
- Local Ollama backend: IPEX control plane at `$HOME/Work/AI/ollama/ipex/`
- Local agent runtime tested: OpenClaw at `$HOME/.openclaw/`
- QMD status during the same optimization pass: Vulkan offloading available on Intel Arc after the `glslc` fix

## Benchmark scope

Goal: rank the local models that are realistic on this machine for CLI agent runtimes such as OpenClaw, not just for raw chat quality.

Benchmarked models:

1. `phi4-mini:latest`
2. `llama3.1:8b`
3. `qwen2.5-coder:3b`
4. `gemma3:4b`

Evaluation axes:

- direct Ollama latency and answer discipline
- real OpenClaw behavior on a fresh session
- respect for approval-sensitive behavior around `exec`
- practical fit for a local agent runtime on this Ubuntu machine

## Direct Ollama observations

### `phi4-mini:latest`

- fastest safe-ish general local option
- good latency on short prompts
- sometimes verbose or hesitant
- acceptable default when the runtime overhead is already high

### `llama3.1:8b`

- strongest raw reasoning in the set
- noticeably slower on this machine
- still interesting outside OpenClaw when direct quality matters more than responsiveness

### `qwen2.5-coder:3b`

- fast and structured
- best coding-oriented small model of the tested set
- more likely to be overconfident or violate guardrails if the runtime prompt is weak

### `gemma3:4b`

- decent in direct plain Ollama
- not suitable for the tested OpenClaw tool path

## OpenClaw observations

Fresh-session OpenClaw runs were the decisive signal.

### `phi4-mini:latest`

- best practical default for OpenClaw on this machine
- respected the spirit of "ask before using exec"
- still slower than desired because OpenClaw injects a large runtime prompt

### `qwen2.5-coder:3b`

- faster than `phi4-mini` in the OpenClaw run
- but emitted an `exec` call directly with `ask: off`
- better as a coding assistant than as the default safe OpenClaw model

### `llama3.1:8b`

- too slow in the current OpenClaw runtime
- hit the timeout budget in the real OpenClaw test

### `gemma3:4b`

- rejected by the OpenClaw tool flow with a "does not support tools" Ollama error
- removed from the active IPEX model set after this pass

## Recommendation for this Ubuntu machine

### Default local agent model

- `phi4-mini:latest`

Why:

- best balance of speed, tool-usage discipline, and survivability inside OpenClaw

### Secondary coding model

- `qwen2.5-coder:3b`

Why:

- strong small coding model
- keep it as an explicit alternate, not the default approval-sensitive agent

### Direct Ollama quality model

- `llama3.1:8b`

Why:

- strongest raw reasoning of the tested set
- acceptable when used directly, but too heavy for the current OpenClaw overhead

## Active local model policy after this pass

Keep installed in the IPEX store:

1. `phi4-mini:latest`
2. `llama3.1:8b`
3. `qwen2.5-coder:3b`

Removed from the active IPEX store:

1. `gemma3:4b`

## OpenClaw optimization posture derived from the benchmark

The limiting factor is not only the model. The OpenClaw runtime itself is costly.

Preferred defaults on this machine:

- `contextTokens: 16384`
- `maxConcurrent: 1`
- `subagents.maxConcurrent: 1`
- `memorySearch.enabled: false`
- `verboseDefault: off`
- only keep locally relevant Ollama models in `openclaw.json`

These settings reduce avoidable runtime overhead and align OpenClaw with the actual local hardware envelope.
