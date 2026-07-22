# k-ollama — Ubuntu

> **OS reference:** Ubuntu (native)
> **Applies to:** `k-ubuntu` (kpihx-ubuntu workstation)

---

## Installation

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

## Service Management

Ollama runs as a systemd service on Ubuntu:

```bash
sudo systemctl status ollama
sudo systemctl stop ollama
sudo systemctl start ollama
sudo systemctl restart ollama
sudo journalctl -u ollama -f
```

## Model Storage

| Path | Purpose |
|------|---------|
| `/usr/share/ollama/.ollama/` | Native/system Ollama model store |
| `~/.ollama-ipex/` | IPEX (Intel Arc) model store |

Both backends expose the same endpoint: `http://127.0.0.1:11434`

## Groups

For GPU access, the user must be in `video` and `render` groups:
```bash
sudo usermod -aG video,render $USER
```
