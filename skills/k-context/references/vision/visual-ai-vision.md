# ScienCurious Lab — The Visual Learning Engine

> Status: ACTIVE · Last updated: 2026-05-02 · [ANTIGRAVITY]
> Mantra: "Enseigner, ce n'est pas remplir un vase, mais allumer une flamme !"
> Context: born from live deck generation session (`.agents/docs/AGENTS.pptx`)
> Related: `vision.md` (general agentic), `performance.md` (hardware benchmarks)

---

## Core Thesis

**Text is the wrong default channel for AI communication.**

The human brain processes visual information 60,000× faster than text (MIT, 2014). 90% of information transmitted to the brain is visual. Yet 99% of current AI interfaces are text-first, with images as decoration.

```
Current paradigm:
  Human → text prompt → AI → text response → Human reads
  (images = optional illustration)

KπX target paradigm:
  Human → concept/voice → AI → visual explanation → Human understands
  (text = annotations, sticky notes, metadata)
```

**One good 30-second animation > infinity of textbooks.**

---

## The Visualization Advantage (Personal)

KπX's natural cognitive strength is the ability to visualize complex systems. Most engineers excel at symbolic abstraction (formulas, code). KπX thinks in spatial representations.

```
Typical engineer:  understands concept → writes it as text/code
KπX:               understands concept → sees it → has it generated

The "sees it" step is the bottleneck for 90% of people.
Not for KπX. The machine only executes what KπX already sees.
```

This makes KπX uniquely positioned to direct visual AI — the creative direction is the hard part, the rendering is now commoditized.

---

## State of the Art — Image Generation (April 2026)

| Rank | Model | Publisher | Type | Quality | Speed | Local? |
|:---:|:---|:---|:---:|:---:|:---:|:---:|
| 1 | **Midjourney v7** | Midjourney | Cloud | 9.5/10 | 10-30s | No |
| 2 | **FLUX.2 [pro]** | Black Forest Labs | Cloud+open | 9.2/10 | 3-10s | Weights avail. |
| 3 | **Nano Banana 2** | Google | Cloud (API) | 9.0/10 | ~5s | No |
| 4 | **DALL-E 3** | OpenAI | Cloud | 8.5/10 | 5-15s | No |
| 5 | **FLUX.2 [dev]** | Black Forest Labs | **Open-source** | 8.8/10 | 15-20s local | **Yes** |
| 6 | **Stable Diffusion 3.5** | Stability AI | **Open-source** | 8.5/10 | 3-5s local | **Yes** |
| 7 | **FLUX.2 [klein]** | Black Forest Labs | Open-source | 8.0/10 | **<1s** | **Yes** |

### Key shifts since 2024

- FLUX.2 achieves best-in-class text rendering (typography in images)
- FLUX.2 [klein] enables sub-second generation — interactive for the first time
- Nano Banana 2 is web-grounded (can reference current events in images)
- Midjourney v7 remains the aesthetic king but is closed-source and Discord/web only

### Mac Studio M4 Max capacity

| Model | RAM | Time/image 1024px | Quality vs cloud |
|:---|:---:|:---:|:---|
| FLUX.2 dev FP16 | 24 GB | 25-35s | ~95% of Nano Banana 2 |
| FLUX.2 dev Q8 | 12 GB | 15-20s | ~90-95% |
| FLUX.2 schnell | ~6 GB | ~3s | 75-80% (draft quality) |
| FLUX.2 klein | ~4 GB | <1s | 70-80% (interactive viable) |
| SDXL | ~7 GB | 3-5s | 70-80% |

---

## State of the Art — Video Generation (April 2026)

