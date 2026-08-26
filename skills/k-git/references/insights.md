# k-git Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- Initial baseline created automatically from insights governance standard.
- If `SSH_AUTH_SOCK` points to `$HOME/.bitwarden-ssh-agent.sock` and `ssh-add -l` returns `Error connecting to agent: Connection refused`, the socket path existing is **not** enough: Bitwarden Desktop / its SSH agent is not actually serving yet, so `git push` will still fail with `Permission denied (publickey)`.
- If Bitwarden Desktop is relaunched and `ssh-add -l` / `ssh -T git@github.com` still hang or time out, treat it as an **unlock / approval pending** state rather than a Git problem: do not force HTTPS, and ask KπX to unlock/approve Bitwarden before retrying `pull` or `push`.
- `fatal: .git/index: index file open failed: Not a directory`, seen ~1-4 times right as a hook starts (once per submodule): this is `git-hook-passthrough.sh`'s submodule loop (`submodule_dirty_report`/`submodule_push_report`) running `git -C <submodule> ...` while still carrying the hook's inherited `GIT_DIR`/`GIT_WORK_TREE`/etc — a submodule's `.git` is a file, not a dir, so a leaked git-dir path colliding with it hits ENOTDIR. Non-fatal to the actual commit/push (git recovers), but noisy. Fixed 2026-08-26 (v2.10.1) with `unset $(git rev-parse --local-env-vars)` at the top of both functions — the pattern `git help githooks` itself documents for running git against a foreign repo from a hook. Could not force-reproduce it in isolated manual testing even with a faithful relative-`GIT_DIR` simulation — the fix is applied on the strength of the documented mechanism matching the symptom exactly (same error text, same "count = submodule count" pattern as a matching real-world case: github.com/sds/overcommit#383), not on a local repro. If it recurs after this fix, that would mean the mechanism is something else and needs re-investigating from scratch, not a "the fix didn't stick" retry.
- No `ssh-agent` runs by default on `deep-pc6` (`XDG_SESSION_TYPE=tty`, no GNOME session → the documented `gcr-ssh-agent` "PREFERRED" strategy in `k-ssh/SKILL.md` never actually starts — it's undocumented-as-unwired, not broken). Every git-over-ssh op decrypts the key fresh; the submodule push gate loops per-submodule, so a passphrase-protected key gets prompted once per submodule in the same `git push` (e.g. 4 submodules = 4 prompts back to back) — looks like a bug, is actually just "no caching, N sequential connections". `ssh-add --help` alone failing with "Could not open a connection to your authentication agent" is the fast way to confirm this is the cause before chasing anything else.
