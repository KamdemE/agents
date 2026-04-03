#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["fastapi", "httpx", "uvicorn[standard]", "zstandard", "websockets"]
# ///
"""
ollama-responses-proxy
Translates OpenAI Responses API (/v1/responses) → Ollama Chat Completions (/v1/chat/completions).
Allows Codex CLI 0.118+ to work with IPEX-LLM / any Ollama lacking the Responses API.

Usage:
  uv run $HOME/Work/sh/ollama-proxy.py [--port 11435] [--upstream http://localhost:11434]

Architecture:
  Codex → :11435/v1/responses  →  proxy  →  :11434/v1/chat/completions  →  IPEX Ollama
  Codex → :11435/<any other>   →  proxy  →  :11434/<passthrough>
"""
import gzip
import json
import time
import uuid
import zlib
import argparse
import os
from pathlib import Path

import httpx
import uvicorn
from fastapi import FastAPI, Request, Response, WebSocket, WebSocketDisconnect
from fastapi.responses import StreamingResponse


def _decompress_json(raw: bytes) -> dict:
    """Decompress bytes (zstd/gzip/deflate) then parse JSON. Used by WS handler."""
    try:
        if raw[:2] == b"\x1f\x8b":
            raw = gzip.decompress(raw)
        elif len(raw) > 2 and raw[0] == 0x28 and raw[1] == 0xb5:
            import zstandard as zstd  # type: ignore
            raw = zstd.ZstdDecompressor().decompress(raw)
    except Exception:
        pass
    return json.loads(raw)


async def _parse_body(request: Request) -> dict:
    """Read request body, decompressing if needed, then parse JSON.
    Handles gzip / deflate / zstd / brotli — Codex Node.js client may compress."""
    raw: bytes = await request.body()
    enc = request.headers.get("content-encoding", "").lower()
    try:
        if enc == "gzip":
            raw = gzip.decompress(raw)
        elif enc in ("deflate", "zlib"):
            raw = zlib.decompress(raw)
        elif enc in ("br", "brotli"):
            import brotli  # type: ignore
            raw = brotli.decompress(raw)
        elif enc == "zstd":
            import zstandard as zstd  # type: ignore
            raw = zstd.ZstdDecompressor().decompress(raw)
        # No explicit encoding — try to auto-detect by first bytes
        elif raw[:2] == b"\x1f\x8b":
            raw = gzip.decompress(raw)
        elif len(raw) > 2 and raw[0] == 0x28 and raw[1] == 0xb5:
            # Zstd magic 0xFD2FB528 — little-endian first bytes 0x28 0xb5
            import zstandard as zstd  # type: ignore
            raw = zstd.ZstdDecompressor().decompress(raw)
    except Exception:
        pass  # Fall through and try to JSON-parse as-is
    return json.loads(raw)

app = FastAPI()
UPSTREAM = "http://localhost:11434"
DEBUG_LOG = Path("/tmp/ollama-proxy-debug.log")
DEFAULT_NUM_CTX = int(os.getenv("OLLAMA_PROXY_NUM_CTX", "16384"))
UPSTREAM_TIMEOUT = float(os.getenv("OLLAMA_PROXY_TIMEOUT", "600"))


def log_debug(message: str) -> None:
    """Append a timestamped debug line to the proxy log and stdout."""
    line = f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {message}"
    try:
        with DEBUG_LOG.open("a", encoding="utf-8") as fh:
            fh.write(line + "\n")
    except Exception:
        pass
    print(line, flush=True)


# ── Input conversion ──────────────────────────────────────────────────────────

def input_to_messages(input_data, instructions: str | None = None) -> list[dict]:
    """Convert Responses API `input` + `instructions` → Chat Completions `messages`."""
    messages = []
    if instructions:
        messages.append({"role": "system", "content": instructions})
    if isinstance(input_data, str):
        messages.append({"role": "user", "content": input_data})
    elif isinstance(input_data, list):
        for item in input_data:
            if not isinstance(item, dict):
                continue
            role = item.get("role", "user")
            content = item.get("content", "")
            # Content can be a list of typed parts
            if isinstance(content, list):
                content = " ".join(
                    p.get("text", "") for p in content
                    if isinstance(p, dict) and p.get("type") in ("input_text", "text")
                )
            messages.append({"role": role, "content": content})
    return messages


