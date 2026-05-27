# Google AI Studio — Playwright / Edge automation

**URL:** `https://aistudio.google.com` · account **kapoivha@gmail.com** (Pro).

**Scope:** Playground chats (`/prompts/…`), History (`/library`), model picker, code execution, multimodal uploads. Not the public Gemini API docs site.

## Session setup

| Step | Action |
|------|--------|
| Browser | Edge agent + Playwright MCP (`browser_snapshot` → `target` refs) or Browser MCP on signed-in profile |
| Model | Playground header → model name button → search/list ( `/models` returns 404 ) |
| Code exec | Run settings → **Code execution** toggle ON before prompts that need matplotlib/Python |
| Grounding | For PDF/video uploads, **disable Google Search grounding** — reduces `internal error` with attachments |

## Attachment readiness gate (critical)

After upload, **do not click Run** until **every** attachment shows a **token count** (e.g. `3 921 tokens`, `10 641 tokens`) and **no** `Loading…` or `Failed`.

| State | Action |
|-------|--------|
| `Loading…` | Wait (poll snapshot every 3–5 s) |
| `Failed` on file | Remove chip, re-upload, or new chat |
| Token count visible | Safe to send prompt |

Early Run → model answers « no video/PDF attached » or `An internal error has occurred.`

## Multimodal preferences

| Media | Notes |
|-------|--------|
| **PDF** | Preferred for course Q&A; 2 PDFs ~14k tokens OK on Gemini 3 Flash Preview |
| **Short MP4** | Often `Failed` + internal errors; abandon unless user insists and gate is respected |
| **Images (Nano Banana)** | Free tier: **Nano Banana** (`gemini-2.5-flash-image`) without Paid badge |

## Downloads

| Output | How to save |
|--------|-------------|
| Generated image | Lightbox → **Download** → `~/Downloads/Generated Image …png` |
| Code execution | In-chat plot image → same lightbox Download; « Code execution result » `.txt` is not the plot |

## History cleanup (`/library`)

Delete only chats from the **current automation run** (titles from last ~hour): homelab image test, sphere/matplotlib variants, video résumé attempts, failed uploads. **Do not** delete older user chats (weeks/months) unless KπX names them.

Flow: row → **More options** (`more_vert`) → Delete → confirm.

## Local Python — forbidden

Never `pip install` on system Python to reproduce AI Studio code-exec plots. All sphere/viz tests stay in AI Studio; see AGENTS.md § « Python & system installs — GRAVÉ ».

## Model catalog (2026-05-26 snapshot)

Explore via playground model selector; capture `browser_snapshot` for names. Families include Gemini 3.x Flash/Pro/Lite, Nano Banana (image), Imagen 4, Veo, Lyria, Gemma, Antigravity/Deep Research agents. Paid badge on selector = billed model.

## Changelog

| Date | Note |
|------|------|
| 2026-05-26 | Initial runbook from AI Studio IME test session (image, code exec sphere, PDF Parrot, video failures). |
