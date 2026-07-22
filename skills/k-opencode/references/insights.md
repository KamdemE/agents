# k-opencode Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- **2026-05-30 — Terminal-as-Consciousness:** Agent can observe and act upon itself using `tmux send-keys` (effector) + `capture-pane` (sensor). This enables a closed proprioceptive loop: write → capture → read → process → write. Full exploration documented in `references/terminal-consciousness.md`. Key practical finding: opencode requires double Enter (`Enter Enter`) via `send-keys` to submit queued text as a message.
- Initial baseline created automatically from insights governance standard.
- OpenCode install script can add PATH in `.zshrc`, but KπX runtime needs `.kshrc` as source of truth for cross-agent shell consistency.
- OpenCode `mcp` local servers require `type: "local"` and a `command` array (not `command`/`args` object shape used by some other runtimes).
- Browser automation MCPs in OpenCode should use local server ids `browser` and `playwright` with commands `browser-mcp-stdio` / `playwright-mcp-stdio` for parity with KπX runtime docs.
- OpenClaw secrets model: `openclaw.json` uses `{env:VAR_NAME}` refs; `models.json` providers use plain UPPER_CASE env var names (e.g. `"apiKey": "HF_TOKEN"`). The codex provider is special — its `apiKey` is an OAuth binary profile name (`codex-app-server`), not a real secret. OpenClaw's `secrets audit` will always flag it as a provider-specific false positive because codex uses OAuth device code flow. Store OAuth binary names in `gateway.env` for systemd resolution, not via env refs.
- `gateway.env` (loaded by systemd via `EnvironmentFile`) is the KπX-standard location for OpenClaw gateway env vars. It contains actual plaintext API keys. This is by design — systemd `EnvironmentFile` provides process-level isolation. Do not try to move these to OpenClaw's `secrets.providers` unless a specific compaction need arises.
- **OpenCode Web health check with password:** When `OPENCODE_SERVER_PASSWORD` is set, the `/global/health` endpoint returns HTTP 401 (not 200). The systemd `ExecStartPost` health check must accept both 200 and 401: `case "$code" in 200|401) exit 0;; esac`. Without this, the service will fail to start even though opencode is running correctly.
- **Tailscale serve persistence:** Do not use `ExecStopPost` to tear down `tailscale serve` on service stop. If the service crashes and restarts, there's a window where the serve is down and the URL is unreachable. Let the serve persist — it will automatically reconnect when opencode comes back up. The serve config survives service restarts and only needs manual cleanup if you permanently disable the service.
- **2026-07-06 — Whisper model management for @renjfk/opencode-voice:** Models go in `~/.local/share/whisper-cpp/` as `ggml-*.bin` files. The plugin auto-discovers them — no config change needed after adding/removing. Small models are 466MB (same size for EN-only and multilingual — different weights, not compression). Download via `wget` from `https://huggingface.co/ggerganov/whisper.cpp/resolve/main/`. Created `references/voice.md` as single source of truth for all STT/TTS model management documentation.
