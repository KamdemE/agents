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
  version: "2.0.0"
  scope: ai-engine
---

# Ollama — Generic Operations

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **OS references:** `references/ubuntu.md` (systemd service, apt install) · `references/windows.md` (WSL setup, native Windows)
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
| 2026-07-22 | [OPENCODE] | v2.0.0 — Rewritten as generic core. Hardware-specific config (Intel Arc GPU, performance tuning, control plane) extracted to k-ubuntu. Added OS references. |
| [SUMMARY] | — | v1.x: Intel Arc GPU setup, IPEX-LLM control plane, specific performance tuning. Full details in k-ubuntu. |
