---
name: k-ollama
description: Guide and templates for setting up Ollama with Intel (Arc) GPU acceleration on Ubuntu, including Vulkan and Docker IPEX-LLM options.
license: private
metadata:
  author: KpihX
  version: "1.6.2"
  scope: ia-engine-setup
  target-agent: all
---

# Ollama on Ubuntu with Intel (Arc) GPU Acceleration

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

This guide documents the methods for configuring Ollama to use hardware acceleration on Intel Arc GPUs on Ubuntu.

## Option 1: Vulkan Acceleration (`systemd` Service)

Enabled via systemd override. Slower than IPEX-LLM.

## Option 2: Docker with IPEX-LLM (Recommended)

This is the **most performant and stable method**, using port **11434** as the standard endpoint.

### Hardware: Intel Core Ultra 7 155H (Meteor Lake)
- GPU: Arc Graphics iGPU — **shared RAM** (no discrete VRAM pool), freq max 2250 MHz
- NPU: `/dev/accel/accel0` — available but not used by IPEX-LLM Ollama directly
- CPU: 6 P-cores + 8 E-cores + 2 LP E-cores → `OMP_NUM_THREADS=6` for inference CPU fallback

### Backend Switch (`.kshrc`)
Single endpoint `OLLAMA_HOST=http://localhost:11434` always — the `ollama-use` function handles start/stop:
```bash
ollama-use ipex    # stop native systemd, start Docker (port 11434)
ollama-use native  # stop Docker, start systemd ollama
ollama-use status  # show which is running
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

### Control Plane
The source of truth for the IPEX backend now lives in the standalone Python project:

- **Project:** `$HOME/Work/AI/ollama/ipex`
- **CLI:** `cd $HOME/Work/AI/ollama/ipex && uv run ipex <command>`
- **Compose:** `$HOME/Work/AI/ollama/ipex/docker-compose.yml`

The shell helper in `$HOME/Work/sh/ollama.sh` is intentionally thin and delegates to the Python CLI.

### Shell Helper (`Work/sh/ollama.sh`)
Per KπX `.kshrc` discipline — thin compatibility functions live in `$HOME/Work/sh/`, not inlined in `.kshrc`.

- **Live script:** `$HOME/Work/sh/ollama.sh` (sourced by `.kshrc`)
- **Template:** `$HOME/.agents/skills/k-ollama/assets/ollama.sh`
- **Proxy helper:** `$HOME/.agents/skills/k-ollama/assets/ollama-proxy.py`
- `.kshrc` entry: `[ -f "$HOME/Work/sh/ollama.sh" ] && source "$HOME/Work/sh/ollama.sh"`

```bash
ollama-use ipex    # stop native systemd → start Docker on :11434
ollama-use native  # stop Docker → start systemd ollama
ollama-use down    # stop everything
ollama-use restart # restart IPEX container cleanly
ollama-use status  # show which is running
ollama-unload qwen2.5:latest  # request model eviction from RAM/VRAM
```

### Compose Template
- **Template:** `$HOME/.agents/skills/k-ollama/assets/docker-compose.yml` → symlink to `$HOME/Work/AI/ollama/ipex/docker-compose.yml`
- **Command:** `ollama-use ipex`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v1.6.2 — surfaced `assets/ollama-proxy.py` explicitly so the skill reflects the full bundled control-plane asset set |
| 2026-04-03 | [CODEX] | v1.6.1 — condensed the changelog to the standard footer format without changing the Ollama runtime guidance |
| [SUMMARY] | — | v1.6.0 moved the IPEX Ollama control plane into `$HOME/Work/AI/ollama/ipex` with a thin `$HOME/Work/sh/ollama.sh` wrapper; v1.5.0 workstation-safe IPEX profile; v1.4.4–v1.0.0 proxy, preload, single-port redesign, assets normalization, and initial GPU/IPEX setup history |
