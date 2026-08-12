#!/bin/bash
# ============================================================
# opencode-ollama6.sh — Ollama6 wrapper + OpenCode model sync
# ============================================================
# Source:  k-dxo/scripts/opencode-ollama6.sh
# Deploy:  source'd from ~/.kshrc (exactly like opencode-ollama.sh)
# Role:    Wraps ollama6 pull/rm/delete to auto-sync deep-pc6 models into
#          the opencode.jsonc ollama6 provider block. This is the exact
#          equivalent of scripts/opencode-ollama.sh but for the `ollama6`
#          provider — deep-pc6's Ollama server reached through the 11436
#          tunnel (see k-dxo: ollama6-tunnel.service + vpn-dxo.service).
#
# If this file is present, kshrc sources it automatically.
# No manual function definition needed in kshrc.
#
# ollama6 stays CORE-ONLY (k-dxo directive): the auto-sync lives in this
# separate wrapper, never inside the ollama6 proxy script itself.
# ============================================================

# Only for interactive shells
case $- in *i*) ;; *) return ;; esac

# ──── Ollama6 auto-sync for OpenCode ────
ollama6() {
  local exit_code=0
  local run_sync=0
  if [[ "$1" == "sync" ]]; then
    run_sync=1
  else
    command ollama6 "$@"
    exit_code=$?
    if [[ "$1" == "pull" || "$1" == "rm" || "$1" == "delete" ]]; then
      run_sync=1
    fi
  fi

  if [[ $run_sync -eq 1 ]]; then
    # Inline Python script — surgical replacement of the ollama6 sub-block only
    # (preserves the other providers, e.g. ollama, untouched).
    python3 - "$@" << 'PYEOF' 2>/dev/null
import json, os, urllib.request

base = "http://127.0.0.1:11436"
config_path = os.environ["HOME"] + "/.config/opencode/opencode.jsonc"

# Fetch models from the deep-pc6 Ollama API (through the tunnel)
try:
    with urllib.request.urlopen(f"{base}/api/tags") as resp:
        data = json.loads(resp.read())
except Exception:
    # Tunnel / deep-pc6 Ollama not reachable — skip silently (like the
    # ollama wrapper does when the local server is down)
    raise SystemExit(0)

# FULL model names as keys (e.g. qwen3-vl:32b and qwen3-vl:8b stay separate)
models = {}
for m in data.get("models", []):
    name = m["name"]
    size_gb = m.get("size", 0) / (1024**3)
    models[name] = {"name": f"{name} ({size_gb:.1f} GB — deep-pc6)"}

if not models:
    raise SystemExit(0)

# Read config
with open(config_path, "r") as f:
    lines = f.readlines()

# Locate the "ollama6" sub-block inside the provider section
start = -1
for i, line in enumerate(lines):
    stripped = line.strip()
    if stripped.startswith("//"):
        continue
    if '"ollama6"' in stripped:
        start = i
        break

if start == -1:
    # Block missing — nothing to sync, leave the rest of the file intact
    raise SystemExit(0)

# Find the end of the ollama6 sub-block (brace-depth back to 0)
depth = 0
end = -1
for j in range(start, len(lines)):
    stripped = lines[j].strip()
    if stripped.startswith("//"):
        continue
    depth += stripped.count("{") - stripped.count("}")
    if depth == 0 and j > start:
        end = j
        break

if end == -1:
    raise SystemExit(0)

# Build the new ollama6 block (keeps npm/name/options, adds models)
new_block = [
    '    "ollama6": {\n',
    '      "npm": "@ai-sdk/openai-compatible",\n',
    '      "name": "Ollama6",\n',
    '      "options": {\n',
    '        "baseURL": "http://localhost:11436/v1"\n',
    '      },\n',
    '      "models": {\n',
]
model_items = sorted(models.items())
for idx, (mid, info) in enumerate(model_items):
    comma = "," if idx < len(model_items) - 1 else ""
    new_block.append(f'        "{mid}": {{ "name": "{info["name"]}" }}{comma}\n')
new_block.extend([
    '      }\n',
    '    },\n',
])

lines[start:end + 1] = new_block

with open(config_path, "w") as f:
    f.writelines(lines)

count = len(models)
print(f"✓ Ollama6 synced: {count} deep-pc6 models into opencode.jsonc")
PYEOF
    local python_exit=$?
    if [[ "$1" == "sync" ]]; then
      return $python_exit
    fi
  fi
  return $exit_code
}
