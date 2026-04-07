# Code-as-Visual — Precision-First Content Generation

> Status: EVOLVING · Last updated: 2026-04-07 · [CLAUDE]

## Core Insight

Instead of generating pixels from text prompts (slow, imprecise, non-editable), generate visuals from **code** (fast, precise, fully editable, interactive).

```
Pixel-gen:  prompt → diffusion model → pixels    (5-30s, no control, one-shot)
Code-gen:   prompt → LLM → code → renderer       (0.1-2s, full control, iterative)
```

## The Toolkit

### Mathematical Animations — Manim

| Property | Value |
|----------|-------|
| Creator | 3Blue1Brown (Grant Sanderson) |
| Language | Python |
| Output | MP4, GIF, PNG |
| Precision | Pixel-perfect math typesetting |
| Speed | 1-5s per scene (rendering) |
| Editability | Full — change any parameter, re-render |

**Strengths:** math notation, geometric transforms, graph animations, morphing
**Weaknesses:** steep learning curve, not interactive, no real-time

### Diagrams — Mermaid

| Property | Value |
|----------|-------|
| Format | Text DSL |
| Output | SVG |
| Precision | Structural (flowcharts, sequences, class diagrams) |
| Speed | <100ms |
| Editability | Change text, re-render |

**Strengths:** universal support (GitHub, Docsify, Notion), trivial syntax
**Weaknesses:** limited styling, no animation

### Interactive Visuals — D3.js

| Property | Value |
|----------|-------|
| Language | JavaScript |
| Output | SVG/Canvas (live in browser) |
| Precision | Arbitrary — data-driven |
| Speed | Real-time |
| Interactivity | Full (hover, click, drag, zoom) |

**Strengths:** any visualization imaginable, data-binding, transitions
**Weaknesses:** verbose API, requires web context

### Rapid Prototyping — HTML/CSS/JS

| Property | Value |
|----------|-------|
| Output | Live web page |
| Speed | Instant |
| Interactivity | Full |

**Strengths:** Claude Artifacts, rapid iteration, universal display
**Weaknesses:** not a "visualization tool" per se, manual styling

### Video from Code — Motion Canvas / Remotion

| Tool | Language | Paradigm |
|------|----------|----------|
| Motion Canvas | TypeScript | Scene graph, declarative animations |
| Remotion | React/TS | React components rendered to video |

**Strengths:** programmatic video production, version-controlled, composable
**Weaknesses:** Node.js ecosystem, fewer math primitives than Manim

## Comparison Matrix

| Dimension | Pixel-Gen (FLUX/MJ) | Manim | Mermaid | D3 | HTML/CSS |
|-----------|---------------------|-------|---------|----|----------|
| Speed | 5-30s | 1-5s | <100ms | <100ms | <100ms |
| Precision | Low (stochastic) | Exact | Exact | Exact | Exact |
| Editability | None (regenerate) | Full | Full | Full | Full |
| Interactivity | None | None | None | Full | Full |
| Math support | Hallucinate | LaTeX-perfect | None | Manual | KaTeX |
| Photorealism | High | None | None | None | None |
| Artistic style | High | Low | None | Medium | Medium |
| LLM generation | Good | Medium | Easy | Medium | Easy |

## The Hybrid Strategy

```
Video backbone:  CODE (Manim + Motion Canvas)
  → 90% of frames: precise, editable, fast
  → Animations, diagrams, math, transitions

Style accents:   PIXEL-GEN (FLUX.2)
  → 10% of frames: hero shots, thumbnails, mood visuals
  → Title cards, chapter breaks, artistic elements

Audio layer:     TTS (Coqui, Bark, or cloud)
  → Narration synced to scene timeline
```

## Why This Beats Pure Pixel-Gen for Education

1. **Mathematical correctness** — FLUX.2 hallucinates equations; Manim renders LaTeX perfectly
2. **1-hour videos in minutes** — code renders are 100-1000x faster than diffusion
3. **Iterative refinement** — change one variable, re-render; no "regenerate and hope"
4. **Version control** — scenes are `.py` files; diff, branch, merge
5. **Interactivity** — web-based visuals (D3/HTML) can be explored live on the article page
6. **Composability** — scenes are functions; build a library, reuse across videos

## Reference: How the Masters Do It

### 3Blue1Brown (Grant Sanderson)

- **Tool:** Manim (custom fork `manimgl`)
- **Process:** writes Python scenes directly, mathematical intuition first
- **Time per video:** 2-8 weeks (mostly scripting/pedagogy, not rendering)
- **Team:** solo + occasional collaborators
- **Key insight:** every animation serves a pedagogical purpose

### ScienceClic (Alexandre Moatti)

- **Tools:** Blender + After Effects + Manim (selective)
- **Process:** 3D scenes in Blender, post-production in AE, some Manim for math
- **Time per video:** 3-6 weeks
- **Team:** 1-2 people
- **Key insight:** cinematic quality makes science feel like a documentary

### Morphocular

- **Tool:** Manim Community Edition
- **Process:** pure Manim, complex custom animations
- **Time per video:** 2-6 weeks
- **Team:** solo
- **Key insight:** animation quality comes from thoughtful composition, not fancy tools

## KpihX Advantage with AI

| Traditional (manual) | KpihX (AI-assisted) |
|----------------------|---------------------|
| Write Manim scene by hand (hours) | LLM generates scene from description (minutes) |
| Debug animation visually (hours) | LLM iterates on code errors (seconds) |
| One style per creator | Agent picks best engine per scene type |
| Manual upload per platform | k-publish automates multi-platform |
| 2-8 weeks per video | Target: 2-8 hours per short, 1-2 days per long |
