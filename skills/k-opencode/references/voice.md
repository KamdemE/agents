# Voice — STT/TTS via @renjfk/opencode-voice

## Overview

Plugin `@renjfk/opencode-voice` enables **Speech-to-Text** (Whisper) and
**Text-to-Speech** (Piper) directly in the TUI. All processing is local —
no external API calls.

## Configuration

Defined in `~/.config/opencode/tui.json` (not `opencode.jsonc`):

```jsonc
{
  "$schema": "https://opencode.ai/tui.json",
  "plugin": [["@renjfk/opencode-voice", {}]]
}
```

Optional LLM endpoint for normalization (skipped if omitted → raw whisper text):

```jsonc
{
  "plugin": [["@renjfk/opencode-voice", {
    "endpoint": "https://api.anthropic.com/v1",
    "model": "claude-haiku-4-5",
    "apiKeyEnv": "ANTHROPIC_API_KEY"
  }]]
}
```

## Dependencies

| Tool | Role |
|------|------|
| `sox` | Audio capture (mic → wav) |
| `whisper-cli` | STT inference (Vulkan GPU build) — wrapped by `k-whisper` |
| `piper` | TTS inference (C++ build) — wrapped by `k-piper` |
| `ffplay` / `mpv` | Audio playback |
| `wget` / `curl` | Model download |

## Whisper Models — Install & Manage

All models stored in `~/.local/share/whisper-cpp/`. The plugin discovers them
automatically from this directory — no config update needed after adding a model.

### Download a model

```bash
# Small English (466 MB, 244M params, english-only)
wget -P ~/.local/share/whisper-cpp/ \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin

# Small Multilingual (466 MB, 244M params, 100+ languages)
wget -P ~/.local/share/whisper-cpp/ \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin

# Large v3 Turbo Q5 (548 MB, 809M params, multilingual, recommended)
wget -P ~/.local/share/whisper-cpp/ \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin
```

### Available models

| Filename | Params | Langs | Size | Quality | Speed |
|----------|--------|-------|------|---------|-------|
| `ggml-tiny.en.bin` | 39M | EN | 75 MB | ⭐⭐ | 🚀🚀🚀🚀🚀 |
| `ggml-tiny.bin` | 39M | 100+ | 75 MB | ⭐⭐ | 🚀🚀🚀🚀🚀 |
| `ggml-base.en.bin` | 74M | EN | 142 MB | ⭐⭐⭐ | 🚀🚀🚀🚀 |
| `ggml-base.bin` | 74M | 100+ | 142 MB | ⭐⭐⭐ | 🚀🚀🚀🚀 |
| `ggml-small.en.bin` | 244M | EN | 466 MB | ⭐⭐⭐⭐ | 🚀🚀🚀 |
| `ggml-small.bin` | 244M | 100+ | 466 MB | ⭐⭐⭐⭐ | 🚀🚀🚀 |
| `ggml-large-v3-turbo-q5_0.bin` | 809M | 100+ | 548 MB | ⭐⭐⭐⭐⭐ | 🚀🚀🚀 |

### Remove a model

```bash
rm ~/.local/share/whisper-cpp/ggml-small.en.bin
```

### Switch model at runtime

In the TUI, press `/stt-model` and select from the dialog. No restart needed.

### Verify model works

```bash
whisper-cli -m ~/.local/share/whisper-cpp/ggml-small.bin -f test.wav
```

## Piper TTS Voices

All voices stored in `~/.local/share/piper-voices/`. Plugin discovers `.onnx`
files + matching `.json` configs automatically.

### Download voices

```bash
# English — Ryan (high quality, male)
wget -P ~/.local/share/piper-voices/ \
  https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/ryan/medium/en_US-ryan-medium.onnx
wget -P ~/.local/share/piper-voices/ \
  https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/ryan/medium/en_US-ryan-medium.onnx.json

# French — Siwis (medium, female)
wget -P ~/.local/share/piper-voices/ \
  https://huggingface.co/rhasspy/piper-voices/resolve/main/fr/fr_FR/siwis/medium/fr_FR-siwis-medium.onnx
wget -P ~/.local/share/piper-voices/ \
  https://huggingface.co/rhasspy/piper-voices/resolve/main/fr/fr_FR/siwis/medium/fr_FR-siwis-medium.onnx.json
```

### Switch voice at runtime

Press `/tts-voice` and select from the dialog.

## Patches (re-apply after plugin update)

