# Insights — k-bw

Durable memory layer for Bitwarden organization and sovereign secret management.

- **Dual-Control Pattern:** Distinguish between shell-injection tasks (`bw-env`) and agent-access tasks (`bw-mcp`). Use the former for infrastructure and the latter for contextual reasoning.
- **Dependency Awareness:** Always verify `bw` CLI availability before troubleshooting `bw-mcp` or `bw-env` failures.
- **Sovereign URL:** The source of truth for the vault is always `https://vault.kpihx-labs.com`. Reject any local/default Bitwarden cloud URLs.
- **Organization:** Technical secrets should prioritize **Custom Fields** over the Notes field for automated parsing resilience.
