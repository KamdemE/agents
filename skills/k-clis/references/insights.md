# k-clis Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes.

## Insights

- Initial baseline created with skill v1.0.0.
- broot replaces tree/lsd/eza for interactive file exploration — v1.55.0, installed via apt.
- lsd (1.2.0) was purged 2026-05-29 — unused, no aliases/configs referenced it.

### 2026-08-26 — `rm -f` wrapper wasn't GNU-`rm`-compatible on nonexistent targets

- Symptom on `deep-pc6`: every new zsh shell printed
  `trash-put: cannot trash non existent '.zcompdump-DEEP-PC6-5.8.1.zwc.old'`.
  Traced to `~/.oh-my-zsh/oh-my-zsh.sh:151` (upstream, unmodified) running
  an unconditional `command rm -rf "$ZSH_COMPDUMP.zwc.old"
  "${ZSH_COMPDUMP}.lock"` on EVERY shell startup — completely standard OMZ
  behavior, an idempotent cleanup of files that only exist after a rare
  `zrecompile` rotation. `command rm` still resolves through `$PATH` to
  the KpihX trash wrapper (only aliases/functions are bypassed by
  `command`, not `$PATH` lookups).
- Root cause: `/usr/bin/trash-put -f <missing-path>` does NOT silently
  no-op like GNU `rm -f` — it prints `cannot trash non existent '<path>'`
  and exits **74**, even with `-f` passed through. Verified directly:
  `trash-put -f /tmp/doesnotexist` → error, vs `rm -f /tmp/doesnotexist`
  → silent, exit 0. The wrapper (`assets/rm`) was blindly forwarding `-f`
  to `trash-put` and trusting it to behave like GNU `rm -f`; it doesn't.
- Fix (assets/rm, default `*)` delete path): before calling `trash-put`,
  detect `-f`/`--force` in the forwarded flags, and if present, filter
  `trash_files` down to only entries that actually exist (`[ -e "$f" ] ||
  [ -L "$f" ]`, the `-L` branch keeps broken symlinks — real `rm` can
  still remove those). If the filtered list is empty, `exit 0` explicitly
  (matching GNU `rm -f` on an all-missing argument list) instead of
  falling through to a bare `[ -gt 0 ] && exec` whose short-circuited
  `false` silently became the script's own nonzero exit status. Without
  `-f`, missing targets still error exactly as before (matches GNU `rm`
  without `-f`, which also errors on a missing target).
- Anti-repeat: any wrapper around a POSIX utility (`rm`, `cp`, `mv`, …)
  that changes the underlying implementation (trash-cli here) must be
  audited against each flag's REAL semantics on edge cases (missing
  files, broken symlinks, empty globs) — don't assume the replacement
  tool treats a same-named flag (`-f`) identically to the original.

### 2026-09-04 — [LIVE] k-cloud-tools merged into k-clis

- **Cloud hub routing:** `references/cloud-hub.md` — all cloud/productivity skills route through it. Original in k-cloud-tools, merged here.
- **Social/dev platforms:** `references/social-dev-platforms.md` — YouTube, X, Meta, LinkedIn, WhatsApp registry. Original in k-cloud-tools.
- **Token gate:** `references/token-gate.md` — Vault token gate procedure. Original in k-cloud-tools.
- **curls:** `scripts/curls.sh` — secure curl wrapper with provider-based secret injection. `assets/providers.json` manifest (cloudflare only for now). Symlink `~/.local/bin/curls`.
- **curls security:** `raw-exec-guard.js` blocks `curl -H "...$VAR..."` and suggests `curls --provider <name>` instead.