# ── Non-streaming response conversion ─────────────────────────────────────────

def chat_to_response(chat: dict, rid: str) -> dict:
    """Convert a Chat Completions response dict → Responses API dict."""
    choice = chat.get("choices", [{}])[0]
    text = choice.get("message", {}).get("content", "")
    usage = chat.get("usage", {})
    msg_id = f"msg_{uuid.uuid4().hex[:24]}"
    return {
        "id": rid,
        "object": "response",
        "created_at": chat.get("created", int(time.time())),
        "model": chat.get("model", ""),
        "status": "completed",
        "output": [{
            "type": "message",
            "id": msg_id,
            "role": "assistant",
            "status": "completed",
            "content": [{"type": "output_text", "text": text, "annotations": []}],
        }],
        "usage": {
            "input_tokens": usage.get("prompt_tokens", 0),
            "output_tokens": usage.get("completion_tokens", 0),
            "total_tokens": usage.get("total_tokens", 0),
        },
        "error": None,
    }


# ── Streaming SSE conversion ───────────────────────────────────────────────────

async def stream_responses(messages, model, max_tokens):
    """Stream Chat Completions SSE → Responses API SSE events."""
    rid = f"resp_{uuid.uuid4().hex[:24]}"
    msg_id = f"msg_{uuid.uuid4().hex[:24]}"

    def sse(event: str, data: dict) -> str:
        return f"event: {event}\ndata: {json.dumps(data)}\n\n"

    # Preamble events
    yield sse("response.created", {"type": "response.created", "response": {
        "id": rid, "object": "response", "status": "in_progress",
        "model": model, "output": [],
    }})
    yield sse("response.output_item.added", {"type": "response.output_item.added",
        "output_index": 0,
        "item": {"type": "message", "id": msg_id, "role": "assistant",
                 "status": "in_progress", "content": []},
    })
    yield sse("response.content_part.added", {"type": "response.content_part.added",
        "item_id": msg_id, "output_index": 0, "content_index": 0,
        "part": {"type": "output_text", "text": ""},
    })

    # Stream tokens from upstream
    full_text = ""
    payload = {
        "model": model,
        "messages": messages,
        "stream": True,
        "options": {"num_ctx": DEFAULT_NUM_CTX},
    }
    if max_tokens:
        payload["max_tokens"] = max_tokens

    async with httpx.AsyncClient(timeout=UPSTREAM_TIMEOUT) as client:
        async with client.stream("POST", f"{UPSTREAM}/v1/chat/completions",
                                 json=payload) as resp:
            async for line in resp.aiter_lines():
                if not line.startswith("data: "):
                    continue
                raw = line[6:]
                if raw.strip() == "[DONE]":
                    break
                try:
                    chunk = json.loads(raw)
                    delta = (chunk.get("choices", [{}])[0]
                             .get("delta", {}).get("content", ""))
                    if delta:
                        full_text += delta
                        yield sse("response.output_text.delta", {
                            "type": "response.output_text.delta",
                            "item_id": msg_id, "output_index": 0, "content_index": 0,
                            "delta": delta,
                        })
                except Exception:
                    pass

    # Closing events
    yield sse("response.output_text.done", {"type": "response.output_text.done",
        "item_id": msg_id, "output_index": 0, "content_index": 0, "text": full_text,
    })
    yield sse("response.output_item.done", {"type": "response.output_item.done",
        "output_index": 0,
        "item": {"type": "message", "id": msg_id, "role": "assistant",
                 "status": "completed",
                 "content": [{"type": "output_text", "text": full_text, "annotations": []}]},
    })
    yield sse("response.completed", {"type": "response.completed", "response": {
        "id": rid, "object": "response", "status": "completed", "model": model,
        "output": [{"type": "message", "id": msg_id, "role": "assistant",
                    "status": "completed",
                    "content": [{"type": "output_text", "text": full_text,
                                 "annotations": []}]}],
    }})


# ── Routes ────────────────────────────────────────────────────────────────────

