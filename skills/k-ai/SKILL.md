---
name: k-ai
description: "KπX Sovereign AI Hub + Agent Runtime Registry — Central inventory of AI runtimes (OpenCode, Ollama, OpenClaw, Hermes, Cursor), and local AI tools/binaries/wrappers (whisper-cli/k-whisper, piper/k-piper, k-translate, k-com, tesseract/OCR, k-whisper STT) + local models. MANDATORY: before any agent executes a task it does NOT have natively (reading an image, voice/image/text transcription, translation, STT/TTS, OCR, NMT) — check k-ai FIRST to see if the right local tool exists and USE it. Compact registry — detailed runtime knowledge lives in each runtime skill. Purged runtimes → references/purged.md."
license: private
metadata:
  author: KpihX
  version: 3.5.0
  scope: runtime-memory
  target-agent: k-ai
allowed-tools: Read, Edit, Write
---

# KπX Sovereign AI Hub

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

This skill is the compact central inventory for all Artificial Intelligence runtimes, models, and binaries configured on KπX infrastructures. Read this skill first to orient, then load the **runtime-specific skill** for deep details. Purged runtimes are archived in `references/purged.md` — never pollute this skill with purge details.

## AI Runtimes & Orchestrators

| Runtime | Status | Skill |
|---------|--------|-------|
| **OpenCode CLI** | 🟢 Active | `k-opencode` |
| **Ollama** | 🟢 Active | `k-ollama` |
| **OpenClaw** | 🟢 Opérationnel | `k-openclaw` |
| **Hermes Agent** | 🟢 Active | `k-hermes` |
| **Cursor** (IDE) | 🟢 Active | `k-code` |
| **Claude Code** | 🔴 Deactive (skill) — binaire conservé pour l'extension Claude d'opencode | `deactive/k-claude` |

## Agent Runtime Registry (source of truth pour Curator)

> Registre compact : **statut + skill à consulter** — toute la connaissance opérationnelle (configs, symlinks, injection, ACP, hooks, monitoring) vit dans le skill de chaque runtime, ne rien détailler ici. Purgés → `references/purged.md` · full details → `references/runtime-registry.md`.

| # | Runtime | Status | Skill |
|---|---------|--------|-------|
| 1 | **OpenCode** | 🟢 | `k-opencode` |
| 2 | **Hermes** | 🟢 | `k-hermes` |
| 3 | **Cursor** | 🟢 | `k-code` |
| 4 | **OpenClaw** | 🟢 | `k-openclaw` |
| 5 | **Claude Code** | 🔴 | `deactive/k-claude` |

> **Purgés 2026-08-14** (AGY, Codex, Gemini, Copilot, VIBE, Cline, Zed, Cursor CLI, Continue, MCPs) → **`references/purged.md`**.

> **Full registry details** (per-runtime configs, injection matrix, curator usage, kernel layout) → **`references/runtime-registry.md`** (preserved from k-agents merge, GRAVÉ).

## Local AI Binaries & Wrappers (Audio & Inference)

Standalone optimized binaries + sovereign shell wrappers, zero background memory when idle:

- **Whisper.cpp** (`whisper-cli` + wrapper `k-whisper` using `scripts/k-whisper.sh`) — STT local. Binaire `~/.local/bin/whisper-cli` (Vulkan GPU Arc), modèles `~/.local/share/whisper-cpp/`. → `references/whisper.md`
- **Piper** (`piper` + wrapper `k-piper` using `scripts/k-piper.sh`) — TTS local. Binaire `~/.local/bin/piper` (ONNX Runtime), modèles `~/.local/share/piper-voices/`. → `references/piper.md`
- **CTranslate2** (`k-translate` using `scripts/k-translate.sh`) — NMT local (int8). Wrapper `~/.local/bin/k-translate`, modèles `~/.local/share/ctranslate2/`. → `references/translate.md`
- **K-Com Hub** (`k-com`) — Orchestrateur STT→Translate→TTS. Projet `~/KpihX-Labs/AI/k-com/` (100% uv), wrapper `~/.local/bin/k-com`. → `references/k-com.md`
- **Tesseract** (`tesseract`) — OCR local. Binaire `/usr/bin/tesseract` (apt), langues `/usr/share/tesseract-ocr/5/tessdata/` (`eng`, `fra`, `osd`). CLI simple, **pas de wrapper** (usage direct `tesseract image stdout -l fra`). Consommé par l'extension GNOME `text-extractor` via le helper `~/.local/bin/text-extractor-ocr` (venv uv `text-extractor-ocr-venv`). → `references/tesseract.md`
- **QMD** (`qmd`/`qmdr`, package npm `@tobilu/qmd`) — Recherche de connaissances locale (BM25+vector hybride) sur les bases markdown KπX. **Embeddings 100% locaux en GGUF** (embeddinggemma-300M + query-expansion-1.7B + reranker-0.6b), **indépendant d'Ollama** (runtime llama.cpp embarqué). Modèles `~/.cache/qmd/models/` (~2.1 GB), config `~/.config/qmd/index.yml`. → `k-qmd`

