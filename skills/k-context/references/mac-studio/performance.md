# Mac Studio — Performance by Modality

> Status: REFERENCE · Last updated: 2026-04-02 · [CLAUDE + GEMINI cross-validated]
> Configuration: M4 Max 128GB | BW=546 GB/s

## Speed Perception Thresholds

| Range | User experience |
|-------|----------------|
| >30 tok/s | Instant — pre-generation complete sensation |
| 15-30 tok/s | Fluent — faster than human reading speed |
| 8-15 tok/s | Comfortable — visible streaming, acceptable |
| 3-8 tok/s | Slow — perceptible, frustrating for live chat |
| <3 tok/s | Very slow — batch processing only |

Human reading speed: ~4 words/sec = 4 tok/s.

---

## TEXT / REASONING

### Local vs Cloud

| Setup | Model | Tok/s | User feel |
|-------|-------|-------|-----------|
| **Mac local** | 8B Q4 | ~87 | ⚡ Ultra-fast |
| **Mac local** | 70B Q4 | ~13 | ✅ Fluent |
| **Mac local** | 70B Q8 | ~8-12 | ✅ Comfortable |
| Cloud ChatGPT-4o | — | ~60-70 | ⚡ |
| Cloud Claude Sonnet | — | ~60-80 | ⚡ |
| Cloud Gemini 2.5 Pro | — | ~50-70 | ⚡ |

**Gap:** Cloud is 5-8× faster for text streaming. Compensated by: zero cost, zero latency, zero privacy leak.

### Concrete time examples

> "Write a 1000-word expert blog post on quantum physics"
> - GPT-4o: ~15s
> - Mac 70B Q8: ~45-80s
> - Mac 70B Q4: ~35-60s
> - Mac 8B Q4: ~12s (lower quality)

> "Analyze this 50-page contract, extract key clauses"
> - Cloud: ~20s (but data leaves your machine)
> - Mac 70B Q8: ~90s (fully private)

### Concurrent users (70B Q4, sweet spot)

| Batch | Tok/s/user | Latency 500-tok resp | Feel |
|-------|-----------|---------------------|------|
| 1 | 13 | 38s | ✅ Fluent |
| 2 | 6.5 | 77s | ⚠️ Acceptable |
| 4 | 3.3 | 152s | ❌ Slow |
| 8 | 1.6 | 313s | ❌ Batch only |

→ **Sweet spot: 1-3 simultaneous live users with 70B Q4.**
→ Router pattern (80% → 8B, 20% → 70B): effective 20-30 simultaneous.

---

## IMAGE GENERATION

| Model | Resolution | Mac M4 Max | Midjourney | DALL-E 3 |
|-------|-----------|-----------|-----------|---------|
| SDXL | 1024×1024 | **3-5s** | 30-60s (queue) | 10-15s |
| Flux.1 dev | 1024×1024 | 15-20s | N/A | N/A |
| Flux.1 schnell | 512×512 | ~3s | N/A | N/A |

**Mac wins on latency** — no queue, no rate limit, no cost per image.

> "Generate 50 logo variations overnight"
> - Cloud: rate-limited, costs ~$5-15 in API credits
> - Mac: runs unattended, done in ~15-25 min, $0

**Limitation:** Video-like quality (Midjourney v7) not reachable with SDXL/Flux.1.

---

## VOICE (STT + TTS)

| Task | Model | Mac Speed | Cloud Equivalent |
|------|-------|-----------|-----------------|
| STT | Whisper large-v3 | 1h audio → ~45s | OpenAI Whisper API (+ upload lag) |
| TTS | Kokoro / XTTS v2 | <0.5s latency | ElevenLabs, Azure TTS |
| Live callbot | Whisper + 8B + TTS | ~1s round-trip | Twilio + OpenAI |

**Neural Engine 16-core accelerates Whisper** — 80× realtime factor.
**Callbot pipeline:** Twilio (line) → Whisper (listen) → Llama 8B (reason) → TTS (speak) → <1s total.

---

## VIDEO GENERATION

| Task | Mac M4 Max | Runway Gen-3 | Notes |
|------|-----------|-------------|-------|
| 5s clip, 1024×576 | 2-5 min | ~1 min | Mac 3-5× slower |
| 10s clip | 4-10 min | ~2 min | Batch only on Mac |

**Video gen is NOT interactive on Mac.** Launch and wait — not a competitive use-case for real-time. Usable for overnight batch generation.

---

## RAG / EMBEDDINGS

| Task | Speed | Notes |
|------|-------|-------|
| Index 1000 docs | ~20 min | nomic-embed-text, ChromaDB |
| Q&A over corpus | ~10-30s | depends on LLM + retrieval |
| Run embedding + 70B simultaneously | ✅ Yes | 128GB allows both in RAM |

---

## FINE-TUNING (LoRA / QLoRA)

| Model | Method | RAM | Train speed | Time for 10k samples |
|-------|--------|-----|-------------|---------------------|
| Llama 3.1 8B | QLoRA 4-bit | ~18 GB | ~1500 tok/s | ~1-2h |
| Llama 3.3 70B | QLoRA 4-bit | ~45 GB | ~200 tok/s | ~4-6h |
| Mistral Large 123B | LoRA 8-bit | ~95 GB | ~80 tok/s | ~12-20h |

Full fine-tune from scratch: NOT viable — M4 Max = 54.7 TFLOPS vs H100 = 989 TFLOPS (18× gap).

---

## WHAT CAN'T BE DONE

| Task | Reason | Workaround |
|------|--------|-----------|
| Training from scratch >7B | 18× GPU gap vs H100 | LoRA only |
| Interactive video gen | 3-5 min/clip | Batch overnight |
| Public API >20 rps | BW-limited | Cloud burst or 2nd Mac |
| DS-R1 671B full | Needs 168 GB (Q2) | M3 Ultra or API |
| CUDA-only frameworks | No CUDA on Apple | MLX/MPS (90% coverage) |
