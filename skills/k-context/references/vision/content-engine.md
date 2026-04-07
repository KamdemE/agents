# Content Engine — End-to-End Visual Production Pipeline

> Status: DESIGN · Last updated: 2026-04-07 · [CLAUDE]

## Pipeline Overview

```
IDEA → SCRIPT → VISUAL → RENDER → PUBLISH → ANALYTICS
  │       │        │        │         │          │
  ▼       ▼        ▼        ▼         ▼          ▼
 Topic  Scene-by  k-visual  ffmpeg  k-publish  Dashboard
 brief  -scene    routing   concat  multi-plat  metrics
        breakdown           + TTS
```

## Phase 1: Ideation

**Input:** topic, target audience, platform(s), duration target
**Output:** structured brief

```yaml
title: "Transformers Explained — The Visual Way"
audience: CS students, ML practitioners
platforms: [youtube, linkedin, x]
duration: 10-15 min (youtube), 2 min clip (linkedin), 30s teaser (x)
key_visuals:
  - attention mechanism as spotlight
  - token embedding as vectors in space
  - positional encoding as color gradients
  - multi-head attention as parallel spotlights
style: dark-tech, clean, minimal text overlay
```

**Time:** 15-30 minutes (human + LLM brainstorm)

## Phase 2: Script Generation

**Input:** brief
**Output:** scene-by-scene breakdown with narration + visual spec

```yaml
scenes:
  - id: 1
    title: "Hook"
    narration: "What if I told you the most important invention in AI..."
    visual_type: hero_image
    visual_spec: "Dark cinematic shot of neural network transforming text to image"
    engine: flux2
    duration: 8s

  - id: 2
    title: "The Problem — Sequential Processing"
    narration: "Before Transformers, we processed text one word at a time..."
    visual_type: math_animation
    visual_spec: "RNN unrolling animation, sequential token processing"
    engine: manim
    duration: 25s

  - id: 3
    title: "Attention Is All You Need"
    narration: "The key insight: look at ALL words simultaneously..."
    visual_type: interactive_diagram
    visual_spec: "Attention matrix visualization, tokens connecting"
    engine: d3
    duration: 30s
```

**Time:** 30-60 minutes (LLM generates, human refines)

## Phase 3: Visual Generation

Per scene, k-visual routes to the appropriate engine:

| Engine | Scene Types | Generation Time |
|--------|------------|----------------|
| Manim | Math animations, transforms, graphs | 1-5s per scene |
| Mermaid | Architecture diagrams, flowcharts | <100ms |
| D3.js | Data visualizations, interactive | <100ms (code gen) |
| HTML/CSS | UI mockups, text layouts | <100ms |
| FLUX.2 (local) | Hero images, artistic shots | 8-15s per image |
| Blender | 3D scenes, physics simulations | 30s-5min per scene |

**Total for 10-min video (~25 scenes):**
- Code-based scenes (20): ~2 minutes
- Pixel-gen scenes (5): ~2 minutes
- **Total visual gen: ~5 minutes**

## Phase 4: Render & Assembly

```
1. Manim → render each scene to MP4 clip
2. FLUX.2 → generate PNG, convert to clip (Ken Burns / zoom)
3. D3/HTML → screen capture or headless browser render
4. TTS → generate narration audio per scene
5. ffmpeg → concatenate clips + audio + transitions
```

| Step | Tool | Time (10-min video) |
|------|------|-------------------|
| Scene rendering | manim render | 5-10 min |
| Image → clip | ffmpeg | <1 min |
| TTS generation | Coqui/Bark (local) or cloud | 2-5 min |
| Assembly | ffmpeg concat | <1 min |
| **Total render** | | **~15 minutes** |

## Phase 5: Publish

k-publish handles multi-platform distribution:

```
youtube:
  title: "Transformers Explained — The Visual Way"
  description: (from template)
  tags: [transformers, AI, deep learning, visual]
  thumbnail: scenes/1/hero.png
  privacy: public

linkedin:
  text: (from template, professional tone)
  video: clips/linkedin_2min.mp4

x:
  thread:
    - "🧵 How Transformers actually work — a visual thread"
    - (scene highlights with images)
  video: clips/x_30s.mp4
```

**Time:** 5 minutes (automated, human reviews before publish)

## Total Production Timeline

| Phase | Traditional (manual) | KpihX (AI-assisted) |
|-------|---------------------|---------------------|
| Ideation | 1-3 days | 15-30 min |
| Script | 3-7 days | 30-60 min |
| Visual gen | 1-4 weeks | 5-15 min |
| Render | 1-3 days | 15-30 min |
| Publish | 2-4 hours | 5 min |
| **Total** | **2-8 weeks** | **2-4 hours** |

Speedup factor: **50-100x** for a 10-minute educational video.

## Realistic Caveats

- LLM-generated Manim scenes need human review for pedagogical quality
- First video will take longer (template/library building)
- TTS quality varies — may need cloud for production
- Multi-platform format adaptation adds overhead
- The 2-4 hour estimate assumes mature tooling (after first 3-5 videos)

## MVP — First Video Plan

1. Pick a topic already well-understood (e.g., Integration Odyssey visual companion)
2. Manual script + LLM scene generation
3. Manim only (no FLUX.2, no Blender)
4. Basic TTS (or manual narration)
5. YouTube only (no multi-platform)
6. **Target: 1 day from start to published**
