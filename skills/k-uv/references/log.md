# k-uv Operation Log

Append-only archive for durable skill history. One single `##` section — rows are stacked underneath it in chronological order, oldest first.

## Archived Changelog Rows

| Date | Agent | Action |
|------|-------|--------|
| [SUMMARY] | — | v1.x: initial uv ecosystem inventory |
| 2026-08-13 | [COLAB] | `piper-tts` and `whisper-ctranslate2` uninstalled from global uv tools; native C++ binaries `k-piper` and `k-whisper` used instead. |
| [LEGACY] | — | Previously removed table (moved from SKILL.md on 2026-08-13): `colab` (KpihX-owned editable project, 2026-07-24) · `k-flow` (KpihX-owned, `~/Work/AI/flow/`, 2026-07-24) · `powerpoint` (MCP server, 2026-07-24) · `grip`, `huggingface-hub`, `ipynb-pdf`, `kpihx-ai`, `kpihx-todo`, `viperx`, `wayland-mcp` (purged in k-optim pass, 2026-05-31). |

## Changelog rotation from `k-uv/SKILL.md` (2026-08-15)

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-14 | [COLAB] | v1.4.0 — **Purged MCP tools moved to `references/purged.md`**: removed `desk-mcp`, `k-mail-mcp`, `mail-mcp`, `mistral-vibe`, `tick-mcp` rows from the MCP table; archived them in `references/purged.md` (never deleted); kept only `*-proxy` CLIs. |
| 2026-08-13 | [COLAB] | v1.3.0 — Removed the legacy "Previously removed" table from SKILL.md; archived to references/log.md. |
