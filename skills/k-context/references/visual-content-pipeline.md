# Visual Content Pipeline — Architecture & Reference

> Merged from: `vision/` directory (7 files). Duplicate `vision/visual-ai-vision.md` resolved → canonical content lives in `sciencurious_lab.md`.
> Sources archived: `archived/` (2026-07-22)

---

## 1. Production Stack Decision

```
LLM (script + scene code)
  → Manim (precise math/concept animations)
  → FLUX.2 (hero images, thumbnails, style frames)
  → ffmpeg (assembly + TTS narration)
  → k-publish (multi-platform distribution)
```

Code-as-visual for backbone (precision, speed, editability). Pixel-gen for hero shots only.

---

## 2. Code-as-Visual: Precision-First Generation

### Core Insight
Generate visuals from **code** (fast, precise, editable, interactive) instead of pixels from text prompts (slow, imprecise, non-editable).

```
Pixel-gen: prompt → diffusion model → pixels    (5-30s, no control, one-shot)
Code-gen:  prompt → LLM → code → renderer       (0.1-2s, full control, iterative)
```

### Toolkit Comparison

| Engine | Best For | Speed | Precision | Editability | Interactivity |
|--------|----------|-------|-----------|-------------|---------------|
| **Manim** | Math animations, transforms, graphs | 1-5s/scene | LaTeX-perfect | Full | None |
| **Mermaid** | Flowcharts, sequences, class diagrams | <100ms | Exact | Full | None |
| **D3.js** | Data viz, interactive | <100ms | Exact | Full | Full |
| **HTML/CSS/JS** | Rapid proto, UI mockups | <100ms | Exact | Full | Full |
| **Motion Canvas / Remotion** | Programmatic video | render-time | Exact | Full | None |
| **FLUX.2 / Midjourney** | Hero images, artistic shots | 5-30s | Low (stochastic) | None (regenerate) | None |

### Hybrid Strategy
- **90%** frames: code (Manim + Motion Canvas) — precise, editable, fast
- **10%** frames: pixel-gen (FLUX.2) — hero shots, thumbnails, mood visuals
- Audio: TTS synced to scene timeline

### Why Code Wins for Education
1. **Mathematical correctness** — FLUX.2 hallucinates equations; Manim renders LaTeX perfectly
2. **100-1000x faster** than diffusion for 1-hour videos
3. **Iterative refinement** — change one variable, re-render
4. **Version control** — scenes are `.py` files; diff, branch, merge
5. **Composability** — scenes are functions; build a library

### How the Masters Do It

| Creator | Tools | Time/Video | Team | Key Insight |
|---------|-------|-----------|------|-------------|
| 3Blue1Brown | Manim (custom fork) | 2-8 weeks | Solo | Every animation serves a pedagogical purpose |
| ScienceClic | Blender + AE + Manim | 3-6 weeks | 1-2 | Cinematic quality = documentary feel |
| Morphocular | Manim CE | 2-6 weeks | Solo | Quality comes from composition, not tools |

**KπX advantage:** AI-assisted — LLM generates scenes from description, iterates on errors, targets best engine per scene type.

---

## 3. k-visual: Orchestrator Architecture

`k-visual` routes visual generation requests to the appropriate engine based on content type.

```
k-visual (orchestrator)
├── k-manim      → Manim scene generation (math animations, precise diagrams)
├── k-pptx       → PowerPoint deck generation (EXISTS)
├── k-napkin     → Napkin AI infographics (EXISTS)
├── k-publish    → Social media distribution pipeline (NEW)
├── k-blender    → Blender 3D scenes via MCP (NEW — Phase 4)
└── [pixel-gen]  → FLUX.2 / Midjourney for hero images
```

### Routing Logic

| Content Type | Primary Engine | Fallback | Output |
|-------------|---------------|----------|--------|
| Math animation | k-manim | — | MP4/GIF |
| Concept diagram | Mermaid/D3 | k-napkin | SVG/PNG |
| Infographic | k-napkin | HTML/CSS | SVG/PNG/PPT |
| Presentation deck | k-pptx | — | PPTX/PDF |
| Hero image/thumbnail | FLUX.2 | — | PNG |
| 3D scene | k-blender | — | PNG/MP4 |
| Interactive visual | HTML/CSS/JS | — | HTML |
| Full video episode | ffmpeg assembly | — | MP4 |

### Dependencies

| Component | Status | Where |
|-----------|--------|-------|
| Manim CE | `pip install manim` | Local |
| python-pptx | Installed | Local |
| Napkin AI | API key needed | Cloud |
| FLUX.2 | Mac Studio (future) | Local |
| Blender 5.1+ | Install needed | Local |
| ffmpeg | Installed | Local |

---

## 4. Content Engine: End-to-End Pipeline

```
IDEA → SCRIPT → VISUAL → RENDER → PUBLISH → ANALYTICS
```

