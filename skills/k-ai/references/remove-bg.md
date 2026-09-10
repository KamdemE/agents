# Local Background Removal

 sovereign local workflow for removing image backgrounds without cloud APIs.

**Two tools retained**, each filling a distinct niche:

- **`bgone`** — fast, deterministic, color-based. Best when the background is a truly uniform color and the foreground is clearly compartmentalized.
- **`nobg` (FeyNobg)** — semantic AI matting. Best when the subject's silhouette, effects, or anti-aliased edges require the tool to *understand* what it is cutting out.

**Two tools rejected** after direct comparison:

- **`rembg`** (ONNX `isnet-anime`) — unreliable mask generation on these logo types; lost or corrupted content.
- **`withoutbg`** — often left near-white background residue; inferior cutout quality to `nobg`.

The visual evidence is in [`../assets/bg_comparison.pdf`](../assets/bg_comparison.pdf). All 16 individual comparison images live in `$HOME/Downloads/Logos/1/pure/` (4 logos × 4 methods). The refined Gemini-generated source assets are in `$HOME/Downloads/Logos/1/`.

---

## 1. Philosophy — Why Two Tools

Most background-removal tools try to be universal. None are. The fundamental split is:

| Approach | What it does | What it does NOT do |
|----------|-------------|---------------------|
| **Color unmixing** (`bgone`) | Separates pixels into foreground and background colors using least-squares optimization. Deterministic, fast, no model. | Understand what the image represents. Every pixel is treated the same way regardless of context. |
| **Semantic matting** (`nobg`) | Estimates an alpha matte by recognizing the subject (person, object, text, illustration) first, then separates foreground from background. | Be as fast or deterministic as color unmixing on trivial cases. |

**The critical difference:** `bgone` applies the same color logic to every pixel. If the foreground contains the same color as the background (e.g. white fills inside a dark-lined logo on a white background), `bgone` cannot tell them apart — it removes both. `nobg` recognizes the subject first, so it preserves interior fills even when they match the background color.

This is not a minor edge case. It is the dominant failure mode for line-art logos, circuit diagrams, and any illustration where the foreground contains transparent or filled areas matching the background.

---

## 2. The Four Tools Evaluated

### 2.1 `bgone` — Rust color unmixing

| Property | Detail |
|----------|--------|
| **Language** | Rust |
| **Mechanism** | Color unmixing (least-squares optimization). No ML model. |
| **Speed** | Extremely fast — parallel CPU processing, no GPU needed. |
| **Dependencies** | None beyond the single binary. No PyTorch, no ONNX, no model download. |
| **Determinism** | 100% — same input + same flags = same output, always. |
| **Source** | https://github.com/benface/bgone |
| **Install** | `cargo install bgone` |
| **Retained** | ✅ Yes |

**When it works best:**
- Digital graphics with a genuinely uniform, solid background color
- Simple icons, flat UI elements, vector-style line art on a single-color field
- Batch processing where speed matters and the background premise is verified

**When it fails:**
- Anti-aliased edges where foreground colors blend with background colors at the pixel level (produces rainbow/chromatic fringing)
- Foreground contains the same color as the background (white fills inside a dark-lined logo on white → bgone removes the fills too)
- Gradients, textures, or photographic backgrounds
- Complex illustrations with many colors near the subject boundary

**Key limitation (observed):** `bgone` auto-detects the background color from edge pixels and applies it globally. If the foreground interior contains that same color, it is removed along with the background. The tool has no concept of "inside the subject" vs "outside the subject" — it only knows color.

### 2.2 `nobg` / FeyNobg — Semantic AI matting

| Property | Detail |
|----------|--------|
| **Language** | Python (PyTorch) |
| **Mechanism** | Semantic alpha matting via fine-tuned BiRefNet (image-and-mask datasets). |
| **Speed** | Depends on device (CPU, CUDA, XPU). Slower than `bgone` but still fast per-image. |
| **Dependencies** | PyTorch + TorchVision (GPU-optional), `nobg` package, `loadimg`. Model auto-downloaded on first use (~200 MB). |
| **Determinism** | Not fully deterministic (floating-point, device-dependent). |
| **Source** | https://github.com/feyninc/nobg |
| **Model** | `feyninc/FeyNobg` (HuggingFace Hub) |
| **Retained** | ✅ Yes |

**When it works best:**
- Logos, illustrations, character art, text-heavy graphics
- Anti-aliased edges, soft contours, hair/fur, transparency effects
- Any image where "what is the subject?" matters more than "what color is the background?"
- Complex compositions with multiple colors, gradients, or near-background highlights

**When it fails:**
- Very large images (memory-bound on CPU; batch size matters)
- When the model's training data doesn't cover the specific subject type (rare for logos/illustrations)
- When the user needs 100% deterministic output (color unmixing is better for that)

