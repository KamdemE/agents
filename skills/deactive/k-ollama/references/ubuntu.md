# k-ollama — Ubuntu

> **OS reference:** Ubuntu (native)
> **Applies to:** `k-ubuntu` (kpihx-ubuntu workstation)

---

## Installation

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

## Service Management

Ollama runs as a systemd service on Ubuntu:

```bash
sudo systemctl status ollama
sudo systemctl stop ollama
sudo systemctl start ollama
sudo systemctl restart ollama
sudo journalctl -u ollama -f
```

## Model Storage

| Path | Purpose |
|------|---------|
| `/usr/share/ollama/.ollama/` | Native/system Ollama model store |
| `~/.ollama-ipex/` | IPEX (Intel Arc) model store |

Both backends expose the same endpoint: `http://127.0.0.1:11434`

## Environment & Groups

For GPU access, the user must be in `video` and `render` groups:
```bash
sudo usermod -aG video,render $USER
```

## IPEX Optimization & CLI Tool (`ollama-ipex`)

On this machine (`kpihx-ubuntu`), an Intel GPU (Intel Arc iGPU) is active. To execute Ollama with hardware acceleration, KπX uses the **`ollama-ipex`** wrapper CLI (installed as a `uv` global tool).

### Commands & Orchestration
The `ollama-ipex` (or `ipex`) command manages the containerized IPEX backend:
*   `ollama-ipex start` — Launches the IPEX-backed Ollama Docker container on the native endpoint (`http://127.0.0.1:11434`).
*   `ollama-ipex down` — Stops the IPEX container and the native Ollama service.
*   `ollama-ipex native` — Stops the IPEX container and switches the API back to native host Ollama.
*   `ollama-ipex status` — Displays the active backend state and defaults.
*   `ollama-ipex logs` — Displays the recent logs of the IPEX container.
*   `ollama-ipex doctor` — Runs a diagnostic check on the runtime.

### Data Storage
*   IPEX-specific model files and caches are stored in `~/.ollama-ipex/` to isolate them from native host Ollama storage (`/usr/share/ollama/.ollama/`).
