---
name: k-ollama
description: Guide and templates for setting up Ollama with Intel (Arc) GPU acceleration on Ubuntu, including Vulkan and Docker IPEX-LLM options.
license: private
metadata:
  author: KpihX
  version: "1.3.1"
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

1.  **Prerequisites:**
    *   Stop local service: `sudo systemctl stop ollama && sudo systemctl disable ollama`

2.  **Launch via Docker Compose:**
    *   **Template:** `~/.agents/skills/k-ollama/assets/docker-compose.yml`
    *   **Command:** `docker compose -f /home/kpihx/.agents/skills/k-ollama/assets/docker-compose.yml up -d`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-31 | [CLAUDE] | v1.3.1 — templates/ → assets/ (skill-creator standard) |
| 2026-03-31 | [GEMINI] | v1.3.0 - Standardized on port 11434 for IPEX-LLM Docker solution. |
| 2026-03-31 | [GEMINI] | v1.2.0 - Updated docs to reflect IPEX-LLM performance. |
| [SUMMARY] | — | v1.1.0 English translation; v1.0.0 Initial creation. |
