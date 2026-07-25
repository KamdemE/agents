# ============================================================
# opencode-ollama.sh — Ollama wrapper + OpenCode model sync
# ============================================================
# Source:  k-opencode/scripts/opencode-ollama.sh
# Deploy:  source'd from ~/.kshrc
# Role:    Wraps ollama pull/rm/delete to auto-sync models into
#          opencode.jsonc provider block.
#
# If this file is present, kshrc sources it automatically.
# No manual function definition needed in kshrc.
# ============================================================

# Only for interactive shells
case $- in *i*) ;; *) return ;; esac

# ──── Ollama auto-sync for OpenCode ────
ollama() {
  command ollama "$@"
  local exit_code=$?
  if [[ "$1" == "pull" || "$1" == "rm" || "$1" == "delete" ]]; then
    # Inline Python script that does what ollama-models-sync did
    python3 - "$@" << 'PYEOF' 2>/dev/null
import json, os, urllib.request

config_path = os.environ["HOME"] + "/.config/opencode/opencode.jsonc"

# Fetch models from Ollama API
try:
    with urllib.request.urlopen("http://localhost:11434/api/tags") as resp:
        data = json.loads(resp.read())
except Exception:
    # Ollama not running — skip
    raise SystemExit(0)

models = {}
for m in data.get("models", []):
    name = m["name"]
    size_gb = m.get("size", 0) / (1024**3)
    model_id = name.split(":")[0]
    models[model_id] = {"name": f"{name} ({size_gb:.1f} GB local)"}

if not models:
    raise SystemExit(0)

# Read config
with open(config_path, "r") as f:
    lines = f.readlines()

# Find provider block boundaries
in_provider = False
provider_start = -1
provider_end = -1
depth = 0

for i, line in enumerate(lines):
    stripped = line.strip()
    if stripped.startswith("//"):
        continue
    if '"provider"' in stripped and "{" in stripped:
        provider_start = i
        in_provider = True
        depth = 0
    if in_provider:
        depth += stripped.count("{") - stripped.count("}")
        if depth == 0 and provider_start != -1:
            provider_end = i
            break

if provider_start == -1:
    raise SystemExit(1)

# Build new provider block
new_provider_lines = [
    '  // ──── Provider — auto-discovered + custom ────\n',
    '  "provider": {\n',
    '    // Ollama local — auto-synced by opencode-ollama.sh\n',
    '    "ollama": {\n',
    '      "npm": "@ai-sdk/openai-compatible",\n',
    '      "name": "Ollama (local)",\n',
    '      "options": {\n',
    '        "baseURL": "http://localhost:11434/v1"\n',
    '      },\n',
    '      "models": {\n'
]

model_items = list(models.items())
for idx, (model_id, model_info) in enumerate(model_items):
    comma = "," if idx < len(model_items) - 1 else ""
    new_provider_lines.append(f'        "{model_id}": {{ "name": "{model_info["name"]}" }}{comma}\n')

new_provider_lines.extend([
    '      }\n',
    '    }\n',
    '  },\n',
])

# Replace the provider block
new_lines = lines[:provider_start] + new_provider_lines + lines[provider_end+1:]

with open(config_path, "w") as f:
    f.writelines(new_lines)

count = len(models)
print(f"✓ Ollama synced: {count} models into opencode.jsonc")
PYEOF
  fi
  return $exit_code
}