## Local Models Inventory (`~/.local/share/`)

- **Whisper (STT)** `~/.local/share/whisper-cpp/` : `ggml-large-v3-turbo-q5_0.bin` (548 MB) · `ggml-small.bin` (466 MB) · `ggml-small.en.bin` (466 MB)
- **Piper (TTS)** `~/.local/share/piper-voices/` : `en_US-ryan-high` · `fr_FR-siwis-medium`

## Edition Rules

- **Tools:** use `edit` tool for updates. Never overwrite this file (except explicit full rewrite).
- **Language:** English ONLY.
- **Atomicity:** keep entries short and numbered.
- **Proactivity:** save new facts/preferences/patterns without waiting.
- **No duplicates:** check existing entries first; when a fact belongs to a runtime skill, POINT to it here instead of repeating (see `rules/skill-governance.md` → Cross-References).

## Project References

| Resource | Path / URL |
|----------|------------|
| **GitHub** | https://github.com/KpihX/k-ai |
| **GitLab** | https://gitlab.com/kpihx/k-ai |

## Notes

- [1] Memories stored atomically, each fact has its own ID.
- [2] Always write memories in English even if conversation is in French.
- [3] User based in Palaiseau, France (3rd year).
- [4] Favorite sports: racket sports (badminton, tennis, table tennis).
- [5] Cross-validate with web search when possible; accuracy is non-negotiable.
- [6] Name: k-ai (sovereign AI hub).
- [7] ALWAYS check current date via shell before assuming any year.
- [8] ALWAYS use `/tmp` for temporary working files.
- [9] When a file/dir is not found, search recursively instead of concluding it doesn't exist.

## References

- `references/whisper.md` — Whisper.cpp (whisper-cli) setup, usage, compilation, Vulkan (Intel iGPU) + CUDA (NVIDIA discrete GPU) optimization guides.
- `references/piper.md` — Piper (TTS) setup, usage, deployment, ONNX Runtime optimization guide.
- `references/tesseract.md` — Tesseract OCR setup, CLI usage, language packs, Text Extractor helper integration.
- `references/purged.md` — Purged AI runtimes archive (AGY, Codex, Gemini, Copilot, VIBE, Cline, Zed, Cursor CLI, Continue, MCPs) — GRAVÉ, never deleted.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-ai/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-ai/references/insights.md` at the end of the task with durable lessons.
- Keep insights autonomous and evolutionary.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-26 | [COLAB] | v3.5.0 — **CUDA build documented for `whisper-cli`** (`references/whisper.md`): full deep-pc6 install (2× RTX 3090, Ampere arch `86`), incl. the `nvcc`(11.5)/`g++`(11.4) parameter-pack incompatibility fix (install `gcc-10`/`g++-10`, pass `-DCMAKE_CUDA_HOST_COMPILER`), and confirmation that `nvidia-cuda-toolkit` via apt does not touch the existing driver package (verified with `apt-get install --simulate` before running for real on a shared GPU box). End-to-end voice stack (`sox`, `whisper-cli` CUDA, `piper`) installed and smoke-tested on deep-pc6 via a synth→transcribe round-trip (no physical mic on this headless server). |
| 2026-08-14 | [COLAB] | v3.4.0 — **Added QMD** to Local AI Binaries: `qmd`/`qmdr` (npm @tobilu/qmd) — local knowledge search (BM25+vector hybrid), 100% local GGUF embeddings (embeddinggemma-300M + query-expansion-1.7B + reranker-0.6b), independent of Ollama. Points to `k-qmd`. |
| 2026-08-14 | [COLAB] | v3.3.0 — **Description reinforced (MANDATORY check)**: agents MUST check k-ai before any task they don't have natively (image reading, voice/image/text transcription, translation, STT/TTS, OCR, NMT) and USE the right local tool. Added tesseract/OCR to tool inventory in description. |
| [SUMMARY] | — | v3.2.0 Tesseract OCR · v3.1.0 rewritten compact · v3.0.0 merged k-agents (→ `references/log.md`) · v2.x and older → `references/log.md` |