| Rank | Model | Publisher | Max res | Max dur | Audio | Open? | Cost |
|:---:|:---|:---|:---:|:---:|:---:|:---:|:---|
| 1 | **Runway Gen-4.5** | Runway | 1080p | **60s** | Yes | No | $20/mo |
| 2 | **Sora 2** | OpenAI | 1080p | 25s | Dialogue | No | $20/mo |
| 3 | **Veo 3.1** | Google | **4K** | 15s | Lip-sync | No | $0.15/s |
| 4 | **Kling 3.0** | Kuaishou | 4K 60fps | 15s | Multi-lang | No | $10/mo |
| 5 | **Seedance 2.0** | ByteDance | 2K | 15s | Dual-ch | No | API |
| 6 | **Wan 2.6** | Alibaba | 1080p | 15s | Yes | **Yes** | **Free** |
| 7 | **LTX-2** | Lightricks | 720p | 10s | No | **Yes** | **Free** |

### Wan 2.6 on Mac Studio (via Wan2mac)

| Variant | RAM | 5s 720p | 5s 1080p | Quality |
|:---|:---:|:---:|:---:|:---|
| Wan 2.6 1.3B | 6 GB | ~1-2 min | ~2-4 min | Correct |
| **Wan 2.6 14B** | ~25 GB | ~3-5 min | ~5-10 min | **Good** (tops VBench) |

### Open-source convergence projection

```
2024 Q4:  Flux.1 dev → 80% of DALL-E 3
2025 Q2:  CogVideoX, Wan2.1 → 60% of Sora
2025 Q4:  Flux.2, Hunyuan v2 → 90% of DALL-E 3
2026 Q1:  LTX-2, Wan2.6 → 75% of Sora
2026 H2:  (projected) Video models <30s/clip on Apple Silicon
2027:     Image parity local/cloud, video at ~90%
```

---

## NotebookLM — The Gold Standard for AI-Generated Presentations

### How it works

NotebookLM produces presentation PDFs where each slide is a single AI-generated image (not text+shapes). This eliminates alignment, font, and styling issues entirely.

```
NotebookLM Pipeline:

  Sources (PDF, Docs, URLs, audio)
      │
      ▼
  Gemini 3.1 Pro (1M token context)
  → Full document ingestion (no chunking)
  → Identifies themes, structures slides
  → Source grounding: inline citations
      │
      ▼
  Nano Banana Pro (Gemini Flash Image)
  → Each slide = one complete rendered image
  → Style applied globally (Heritage, Anime, Whiteboard...)
  → Text, diagrams, formulas rendered IN the image
      │
      ▼
  PDF assembly (60-90 seconds total)
```

### Why it looks so good

| Factor | Explanation |
|:---|:---|
| No RAG chunking | 1M token window → entire document in context, zero information loss |
| Source grounding | Every claim anchored to source passages → no hallucination |
| Slide = single image | No text+shape assembly → no alignment bugs, perfect composition |
| Global style enforcement | Style applied at generation time, not post-hoc theming |
| Gemini plans, Nano Banana renders | Clean separation: LLM structures, image model executes |

### What NotebookLM can't do (and KπX can)

| Capability | NotebookLM | KπX local pipeline |
|:---|:---:|:---:|
| Editable output | No (image-locked) | **Yes** (python-pptx) |
| Sovereignty / privacy | Cloud (Google) | **100% local** |
| Custom styles (unlimited) | 6 presets | **LoRA custom** |
| Video / animation | No | **Wan 2.6** |
| Audio narration | Podcast only | **Kokoro TTS per-slide** |
| Cost per deck | API / subscription | **$0** |
| Regeneration freedom | Rate-limited | **Unlimited** |

---

## The Education Game-Changer Thesis

### Problem

The world's best explanations are locked behind individual YouTubers who happen to be both domain experts AND visual storytellers. The supply of high-quality visual education is:

- **Scarce** — few people combine domain expertise + visual communication talent
- **Expensive** — a single 3Blue1Brown video takes weeks/months
- **Static** — once published, can't be customized per learner
- **Language-locked** — mostly English

### KπX's proposed solution

**Automated visual explanation pipeline:**

