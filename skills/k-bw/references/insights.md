# Insights — k-bw

Durable memory layer for Bitwarden organization and sovereign secret management.

- **Dual-Control Pattern:** Distinguish between shell-injection tasks (`bw-env`) and agent/vault-management tasks (`bw-proxy`). Use the former for infrastructure environment injection and the latter for AI-blind vault reasoning and human-approved changes.
- **Dependency Awareness:** Always verify `bw` CLI availability before troubleshooting `bw-mcp` or `bw-env` failures.
- **Sovereign URL:** The source of truth for the vault is always `https://vault.kpihx-labs.com`. Reject any local/default Bitwarden cloud URLs.
- **Organization:** Technical secrets should prioritize **Custom Fields** over the Notes field for automated parsing resilience.
- **RAM-Only Proxy Auth:** `bw-proxy` must not ingest parent-process `BW_PASSWORD` or `BW_SESSION`; each operation should prompt, derive a fresh session, and wipe it.
- **Agnostic HITL Portability:** The Web HITL UI allows `bw-proxy` to operate in headless or remote environments (e.g. Docker, SSH) without X11 forwarding dependencies, provided port `1138` is accessible/forwarded.
