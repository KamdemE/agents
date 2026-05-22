---
name: k-ollama
description: Guide and templates for setting up Ollama with Intel (Arc) GPU acceleration on Ubuntu, including Vulkan and Docker IPEX-LLM options.
license: private
metadata:
  author: KpihX
  version: "1.11.3"
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
- Stop local service: run in **shared tmux** — `sudo systemctl stop ollama && sudo systemctl disable ollama` (KπX approves in pane; **`sui` deprecated**).
- User must be in `video` + `render` groups: `sudo usermod -aG video,render $USER` via shared tmux when needed.

### Notes

- Keep one public endpoint only: `11434`
- Do not reintroduce shell wrappers or proxy layers
- Docker/container tuning lives in the project config, not in this skill
- For the X cluster launcher in `$HOME/ai_cluster/start_ia.sh`, keep `~/.ollama/models` as the canonical persistent store and sync it into `/tmp/$USER/ollama_models` at start, then sync `/tmp` back to `~/.ollama/models` periodically and on exit. Otherwise models pulled through the dispatcher vanish on the next restart because they were only written to the ephemeral store.
- Current recommended active local set on this Ubuntu machine: `phi4-mini:latest` (default), `llama3.1:8b`, `qwen2.5-coder:3b`
- `gemma3:4b` was removed from the active IPEX store after benchmark because the tested agentic runtime flow rejected it

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-ollama/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-ollama/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-25 | [CODEX] | v1.11.3 — Documented the X-cluster dispatcher persistence rule: `~/.ollama/models` stays canonical, `/tmp/$USER/ollama_models` is the fast cache, and sync-back is mandatory to preserve pulls across restarts. |
| 2026-04-18 | [CODEX] | v1.11.2 — Replaced raw `sudo` examples with the audited `sui -r` privilege pattern for local Ollama setup. |
| [SUMMARY] | — | v1.11.1 standardized insights discipline; v1.11.0 removed retired benchmark reference and kept current local model guidance; older history in git |
