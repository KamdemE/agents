# k-ollama — Windows / WSL

> **OS reference:** Microsoft Windows (with WSL subsystem)
> **Applies to:** `k-alienware` (blglaptop139)

---

## Native Windows Ollama

Ollama has a native Windows build. Download from https://ollama.com/download and run the installer.

- Runs as a Windows service (background)
- Exposes `http://127.0.0.1:11434` (same as Linux)
- GPU acceleration available for NVIDIA CUDA and some DirectML-supported GPUs

## Ollama in WSL

Ollama can also run inside WSL (Linux-native):

```bash
# Inside WSL
curl -fsSL https://ollama.com/install.sh | sh
```

If Ollama is running natively on Windows AND in WSL, they conflict on port 11434. Choose one:
- **Native Windows**: Better GPU support (DirectML)
- **WSL**: Linux-native workflows, uses WSL filesystem

## GPU Support

- Windows native Ollama supports NVIDIA CUDA and AMD DirectML
- WSL supports NVIDIA CUDA via GPU passthrough
- Intel Arc GPUs in WSL are experimental — see `k-ubuntu` for Intel Arc setup (applies to native Ubuntu only)

## Uninstalling

```powershell
# Windows native
winget uninstall Ollama.Ollama
# or via Settings > Apps
```