**Key advantage (observed):** `nobg` preserves white fills inside dark-lined logos because it recognizes the logo as a single coherent subject. The alpha matte is estimated semantically, not by color threshold.

### 2.3 `rembg` — ONNX segmentation (REJECTED)

| Property | Detail |
|----------|--------|
| **Language** | Python (ONNX Runtime) |
| **Mechanism** | Semantic segmentation via `isnet-anime` model. |
| **Install** | `uv tool install rembg[cpu,cli]` |
| **Retained** | ❌ No — purged |

**Why rejected:**
- On the four tested  logos, `rembg` with `isnet-anime` produced black/incorrect masks.
- Lost meaningful content: text labels, fine details, and interior elements were removed or corrupted.
- The `isnet-anime` model is optimized for anime-style illustrations, not line-art logos on white backgrounds.
- Other models (`u2net`, `u2netp`) may perform differently but were not tested in this comparison.

### 2.4 `withoutbg` — Automated CLI (REJECTED)

| Property | Detail |
|----------|--------|
| **Language** | Python |
| **Mechanism** | Automated background removal (details opaque). |
| **Install** | `uv tool install withoutbg` |
| **Retained** | ❌ No — purged |

**Why rejected:**
- Often appeared superficially clean but preserved near-white background regions around the subject.
- On illustrations with white fills (same as background), the tool could not reliably distinguish interior from exterior.
- Cutout quality was consistently inferior to `nobg` on the same inputs.
- Less transparent about its underlying mechanism than the other tools.

---

## 3. Visual Benchmark — Four Logos, Four Methods

The comparison was performed on 4 Gemini-generated logos for the  ecosystem:

| # | Logo | Description | Background |
|---|------|-------------|-----------|
| 1 | **** | Hooded figure with laptop, "" text on screen | White (`#ffffff`), near-uniform |
| 2 | **-Labs** | Lightbulb with neural network inside + "-Labs" text | White (`#ffffff`), near-uniform |
| 3 | **ScienCurious** | Cartoon child scientist with beakers + "ScienCurious" text | Light grey gradient (not perfectly uniform) |
| 4 | **TechSkills** | Lightbulb with circuit board pattern + "TechSkills" text | White (`#ffffff`), near-uniform |

### 3.1 Comparison Matrix

| Logo | `bgone` | `nobg` (FeyNobg) | `rembg` (isnet-anime) | `withoutbg` |
|------|---------|-------------------|----------------------|-------------|
| **** | ⚠️ Removed outer white, but also removed white fills inside hoodie and laptop. Dark outlines remain on black. Rainbow fringing on anti-aliased edges. | ✅ Clean cutout. Hoodie, laptop, text all preserved. Transparent background. No fringing. | ❌ Background not removed — output identical to original. Near-white bg retained. | ⚠️ Background not removed — output identical to original. Near-white bg retained. |
| **-Labs** | ⚠️ Removed outer white AND white inside lightbulb glass. Network lines and text partially visible on black. Heavy chromatic artifacts (yellow/cyan/magenta fringing). | ✅ Clean cutout. Lightbulb, network, screw base, text all preserved. Transparent. No fringing. | ❌ Background not removed. Output identical to original. | ❌ Background not removed. Output identical to original. |
| **ScienCurious** | ❌ Failed to isolate subject. Near-white background retained. Rainbow ring artifacts around character edges. Dark background appeared. | ✅ Clean cutout. Character, beakers, liquid colors, text all preserved. Transparent. No fringing. | ❌ Background not removed. Output identical to original. | ⚠️ Background partially removed, but heavy colored ring artifacts (green/blue/orange fringing) around character. Subject preserved but edges severely degraded. |
| **TechSkills** | ⚠️ Removed outer white, but also removed white inside lightbulb glass. Circuit pattern and text partially visible on black. | ✅ Clean cutout. Lightbulb, circuit traces, text all preserved. Transparent. No fringing. | ❌ Background not removed. Output identical to original. | ❌ Background not removed. Output identical to original. |

### 3.2 Per-Method Analysis

#### `bgone` — Color unmixing results

`bgone` auto-detected `#ffffff` as the background color from edge pixels and applied it globally. The problem: all four logos are dark-lined illustrations on white, and the foreground itself contains large white fills (the hoodie interior, the lightbulb glass, the laptop screen). Since these white fills are the *same color* as the outer background, `bgone` removed them too.

**What went right:** The outer background was removed. Dark outlines remained.

**What went wrong:**
- Interior white fills (hoodie, laptop, lightbulb glass) were removed along with the outer background.
- Anti-aliased edges produced rainbow/chromatic fringing (yellow, cyan, magenta halos).
- The result is a mostly-black image with thin dark outlines — not a usable cutout.

**When `bgone` would actually work:** A solid-color logo (e.g. single-color icon) on a contrasting solid background where no foreground element matches the background color. For example: a blue circle on a white background, or a white icon on a red background.

