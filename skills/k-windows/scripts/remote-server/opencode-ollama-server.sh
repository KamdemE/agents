#!/bin/bash
# ============================================================
# opencode-ollama-server.sh — ollama-server.sh wrapper + OpenCode model sync
# ============================================================
# Generic template — the OS-agnostic equivalent of a local
# opencode-ollama.sh wrapper, but for a remote server's Ollama reached
# through a tunnel (see tunnel-server.service + ollama-server.sh in this
# same skill). Personalize PROVIDER_NAME/LOCAL_PORT below.
#
# Deploy: source'd from ~/.kshrc, exactly like the local opencode-ollama.sh.
# ollama-server.sh stays CORE-ONLY: the auto-sync lives in this separate
# wrapper, never inside the ollama-server.sh proxy script itself.
# ============================================================

# Only for interactive shells
case $- in *i*) ;; *) return ;; esac

# ──── Personalize these two ────
OPENCODE_OLLAMA_SERVER_PROVIDER="${OPENCODE_OLLAMA_SERVER_PROVIDER:-ollama-server}"
OPENCODE_OLLAMA_SERVER_PORT="${OPENCODE_OLLAMA_SERVER_PORT:-11435}"

# ──── ollama-server auto-sync for OpenCode ────
ollama-server() {
  local exit_code=0
  local run_sync=0
  if [[ "$1" == "sync" ]]; then
    run_sync=1
  else
    command ollama-server "$@"
    exit_code=$?
    if [[ "$1" == "pull" || "$1" == "rm" || "$1" == "delete" ]]; then
      run_sync=1
    fi
  fi

  if [[ $run_sync -eq 1 ]]; then
    # Inline Python — surgical replacement of the provider's own sub-block
    # only (preserves every other provider in opencode.jsonc, untouched).
    PROVIDER="$OPENCODE_OLLAMA_SERVER_PROVIDER" PORT="$OPENCODE_OLLAMA_SERVER_PORT" python3 - "$@" << 'PYEOF' 2>/dev/null
import json, os, urllib.request

provider = os.environ["PROVIDER"]
port = os.environ["PORT"]
base = f"http://127.0.0.1:{port}"
config_path = os.environ["HOME"] + "/.config/opencode/opencode.jsonc"

# Fetch models from the remote Ollama API (through the tunnel)
try:
    with urllib.request.urlopen(f"{base}/api/tags") as resp:
        data = json.loads(resp.read())
except Exception:
    # Tunnel / remote Ollama not reachable — skip silently (like the local
    # ollama wrapper does when the local server is down)
    raise SystemExit(0)

# FULL model names as keys (keeps e.g. tag:32b and tag:8b separate)
models = {}
for m in data.get("models", []):
    name = m["name"]
    size_gb = m.get("size", 0) / (1024**3)
    models[name] = {"name": f"{name} ({size_gb:.1f} GB — {provider})"}

if not models:
    raise SystemExit(0)

with open(config_path, "r") as f:
    lines = f.readlines()

# Locate the provider's own sub-block inside the provider section
start = -1
key = f'"{provider}"'
for i, line in enumerate(lines):
    stripped = line.strip()
    if stripped.startswith("//"):
        continue
    if key in stripped:
        start = i
        break

if start == -1:
    raise SystemExit(0)

# Find the end of the sub-block (brace-depth back to 0)
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

new_block = [
    f'    "{provider}": {{\n',
    '      "npm": "@ai-sdk/openai-compatible",\n',
    f'      "name": "{provider.title()}",\n',
    '      "options": {\n',
    f'        "baseURL": "http://localhost:{port}/v1"\n',
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
print(f"✓ {provider} synced: {count} remote models")
PYEOF
    local python_exit=$?
    if [[ "$1" == "sync" ]]; then
      return $python_exit
    fi
  fi
  return $exit_code
}
