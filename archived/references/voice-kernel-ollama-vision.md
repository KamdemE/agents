# Voice Kernel — Ollama Vision

**Status:** Brainstorm
**Date:** 2026-05-31
**Author:** KpihX

## Problem

The voice module (STT + TTS) is currently coupled to OpenCode via `@renjfk/opencode-voice` (TUI-only plugin). It cannot be used by other agent runtimes (Codex, Cline, Copilot, Gemini CLI, Vibe) without duplicating the setup. Each agent has its own plugin system, and voice is reimplemented per runtime.

## Goal

Centralize STT/TTS as a **sovereign cross-agent module** at the Oriyama level — a single voice kernel that any agent runtime can consume via a standard interface (HTTP API, MCP tool, or CLI bridge).

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Oriyama Voice Kernel                │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌───────────────┐  │
│  │ STT      │  │ TTS      │  │ Language      │  │
│  │ Engine   │  │ Engine   │  │ Router        │  │
│  │          │  │          │  │               │  │
│  │ whisper  │  │ piper    │  │ detect lang → │  │
│  │ .cpp     │  │ ONNX     │  │ route voice   │  │
│  │ (Vulkan  │  │          │  │               │  │
│  │  GPU)    │  │          │  │               │  │
│  └────┬─────┘  └────┬─────┘  └───────┬───────┘  │
│       │              │                │           │
│  ┌────▼──────────────▼────────────────▼───────┐  │
│  │          HTTP API (localhost:PORT)          │  │
│  │  POST /stt   ← audio/wav → text           │  │
│  │  POST /tts   ← text → audio/wav           │  │
│  │  GET  /lang  ← detected language          │  │
│  │  GET  /voices ← available voices          │  │
│  └────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
         │              │              │
    ┌────▼────┐   ┌────▼────┐   ┌────▼────┐
    │ OpenCode│   │ Codex   │   │ Cline   │
    │ (TUI)   │   │ (CLI)   │   │ (VSCode)│
    └─────────┘   └─────────┘   └─────────┘
```

## Models (all local, no API)

| Component | Model | Size | RAM | Backend |
|-----------|-------|------|-----|---------|
| **STT** | ggml-large-v3-turbo-q5_0.bin | 548 MB | ~1.5 GB | whisper.cpp (Vulkan GPU) |
| **TTS EN** | en_US-ryan-high.onnx | 116 MB | ~150 MB | piper ONNX |
| **TTS FR** | fr_FR-siwis-medium.onnx | 61 MB | ~100 MB | piper ONNX |
| **LLM (optional)** | Ollama qwen3 / qwen2.5-coder | varies | 2-4 GB | Ollama (local, already running) |

## Interface for agent runtimes

### Option A: HTTP API (recommended)
The voice kernel runs as a persistent service. Any agent calls `POST /stt` and `POST /tts`.

### Option B: MCP Server
Expose STT/TTS as MCP tools. OpenCode, Codex, Cline all support MCP natively.

### Option C: CLI bridge
`voice-stt < audio.wav` → text to stdout. `echo "text" | voice-tts` → audio to stdout.

## Current state (OpenCode-only)

- `@renjfk/opencode-voice` — TUI plugin, uses sox + whisper-cli + piper directly
- Works but tightly coupled to OpenCode's plugin API (`api.tui`, `api.kv`, `api.command`)
- Patches in cache (keybinds, fallbacks) are fragile — lost on plugin update

## Next steps

1. Extract STT engine into standalone HTTP server (whisper-cli already has `whisper-server`)
2. Extract TTS engine into standalone HTTP server (piper + simple HTTP wrapper)
3. Add language auto-detection + voice routing
4. Expose as MCP server for agent-agnostic access
5. Document resource requirements per platform
