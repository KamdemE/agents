# k-ollama Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.
- Disabling/stopping `ollama.service` does not free `127.0.0.1:11434` when `ollama serve` was started manually in a user shell. Before switching a machine to a remote-tunnel-backed default Ollama endpoint, verify the listener with `lsof -nP -iTCP:11434 -sTCP:LISTEN` and kill the user process explicitly (for example `pkill -f '^ollama serve$'`) if the service manager is already inactive.
- On the X students NFS home, the effective user quota is about `30 GiB` (`30720M`). This is enough for `phi4-mini` plus `qwen3.5`, but not for stacking several additional `14-15 GiB` models such as `devstral` and `mistral-small3.2`. Treat the NFS store as a curated persistent tier and `/tmp/$USER/ollama_models` as the full fast cache tier.
