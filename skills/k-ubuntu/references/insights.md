# k-ubuntu Workstation Insights

Purpose: durable operational memory for KpihX-Ubuntu workstation (Dell 7640).

## Governance (mandatory)

- Agent-managed, update autonomously without prior approval.
- Additive and evolutionary: add, refine, reorganize, prune stale entries.
- Record only durable, reusable insights (not temporary chatter).

## Current Insights

- **[2026-07-25] Skill migration breaks systemd symlinks — mandatory post-move check.** When skills are refactored and files moved (e.g., from `scripts/` to `assets/`, or from `.config/opencode/skills/` to `.agents/skills/`), ALL systemd symlinks pointing to the old location become dead. Mitigation: after any skill content migration, always run `find /etc/systemd/system/ ~/.config/systemd/user/ -xtype l` to find broken symlinks and re-point them to the new canonical `.agents/` path. A pre-commit hook (`hooks/pre-commit`) should be added to `.agents/` that checks all systemd symlinks point to valid targets under `.agents/skills/`.
