# k-cloudflare — Windows / WSL

> **OS reference:** Microsoft Windows (with WSL subsystem)
> **Applies to:** `k-alienware` (blglaptop139)

---

## Installation in WSL

flarectl and wrangler can be installed inside WSL — they work identically to a native Linux environment.

```bash
# Inside WSL (Ubuntu)
go install github.com/cloudflare/cloudflare-go/cmd/flarectl@latest
```

## Access from Windows Native

- **flarectl**: Run via WSL (`wsl flarectl zone list`)
- **cloudflared**: NOT on any workstation — prod tunnel connector runs on the server only
- **Wrangler**: Run via WSL for the inbound email worker deploy script

## CF API Token

Gate via `k-bw` / `k-clis` token gate. The token is the same regardless of OS.
