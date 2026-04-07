# Vision — KpihX Visual Content Architecture

> Living documents describing the visual-first AI content creation ecosystem.
> All files here are brainstorm/design artifacts — NOT operational runbooks.
> Promote to a skill or techskills/ when mature enough for production use.

## Index

| Document | Scope |
|----------|-------|
| `visual-ai-vision.md` | Core thesis: image-first AI communication paradigm, SOTA analysis, NotebookLM benchmark, education game-changer thesis |
| `k-visual-architecture.md` | Skill architecture: k-visual orchestrator + sub-skills (k-manim, k-pptx, k-napkin, k-publish) |
| `code-as-visual.md` | Code-driven visuals: Manim, Mermaid, D3, HTML/CSS/JS vs pixel-gen — the precision-first approach |
| `social-media-apis.md` | Platform APIs for automated content distribution (YouTube, LinkedIn, X, Facebook, Instagram) |
| `content-engine.md` | End-to-end pipeline: idea → script → visual → render → publish — with time/cost estimates |
| `blender-scripting.md` | Blender MCP/API/scripting: bpy, official MCP, better-blender, headless execution |
| `edge-automation.md` | Edge automation stack: favorites, Playwright/CDP, accessibility fallback, vision fallback, safety model |

## Status

All documents are **EVOLVING** — updated as the vision crystallizes through real experimentation.

## Decision: LLM + Manim + FLUX.2

The primary production stack for educational content is:

```
LLM (script + scene code)
  → Manim (precise math/concept animations)
  → FLUX.2 (hero images, thumbnails, style frames)
  → ffmpeg (assembly + TTS narration)
  → k-publish (multi-platform distribution)
```

Code-as-visual for backbone (precision, speed, editability).
Pixel-gen for hero shots and stylistic elements only.
