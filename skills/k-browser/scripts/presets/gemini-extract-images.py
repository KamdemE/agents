#!/usr/bin/env python3
"""Gemini image extraction — extracts all generated images from a Gemini conversation.

Usage:
    python3 gemini-extract-images.py <TARGET_ID> <OUTPUT_DIR>

Extracts all blob images >300px wide from the Gemini page and saves them as PNG.
Files are named: gemini_<idx>_<W>x<H>.png

Requires: browser-proxy running, TARGET_ID from tab-list.
"""

import base64
import json
import os
import subprocess
import sys


def run_proxy(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True, check=False)
    return json.loads(r.stdout)


def list_images(target_id):
    cmd = json.dumps(
        {
            "profile": "default",
            "target_id": target_id,
            "expression": 'var imgs = Array.from(document.querySelectorAll("img")).filter(function(i){return i.naturalWidth > 300 && i.src.indexOf("blob:") === 0}); JSON.stringify(imgs.map(function(i,idx){return {idx:idx, w:i.naturalWidth, h:i.naturalHeight, alt:(i.alt||"").substring(0,30)}}))',
        }
    )
    r = run_proxy(["browser-proxy", "do", "page-evaluate", cmd])
    return json.loads(json.loads(r.stdout)["data"]["result"])


def extract_image(target_id, idx):
    # Convert to data URL
    cmd = json.dumps(
        {
            "profile": "default",
            "target_id": target_id,
            "expression": f'var imgs = Array.from(document.querySelectorAll("img")).filter(function(i){{return i.naturalWidth > 300 && i.src.indexOf("blob:") === 0}}); var canvas = document.createElement("canvas"); canvas.width = imgs[{idx}].naturalWidth; canvas.height = imgs[{idx}].naturalHeight; canvas.getContext("2d").drawImage(imgs[{idx}], 0, 0); window.__ext = canvas.toDataURL("image/png").split(",")[1]; window.__ext.length',
        }
    )
    r = run_proxy(["browser-proxy", "do", "page-evaluate", cmd])
    length = json.loads(r.stdout)["data"]["result"]

    # Extract in chunks
    b64 = ""
    for offset in range(0, length, 100000):
        cmd_chunk = json.dumps(
            {
                "profile": "default",
                "target_id": target_id,
                "expression": f"window.__ext.substring({offset}, {offset + 100000})",
            }
        )
        r3 = run_proxy(["browser-proxy", "do", "page-evaluate", cmd_chunk])
        b64 += json.loads(r3.stdout)["data"]["result"]
        pct = min(100, 100 * len(b64) // length)
        print(f"\r  Extracting {idx}: {len(b64)}/{length} ({pct}%)", end="", flush=True)
    print()

    return base64.b64decode(b64)


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <TARGET_ID> <OUTPUT_DIR>")
        sys.exit(1)

    target_id = sys.argv[1]
    output_dir = sys.argv[2]
    os.makedirs(output_dir, exist_ok=True)

    print(f"Listing images on {target_id}...")
    images = list_images(target_id)
    print(f"Found {len(images)} images")

    for img in images:
        kind = "LOGO" if img["w"] == img["h"] else "BANNER"
        fname = f"gemini_{img['idx']:02d}_{img['w']}x{img['h']}.png"
        fpath = os.path.join(output_dir, fname)
        print(f"[{img['idx']}] {img['w']}x{img['h']} [{kind}] → {fname}")
        raw = extract_image(target_id, img["idx"])
        with open(fpath, "wb") as f:
            f.write(raw)
        print(f"  Saved: {len(raw)} bytes")

    print(f"\nDone! {len(images)} images saved to {output_dir}")


if __name__ == "__main__":
    main()
