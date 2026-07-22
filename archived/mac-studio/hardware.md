# Mac Studio — Hardware Decision

> Status: DECIDED · Last updated: 2026-04-02 · [CLAUDE]

## Chosen Configuration

| Spec | Value | Notes |
|------|-------|-------|
| Chip | M4 Max | 16-core CPU, 40-core GPU, 16-core Neural Engine |
| RAM | 128 GB unified memory | Sweet spot — fits all major open models |
| Storage (internal) | 1 TB SSD | Minimal — OS + hot models only |
| Storage (external) | **4 TB NVMe TB4** | MANDATORY — ~350€, Acasis/ZikeDrive + WD Black |
| Price (edu) | **3 981.50€** | + ~350€ external SSD = **~4 331€ total** |

## Key Specs

| Metric | M4 Max 128GB | M3 Ultra 256GB | Ratio |
|--------|-------------|----------------|-------|
| Memory bandwidth | **546 GB/s** | 819 GB/s | 1.50x |
| GPU TFLOPS FP16 | **54.7** | 43.6 | M4 Max wins |
| RAM | 128 GB | 256 GB | 2× |
| Price | 3 982€ | 13 661€ | **3.43×** |
| Price/GB RAM | 31€ | 53€ | M4 Max wins |
| SSD | 1 TB | 16 TB | — |

**Why M4 Max and not M3 Ultra:**
- 3.43× cheaper for 1.5× bandwidth → M4 Max wins on price/perf
- M4 Max GPU TFLOPS FP16 (54.7) > M3 Ultra (43.6) — compute tasks faster
- 128 GB fits all models up to Mixtral 8×22B Q6 and Mistral Large Q6
- M3 Ultra only needed for DS-R1 671B full or teams >10 simultaneous users

**Why NOT 1 TB internal only:**
- macOS + apps ~12 GB OS overhead
- Single 70B Q8 model = 70 GB
- 1 TB fills in 1-2 months of experimentation
- External TB4 NVMe: ~3 GB/s read → loads 70B in ~15s → zero inference speed impact once in RAM

**Apps Pro (+229€): DO NOT BUY** — useless for AI workloads.

## Effective RAM Budget

```
128 GB physical
-  12 GB  macOS overhead
= 116 GB effective

Multi-model hot stack:
   4 GB  Llama 3.1 8B Q4      ← router/fast
  36 GB  Qwen 2.5 72B Q4      ← main LLM
  44 GB  Codestral 22B FP16   ← code
   1.5 GB Whisper large-v3    ← STT
   1 GB  Kokoro/XTTS v2       ← TTS
   0.5 GB nomic-embed-text    ← RAG
  12 GB  Flux.1 dev Q8        ← image
─────────────────────────────
 100 GB  total loaded
  16 GB  free for KV cache    ← ~12 sessions × 4k ctx
```
