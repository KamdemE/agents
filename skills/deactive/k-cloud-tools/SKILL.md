---
name: k-cloud-tools
description: >
  **MERGED into k-clis (2026-05-29).** This skill is kept as a redirect reference.
license: private
metadata:
  author: KpihX
  version: 1.5.0
  scope: operations
---

# KπX — Cloud Tools (redirect only)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

**⚠️ DEPRECATED — This skill is merged into `k-clis`. Load `k-clis` instead.**

> Contents merged into `$HOME/.agents/skills/k-clis/SKILL.md`

## curls — Secure curl wrapper

`curls` injects auth headers from env vars (set by `with-env`) based on a provider manifest. The agent never touches secret values.

```bash
# With provider (injects auth headers from providers.json)
with-env curls --provider cloudflare https://api.cloudflare.com/client/v4/zones/...

# Short form
with-env curls -p cloudflare https://api.cloudflare.com/client/v4/zones/...

# Without provider (plain curl — public APIs)
curls https://api.example.com/public/data
```

**Adding a provider:** edit `assets/providers.json`.

**Manifest format (`assets/providers.json`):**

```json
{
  "providers": {
    "<name>": {
      "secrets": [
        {"env": "VAR_NAME", "header": "Header-Name", "scheme": "Bearer", "optional": false}
      ]
    }
  }
}
```

**Rules:**
- Agent never manipulates secret values — only specifies `--provider <name>` or `-p <name>`
- Secret values exist ONLY inside the `with-env` subshell
- Unknown provider → explicit error (no silent injection)
- Missing non-optional secret → explicit error
- Optional secrets (`"optional": true`) → skip if not set

**Files:**

| File | Role |
|------|------|
| `scripts/curls` | Secure curl wrapper (source of truth) |
| `assets/providers.json` | Provider→secret mapping manifest |

**Symlink:** `~/.local/bin/curls` → `scripts/curls` (registered in `assets/links.jsonc`)

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-04 | [LIVE] | v1.5.0 — `curls` v1.0.0: secure curl wrapper, provider-based secret injection; v1.4.0 merged into `k-clis`. |
| [SUMMARY] | — | v1.3.x social hub (k-media/k-meta/k-x); v1.1.x registry; older → `references/log.md` |

Bundled: `references/cloud-hub.md`

Bundled: `references/insights.md`

Bundled: `references/social-dev-platforms.md`

Bundled: `references/token-gate.md`
