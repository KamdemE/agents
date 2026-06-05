# Hermes Agent Governance

Hermes Agent is integrated purely as a cross-session Memory Layer and Headless Daemon.
It is forbidden from acting as the primary code executor.

## Core Mandates

1.  **Isolation (`$HERMES_HOME`)**: The asset at `~/.agents/skills/k-hermes/assets/hermes.sh` wraps Hermes with `$HERMES_HOME=$HOME/.hermes` and is symlinked to `~/.local/bin/hermes`. Always invoke via `hermes` (which hits the KπX-managed symlink). To bypass KπX isolation (e.g., run stock Hermes), use the full path to the pip-installed binary.
2.  **Zero-Trust Auto-Skills**:
    *   `~/.hermes/skills` is considered an untrusted sandbox for Hermes' AI-generated skills.
    *   It MUST NEVER be symlinked to the KπX production kernel (`~/.agents/skills`).
    *   Skills are only promoted to the kernel after manual/OpenCode review using `k-skill-creator`.
3.  **Headless Execution (Daemon)**:
    *   Daemon/Cron jobs must explicitly use `--profile cron`.
    *   The `cron` profile in `~/.hermes/profiles/cron/config.yaml` explicitly disables the `bash` tool to prevent prompt-injection attacks.
4.  **Kernel Reading**: Hermes reads the global KπX rules via its `SOUL.md` (which is symlinked to `AGENTS.md`) and loads the kernel skills via the `external_dirs` setting in its `config.yaml`.
