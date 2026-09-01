---
name: k-ollama
description: >
  Generic Ollama operations — installation, model management, API usage,
  backend switching, and troubleshooting. Cross-platform patterns that
  work on any OS. Hardware-specific tuning (Intel Arc GPU, performance
  variables) lives in the relevant infra skill (e.g., k-ubuntu references).
  Load for Ollama install, model pull/run, API queries, or backend switch.
license: private
metadata:
  author: KpihX
  version: "2.3.0"
  scope: ai-engine
---

# Ollama — Generic Operations

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **OS references:** `references/ubuntu.md` (systemd service, apt install) · `references/windows.md` (WSL setup, native Windows) · `references/directory-structure.md` (`~/.ollama` & `~/.ollama-ipex` layout + history hygiene + safe clean)
> **Hardware-specific tuning:** See the relevant infra skill — e.g., `k-ubuntu` for Intel Core Ultra 7 155H with Arc Graphics iGPU on this workstation.

---

## Installation

### Linux (Ubuntu/Debian)

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### macOS

```bash
brew install ollama
# Or download from https://ollama.com/download
```

### Windows

Download from https://ollama.com/download (native Windows build available).

---

## Systemd Service (system)

Le service systemd canonical et son drop-in vivent dans ce skill (`assets/`). Leur installation se fait via symlinks :

```bash
# Service principal
sudo ln -sf ~/.agents/skills/k-ollama/assets/ollama.service /etc/systemd/system/ollama.service

# Drop-in (override) — configuration GPU/hardware
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo ln -sf ~/.agents/skills/k-ollama/assets/ollama-override.conf /etc/systemd/system/ollama.service.d/override.conf

# Activer
sudo systemctl daemon-reload
sudo systemctl enable ollama.service
sudo systemctl restart ollama.service
```

> **Source of truth:** les fichiers dans `assets/` sont la seule source — ne JAMAIS éditer directement `/etc/systemd/system/ollama.service` ou son drop-in.

**Bundled assets:** `assets/ollama.service` (systemd unit), `assets/ollama-override.conf` (GPU/hardware drop-in), `assets/ollama-vulkan.service` (Vulkan backend variant).

## Basic Commands

```bash
# List downloaded models
ollama list

# Show running models
ollama ps

# Pull a model
ollama pull <model>

# Remove a model
ollama rm <model>

# Run a model (interactive)
ollama run <model>

# Run a model (one-shot prompt)
ollama run <model> "Your prompt here"

# API endpoint (default)
curl http://127.0.0.1:11434/api/generate -d '{
  "model": "<model>",
  "prompt": "Your prompt here"
}'
```

---

## Server Management

```bash
# Start server (if not running as a service)
ollama serve

# Check if server is running
curl http://127.0.0.1:11434/api/tags

# Stop server
sudo systemctl stop ollama   # Linux (systemd)
# or: pkill ollama
```

---

## Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `OLLAMA_HOST` | Bind address | `http://127.0.0.1:11434` |
| `OLLAMA_MODELS` | Model storage path | `~/.ollama/models` |
| `OLLAMA_KEEP_ALIVE` | Model unload delay | `10m` |
| `OLLAMA_NUM_PARALLEL` | Concurrent requests | `1` |
| `OLLAMA_MAX_LOADED_MODELS` | Max models in RAM | `1` |
| `OLLAMA_FLASH_ATTENTION` | Flash attention | `1` (enable) |

---

## Model Recommendations (Generic)

These models work well on most consumer hardware:

| Model | Size | RAM needed | Use case |
|-------|------|------------|----------|
| `phi4-mini:latest` | ~2.3 GB | 4 GB+ | Fast, lightweight coding |
| `qwen2.5-coder:3b` | ~1.8 GB | 4 GB+ | Code completion |
| `llama3.1:8b` | ~4.6 GB | 8 GB+ | General purpose |
| `qwen3:latest` | ~4.9 GB | 8 GB+ | Strong general reasoning |

For hardware-specific recommendations, consult the relevant infra skill.

---

## Troubleshooting

```bash
# Check logs
journalctl -u ollama -f   # Linux (systemd)

# Test API
curl http://127.0.0.1:11434/api/tags

# Reset (delete all models and config)
rm -rf ~/.ollama

# GPU not detected
ollama run <model> --verbose  # Check "GPU" line in output
```

---

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial work in this skill domain.
- Update `references/insights.md` at the end of the task with durable lessons.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-25 | [CLAUDE] | v2.3.0 — **`references/windows.md` rewritten + new `scripts/install-wsl-client.sh`**: WSL now has two real options, not "conflict, pick one" — Option A (full `install.sh`, own server+GPU libs, auto-enables `ollama.service`) vs. **Option B (client-only, talks to the Windows-hosted server via `.wslconfig`'s `networkingMode=mirrored`, no tunnel needed)**, verified live on `blglaptop139-wsl` (`ollama list` returned the Windows host's 7 models). New idempotent script does the client-only install (latest releases only ship `.tar.zst`, decompressed via a throwaway `uv run --with zstandard` env — no sudo, no `zstd` system package — extracting only `bin/ollama`, skipping the multi-GB `lib/ollama/{cuda_v12,cuda_v13,rocm}` backend libs a pure client never needs) and never touches systemd. Two real bugs hit and fixed while writing/testing it, captured in `references/insights.md`: a `curl | grep -m1` pipe-breakage ("Failure writing output"), and a PATH-blind idempotency check that always re-downloaded because `~/.local/bin` wasn't on `$PATH` in a non-interactive shell. 🔴 rule restated: never `systemctl enable ollama` in WSL when Windows already hosts one on the same mirrored `localhost:11434`. |
| 2026-08-14 | [COLAB] | v2.2.0 — **Added `references/directory-structure.md`**: documents `~/.ollama` & `~/.ollama-ipex` layout (config/history/id keys/models), history hygiene (`truncate -s 0`), and safe-clean rules. History emptied per KπX directive. |
| [SUMMARY] | — | v2.1.0 ipex wrapper CLI docs (→ `references/log.md`) · v2.0.0 rewritten generic core (→ `references/log.md`) · v1.x: Intel Arc GPU setup, IPEX-LLM control plane, specific performance tuning. Full details in k-ubuntu. |