@app.post("/v1/responses")
async def responses_endpoint(request: Request):
    body = await _parse_body(request)
    log_debug(
        "HTTP /v1/responses "
        f"stream={body.get('stream', False)} "
        f"model={body.get('model', 'phi4-mini:latest')} "
        f"keys={sorted(body.keys())}"
    )
    model = body.get("model", "phi4-mini:latest")
    messages = input_to_messages(body.get("input", ""), body.get("instructions"))
    stream = body.get("stream", False)
    max_tokens = body.get("max_output_tokens") or body.get("max_tokens")

    if stream:
        return StreamingResponse(
            stream_responses(messages, model, max_tokens),
            media_type="text/event-stream",
            headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
        )

    rid = f"resp_{uuid.uuid4().hex[:24]}"
    payload = {"model": model, "messages": messages, "options": {"num_ctx": DEFAULT_NUM_CTX}}
    if max_tokens:
        payload["max_tokens"] = max_tokens

    async with httpx.AsyncClient(timeout=UPSTREAM_TIMEOUT) as client:
        resp = await client.post(f"{UPSTREAM}/v1/chat/completions", json=payload)
        return chat_to_response(resp.json(), rid)


async def _ws_receive_json(websocket: WebSocket) -> dict:
    """Receive a WS message as JSON, handling both text and binary (zstd/gzip)."""
    try:
        raw = await websocket.receive_text()
        msg = json.loads(raw)
        log_debug(f"WS <= text type={msg.get('type', '<none>')} keys={sorted(msg.keys())}")
        return msg
    except Exception:
        raw_bytes = await websocket.receive_bytes()
        msg = _decompress_json(raw_bytes)
        log_debug(f"WS <= binary type={msg.get('type', '<none>')} keys={sorted(msg.keys())}")
        return msg


