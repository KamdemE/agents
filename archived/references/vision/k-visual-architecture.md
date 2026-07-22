# k-visual — Visual Content Orchestrator Architecture

> Status: DESIGN · Last updated: 2026-04-07 · [CLAUDE]

## Purpose

`k-visual` is the proposed orchestrator skill that routes visual generation requests to the appropriate engine based on content type, precision requirements, and output format.

## Architecture

```
k-visual (orchestrator)
├── k-manim      → Manim scene generation (math animations, precise diagrams)
├── k-pptx       → PowerPoint deck generation (EXISTS — python-pptx MCP)
├── k-napkin     → Napkin AI infographics (EXISTS — API-based SVG/PNG)
├── k-publish    → Social media distribution pipeline (NEW)
├── k-blender    → Blender 3D scenes via MCP (NEW — bpy + blender_mcp)
└── [pixel-gen]  → FLUX.2 / Midjourney for hero images (Mac Studio local or cloud)
```

## Routing Logic

| Content Type | Primary Engine | Fallback | Output |
|-------------|---------------|----------|--------|
| Math animation | k-manim | - | MP4/GIF |
| Concept diagram | Mermaid/D3 | k-napkin | SVG/PNG |
| Infographic | k-napkin | HTML/CSS | SVG/PNG/PPT |
| Presentation deck | k-pptx | - | PPTX/PDF |
| Hero image / thumbnail | FLUX.2 | GenerateImage | PNG |
| 3D scene | k-blender | - | PNG/MP4 |
| Interactive visual | HTML/CSS/JS | - | HTML |
| Full video episode | ffmpeg assembly | - | MP4 |

## Sub-Skill Responsibilities

### k-manim (NEW — to create)

- Manim Community Edition scene templates
- Common animation patterns (transform, morph, camera moves)
- Rendering config (resolution, fps, codec)
- Scene library: number line, coordinate system, graph, matrix, neural net
- Integration with LLM for script-to-scene generation

### k-pptx (EXISTS)

- `powerpoint` MCP server (Ichigo3766/powerpoint-mcp)
- `python-pptx` direct scripting
- Dark-tech template, brand colors
- Slide-as-image workflow

### k-napkin (EXISTS)

- Napkin AI API (direct calls, no MCP)
- Visual types: mindmap, flowchart, timeline, comparison, hierarchy
- SVG/PNG/PPT output
- Brand-consistent styling

### k-publish (NEW — to create)

- Multi-platform distribution pipeline
- YouTube Data API v3 (upload, metadata, thumbnails)
- LinkedIn Posts API (text, images, video)
- X API v2 (tweets, media upload)
- Facebook/Instagram Graph API (posts, reels)
- Scheduling, analytics tracking

### k-blender (NEW — to create)

- Blender MCP integration (official `blender_mcp` or `better-blender`)
- Headless rendering pipeline
- Scene templates for common visualizations
- Python script execution via MCP

## Dependencies

| Component | Status | Local/Cloud |
|-----------|--------|-------------|
| Manim CE | `pip install manim` | Local |
| python-pptx | Installed | Local |
| Napkin AI | API key needed | Cloud |
| FLUX.2 | Mac Studio (future) | Local |
| Blender 5.1+ | Install needed | Local |
| ffmpeg | Installed | Local |
| YouTube API | OAuth setup needed | Cloud |
| LinkedIn API | OAuth setup needed | Cloud |

## Production Pipeline

```
1. IDEATION
   User/LLM → article topic + key visuals list

2. SCRIPT
   LLM → scene-by-scene breakdown
   Each scene: narration text + visual description + code hint

3. VISUAL GENERATION
   Per scene → k-visual routes to best engine:
     - Math → k-manim (Python scene)
     - Diagram → Mermaid/D3 (code)
     - Hero shot → FLUX.2 (prompt)
     - 3D → k-blender (Python script)

4. RENDER
   manim render → MP4 clips
   FLUX.2 → PNG frames
   ffmpeg → concatenate + TTS audio overlay

5. PUBLISH
   k-publish → YouTube + LinkedIn + X + Facebook
   Metadata, thumbnails, scheduling
```
