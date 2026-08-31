# Tool-Calling + Reasoning Protocol — Design & Root Causes

## Root cause — `apply_chat_template` without `tools=`

The original `serve.py` built the prompt via:

```python
prompt = tok.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
```

`body.get("tools")` (the OpenAI-compatible `tools` array OpenCode sends on every request) was **never read**. Qwen3's chat template only injects the `<tools>...</tools>` system block and the `<tool_call>` format instructions when `tools=` is explicitly passed — omitting it means the model has **zero knowledge** that tool-calling exists, at any model size. Verified directly (before/after prompt diff):

```python
tok.apply_chat_template(msgs, tools=tools, tokenize=False, add_generation_prompt=True)
# → injects:
# # Tools
# You may call one or more functions to assist with the user query.
# <tools>{"type": "function", "function": {...}}</tools>
# For each function call, return a json object ... within <tool_call></tool_call> XML tags
```

Without this, the model narrates actions in plain text ("bash ls /tmp") instead of ever emitting a real tool call — this was the exact cause of the very first bug of the session (a fake `webfetch` hallucination).

## Fix — read `tools=` and `enable_thinking=` from the request body

```python
tools = body.get("tools") or None
enable_thinking = bool(body.get("enable_thinking", CONFIG.default_enable_thinking))
prompt = await asyncio.to_thread(
    tok.apply_chat_template,
    _normalize_messages(messages),
    tools=tools,
    tokenize=False,
    add_generation_prompt=True,
    enable_thinking=enable_thinking,
)
```

`_normalize_messages`/`_normalize_content` extract plain text from either a string `content` or an OpenAI multimodal parts array (`text`/`image_url`/`input_audio`/`file`) — HF chat templates expect a string; centralizing extraction here means a future image/video/audio OpenVINO backend only extends this one function, never every call site.

## Output parsing — `_StreamParser`

Qwen3 (Hermes/Qwen tool-call convention) emits, in order:

```
<think>...reasoning...</think>          (optional)
<tool_call>{"name": ..., "arguments": {...}}</tool_call>   (0+ blocks)
plain text                              (the rest)
```

`_StreamParser` is a state machine (`scan` / `thinking` / `toolcall`) shared between the streaming and non-streaming paths — **one grammar, never duplicated**. Key correctness points (both found by unit tests, not by inspection):

- **`scan` state must search for tag POSITION, not `startswith`.** A leading `\n` before `<tool_call>` (e.g. right after `</think>\n`) breaks a naive `buffer.startswith(...)` check — the fix searches `buffer.find(tag)` for both open tags and flushes everything before the earliest match as content.
- **`_longest_tag_prefix` must be scoped per state** to only the tags relevant to that state's own lookahead (open tags while `scan`ning, only `</think>` while `thinking`) — otherwise a fully-formed CLOSING tag from a different phase (e.g. `</tool_call>` appearing while still in `scan`) is wrongly treated as "might still be growing," holding back content that should have flushed.
- Tool calls are buffered **whole** (not char-by-char JSON deltas) and emitted as one complete event once `</tool_call>` closes — matches how many OpenAI-compatible providers behave when the model doesn't natively support incremental JSON argument streaming, and avoids the fragility of reassembling partial JSON across chunks.

## Response shape

- `reasoning_content` — the `@ai-sdk/openai-compatible` interleaved-reasoning field, the same convention already used for DeepSeek's thinking mode. Non-streaming: `message.reasoning_content`. Streaming: `delta.reasoning_content` per chunk.
- `tool_calls` — standard OpenAI array (`id`/`type: "function"`/`function.name`/`function.arguments` as a JSON string), `finish_reason: "tool_calls"`.
- **Anti-loop fallback (critical):** if a turn ends with no `tool_calls` AND empty `content`, fall back `content` to the full `reasoning_content` text rather than leaving it empty. OpenCode's client only creates a visible text part on a non-empty `content` delta (`text-start` never fires on empty/null content) — a turn that puts everything in `reasoning_content` and never emits real `content` **vanishes entirely** from the TUI, and OpenCode retries the same turn indefinitely (a documented upstream pattern, `opencode` issue #37073 — "final response missing after Thought block", seen across DeepSeek/GLM/Qwen). This was reproduced live: `qwen3-4b` on a trivial "hi" repeatedly thought without ever producing content, causing an apparent infinite loop that was actually OpenCode silently re-sending the same message forever.

## Async architecture — never block the event loop

`serve.py` runs as a single-process, single-event-loop `uvicorn` server (no `workers=N`). ANY blocking call directly inside an `async def` route freezes **every** route (including `/health`) for its duration — not just the current request. All of these must go through `asyncio.to_thread`: `_discover_models()`, `_load()` (GPU pipeline construction — the single biggest offender, can take tens of seconds), `apply_chat_template()`, `_token_count()`, `gc.collect()` in `/v1/unload`. `pipe.generate()` itself is threaded via `asyncio.to_thread` (non-streaming) or a dedicated `threading.Thread` (streaming, feeding a queue consumed by the SSE generator, which Starlette auto-threads since it's a plain sync generator).

**Lock lifetime bug (found live, fixed):** `_gen_lock.release()` must live in the **generation thread's** `finally`, not the SSE generator's `finally`. If OpenCode disconnects early — e.g. right after receiving a complete `tool_calls` delta, since it doesn't need the rest of the stream — the generator is never fully drained/closed, so its `finally` never runs, permanently leaking the lock (every subsequent request gets `429 model busy` forever, even though the server process is alive and healthy). Tying release to the generation thread instead makes it release unconditionally the moment `pipe.generate()` actually finishes, regardless of client behavior.

## Restart caveat

`systemctl --user restart openvino.service` does **not** take effect immediately if a `pipe.generate()` call is mid-flight in a background thread — that raw C++ call has no Python-level cancellation hook, so `SIGTERM` cannot interrupt it. `systemd` waits up to `TimeoutStopSec` (default 90s) before `SIGKILL`. Always verify the NEW `PID` via `systemctl --user status` before re-testing a fix — otherwise you may be testing against the still-running OLD code for up to 90 seconds.
</content>
