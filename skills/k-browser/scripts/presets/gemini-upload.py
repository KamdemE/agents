#!/usr/bin/env python3
"""Gemini file upload — upload a local image to Gemini via DataTransfer pattern.

Usage:
    python3 gemini-upload.py <TARGET_ID> <IMAGE_PATH> [FILENAME]

Uploads IMAGE_PATH to Gemini using the DataTransfer/inject-file-input pattern.
FILENAME defaults to the basename of IMAGE_PATH.

Requires: browser-proxy running, TARGET_ID from tab-list.
The Gemini Importation menu must be open and file inputs must be present.
Check: browser-proxy do page-evaluate '{"profile":"default","target_id":"...","expression":"document.querySelectorAll(\"input[type=file]\").length"}'
Must return 2 before running this script.
"""

import base64
import json
import os
import subprocess
import sys


def run_proxy(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True, check=False)
    return json.loads(r.stdout)


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <TARGET_ID> <IMAGE_PATH> [FILENAME]")
        sys.exit(1)

    target_id = sys.argv[1]
    image_path = sys.argv[2]
    filename = sys.argv[3] if len(sys.argv) > 3 else os.path.basename(image_path)

    if not os.path.exists(image_path):
        print(f"Error: {image_path} not found")
        sys.exit(1)

    # Determine MIME type
    ext = os.path.splitext(image_path)[1].lower()
    mime_map = {
        ".png": "image/png",
        ".jpg": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".gif": "image/gif",
        ".webp": "image/webp",
    }
    mime_type = mime_map.get(ext, "image/png")

    # Read and encode
    with open(image_path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode()

    print(f"Uploading {filename} ({len(b64)} bytes base64, {mime_type})...")

    # Build JS expression
    expr = (
        f"var b64 = '{b64}'; "
        f"var byteChars = atob(b64); "
        f"var byteNums = new Array(byteChars.length); "
        f"for(var i=0; i<byteChars.length; i++) byteNums[i] = byteChars.charCodeAt(i); "
        f"var byteArray = new Uint8Array(byteNums); "
        f"var blob = new Blob([byteArray], {{type: '{mime_type}'}}); "
        f"var file = new File([blob], '{filename}', {{type: '{mime_type}'}}); "
        f"var input = document.querySelector('input[type=file]'); "
        f"var dt = new DataTransfer(); "
        f"dt.items.add(file); "
        f"input.files = dt.files; "
        f"input.dispatchEvent(new Event('change', {{bubbles: true}})); "
        f"'uploaded ' + input.files.length + ' files'"
    )

    # Write payload to file (avoids shell arg length limits)
    payload = json.dumps(
        {"profile": "default", "target_id": target_id, "expression": expr}
    )
    payload_path = "/tmp/gemini-upload.json"
    with open(payload_path, "w") as f:
        f.write(payload)

    # Execute
    r = run_proxy(["browser-proxy", "do", "page-evaluate", payload_path])
    result = r.get("data", {}).get("result", "")
    status = r.get("meta", {}).get("status", "")
    print(f"Result: {result} (status: {status})")

    if "uploaded" in str(result):
        print("✅ Upload successful")
    else:
        print("⚠️ Upload may have failed — verify via screenshot")


if __name__ == "__main__":
    main()
