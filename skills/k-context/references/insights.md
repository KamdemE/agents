# k-context General Insights

Purpose: autonomous cross-domain runtime memory to reduce repeated mistakes, repeated dead-end searches, and repeated ineffective actions across sessions.

## Governance (mandatory)

- This file is agent-managed and can be updated autonomously at any time without prior user approval.
- Preferred operations are additive and evolutionary: add, refine, reorganize, and prune stale entries to keep signal high.
- Record only durable, reusable insights (not temporary chatter).
- Every new insight should help avoid a future repeat error, repeat search loop, or repeat failed operation pattern.
- When a skill-specific insight is discovered and the target skill has no `references/insights.md`, create it immediately and write first insights in the same workstream.
- When new insights are added during a task, inform KpihX briefly in the same response.

## Current Seed Insights

- **Continue + Antigravity:** Global model config is `$HOME/.continue/config.yaml`; `${{ secrets.MISTRAL_API_KEY }}` resolves from `$HOME/.continue/.env` (and workspace `.env`). Prefer the `kpihx-antigravity-open-cloud.desktop` / `bootstrap_open_cloud.sh --launch` path so `$HOME/.kshrc` runs before the IDE when Bitwarden injects keys at shell login.
- What’s up slices must run as batch deep-dives and stop only after materially complete information coverage.
- For mail-mcp stdio, accented query strings can fail with ASCII codec errors; use ASCII-safe fallback queries and resolve target UIDs with `get_message`.
- For TickTick destination resolution, trust live `workspace_map` names (for example `🎓 X`) over stale naming assumptions.
- For TickTick checklist writes, fallback to markdown checklist content when native checklist creation path fails.
- Historical reference docs inside `$HOME/.agents/` should still respect the `$HOME` generalization rule; normalize `~` and hardcoded `/home/<user>` paths even when the file is archival or visionary.
- **Auth-Block behavior (Mandatory):** When an MCP tool reports a connection or authentication failure (e.g., "WhatsApp is not connected"), the only valid action is to **STOP immediately** and report the issue to KπX. Attempts to "save the task" via browser-based hacks, local server workarounds, or vision-based verification loops lead to void results, wasted tokens, and environment drift. Wait for explicit user intervention (QR scan/re-auth) before proceeding.
- **Exam Environment Guard:** Certification platforms using "Secure Browsers" (e.g., Linguaskill, Talview) generally do **not** support Linux and may block Virtual Machines. When such an exam is detected, proactively check OS compatibility and warn KπX of the need for a native Windows/macOS machine.
- **Network triage pattern:** If `ping` and raw TCP connect succeed but SSH hangs during banner exchange on both the main host and inner routed hosts, while another control-plane port (for example Proxmox `8006`) still answers, suspect a host-side firewall/conntrack/sshd pathology or selective payload drop rather than total node loss. Distinguish "host alive" from "interactive control plane unavailable" early.
