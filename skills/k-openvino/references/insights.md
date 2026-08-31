# k-openvino Insights

Autonomous, evolving log of durable lessons for this skill domain. Read before non-trivial work; update at the end of any task with new findings.

## 2026-08-29 — Founding session insights

1. **`apply_chat_template` silently drops tool-calling capability if `tools=` isn't passed.** This is the single most impactful gotcha for ANY custom OpenAI-compatible server built on `transformers`/`openvino_genai` — no error, no warning, the model just never learns tools exist. Always verify by diffing the rendered prompt with/without `tools=` before assuming a model "can't" tool-call.

2. **Model size is never the fix for a broken tool-calling wiring.** Verified: a 0.6B model tool-calls perfectly once `tools=` is wired; a 20B+ model would have failed identically without it. Chasing bigger models to fix a protocol gap wastes time and money — check the wiring first, every time.

3. **`bifrost` and `litellm` `modelsDiscovery` formats are NOT interchangeable** for capability enrichment — verified by reading the actually-installed plugin source (never trust docs/blog posts alone; the installed version is the only ground truth). `bifrost` maps limits/modalities/cost only; `litellm` additionally maps `reasoning`. Always read the real installed plugin code (`~/.cache/opencode/packages/<name>@latest/node_modules/...`) before assuming a documented capability actually exists in the version you have.

4. **A blocking call inside a single-worker `async def` FastAPI route freezes literally everything**, including trivial routes like `/health`, for the entire duration — not just the slow request. This is easy to miss because the bug only manifests under load/cold-start, and looks exactly like "the server is down" from the outside even though the process is alive.

5. **Lock/resource release must be tied to the actual work unit (thread), not to the consumer's iteration of a generator/stream.** A client (OpenCode) legitimately disconnecting early — e.g. right after getting a complete tool call, since it doesn't need the rest of an SSE stream — will otherwise leak the lock permanently. Never assume a generator's `finally` will run just because the work behind it finished; it only runs if the generator itself is fully drained or explicitly closed.

6. **`systemctl restart` does not guarantee new code is live within your next test** if a raw C-extension call (like `openvino_genai`'s `pipe.generate()`) is mid-flight — Python-level signals can't interrupt it, and systemd's `TimeoutStopSec` (default 90s) delays the `SIGKILL`. Always confirm the new PID via `systemctl --user status` before drawing conclusions from a "still failing" retest.

7. **An LLM that puts its entire answer inside `<think>`/`reasoning_content` and emits nothing in `content` will silently vanish from a client's UI and can trigger infinite retry loops** (client-side, not server-side) — this is a known cross-vendor pattern (DeepSeek/GLM/Qwen), not specific to this project. Always have a content fallback for this case in any custom server implementing the `reasoning_content` convention.

8. **Qwen3's `enable_thinking=False` is not fully authoritative** on at least this exported checkpoint — the model can still self-emit a `<think>` block despite the empty pre-filled template block. Don't rely on this flag alone to guarantee "no thinking" behavior; verify empirically per checkpoint.
</content>