```
Input:  concept (text, voice, or reference paper)
    │
    ▼
LLM decomposes into pedagogical scenes
    │   (e.g., "Transformers" → 6 progressive steps:
    │    tokenization → embedding → self-attention →
    │    multi-head → feed-forward → output)
    │
    ├──────────────────────────────────────────┐
    │                                          │
    ▼                                          ▼
FLUX.2 dev (static diagrams)          Wan 2.6 14B (5s animations)
    ~20s/image                             ~3-5 min/clip
    │                                          │
    └──────────┬───────────────────────────────┘
               │
               ▼
        Kokoro TTS (narration, <1s latency)
               │
               ▼
        ffmpeg / python-pptx (assembly)
               │
               ▼
Output: 30s explainer video or 10-slide visual deck

TOTAL: ~20-25 min for 30s of visual education
       (vs days/weeks for a human creator)
```

### Concrete benchmarks on Mac Studio

| Output type | Models used | RAM | Time | Cost |
|:---|:---|:---:|:---:|:---:|
| 10 pedagogical diagrams | FLUX.2 dev | 24 GB | ~3 min | $0 |
| 7-slide deck (our `.agents/` example) | FLUX.2 dev | 24 GB | ~2 min | $0 |
| 30s explainer (6 clips + narration) | Wan 2.6 + FLUX.2 + Kokoro | 50 GB | ~20-25 min | $0 |
| 50 logo variations | FLUX.2 schnell | 6 GB | ~2.5 min | $0 |
| Interactive "sticky notes" | FLUX.2 klein | 4 GB | **<1s each** | $0 |

### What makes this different from "just using Midjourney"

```
Midjourney/DALL-E:
  → Generates beautiful images
  → No pedagogical structure
  → No scene decomposition
  → No animation
  → No narration
  → No assembly pipeline
  → Pay per image

KπX pipeline:
  → LLM understands the CONCEPT and decomposes it
  → Each visual is part of a PROGRESSION
  → Static + animated + narrated = complete explanation
  → Assembled automatically into a deliverable
  → Zero marginal cost
  → Runs 24/7 unattended
```

---

## The "Visual-First AI Interface" Long-Term Vision

### Beyond presentations — towards a visual communication protocol

The ultimate goal is not "generate presentations faster." It is to change the **default communication channel** between human and AI:

```
TODAY:         Human ←── text ──→ AI
                        (images = decoration)

NEAR FUTURE:   Human ←── visual ──→ AI
                        (text = sticky notes / annotations)

LONG TERM:     Human ←── spatial/interactive ──→ AI
                        (text = metadata layer)
```

### The three horizons

| Horizon | Timeline | Description | Mac Studio role |
|:---|:---|:---|:---|
| **H1: Batch visual** | Now–6 months | Generate decks, diagrams, short clips on demand | Primary compute |
| **H2: Interactive visual** | 6–18 months | <1s image gen inline during conversation (FLUX.2 klein) | Primary compute |
| **H3: Spatial studio** | 18–36 months | Non-linear thinking board with embedded visual gen | Compute substrate |

### H1 (Now): already proven

The `.agents/docs/AGENTS.pptx` deck — 7 slides with AI-generated visuals, assembled in <5 min — is prototype zero.

### H2 (6-18 months): interactive "visual sticky notes"

With FLUX.2 klein (<1s per image), the AI can generate a visual FOR EVERY RESPONSE:
- User asks about Transformer architecture → AI responds with diagram + 2 sentences
- User asks about Docker networking → AI responds with topology visual + annotation
- Every concept gets a visual, automatically, in real-time

This shifts image from "expensive illustration" to "default output format."

### H3 (18-36 months): Thought Studio

The spatial board environment described in `vision.md` — but now with visual gen as a first-class primitive:
- Each card on the board can contain AI-generated visuals
- Branching explorations generate visual diffs
- The knowledge graph is navigable spatially AND visually
- Export any branch as a video, deck, or article

