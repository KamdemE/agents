# k-ai Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.
- **2026-08-29 — Model size is never the fix for a broken tool-calling wiring, across ANY local runtime.** Root cause traced live on `k-openvino`: a custom OpenAI-compatible server built on `transformers`/`openvino_genai` silently drops tool-calling capability if `tools=` isn't passed to `apply_chat_template()` — no error, no warning, the model just never learns tools exist and hallucinates plain-text action narration instead. Verified fix: a 0.6B model (`qwen3-0.6b`) tool-calls perfectly (real `exa_web_search_exa` execution, real results, coherent answer) once the wiring is correct — a 20B+ model would have failed identically without it. This generalizes beyond OpenVINO to any local runtime (Ollama included) exposing an OpenAI-compatible chat completions endpoint on top of a raw `transformers`-style chat template: **before reaching for a bigger model to "fix" broken tool-calling, verify the tool schema is actually reaching the model's prompt.** Full protocol design → `k-openvino` → `references/tool-calling-protocol.md`.
