# k-clis Operation Log

Append-only archive for durable skill history. One single `##` section — rows are stacked underneath it in chronological order, oldest first.

## Archived Changelog Rows

| Date | Agent | Action |
|------|-------|--------|
| [SUMMARY] | — | v1.8.0 and earlier |
| 2026-07-24 | [OPENCODE] | v1.8.0 — `uv` routing: `k-project` → `k-uv` · `k-project` (dual). New `k-uv` skill created for comprehensive UV/Python ecosystem inventory. |
| 2026-07-25 | [OPENCODE] | v1.9.0 — `bun`/`fnm`/`node`/`npm` routing: `k-project` → `k-node` (dual for bun). New `k-node` skill created for comprehensive Node/JS/TS ecosystem inventory. |
| 2026-08-13 | [COLAB] | v1.10.0 — Rerouted whisper-cli and piper commands to k-ai skill, uninstalled redundant Python wrapper tools. |
| 2026-08-13 | [COLAB] | v1.11.0 — Added k-whisper and k-piper wrapper rows alongside whisper-cli and piper binaries (all routed to k-ai). |
| 2026-08-13 | [COLAB] | v1.12.0 — Split k-whisper/k-piper into explicit rows; registered piper (C++ binary v1.2.0) alongside k-piper.

## Changelog rotation from `k-clis/SKILL.md` (2026-08-15)

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-13 | [COLAB] | v1.14.0 — whisper-cli row updated: Vulkan build (ggml 0.19.0) user-local ~/.local/bin + ~/.local/lib, GPU Arc MTL detected. | |
| 2026-08-14 | [COLAB] | v1.15.0 — **Purged agent CLIs moved to `references/purged.md`**: removed `codex`, `cline`, `gemini`, `vibe`, `copilot`, `zed` rows from the CLI registry (purged 2026-08-14); archived in `references/purged.md` (never deleted); kept only active CLIs + `*-proxy`. |