async def _stream_one_turn(
    websocket: WebSocket,
    messages: list[dict],
    model: str,
    tools: list[dict] | None,
    max_tokens: int | None,
    rid: str,
    output_index: int,
) -> tuple[str, list[dict], list[dict]]:
    """
    Run one LLM turn, streaming events back on the WebSocket.
    Returns (finish_reason, tool_calls_list, output_items).
    finish_reason = "tool_calls" signals that Codex must run tools before continuing.
    """
    def ev(event: str, data: dict) -> str:
        return json.dumps({"type": event, **data})

    msg_id = f"msg_{uuid.uuid4().hex[:24]}"
    payload: dict = {
        "model": model,
        "messages": messages,
        "stream": True,
        "options": {"num_ctx": DEFAULT_NUM_CTX},
    }
    if max_tokens:
        payload["max_tokens"] = max_tokens
    if tools:
        payload["tools"] = tools
        payload["tool_choice"] = "auto"

    log_debug(f"WS -> upstream turn model={model} msgs={len(messages)} tools={len(tools or [])} idx={output_index}")

    full_text = ""
    tool_calls_acc: dict[int, dict] = {}  # index → {id, name, arguments}
    finish_reason = "stop"

    async with httpx.AsyncClient(timeout=UPSTREAM_TIMEOUT) as client:
        async with client.stream("POST", f"{UPSTREAM}/v1/chat/completions",
                                 json=payload) as resp:
            # Announce the message item only if we expect text (not tool-only turn)
            item_announced = False

            async for line in resp.aiter_lines():
                if not line.startswith("data: "):
                    continue
                chunk_raw = line[6:]
                if chunk_raw.strip() == "[DONE]":
                    break
                try:
                    chunk = json.loads(chunk_raw)
                    choice = chunk.get("choices", [{}])[0]
                    delta = choice.get("delta", {})
                    finish_reason = choice.get("finish_reason") or finish_reason

                    # Accumulate tool_calls deltas
                    for tc in delta.get("tool_calls", []):
                        idx = tc.get("index", 0)
                        if idx not in tool_calls_acc:
                            tool_calls_acc[idx] = {"id": "", "name": "", "arguments": ""}
                        if tc.get("id"):
                            tool_calls_acc[idx]["id"] = tc["id"]
                        if tc.get("function", {}).get("name"):
                            tool_calls_acc[idx]["name"] = tc["function"]["name"]
                        if tc.get("function", {}).get("arguments"):
                            tool_calls_acc[idx]["arguments"] += tc["function"]["arguments"]

                    # Stream text content
                    text_delta = delta.get("content", "")
                    if text_delta:
                        if not item_announced:
                            item_announced = True
                            await websocket.send_text(ev("response.output_item.added", {
                                "output_index": output_index,
                                "item": {"type": "message", "id": msg_id, "role": "assistant",
                                         "status": "in_progress", "content": []},
                            }))
                            await websocket.send_text(ev("response.content_part.added", {
                                "item_id": msg_id, "output_index": output_index, "content_index": 0,
                                "part": {"type": "output_text", "text": ""},
                            }))
                        full_text += text_delta
                        await websocket.send_text(ev("response.output_text.delta", {
                            "item_id": msg_id, "output_index": output_index, "content_index": 0,
                            "delta": text_delta,
                        }))
                except Exception:
                    pass

    output_items: list[dict] = []

    # Finalize text output
    if full_text:
        text_part = {"type": "output_text", "text": full_text, "annotations": []}
        text_item = {
            "type": "message",
            "id": msg_id,
            "role": "assistant",
            "status": "completed",
            "content": [text_part],
        }
        await websocket.send_text(ev("response.output_text.done", {
            "item_id": msg_id, "output_index": output_index, "content_index": 0, "text": full_text,
        }))
        await websocket.send_text(ev("response.content_part.done", {
            "item_id": msg_id,
            "output_index": output_index,
            "content_index": 0,
            "part": text_part,
        }))
        await websocket.send_text(ev("response.output_item.done", {
            "output_index": output_index,
            "item": text_item,
        }))
        output_items.append(text_item)

    # Emit function_call items for each tool call
    tool_calls_list = list(tool_calls_acc.values())
    for i, tc in enumerate(tool_calls_list):
        fc_id = tc["id"] or f"fc_{uuid.uuid4().hex[:16]}"
        tc["id"] = fc_id
        call_idx = output_index + (1 if full_text else 0) + i
        function_item = {
            "type": "function_call",
            "id": fc_id,
            "call_id": fc_id,
            "name": tc["name"],
            "arguments": tc["arguments"],
            "status": "completed",
        }
        await websocket.send_text(ev("response.output_item.added", {
            "output_index": call_idx,
            "item": {k: v for k, v in function_item.items() if k != "status"},
        }))
        await websocket.send_text(ev("response.output_item.done", {
            "output_index": call_idx,
            "item": function_item,
        }))
        output_items.append(function_item)

    log_debug(f"WS <- upstream turn model={model} text_chars={len(full_text)} tools={len(tool_calls_list)} finish={finish_reason}")
    return finish_reason, tool_calls_list, output_items


