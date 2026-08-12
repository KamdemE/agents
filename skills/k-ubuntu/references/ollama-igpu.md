# Ollama (Intel Arc iGPU)

This workstation has Intel Core Ultra 7 155H with Arc Graphics iGPU. Ollama is tuned for this hardware.

## Hardware

| Component | Detail |
|-----------|--------|
| CPU | Intel Core Ultra 7 155H (6P + 8E + 2LP cores) |
| GPU | Arc Graphics iGPU — shared RAM, no discrete VRAM, max 2250 MHz |
| NPU | `/dev/accel/accel0` — available but not used by Ollama directly |
| RAM | 30 GiB total |

## Control Plane

Ollama backend orchestration: `$HOME/Work/AI/ollama/ipex/`

```bash
ollama-ipex start      # Switch to IPEX (Intel Arc GPU) backend
ollama-ipex native     # Switch to native (CPU) backend
ollama-ipex status     # Check current backend
ollama-ipex preload <model>
```

## Performance Tuning

| Variable | Value | Reason |
|----------|-------|--------|
| `OLLAMA_KEEP_ALIVE` | `10m` | Warm cache without pinning RAM |
| `OLLAMA_NUM_GPU` | `999` | Offload all layers to iGPU |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Avoid RAM split (shared VRAM) |
| `OLLAMA_FLASH_ATTENTION` | `1` | Faster attention for long contexts |
| `OMP_NUM_THREADS` | `6` | P-cores only for CPU fallback |
| `mem_limit` | `24g` | Headroom for desktop + editors on 30 GiB |

## Prerequisites

- User in `video` + `render` groups: `sudo usermod -aG video,render $USER`
- Native service management: `sudo systemctl stop ollama && sudo systemctl disable ollama` (stop before switching to IPEX)
- Single endpoint: both backends expose `http://127.0.0.1:11434`

Generic Ollama operations (install, model management, API): **`k-ollama`**
