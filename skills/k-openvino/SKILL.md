---
name: k-openvino
description: >
  OpenVINO GenAI local LLM serving — Qwen3 IR models on Intel Arc iGPU via
  the `openvino` CLI (pull/ls/ps/search/serve) and a FastAPI OpenAI-compatible
  server (serve.py). Covers async-safe generation architecture, the full
  tool-calling protocol (tools= wiring + <think>/<tool_call> parsing), and
  dynamic capability discovery (litellm model-info format) for OpenCode's
  reasoning UI + context% display. Load before any OpenVINO model/server
  work, or when a custom OpenAI-compatible provider mishandles tool calls
  or reasoning in OpenCode.
license: private
metadata:
  author: 
  version: "1.0.0"
  scope: ai-engine
---

# OpenVINO GenAI — Local LLM Serving

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

> Project: `$HOME/Labs/AI/openvino/` (uv package `k-openvino`, binary `openvino`). Server: FastAPI OpenAI-compatible, port `11437`, systemd user service `openvino.service`. Published to PyPI as [`k-openvino`](https://pypi.org/project/k-openvino/) (v0.2.0 live, single remote `origin` under `<user>/openvino`).
> See also **`k-ai`** (AI hub registry entry + cross-domain insight) · **`k-ollama`** (Ollama, historical comparison baseline — deactivated) · **`k-opencode`** (custom provider config in `opencode.jsonc`).

---

## CLI (`openvino`)

```bash
openvino search <query>              # HuggingFace search, Arc-compatible + fits disk/RAM (strict by default, --all for everything)
openvino pull <hf-id>                # download + export to OpenVINO IR (optimum-cli export openvino)
openvino ls                          # list local IR models (or live server models if reachable)
openvino ps                          # server status + loaded model
openvino server start --foreground   # what the systemd service runs
```

Models live in `~/.local/share/openvino/models/<name>/` (`openvino_model.xml`/`.bin` + tokenizer + `config.json`). Real download size is unreliable from `info.safetensors.total` (can undercount 2x+) — the CLI cross-checks real sibling file sizes via `files_metadata=True`, targeting the exact `transformers`-convention checkpoint (`model-000XX-of-000YY.safetensors` or `model.safetensors`), never a naive sum (some repos ship duplicate full-weight distributions in different formats).

## Server architecture (`serve.py`)

FastAPI + `openvino_genai.LLMPipeline`, OpenAI-compatible (`/v1/chat/completions`, `/v1/models`, `/v1/model/info`, `/v1/unload`, `/health`). Single systemd `--user` process, single asyncio event loop — **every blocking call inside an `async def` route must be offloaded via `asyncio.to_thread`** (model load, `apply_chat_template`, `pipe.generate`, tokenization) or it freezes ALL routes (including `/health`) for its duration. `_gen_lock` release lives in the generation THREAD's `finally`, never in the SSE generator's `finally` — a client disconnecting early (e.g. right after a `tool_calls` delta) must never leave the lock stuck. A global FastAPI exception handler returns OpenAI-style `{"error": {...}}` JSON on any unhandled exception — without it, OpenCode's AI SDK can't parse a plain-text 500 and the client silently hangs instead of showing red.

Full protocol design (tool-calling, reasoning, anti-loop fallback) → **`references/tool-calling-protocol.md`**.
Dynamic capability discovery for OpenCode (reasoning/thinking UI, context%) → **`references/model-discovery.md`**.
GPU backend benchmark vs Ollama/IPEX/Vulkan → **`references/benchmark.md`**.

## Config (`config.py`) — central constants, no hardcoding

| Constant | Role |
|----------|------|
| `max_context` | Hard ceiling for `context_length` (32768 — IR reliability drops above this on Arc iGPU) |
| `default_output_tokens` | Absolute cap for `max_output_tokens` (8192) — **never equal to `max_context`**: OpenCode's compaction reserves `max(output, buffer)` tokens of headroom; if output==context, usable budget is 0 and compaction fires almost instantly. Real providers (GPT-4o, Gemini, DeepSeek) use a flat absolute cap independent of context size, never a percentage/ratio of it |
| `default_enable_thinking` | Qwen3 chain-of-thought toggle (default `True`) — per-request `enable_thinking` overrides; Qwen3 (this checkpoint) does not fully respect `enable_thinking=False` — it can still self-emit a `<think>` block despite the empty pre-fill |

## Key insight — tool-calling capability is about wiring, not model size

A 0.6B model does perfect real tool-calling (verified live in OpenCode's interactive TUI: `exa_web_search_exa` executed correctly, real search results, coherent final answer) once `tools=` is actually passed to `apply_chat_template()`. Before that fix, even a hypothetical 20B+ model would have hallucinated tool calls identically — the model was never shown the tool schema at all, regardless of its size. **Never assume "model too small" when tool-calling fails on a custom OpenAI-compatible server — check the wiring first.** Same insight, cross-domain framing → **`k-ai`**.

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial work in this skill domain.
- Update `references/insights.md` at the end of the task with durable lessons.

## References

- `references/tool-calling-protocol.md` — full tool-calling + reasoning protocol design (root cause, fix, `_StreamParser`, anti-loop fallback)
- `references/model-discovery.md` — bifrost vs litellm `modelsDiscovery` formats, `/v1/model/info` endpoint, why bifrost never mapped `reasoning`
- `references/benchmark.md` — OpenVINO vs IPEX-LLM vs Vulkan (Ollama) GPU inference speed comparison
- `references/insights.md` — durable lessons

