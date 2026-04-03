# Mac Studio — Model Capabilities (M4 Max 128GB)

> Status: REFERENCE · Last updated: 2026-04-02 · [CLAUDE]
> Specs: BW=546 GB/s · RAM_eff=116 GB · EFF=0.85

## Formula

```
tokens/s ≈ (BW_GBs / model_size_GB) × 0.85
model_size_GB = params_B × bytes_per_param[quant]
```

| Quant | Bytes/param | Quality |
|-------|------------|---------|
| FP32  | 4.0        | exact   |
| FP16  | 2.0        | near-lossless |
| Q8_0  | 1.0        | excellent |
| Q6_K  | 0.75       | very good |
| Q5_K_M| 0.625      | good |
| Q4_K_M| 0.5        | good (default) |
| Q2_K  | 0.25       | degraded |

## Mistral Family (all fit on M4 Max 128GB)

| Model | Params | Best Quant | Size GB | Tok/s | Notes |
|-------|--------|-----------|---------|-------|-------|
| Mistral 7B v0.3 | 7B | FP32 | 28 | 16.6 | Classic |
| Codestral Mamba 7B | 7B | FP32 | 28 | 16.6 | 256k ctx, SSM |
| Pixtral 12B | 12B | FP32 | 48 | 9.7 | Vision+text |
| Mistral NeMo 12B | 12B | FP32 | 48 | 9.7 | 128k ctx |
| Codestral 22B | 22B | FP32 | 88 | 5.3 | Code SOTA |
| Mistral Small 3.1 | 24B | FP32 | 96 | 4.8 | Vision, 128k |
| Mixtral 8×7B | 47B | FP16 | 94 | **17.8** | MoE 13B active |
| **Mixtral 8×22B** | 141B | Q6_K | 106 | **15.9** | MoE 39B active — best Mistral |
| Mistral Large 2/3 | 123B | Q6_K | 92 | 5.0 | Dense flagship |

> **Sweet spot:** Mixtral 8×22B Q6_K = 106 GB, ~16 tok/s. Best quality/speed ratio.
> Mistral Large FP16 (246 GB) and Q8 (123 GB) exceed effective RAM — use Q6_K.
> MoE tok/s computed on active params only (sparse routing).

## Other Key Families

| Model | Params | Best Quant | Size GB | Tok/s | Notes |
|-------|--------|-----------|---------|-------|-------|
| Llama 3.2 8B | 8B | FP32 | 32 | 14.5 | Fast router |
| Llama 3.1 8B | 8B | FP32 | 32 | 14.5 | Workhorse |
| Phi-4 14B | 14B | FP32 | 56 | 8.3 | Best compact |
| Llama 3.3 70B | 70B | Q8_0 | 70 | 6.6 | GPT-4 class |
| Qwen 2.5 72B | 72B | Q8_0 | 72 | 6.4 | SOTA coding |
| DeepSeek-R1 70B | 70B | Q8_0 | 70 | 6.6 | Reasoning |
| Mistral Large Q6 | 123B | Q6_K | 92 | 5.0 | |
| Llama 3.1 405B | 405B | Q2_K | 101 | 4.6 | Degraded |
| DeepSeek-R1 671B | 671B | ❌ NO FIT | 168 (Q2) | — | Needs M3 Ultra |
| Qwen 2.5 235B | 235B | ❌ NO FIT | 118 (Q4) | — | Exceeds 116 GB |

## Quality Benchmarks vs Frontier

| Model | MMLU | HumanEval | MATH | Equivalent |
|-------|------|-----------|------|-----------|
| GPT-4o / GPT-4.1 | 88.7 | 90.2 | 76.6 | Frontier |
| Gemini 2.5 Pro | 90.0 | 88.5 | 91.5 | Frontier |
| Claude Sonnet 4.6 | 88.0 | 89.0 | 89.0 | Frontier |
| **Llama 3.3 70B** | **85.9** | **77.0** | **77.0** | **~GPT-4** |
| Qwen 2.5 72B | 86.0 | 79.7 | 83.1 | ~GPT-4 |
| Phi-4 14B | 84.8 | 82.6 | 70.6 | ~GPT-4 lite |
| Mistral Large | 84.0 | 73.0 | 69.0 | GPT-3.5+ |

**Gap to frontier: ~4-5 MMLU points. Imperceptible for 90% of real tasks.**

## Non-LLM Models

| Model | Task | Speed | vs Cloud |
|-------|------|-------|----------|
| Whisper large-v3 | STT | 1h audio → ~45s | = OpenAI API (no upload lag) |
| Kokoro / XTTS v2 | TTS | <0.5s latency | = ElevenLabs |
| Flux.1 dev Q8 | Image 1024px | ~15-20s | ≈ Midjourney (no queue) |
| SDXL | Image 1024px | ~3-5s | faster than Midjourney |
| CogVideoX / SVD | Video 5s | ~2-5 min | 3-5× slower than Runway |
| nomic-embed-text | Embeddings | ~50 docs/min | local, free |