Located in the plugin's cache directory (under `node_modules` of the TUI).
After `npm update` or plugin upgrade, these must be re-applied:

- `stt.js` L385: `ctrl+r` → `<leader>r` (avoid TUI rename conflict)
- `stt.js` L339: remove `toast("Normalizing...")` notification
- `tts.js` L266: `llmResult.text || result.text` fallback
- `tts.js` L298: same fallback for manual speak
- `tts.js` L312: `<leader>s` keybind
- `tts.js` TTS_VOICES: add `siwis` (FR) entry

## Commands

| Command | Keybind | Description |
|---------|---------|-------------|
| `/stt-record` | `<leader>r` | Start/stop recording |
| `/stt-submit` | `<leader>R` | Stop, transcribe & submit |
| `/stt-stop` | — | Cancel recording |
| `/stt-model` | — | Select whisper model |
| `/stt-mic` | — | Select microphone |
| `/tts-speak` | `<leader>s` | Speak selected/typed text |
| `/tts-auto` | `<leader>v` | Toggle auto TTS after each response |
| `/tts-stop` | `Escape` | Stop audio playback |
| `/tts-voice` | — | Select TTS voice |
| `/tts-speed` | — | Adjust speech rate |

## STT API (optional, remote Whisper)

Instead of local `whisper-cli`, use an OpenAI-compatible endpoint:

```jsonc
{
  "plugin": [["@renjfk/opencode-voice", {
    "sttEndpoint": "http://127.0.0.1:8000/v1",
    "sttModel": "whisper-large-v3-turbo",
    "sttApiKeyEnv": "MY_STT_API_KEY"
  }]]
}
```

- `/stt-model` fetches available models from the endpoint's `/models` listing
- Supports OpenRouter JSON/base64 transcription format automatically when
  `sttEndpoint` points at `https://openrouter.ai/api/v1`

## Installed models (current)

### Whisper
| Model | File | Size |
|-------|------|------|
| Large v3 Turbo Q5 | `ggml-large-v3-turbo-q5_0.bin` | 548 MB |
| Small English | `ggml-small.en.bin` | 466 MB |
| Small Multilingual | `ggml-small.bin` | 466 MB |

### Piper
| Voice | Lang | Quality |
|-------|------|---------|
| Ryan (Medium) | EN-US | High |
| Siwis (Medium) | FR-FR | Medium |

## Web UI Voice Input (via opencode-web-voice)

The Web UI voice input provides a browser-based speech-to-text integration using the native **Web Speech API** of Chrome or Edge. It is injected into the OpenCode Web UI via the `opencode-lens` proxy.

### Architecture

1.  **Backend Proxy (`opencode-lens`):** Intercepts traffic to the native OpenCode web server, strips the Content-Security-Policy (CSP) headers, and injects the frontend script.
2.  **Frontend Plugin (`opencode-web-voice`):** Injected into the browser DOM to mount a microphone button and language selector next to the composer text field.
3.  **Speech Engine:** Uses the browser's built-in Web Speech API (online recognition via browser vendor cloud, e.g., Google cloud for Chrome).

### Language Configuration

Since OpenCode forces `<html lang="en">` on the DOM, the browser would normally lock recognition to English. The plugin implements a priority-based language resolution:

1.  **Explicit developer override:** `window.__opencodeVoiceLang` (e.g. set via console).
2.  **User choice:** Persisted in `localStorage` under the key `opencodeWebVoiceLang` (options: `auto`, `en-US`, `fr-FR`).
3.  **Browser locale:** `navigator.language` if it is a non-English language (e.g. `fr-FR` on a French OS browser).
4.  **Fallback:** Defaults to `en-US` if all else is unset.

A small dropdown selector is visible next to the microphone icon in the UI to easily cycle or select:
-   **Auto:** Auto-detects language using the browser locale (ideal if the browser is configured in your preferred language).
-   **EN:** Forces English speech recognition.
-   **FR:** Forces French speech recognition.

Your selected preference is automatically saved in `localStorage` and persists across page reloads.

### Setup and Running

To run the Web Voice integration, ensure the `opencode-lens` service is running and Tailscale routes port `2443` to it.

```bash
# Verify systemd service status
systemctl --user status opencode-lens

# Verify Tailscale serve status
tailscale serve status
```

The native web interface remains accessible on port `1443` (proxying to port `4097`), while the Lens proxy version is exposed on port `2443` (proxying to port `3000`).