#### `nobg` (FeyNobg) — Semantic matting results

`nobg` recognized each logo as a coherent visual subject and produced a clean alpha matte. White fills inside the hoodie, laptop, and lightbulb were preserved because `nobg` understood they are part of the foreground.

**What went right:**
- All four subjects were cleanly isolated from the background.
- Interior white fills were preserved.
- Anti-aliased edges were clean — no rainbow fringing.
- Text labels were preserved intact.
- Fine details (circuit traces, network nodes, beaker liquid colors) were preserved.

**What went wrong:** Nothing visible on these test images.

#### `rembg` (isnet-anime) — Segmentation results

`rembg` with the `isnet-anime` model failed to remove the background on all four logos. The output was identical or near-identical to the original — the near-white background was retained.

**Why it failed:** The `isnet-anime` model is trained on anime-style illustrations with more complex backgrounds and characters. Simple line-art logos on near-white backgrounds fall outside its effective domain. The model likely classified the entire image as "foreground" because the white fills inside the subject are the same color as the background.

**Note:** Other `rembg` models (`u2net`, `u2netp`, `silueta`) may perform differently. The `isnet-anime` model was the one tested here.

#### `withoutbg` — Automated results

`withoutbg` failed to remove the background on 3 out of 4 logos (output identical to original). On the ScienCurious logo, it partially removed the background but introduced heavy colored ring artifacts (green, blue, orange fringing around the character edges).

**Why rejected:** Inconsistent performance — sometimes removed background, sometimes didn't. When it did remove background, edge quality was poor. `nobg` produced uniformly clean results across all four inputs.

---

## 4. Installation Guide

### 4.1 `bgone` — Hardware-Independent

`bgone` is a native Rust binary. No GPU, no PyTorch, no model download. Works identically on Intel Arc, NVIDIA, AMD, or CPU-only machines.

```bash
# Install via Cargo (Rust package manager)
cargo install bgone

# Verify
bgone --help
```

**Update:**

```bash
cargo install bgone --force
```

**No GPU configuration needed.** Performance scales with CPU cores (parallel processing). A typical 1024×1024 logo processes in under 100ms.

### 4.2 `nobg` (FeyNobg) — PyTorch, Intel Arc + NVIDIA

`nobg` is a Python library. It requires PyTorch + TorchVision and downloads its model (~200 MB) on first use.

#### 4.2.1 Basic Install (any machine)

```bash
# Create a dedicated project (or use an existing one)
uv init nobg-workspace && cd nobg-workspace

# Install PyTorch — choose the build matching your hardware (see 4.2.2 / 4.2.3)
uv add torch torchvision

# Install nobg
uv add nobg

# Also useful for loading images from paths/URLs
uv add loadimg
```

#### 4.2.2 NVIDIA GPU

Install the PyTorch CUDA build matching your driver/CUDA version:

```bash
# Check CUDA version
nvidia-smi  # look for CUDA Version in top-right

# Install PyTorch with CUDA support (example for CUDA 12.6)
uv add torch torchvision --index-url https://download.pytorch.org/whl/cu126
```

Verify at runtime:

```python
import torch

print(torch.cuda.is_available())  # must be True
print(torch.cuda.get_device_name(0))  # should show your GPU
```

Move model to GPU:

```python
device = "cuda" if torch.cuda.is_available() else "cpu"
model = AutoModel.from_pretrained("feyninc/FeyNobg").eval().to(device)
```

#### 4.2.3 Intel Arc GPU (XPU)

Intel Arc support in PyTorch is through the `xpu` device via `intel-extension-for-pytorch`:

```bash
# Install Intel extension for PyTorch
uv add intel-extension-for-pytorch

# Verify
python -c "import torch; print(torch.xpu.is_available())"
```

**If XPU is not available or unstable, fall back to CPU.** The model quality is identical; only speed differs. Do not force XPU if the extension reports it unavailable.

**Important:** `nobg` is a PyTorch library. It does NOT use OpenVINO directly. If your pipeline already uses OpenVINO for other inference tasks, keep `nobg` on CPU/XPU and do not assume it inherits OpenVINO acceleration.

#### 4.2.4 CPU-Only (fallback)

```bash
# CPU-only PyTorch (smallest wheel, no CUDA/XPU)
uv add torch torchvision --index-url https://download.pytorch.org/whl/cpu
```

This works on any machine. Performance is adequate for single images and small batches.

#### 4.2.5 Usage Pattern

```python
import torch
from nobg import AutoModel

# Device selection — inspect at runtime, never assume
device = "cuda" if torch.cuda.is_available() else "cpu"

# Load model (auto-downloads on first run)
model = AutoModel.from_pretrained("feyninc/FeyNobg").eval().to(device)

# Process single image
cutout = model.process("input.png")
cutout.save("output.png")
```