@app.websocket("/v1/responses")
async def responses_ws(websocket: WebSocket):
    """
    Multi-turn WebSocket handler for Codex 0.118+.
    Supports: streaming text, tool calling, tool result relay → final response.
    """
    await websocket.accept()
    try:
        log_debug("WS /v1/responses accepted")
        # ── Initial request ───────────────────────────────────────────────────
        body = await _ws_receive_json(websocket)
        model = body.get("model", "phi4-mini:latest")
        messages = input_to_messages(body.get("input", ""), body.get("instructions"))
        tools: list[dict] | None = body.get("tools") or None
        max_tokens = body.get("max_output_tokens") or body.get("max_tokens")
        rid = f"resp_{uuid.uuid4().hex[:24]}"

        def ev(event: str, data: dict) -> str:
            return json.dumps({"type": event, **data})

        log_debug(f"WS session init model={model} tools={len(tools or [])} input_type={type(body.get('input', '')).__name__}")
        await websocket.send_text(ev("response.created", {"response": {
            "id": rid, "object": "response", "status": "in_progress",
            "model": model, "output": [],
        }}))

        output_index = 0
        final_output: list[dict] = []

        # ── Conversation loop (text → tool_calls → tool_results → text) ──────
        while True:
            finish_reason, tool_calls, output_items = await _stream_one_turn(
                websocket, messages, model, tools, max_tokens, rid, output_index
            )
            final_output.extend(output_items)
            output_index += len(output_items)

            if not tool_calls or finish_reason != "tool_calls":
                # No tool calls or model finished — done
                break

            # ── Relay tool calls to Codex, wait for results ──────────────────
            # Signal Codex that tool execution is needed
            log_debug(f"WS requires_action tool_calls={len(tool_calls)}")
            await websocket.send_text(ev("response.requires_action", {
                "response_id": rid,
                "required_action": {
                    "type": "submit_tool_outputs",
                    "submit_tool_outputs": {
                        "tool_calls": [
                            {"id": tc["id"], "type": "function",
                             "function": {"name": tc["name"], "arguments": tc["arguments"]}}
                            for tc in tool_calls
                        ]
                    }
                }
            }))

            # Wait for tool results from Codex
            tool_results_received: dict[str, str] = {}
            saw_response_create = False
            while len(tool_results_received) < len(tool_calls):
                incoming = await _ws_receive_json(websocket)
                itype = incoming.get("type", "")

                if itype == "conversation.item.create":
                    item = incoming.get("item", {})
                    if item.get("type") == "function_call_output":
                        call_id = item.get("call_id", "")
                        output = item.get("output", "")
                        tool_results_received[call_id] = output
                        log_debug(f"WS tool output received call_id={call_id} bytes={len(output)}")
                        # Acknowledge
                        await websocket.send_text(ev("conversation.item.created", {"item": item}))

                elif itype == "response.create":
                    # Codex signals it wants the next response turn.
                    # Keep waiting for remaining tool outputs to avoid re-entering
                    # the model turn with an incomplete tool result set.
                    saw_response_create = True
                    log_debug("WS response.create received")

            # Add assistant tool_calls + tool results to conversation
            messages.append({
                "role": "assistant",
                "content": None,
                "tool_calls": [
                    {"id": tc["id"], "type": "function",
                     "function": {"name": tc["name"], "arguments": tc["arguments"]}}
                    for tc in tool_calls
                ]
            })
            for tc in tool_calls:
                result = tool_results_received.get(tc["id"], "")
                messages.append({
                    "role": "tool",
                    "tool_call_id": tc["id"],
                    "content": result,
                })

            # Continue to next turn with tool results in context
            if saw_response_create:
                log_debug("WS continue after tool outputs")
                await websocket.send_text(ev("response.created", {"response": {
                    "id": rid, "object": "response", "status": "in_progress",
                    "model": model, "output": [],
                }}))

        # ── Final completion event ────────────────────────────────────────────
        log_debug(f"WS completed output_items={len(final_output)}")
        await websocket.send_text(ev("response.completed", {"response": {
            "id": rid, "object": "response", "status": "completed", "model": model,
            "output": final_output,
        }}))

    except WebSocketDisconnect:
        log_debug("WS disconnected")
        pass
    except Exception as e:
        log_debug(f"WS error: {type(e).__name__}: {e!r}")
        try:
            await websocket.send_text(json.dumps({"type": "error", "error": {"message": str(e)}}))
        except Exception:
            pass
    finally:
        try:
            await websocket.close()
        except Exception:
            pass


@app.api_route("/{path:path}",
               methods=["GET", "POST", "DELETE", "PUT", "PATCH", "HEAD"])
async def passthrough(request: Request, path: str):
    """Forward everything else directly to upstream Ollama."""
    log_debug(f"HTTP passthrough {request.method} /{path}")
    async with httpx.AsyncClient(timeout=UPSTREAM_TIMEOUT) as client:
        resp = await client.request(
            method=request.method,
            url=f"{UPSTREAM}/{path}",
            headers={k: v for k, v in request.headers.items() if k.lower() != "host"},
            content=await request.body(),
            params=dict(request.query_params),
        )
    return Response(content=resp.content, status_code=resp.status_code,
                    headers=dict(resp.headers))


# ── Entry point ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ollama Responses API proxy")
    parser.add_argument("--port", type=int, default=11435)
    parser.add_argument("--upstream", default="http://localhost:11434")
    args = parser.parse_args()
    UPSTREAM = args.upstream
    log_debug(f"proxy start ::{args.port} -> {UPSTREAM} num_ctx={DEFAULT_NUM_CTX} timeout={UPSTREAM_TIMEOUT}")
    uvicorn.run(app, host="127.0.0.1", port=args.port, log_level="warning")
