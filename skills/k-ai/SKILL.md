---
name: k-ai
description: "KπX Sovereign AI Hub + Agent Runtime Registry — Central inventory of AI runtimes (OpenCode, Ollama, OpenClaw, Hermes, Cursor), and local AI tools/binaries/wrappers (whisper-cli/k-whisper, piper/k-piper, k-translate, k-com, tesseract/OCR, k-whisper STT) + local models. MANDATORY: before any agent executes a task it does NOT have natively (reading an image, voice/image/text transcription, translation, STT/TTS, OCR, NMT) — check k-ai FIRST to see if the right local tool exists and USE it. Compact registry — detailed runtime knowledge lives in each runtime skill. Purged runtimes → references/purged.md."
license: private
metadata:
  author: KpihX
  version: 3.7.3
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
| **Ollama** | 🔴 Deactivated 2026-09-01 (replaced by k-openvino) | `deactive/k-ollama` |
| **OpenVINO GenAI** | 🟢 Active | `k-openvino` |
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
  - **Keyboard shortcut** : `Super+Shift+T` — select a screen region, OCR in French, result copied to clipboard. Configured in GNOME extension `text-extractor@aditya190803` (language `fra`, notifications enabled).
  - **⚠️ Fix if shortcut stops responding** : the extension can silently lose its keybinding registration. Quick fix:
    ```bash
    gnome-extensions disable text-extractor@aditya190803 && gnome-extensions enable text-extractor@aditya190803
    ```
    This forces the `enable()` call in `extension.js`, which re-runs `Main.wm.addKeybinding(...)`. No systemd, no service — the extension runs inside the `gnome-shell` process itself.
- **QMD** (`qmd`/`qmdr`, package npm `@tobilu/qmd`) — Recherche de connaissances locale (BM25+vector hybride) sur les bases markdown KπX. **Embeddings 100% locaux en GGUF** (embeddinggemma-300M + query-expansion-1.7B + reranker-0.6b), **indépendant d'Ollama** (runtime llama.cpp embarqué). Modèles `~/.cache/qmd/models/` (~2.1 GB), config `~/.config/qmd/index.yml`. → `k-qmd`
- **Hugging Face Hub CLI** (`hf` nouveau standard, `huggingface-cli` déprécié, package `huggingface_hub` via `uv`/`pip`) — Auth + download Hub. **PAS un paquet `apt`** (`apt install huggingface-cli` → `Unable to locate package`). Install : `uv tool install huggingface_hub` → binaire `~/.local/bin/hf` (nouveau, `huggingface-cli` reste en alias déprécié). Token `HF_TOKEN` via `hf auth login` → `~/.cache/huggingface/token` ou `~/.agents/.env` (`HF_TOKEN`), évite `Warning: unauthenticated` et débloque le débit `pull` (ex: `openvino pull` passe de 1.49 à 78 MB/s). → `references/huggingface.md`
- **Background removal** — retained local pair: `bgone` (Rust, CPU, ~0.2s/img 1024×1024) for deterministic solid-color backgrounds and `nobg` (FeyNobg, PyTorch, ~8.8s/img batch on Intel Arc XPU) for semantic alpha matting. Project: `$HOME/KpihX-Labs/AI/nobg/` (git: github+gitlab kpihx-labs/nobg, PyPI: `k-nobg`). Install: `uv tool install '.[gpu-intel]' -e` or `uv tool install k-nobg[gpu-intel]`. Full reference, comparison, and benchmark → `references/remove-bg.md`.

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
- `references/huggingface.md` — Hugging Face Hub CLI (`hf` nouveau standard, `huggingface-cli` déprécié) — install via `uv` (not `apt`), `HF_TOKEN` auth via `hf auth login`, rate-limit fix for `openvino pull`.
- `references/remove-bg.md` — retained `bgone` + FeyNobg (`nobg`) background-removal workflow, hardware-aware setup, and logo-comparison evidence.
- `assets/bg_comparison.pdf` — visual comparison of bgone vs nobg background removal results (referenced by `remove-bg.md`).
- `references/purged.md` — Purged AI runtimes archive (AGY, Codex, Gemini, Copilot, VIBE, Cline, Zed, Cursor CLI, Continue, MCPs) — GRAVÉ, never deleted.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-ai/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-ai/references/insights.md` at the end of the task with durable lessons.
- Keep insights autonomous and evolutionary.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-03 | [LIVE] | v3.7.3 — Added `nobg` project reference (`$HOME/KpihX-Labs/AI/nobg/`, PyPI `k-nobg`) with measured inference times (bgone ~0.2s CPU, nobg ~8.8s batch Intel Arc XPU). |
| 2026-09-03 | [LIVE] | v3.7.2 — Comprehensive `references/remove-bg.md` rewrite: full 4-tool evaluation, visual benchmark matrix, installation guides (Intel Arc + NVIDIA), decision flowchart. |
| [SUMMARY] | — | v3.7.1 Added bgone + nobg pair · v3.7.0 Text Extractor keyboard shortcut · v3.6.2 OpenVINO GenAI added + tool-wiring insight · v3.6.1 HF CLI standard · v3.6.0 Hugging Face Hub CLI · v3.5.0 CUDA whisper-cli · v3.4.0 QMD · v3.3.0 Description reinforced · v3.2.0 Tesseract OCR · v3.1.0 rewritten compact · v3.0.0 merged k-agents · v2.x and older → `references/log.md` |