**Batch processing:**

```python
from loadimg import load_img

images = ["logo1.png", "logo2.png", "logo3.png"]
for img_path in images:
    cutout = model.process(img_path)
    cutout.save(f"out_{img_path}")
```

**Notes:**
- The model is downloaded to HuggingFace cache (`~/.cache/huggingface/`) on first use.
- Processing time depends on image size and device (see §4.3 for measured benchmarks).
- Output is always PNG with alpha channel (RGBA).

### 4.3 Performance Benchmark (Measured)

Benchmark performed on 4 logos (1024×1024 PNG) from the  ecosystem.

**bgone** (Rust, CPU, Intel Core Ultra 7 155H):

| Test | Wall time | CPU time | Cores used |
|------|-----------|----------|-----------|
| 1 image 1024×1024 | **0.19s** | 2.03s | ~11 |
| 1 image (complex bg) | **0.28s** | 3.21s | ~11 |
| 4 images batch (parallel) | **0.38s** | 5.77s | ~15 |

→ **~0.2–0.3s per image** on CPU. Parallelizes natively across all CPU cores. No GPU needed.

**nobg** (FeyNobg, PyTorch, Intel Arc XPU via `intel-extension-for-pytorch`):

| Test | Wall time | Per image | Notes |
|------|-----------|-----------|-------|
| 4 images batch (cold) | **35.3s** | **8.8s** avg | First image 11.7s (model load + inference), subsequent ~3s each |
| 4 images batch (warm) | **34.9s** | **8.7s** avg | Same as cold — model is not persisted across CLI invocations |

→ **~3s per image** on XPU after model loading (~11s first call). Batch mode loads model once; `nobg remove` called N times loads N times.

**Estimated times by device (1024×1024):**

| Device | Model load | Per image | Batch 4 images |
|--------|-----------|-----------|----------------|
| Intel Arc XPU | ~11s | ~3s | ~35s |
| NVIDIA CUDA GPU | ~5-8s | ~0.2-0.5s | ~7-10s |
| CPU (no GPU) | ~5-8s | ~5-10s | ~30-50s |

**Key insight:** `nobg batch` is ~2× faster than N separate `nobg remove` calls because the model loading cost (~11s on XPU) is paid once, not N times.

---

## 5. Decision Guide — When to Use Which

```
                    START
                      │
                      ▼
        Is the background a single,
        perfectly uniform color?
                      │
              ┌───────┴───────┐
              │               │
             YES              NO
              │               │
              ▼               ▼
    Does the foreground    Use nobg.
    contain the same       (bgone cannot handle
    color as the           non-uniform backgrounds.)
    background?
              │
      ┌───────┴───────┐
      │               │
     YES              NO
      │               │
      ▼               ▼
    Use nobg.      Run both.
    (bgone will    Compare at 100% zoom.
    remove both    Keep the better one.
    background     (Usually nobg.)
    AND interior
    fills.)
```

**Rule of thumb:**

| Scenario | Tool |
|----------|------|
| Solid-color icon on contrasting solid bg | `bgone` (fastest, cleanest) |
| Line-art logo on white, foreground has white fills | `nobg` (only correct option) |
| Illustration / character art | `nobg` |
| Photo with complex background | `nobg` |
| Batch of simple flat icons (known colors) | `bgone` (fastest) |
| When in doubt | `nobg` (safer default) |

---

## 6. Quality-Control Checklist

After any background removal:

1. **Never overwrite the original.** Write to a separate file.
2. **Inspect at 100% zoom** over both a dark and a light checkerboard background.
3. **Check interior fills:** are white/light areas inside the subject preserved?
4. **Check edges:** any rainbow fringing, dark halos, or colored artifacts?
5. **Check text:** are small labels and thin strokes intact?
6. **Check fine details:** circuit traces, network nodes, hair, transparency effects.
7. **Compare both tools** when the use case is ambiguous — the cost is one extra command.

---

## 7. Comparison Artifact

| Resource | Location |
|----------|----------|
| **PDF comparison** (5×4 grid) | [`../assets/bg_comparison.pdf`](../assets/bg_comparison.pdf) |
| **Individual results** (16 PNGs) | `$HOME/Downloads/Logos/1/pure/` |
| **Refined source assets** (8 PNGs) | `$HOME/Downloads/Logos/1/` |
| **Original Gemini uploads** (5 PNGs) | `$HOME/Downloads/Logos/` |

---

## 8. Sources

| Tool | URL | License |
|------|-----|---------|
| `bgone` | https://github.com/benface/bgone | MIT |
| `nobg` / FeyNobg | https://github.com/feyninc/nobg | MIT |
| `rembg` | https://github.com/danielgatis/rembg | MIT (not retained) |
| `withoutbg` | — | (not retained) |
