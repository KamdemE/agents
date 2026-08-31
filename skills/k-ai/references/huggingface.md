# Hugging Face Hub CLI — `hf` (nouveau standard, `huggingface-cli` déprécié)

> **PAS un paquet `apt`** — `sudo apt install huggingface-cli` → `E: Unable to locate package huggingface-cli` — le binaire s'appelle maintenant `hf`.

## Install (uv-first, 0 apt)

```bash
# Recommandé (outil isolé, binaire dans ~/.local/bin)
uv tool install huggingface_hub
# ou
uv tool install "huggingface_hub[cli]"

# Alternative pip (dans un venv)
uv pip install huggingface_hub
# ou
pipx install huggingface_hub

# Vérif
which hf               # → ~/.local/bin/hf (nouveau standard)
which huggingface-cli  # déprécié, alias de compatibilité
hf --help
huggingface-cli --help  # déprécié → affiche `Use hf instead`
```

Binaire : `~/.local/bin/hf` (nouveau, symlink → `~/.local/share/uv/tools/huggingface_hub/bin/hf`), `huggingface-cli` reste en alias déprécié.

## Auth — `HF_TOKEN`

Sans token : `Warning: You are sending unauthenticated requests to the HF Hub...` + rate-limit (ex: `openvino pull Qwen3-8B` à 1.49 MB/s, `Fetching 5 files: 0/5` figé).

Avec token : `~78-120 MB/s`, `Fetching 5 files: 1/5 → 5/5` fluide.

```bash
# 1. Crée un token fine-grained `read` sur https://huggingface.co/settings/tokens
# 2. Login (écrit ~/.cache/huggingface/token et ~/.config/huggingface/token)
hf auth login
# colle hf_...  (ancien: huggingface-cli login → déprécié)

# Vérif
cat ~/.cache/huggingface/token
hf auth whoami
# ou huggingface-cli whoami (déprécié)
```

# Alternative env (pour CI / .agents)
export HF_TOKEN=hf_...
# ou dans ~/.agents/.env :
# HF_TOKEN=hf_...
# (chargé par python-dotenv dans k-openvino, transmis à optimum-cli via env["HF_TOKEN"])
```

`huggingface_hub` cherche dans l'ordre : `HF_TOKEN` env → `~/.cache/huggingface/token` → `~/.config/huggingface/token`.

## Usage avec `openvino`

```bash
# Sans token (lent, warning)
openvino pull Qwen/Qwen3-8B  # → Warning + 1.49 MB/s

# Avec token (rapide)
export HF_TOKEN=$(cat ~/.cache/huggingface/token)
openvino pull Qwen/Qwen3-8B  # → 78 MB/s, Fetching 1/5 → 5/5
```

Le `openvino` CLI transmet automatiquement `HF_TOKEN` s'il est dans l'env (voir `src/k_openvino/cli.py` → `env["HF_TOKEN"]`).

## Notes

- `torch_dtype` deprecated → `dtype` : warning `optimum-cli`/`transformers`, inoffensif.
- `Downloading (incomplete total...):` + `Fetching 5 files: 0/5` figé = normal au début du 1er shard (3 Go) en anonyme, se débloque à la fin du shard (1/5). Avec token, le déblocage est < 30s.
