# k-cloudflare — Ubuntu

> **OS reference:** Ubuntu (native)
> **Applies to:** `k-ubuntu` (kpihx-ubuntu workstation)

---

## Installation

```bash
# flarectl — Cloudflare CLI for DNS and zone management
go install github.com/cloudflare/cloudflare-go/cmd/flarectl@latest

# cloudflared — NOT installed on workstation (prod connector on server)
# See references/debian.md for server setup
```

flarectl binary installs to `~/go/bin/flarectl` (or `$GOPATH/bin/flarectl`).

## Usage

flarectl requires `CF_API_TOKEN` environment variable. Gate via `k-bw` / `k-clis` token gate.

Common operations:
```bash
flarectl zone list
flarectl dns records list --zone kpihx-labs.com
```

## Wrangler (Inbound Email Worker only)

Installed via npm on demand (not persistent):
```bash
npx wrangler@3 deploy
```

Not for routine IDE Workers development — only for the inbound email router deploy script.