### Phase 1: Ideation (15-30 min)
Input: topic, audience, platform, duration → structured brief (YAML)

### Phase 2: Script Generation (30-60 min)
Input: brief → scene-by-scene breakdown with narration + visual spec (YAML)

### Phase 3: Visual Generation (~5 min)
Per scene routing: Manim (1-5s), Mermaid (<100ms), D3 (<100ms), FLUX.2 (8-15s), Blender (30s-5min)

### Phase 4: Render & Assembly (~15 min)
1. Manim → MP4 clips
2. FLUX.2 → PNG → Ken Burns clip
3. TTS → narration audio per scene
4. ffmpeg → concatenate + audio + transitions

### Phase 5: Publish (5 min)
k-publish handles multi-platform: YouTube, LinkedIn, X, Meta.

### Timeline Comparison

| Phase | Traditional | KpihX AI-assisted |
|-------|-------------|-------------------|
| Ideation | 1-3 days | 15-30 min |
| Script | 3-7 days | 30-60 min |
| Visual gen | 1-4 weeks | 5-15 min |
| Render | 1-3 days | 15-30 min |
| Publish | 2-4 hours | 5 min |
| **Total** | **2-8 weeks** | **2-4 hours** |

Speedup: **50-100x** for a 10-minute educational video.

### MVP First Video
1. Well-understood topic
2. Manual script + LLM scene gen
3. Manim only (no FLUX/Blender)
4. Basic TTS
5. YouTube only
6. **Target: 1 day** start to published

---

## 5. Blender Scripting Reference

### Approaches

| Approach | Tool | Best for |
|----------|------|----------|
| Python scripting | `bpy` (built-in) | Full control, headless: `blender --background --python script.py` |
| Official MCP | `blender_mcp` (blender.org) | Blender 5.1+, `execute_blender_code`, render, scene inspection |
| Community MCP | `better-blender` | Scene/object/animation/materials/rendering |
| Headless MCP | `cwahlfeldt/blender_mcp` | CI/batch pipelines |

### Security
All MCP servers execute arbitrary Python code. Use isolated environments.

### Priority: Phase 4
Manim + FLUX.2 cover 90% of educational content. Blender adds 3D when topic demands it (spacetime curvature, molecular structures, neural network 3D topology).

---

## 6. Edge Automation Architecture

### Four-Layer Stack

| Layer | Method | Use When |
|-------|--------|----------|
| **A — Fast Path** | Playwright/CDP + extension APIs | Default — deterministic, low latency |
| **B — UI Path** | Accessibility tree + keyboard/mouse | Tab groups/workspaces/system dialogs |
| **C — Vision Path** | Screenshot + VLM + action proposal | Last resort — A/B cannot resolve state |
| **D — Safety Envelope** | Allowlist, dry-run, replay logs, rollback | Always on |

**Target:** 90% DOM/API, 9% accessibility, 1% vision.

### Favorites Management
Recommended: extension bridge + `chrome.bookmarks` API. Alternative: Edge profile `Bookmarks` JSON editing (Edge closed).

### Controlled Execution
1. Action allowlist (domains, operation classes)
2. Dry-run preview
3. Step logs + replay
4. Checkpoint/rollback hooks
5. Timeout + recovery policy (A → B → C escalation)

---

## 7. Social Media APIs Reference

### Platform Matrix

| Platform | Auth | Rate Limit | Free Tier |
|----------|------|------------|-----------|
| YouTube | OAuth 2.0 | 10k units/day | ~6 uploads/day |
| LinkedIn | OAuth 2.0 | 100 calls/day | Videos 15-30 min |
| X (Twitter) | OAuth 2.0 | 1,500 tweets/month | Free tier |
| Facebook/Instagram | OAuth 2.0 | Standard | Free |

### k-publish Architecture

```
k-publish/
├── auth/           ← OAuth tokens (Vaultwarden-managed)
├── templates/      ← Post templates per platform
└── scripts/        ← upload-youtube.py, post-linkedin.py, tweet.py, post-meta.py
```

Scheduling via cron/systemd timer/n8n (no native scheduling API on most platforms).

### Content Adaptation Per Platform

| Platform | Best Format |
|----------|-------------|
| YouTube | 16:9, 1080p+ long-form educational |
| LinkedIn | 1-3 min clips + article, professional tone |
| X (Twitter) | Thread + clip, 280 chars |
| Instagram | 15-60s vertical reels |
| Facebook | 1-3 min casual clips |

### ScienCurious Lab Thesis
The core visual-first AI communication paradigm is documented in `sciencurious_lab.md` (Visual Learning Engine — Manim + FLUX.2 + Wan 2.6 + TTS). Thesis: visual communication is 60,000x faster than text. Team: KπX (CTO) + Demartino KUETE (CPO).
