# Blender — MCP / API / Scripting

> Status: REFERENCE · Last updated: 2026-04-07 · [CLAUDE]

## Overview

Blender is fully scriptable via Python (`bpy`) and has first-class MCP support. An AI agent can create 3D scenes, animate, and render headlessly — opening the door to a `k-blender` skill for programmatic 3D content generation.

## Approaches

| Approach | Tool | Description |
|----------|------|-------------|
| **Python scripting** | `bpy` (built-in) | Full Blender API — create scenes, materials, animations, render. Run headless: `blender --background --python script.py` |
| **Official MCP** | `blender_mcp` (blender.org) | Blender 5.1+ addon + MCP server. `execute_blender_code`, render, scene inspection via MCP. Install: `pip install git+https://projects.blender.org/lab/blender_mcp.git` |
| **Community MCP** | `better-blender` | Local-first MCP: scene management, object manipulation, animation, materials, camera, compositing, rendering. CLI: `serve`, `doctor`, `install-addon` |
| **Headless MCP** | `cwahlfeldt/blender_mcp` | Script management + headless execution with result tracking. Ideal for CI/batch pipelines |

## Python `bpy` API

The built-in API gives full programmatic control over Blender:

```python
import bpy

bpy.ops.mesh.primitive_cube_add(location=(0, 0, 0))
cube = bpy.context.active_object
cube.scale = (2, 1, 0.5)

mat = bpy.data.materials.new("DarkTech")
mat.use_nodes = True
mat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.1, 0.8, 1.0, 1.0)
cube.data.materials.append(mat)

bpy.context.scene.render.filepath = "/tmp/render.png"
bpy.context.scene.render.resolution_x = 1920
bpy.context.scene.render.resolution_y = 1080
bpy.ops.render.render(write_still=True)
```

Headless execution:

```bash
blender --background --python scene.py
blender --background scene.blend --python render.py
```

## Official MCP Server (blender.org)

- **Requires:** Blender 5.1+
- **Architecture:** Blender addon (TCP server) + MCP server process (TCP client)
- **Tools:** `execute_blender_code`, render, scene inspection, interface navigation
- **Install:** `pip install git+https://projects.blender.org/lab/blender_mcp.git`

## better-blender MCP

- **Type:** local-first MCP server
- **Tools:** scene management, object manipulation, animation/keyframe control, modifiers, materials, camera/lighting, compositing, rendering (`render_still`, `render_animation`)
- **CLI:** `serve` (start MCP), `doctor` (health check), `install-addon` (Blender addon)
- **GitHub:** `JonathanGrocott/better-blender`

## Security

All MCP servers execute arbitrary Python code without guards. Use in isolated environments (VMs, containers) without sensitive data access.

## Relevance to k-visual Pipeline

| Use Case | Engine | Why Blender |
|----------|--------|-------------|
| 3D physics simulations | k-blender | Relativity, fluid dynamics, particle systems |
| Cinematic science visuals | k-blender | ScienceClic-style documentary shots |
| Architectural diagrams | k-blender | 3D infrastructure/network visualizations |
| Hero shots / thumbnails | k-blender or FLUX.2 | When 3D precision beats pixel-gen |

**Priority:** Phase 4 in the content engine pipeline. Manim and FLUX.2 cover 90% of educational content needs; Blender adds 3D when the topic demands it (e.g., spacetime curvature, molecular structures, neural network 3D topology).
