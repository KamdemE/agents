---
name: k-ollama
description: Guide and templates for setting up Ollama with Intel (Arc) GPU acceleration on Ubuntu, including Vulkan and Docker IPEX-LLM options.
license: private
metadata:
  author: KpihX
  version: "1.10.1"
  scope: ia-engine-setup
  target-agent: all
---

# Ollama on Ubuntu with Intel (Arc) GPU Acceleration

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

This guide points to the source of truth for Ollama on Intel Arc Ubuntu.

## Backends

- Native: `ollama.service`
- IPEX: Docker control plane project at `$HOME/Work/AI/ollama/ipex`

Both must expose the same endpoint: `http://127.0.0.1:11434`

### Hardware: Intel Core Ultra 7 155H (Meteor Lake)
- GPU: Arc Graphics iGPU — **shared RAM** (no discrete VRAM pool), freq max 2250 MHz
- NPU: `/dev/accel/accel0` — available but not used by IPEX-LLM Ollama directly
- CPU: 6 P-cores + 8 E-cores + 2 LP E-cores → `OMP_NUM_THREADS=6` for inference CPU fallback

### Control Plane

- Project: `$HOME/Work/AI/ollama/ipex`
- Repo: `https://github.com/KpihX/ollama-ipex` · `https://gitlab.com/kpihx/ollama-ipex`
- Config: `$HOME/Work/AI/ollama/ipex/src/ipex/config.yaml`
- Compose: `$HOME/Work/AI/ollama/ipex/docker-compose.yml`
- Project AGENTS: `$HOME/Work/AI/ollama/ipex/AGENTS.md`
- CLI: `ollama-ipex ...` and `ipex ...` after `uv tool install --editable $HOME/Work/AI/ollama/ipex`

### Around This Project

- `$HOME/Work/AI/ollama/ipex/` — source of truth: CLI, config, compose, docs, packaging
- `$HOME/Work/AI/ollama/sh/` — neighboring shell area only; do not move orchestration back there
- `$HOME/.ollama-ipex/` — IPEX model store
- `/usr/share/ollama/.ollama/` — native/system Ollama store

Use the control plane only to switch/inspect the backend:
```bash
ollama-ipex start
ollama-ipex native
ollama-ipex status
ollama-ipex preload qwen2.5-coder:3b
ollama-ipex logs --lines 200
```

Use plain `ollama ...` for model operations:
```bash
ollama list
ollama ps
ollama run phi4-mini:latest
```

### Key Performance Variables
| Variable | Value | Reason |
|---|---|---|
| `OLLAMA_KEEP_ALIVE` | `10m` | Workstation-safe warm cache without pinning RAM forever |
| `OLLAMA_NUM_GPU` | `999` | Offloads all layers to Arc iGPU |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Avoids RAM split (shared VRAM) |
| `OLLAMA_FLASH_ATTENTION` | `1` | Faster attention for long contexts |
| `OMP_NUM_THREADS` | `6` | P-cores only for CPU fallback |
| `SYCL_PI_LEVEL_ZERO_USE_IMMEDIATE_COMMANDLISTS` | `1` | Benchmark both 0/1 — workload dependent |
| `mem_limit` | `24g` | Leaves real headroom for desktop + editors on a 30 GiB machine |

### Prerequisites
- Stop local service: `sudo systemctl stop ollama && sudo systemctl disable ollama`
- User must be in `video` + `render` groups: `sudo usermod -aG video,render $USER`

### Notes

- Keep one public endpoint only: `11434`
- Do not reintroduce shell wrappers or proxy layers
- Docker/container tuning lives in the project config, not in this skill
- Local agentic benchmark reference: `$HOME/.agents/skills/k-ollama/references/agentic-local-benchmark-2026-04-04.md`
- Current recommended active local set on this Ubuntu machine: `phi4-mini:latest` (default), `llama3.1:8b`, `qwen2.5-coder:3b`
- `gemma3:4b` was removed from the active IPEX store after benchmark because the tested OpenClaw tool flow rejected it

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CODEX] | v1.10.1 — replaced the stale `qwen2.5:latest` preload example with the active `qwen2.5-coder:3b` model |
| 2026-04-04 | [CODEX] | v1.10.0 — added the timestamped local agentic benchmark reference for this Ubuntu Intel Arc machine and recorded the final recommended active model set |
| [SUMMARY] | — | v1.9.1–v1.0.0 covered the same-endpoint validation on `127.0.0.1:11434`, the legacy proxy/wrapper era, the move into `$HOME/Work/AI/ollama/ipex`, preload guidance, and the initial GPU/IPEX setup history |
