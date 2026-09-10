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
  local exit_code=0
  local run_sync=0
  if [[ "$1" == "sync" ]]; then
    run_sync=1
  else
    command ollama "$@"
    exit_code=$?
    if [[ "$1" == "pull" || "$1" == "rm" || "$1" == "delete" ]]; then
      run_sync=1
    fi
  fi

  if [[ $run_sync -eq 1 ]]; then
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
    # Ollama resolves a bare (untagged) name to its ":latest" tag implicitly, so the
    # short form is safe ONLY when the pulled tag IS "latest". Any other explicit tag
    # (e.g. ":1.7b", ":4b", ":14b") must keep its full "name:tag" as the JSON key —
    # that key is the literal model ID sent to Ollama's OpenAI-compat endpoint, and a
    # stripped non-latest tag 404s with `model "X" not found, try pulling it first`
    # even though the model is actually present (real incident 2026-08-27, see
    # k-ollama/SKILL.md insights).
    model_id = name.split(":")[0] if name.endswith(":latest") else name
    models[model_id] = {"name": f"{name} ({size_gb:.1f} GB local)"}

if not models:
    raise SystemExit(0)

# Read config
with open(config_path, "r") as f:
    lines = f.readlines()

# Find the "ollama" sub-block boundaries inside the provider section
# (surgical — preserves the other providers untouched)
start = -1
for i, line in enumerate(lines):
    stripped = line.strip()
    if stripped.startswith("//"):
        continue
    # exact key match: '"ollama"' (closing quote) never matches longer keys like "ollama-remote"
    if '"ollama"' in stripped:
        start = i
        break

if start == -1:
    raise SystemExit(1)

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
    raise SystemExit(1)

# Build the new ollama sub-block
new_block = [
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
    new_block.append(f'        "{model_id}": {{ "name": "{model_info["name"]}" }}{comma}\n')

new_block.extend([
    '      }\n',
    '    },\n',
])

# Replace the ollama sub-block only
lines[start:end + 1] = new_block

with open(config_path, "w") as f:
    f.writelines(lines)

count = len(models)
print(f"✓ Ollama synced: {count} models into opencode.jsonc")
PYEOF
    local python_exit=$?
    if [[ "$1" == "sync" ]]; then
      return $python_exit
    fi
  fi
  return $exit_code
}