---

## Honest Limitations & Risks

| Risk | Severity | Mitigation |
|:---|:---:|:---|
| AI images are aesthetically stunning but pedagogically shallow | **High** | Hybrid pipeline: AI generates, KπX curates and corrects |
| Text in AI-generated images is sometimes incorrect | Medium | FLUX.2 has best-in-class text rendering; validate critical labels |
| Video generation is batch-only (2-5 min/clip) | Medium | Pre-generate overnight; interactive video waits for 2027+ models |
| Thought Studio is a multi-year R&D project | High | Start with H1/H2 prototypes; let the Studio emerge from usage |
| LoRA fine-tuning for custom styles requires experimentation | Low | Start with stock FLUX.2; add LoRA later when style is defined |

### The "pretty ≠ pedagogical" gap

```
What impresses ≠ what teaches

3Blue1Brown works because:
  1. Each frame is designed for cognitive progression
  2. Animation REVEALS the concept step by step
  3. Visual is minimal — no aesthetic noise
  4. Timing calibrated on human cognitive load

AI-generated visuals:
  1. Aesthetically striking
  2. Often overloaded
  3. No pedagogical progression (unless LLM-directed)
  4. Text in image sometimes decorative, not informative

SOLUTION: LLM directs the pedagogy, image model executes.
The creative DIRECTION is KπX's value-add, not the rendering.
```

---

## Competitive Landscape

| Player | Approach | Threat level |
|:---|:---|:---:|
| **NotebookLM** (Google) | Best slide gen today, but cloud-only, non-editable, 6 styles | Medium |
| **Gamma.app** | AI presentation builder, templates, cloud | Low (shallow) |
| **Beautiful.ai** | Design automation, no deep AI | Low |
| **Canva AI** | Mass-market, no source grounding | Low |
| **tldraw/make-real** | Spatial + generative, closest to H3 vision | Medium (open-source ally) |
| **Fermat.ws** | Spatial AI canvas, closest conceptual match | Medium |

**KπX differentiators:** sovereignty, editability, unlimited styles, video+audio, zero marginal cost, pipeline extensibility.

---

## Actionable Next Steps

| Step | When | Description |
|:---|:---|:---|
| 1 | **Now** | Prototype "concept → 5 images + 1 video" pipeline on homelab (SDXL/Ollama) |
| 2 | **Now** | Test NotebookLM with `.agents/AGENTS.md` as source to calibrate the quality gap |
| 3 | **Now** | Explore Gemini API + Nano Banana 2 (free tier) for cloud baseline |
| 4 | **Mac arrives** | Day 1: install Ollama + FLUX.2 dev + Wan2mac + Kokoro |
| 5 | **Week 1** | Generate first fully-local 30s explainer video |
| 6 | **Month 1** | First LoRA fine-tune for a consistent KπX visual style |
| 7 | **Month 3** | Evaluate ComfyUI as orchestration layer for multi-model pipelines |
| 8 | **Month 6** | First "interactive visual sticky note" prototype (FLUX.2 klein) |

---

## References

| Source | Relevance |
|:---|:---|
| `performance.md` | Hardware benchmarks for image/video gen on M4 Max |
| `vision.md` | General agentic philosophy and Thought Studio concept |
| `models.md` | LLM model capabilities and RAM budget |
| `stack.md` | Technical stack (Ollama, Open-WebUI, ComfyUI TBD) |
| `.agents/docs/AGENTS.pptx` | Prototype zero — 7-slide deck generated in this session |
| 3Blue1Brown / Manim | Gold standard for math visualization (open-source engine) |
| tldraw/make-real | Spatial canvas + AI generation (open-source, H3 reference) |
| Fermat.ws | Commercial spatial AI canvas (conceptual reference) |
| Wan2mac (GitHub) | Wan 2.6 on Apple Silicon implementation |
