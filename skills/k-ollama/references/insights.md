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
- **`curl ... | grep -m1 ...` can make curl fail with "(23) Failure writing output"**: `grep -m1` exits the instant it finds its first match, closing its stdin pipe out from under `curl` before curl has finished writing the rest of a large response (e.g. the GitHub releases API JSON). Capture the full curl output into a variable first, then `grep -m1` the variable — never pipe `curl` straight into `grep -m1` for anything non-trivially sized. Found and fixed in `scripts/install-wsl-client.sh` (2026-08-25).
- **A version/idempotency check via `command -v <bin>` is blind to a non-login/non-interactive shell** (cron, a script run standalone, this tool's own Bash sandbox) where `~/.local/bin` isn't on `$PATH` even though the binary is there on disk — the check silently always reports "not installed" and re-downloads every time. Check the known install path directly first (`[ -x "$INSTALL_PATH" ]`), fall back to `command -v` only if that misses. Found in `scripts/install-wsl-client.sh` (2026-08-25) — likely a general anti-pattern worth watching for in any install/update script this kernel writes.
