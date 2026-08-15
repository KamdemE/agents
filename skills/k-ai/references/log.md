# k-ai Operation Log

Append-only archive for durable skill history. One single `##` section — rows are stacked underneath it in chronological order, oldest first.

## Archived Changelog Rows

| Date | Agent | Action |
|------|-------|--------|
| [SUMMARY] | — | v1.3.1 and earlier |
| 2026-04-13 | [CODEX] | v1.3.2 — Standardized insights discipline and autonomous maintenance hooks for this skill. |
| 2026-08-13 | [COLAB] | v2.0.0 — Reactivated k-ai skill and refactored it as the central KπX Sovereign AI Hub documenting runtimes, C++ binaries, and models. |
| 2026-08-13 | [COLAB] | v2.1.0 — Added references/whisper.md and references/piper.md to document compilation, usage, and optimizations. |
| 2026-08-13 | [COLAB] | v2.2.0 — Removed default models from wrappers; updated SKILL.md and references for k-whisper and k-piper wrappers. |
| 2026-08-13 | [COLAB] | v2.3.0 — Removed DEFAULT_MODEL / DEFAULT_VOICE constants from k-whisper.sh and k-piper.sh; model/voice is now mandatory at call time. |
| 2026-08-13 | [COLAB] | v2.4.0 — Simplified k-whisper.sh and k-piper.sh: standalone top-level scripts (no function wrapper, never sourced), highly commented in English. |
| 2026-08-13 | [COLAB] | v2.5.0 — Installed piper C++ binary (v1.2.0) + libs + espeak-ng-data; k-piper.sh now exports LD_LIBRARY_PATH and passes --espeak_data.

## Changelog rotation from `k-ai/SKILL.md` (2026-08-15)

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-14 | [COLAB] | v3.2.0 — **Added Tesseract OCR** to Local AI Binaries: `references/tesseract.md` created (install from scratch, CLI usage, language packs, Text Extractor helper integration). No wrapper (simple CLI, direct `tesseract` usage). |
| 2026-08-14 | [COLAB] | v3.1.0 — **Rewritten compact**: removed duplicated runtime details from the merged registry; each runtime now POINTS to its dedicated skill (`k-opencode`, `k-hermes`, `k-openclaw`, `k-code`, `deactive/k-claude`); purged runtimes archived to `references/purged.md` (no skill pollution). |
| 2026-08-14 | [COLAB] | v3.0.0 — **Merged k-agents into k-ai (Agent Runtime Registry)** : absorbed Runtime Registry, Per-Runtime Details, Injection Matrix, Cross-References, Curator Usage, Kernel File Layout. Corrections : OpenClaw opérationnel ; Claude Code = extension-auth opencode ; Continue purgé. k-agents removed. | |
