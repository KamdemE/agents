# Mac Studio — Technical Stack

> Status: REFERENCE · Last updated: 2026-04-02 · [CLAUDE + GEMINI]
> Target: Day-1 operational after delivery (~16-18 weeks wait)

---

## Inference Layer

| Tool | Role | Notes |
|------|------|-------|
| **Ollama** | Model serving (primary) | OpenAI-compatible API, MLX backend |
| **mlx-lm** | Fast MLX inference | Lower-level, better for benchmarking |
| **llama.cpp** | Fallback / GGUF models | Most universal compatibility |

**Ollama endpoints:**
- `http://localhost:11434/v1` — OpenAI-compatible
- All tools (Open-WebUI, n8n, LangChain) connect here

---

## Interface Layer

| Tool | Role | Notes |
|------|------|-------|
| **Open-WebUI** | Chat UI for users | Multi-user, auth, RAG built-in |
| **Dify.ai** | Workflow builder (visual) | Good for non-technical clients |
| **Continue.dev** | IDE integration (VSCode/JetBrains) | Connects to local Ollama |

---

## Orchestration Layer

| Tool | Role | Notes |
|------|------|-------|
| **n8n** | Workflow automation | Email, CRM, API integrations |
| **LangChain / LlamaIndex** | Agent frameworks | Python, RAG pipelines |
| **Celery + RabbitMQ** | Async task queue | Scale to 300-500+ async clients |

---

## Memory & Storage Layer

| Tool | Role | Notes |
|------|------|-------|
| **ChromaDB** | Vector store | Local, embedded, fast |
| **LanceDB** | Vector store (alternative) | Already used in k-ai |
| **SQLite** | Session/metadata storage | Zero-config |
| External 4TB TB4 | Model zoo + logs | ~3 GB/s read, loads 70B in ~15s |

---

## Access Layer

| Tool | Role | Config |
|------|------|--------|
| **Tailscale** | Secure access everywhere | MagicDNS: `mac-studio.kpihx-labs.com` |
| **Cloudflare Tunnel** | Public HTTPS (no port forwarding) | Alternative if Tailscale not available |
| **Traefik** | Reverse proxy (if multi-service) | Same as homelab pattern |

---

## Voice Pipeline (Callbot)

```
Twilio (phone) → webhook → n8n
  → Whisper large-v3 (STT, ~1s for 10s audio)
  → Llama 3.1 8B (decision, ~0.5s)
  → Kokoro TTS (speech, ~0.3s)
  → Twilio (response audio)
Total latency: ~2-3s ← acceptable for phone
```

---

## Docker Compose Skeleton

```yaml
services:
  ollama:
    image: ollama/ollama
    volumes:
      - /Volumes/ModelZoo:/root/.ollama  # external SSD mount
    environment:
      - OLLAMA_HOST=0.0.0.0
    
  open-webui:
    image: ghcr.io/open-webui/open-webui
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
    depends_on: [ollama]
    
  n8n:
    image: n8nio/n8n
    volumes:
      - n8n_data:/home/node/.n8n
    
  chromadb:
    image: chromadb/chroma
    volumes:
      - chroma_data:/chroma/chroma
```

Note: On macOS, Docker does NOT have direct GPU access.
**Run Ollama natively** (not in Docker) to get M4 Max GPU acceleration.
Docker = only for orchestration services (n8n, open-webui, chromadb).

---

## Storage Strategy

```
/           (internal 1TB SSD)
├── macOS + apps         ~50 GB
├── Ollama hot models    ~100 GB  ← 70B Q8 + 8B + Codestral + Whisper
└── Logs / ChromaDB      ~50 GB

/Volumes/ModelZoo/      (external 4TB TB4 NVMe)
├── models/             ← full model zoo (cold storage)
│   ├── mistral/
│   ├── llama/
│   ├── flux/
│   └── ...
├── datasets/           ← fine-tuning data
├── checkpoints/        ← LoRA outputs
└── archives/           ← session logs, exports
```

Load time (external → RAM): 70B Q8 (70 GB) at 3 GB/s = ~23s.
Once in RAM: full 546 GB/s bandwidth — zero difference vs internal.

---

## Monitoring

| Tool | Purpose |
|------|---------|
| Grafana + Prometheus | RAM/CPU/GPU usage dashboard |
| Ollama `/api/ps` | Active models and their RAM usage |
| `htop` / `sudo powermetrics` | Real-time Apple Silicon metrics |

Priority quotas per user (Docker cgroups for non-Ollama services):
- Ollama: no hard limit (uses GPU directly)
- Per-user KV sessions: managed at Ollama/vLLM level via context limits
