# k-ssh — Insights

## Durable Lessons

### 2026-07-22 — Creation

- **Single source of truth for SSH:** The `Include` directive in OpenSSH makes
  it possible to centralize all Host blocks into one file. Each machine's
  `~/.ssh/config` becomes a one-liner. This eliminates drift between machines.
- **Key naming:** `id_ed25519_<target>` with comment `<source>` is the standard.
  The suffix tells where the key authenticates TO; the comment tells where it
  was generated ON. Makes `authorized_keys` instantly readable.
- **Bitwarden + SSH agent:** The Bitwarden desktop app's SSH agent replaces
  the need for `IdentityFile` in most cases. Keys stored in the vault are
  available everywhere without copying private key files.
- **Duplication problem:** Before `k-ssh`, each machine had its own `~/.ssh/config`
  with different HostName values for the same host (e.g., `pve.local` on Ubuntu
  vs `129.104.234.138` on Phone). The canonical fragment documents both variants
  as comments so the user knows which HostName works from which machine.
- **Phone config distribution:** The phone does not have `.agents/` cloned.
  The canonical fragment must be copied via `scp` to the phone's shared storage,
  then Included from there. This is a manual step after each edit.

### 2026-08-26 — gcr-ssh-agent silently never starts on tty-only infra

- Diagnosed on `deep-pc6`: `gcr-ssh-agent.service` depends on
  `graphical-session-pre.target`. That target only fires under a real GNOME
  session — never on a machine reached purely via SSH+tmux
  (`XDG_SESSION_TYPE=tty`). The failure is silent: no error at boot, just an
  agent that never exists. `ssh-add --help` → "Could not open a connection to
  your authentication agent" is the fast, unambiguous confirmation — check
  that before chasing anything else (wrong keys, wrong `IdentityFile`, etc.).
- Symptom this produces downstream: every single git-over-ssh op prompts for
  the passphrase fresh (no caching), and `git-hook-passthrough.sh`'s submodule
  gates loop per-submodule, so one `git push` can prompt N times in a row —
  reads like a bug in the hook, is actually just "zero agent caching, N
  sequential SSH connections."
- Fix: `gpg-agent`'s SSH-agent emulation (`gpg-agent-ssh.socket`) is
  socket-activated independently of any graphical target and was already
  running (54+ days uptime, unused) the moment this was checked. No package
  to install, no service to enable on this machine — just point
  `SSH_AUTH_SOCK` at `$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh`. Before assuming
  a fresh install is needed on a *different* machine, always check
  `systemctl --user status gpg-agent-ssh.socket` first — it may already be
  there.
- Don't assume default cache TTLs — query them: `gpgconf --list-options
  gpg-agent | grep cache-ttl` prints the actual compiled-in values
  (`default-cache-ttl-ssh`/`max-cache-ttl-ssh`), which turned out to already
  be sudo-shaped (1800s sliding / 7200s hard ceiling) with zero configuration.

### 2026-08-26 (bis) — gpg-agent "agent refused operation" on ssh-add → updatestartuptty

- Symptom on `deep-pc6`: `SSH_AUTH_SOCK` correctly points at gpg-agent's ssh
  socket and `ssh-add -l` round-trips fine ("no identities"), but
  `ssh-add ~/.ssh/id_ed25519_gitlab` fails with `agent refused operation`
  AFTER the passphrase is accepted (the prompt comes from ssh-add decrypting
  locally — the refusal is gpg-agent's own ADD_IDENTITY).
- `export GPG_TTY=$(tty)` in the pane is NOT sufficient — gpg-agent pins
  pinentry to the *startup TTY* recorded when the agent started, and the ssh
  path uses that, not the caller's TTY. Classic on headless/tmux machines
  where the agent started under another (or no) TTY.
- Fix (validated live 2026-08-26): run FROM THE PANE that should receive the
  prompt, then re-run ssh-add:
  `gpg-connect-agent updatestartuptty /bye && ssh-add <key>`
  → "Identity added". Refs: unix.SE #371901 (accepted answer).
- Durable wiring idea (not yet applied): call `gpg-connect-agent
  updatestartuptty /bye` from `.kshrc`'s interactive section so every new tmux
  pane re-points pinentry automatically — would remove the manual step per
  boot/session entirely.

### 2026-08-26 (ter) — `min-passphrase-len 8` silently blocks unencrypted keys + zombie `pinentry` + `ssh-add -d`/`-D` don't purge

- **`min-passphrase-len 8` (GnuPG compiled-in default) rejects an empty
  internal protection passphrase** at `ssh-add` time, even when the SOURCE
  `~/.ssh/id_ed25519_*` key file is itself completely unencrypted (verify
  with `ssh-keygen -y -f <key> -P ""` succeeding instantly, or decode the
  OpenSSH-v1 header: `cipher: none, kdf: none`). The failure surfaces as
  `Bad Passphrase (try N of 3)` in the pinentry dialog when leaving the field
  empty, then downstream as the generic, misleading `agent refused
  operation` on every `ssh`/`git` op for that key — nothing in that message
  hints at a *length policy*, not a wrong/forgotten passphrase. Diagnose with
  `gpgconf --list-options gpg-agent | grep min-passphrase-len`. Fix: canonical
  `k-ssh/assets/gpg-agent.conf` (symlinked to `~/.gnupg/gpg-agent.conf`,
  `min-passphrase-len 0`) now ships this permanently — see SKILL.md v1.4.0.
- **Zombie `pinentry` holding the lock:** a freshly spawned `pinentry`
  process can start spinning at 70-95% CPU (`ps aux | grep pinentry`)
  instead of rendering its dialog, and hold gpg-agent's internal pinentry
  lock — confirmed via `journalctl --user -u gpg-agent` showing repeating
  `failed to acquire the pinentry lock: Timeout` / `failed to unprotect the
  secret key: Timeout` / `ssh sign request failed: Timeout <GPG Agent>`
  every ~1-3 minutes while it spins. Observed TWICE in the same session
  (once per key, ~25 min apart) — not a one-off. Fix: `kill -9 <pid>` the
  spinning `pinentry` process; the NEXT sign/add attempt spawns a fresh
  `pinentry` that renders correctly and prompts as expected. No known
  trigger identified yet (possibly a redraw race when the pane the dialog
  targets isn't the one an interactive client is currently viewing) — if
  this recurs, capture `strace -p <pinentry-pid>` before killing it next
  time to find the actual root cause instead of just clearing the symptom.
- **`ssh-add -d <key>` and `ssh-add -D` do NOT purge gpg-agent's persisted
  ssh keystore** (`~/.gnupg/private-keys-v1.d/<keygrip>.key`) — they report
  success ("Identity removed" / "All identities removed") and `ssh-add -l`
  still lists the same keys immediately after, because gpg-agent treats
  ssh-imported keys as permanently confirmed/protected entries, not
  session-ephemeral ones. To truly force a clean re-import (e.g. after a
  corrupted/partial import from a failed passphrase attempt), the specific
  `.key` file must be deleted directly: identify it by file mtime
  (correlate with the timestamp of the failed `ssh-add` attempt — the OTHER
  working key's `.key` file will have an older, stable mtime) since there is
  no simple CLI to map a keygrip back to which `~/.ssh/id_ed25519_*` file it
  came from. Use the `rm` trash-safe wrapper (never raw `/bin/rm`), then
  `gpgconf --reload gpg-agent` and re-run `ssh-add`.
- **Split-brain `GPG_TTY` across shells:** running `ssh -T git@host` from a
  DIFFERENT shell/tty than the one where `gpg-connect-agent updatestartuptty
  /bye` was last run causes pinentry to try rendering in the WRONG pane (or
  nowhere visibly), hanging the command with no visible prompt anywhere.
  Always run the `updatestartuptty` call AND the ssh/git command that
  follows it in the SAME tmux pane/shell, back-to-back in one `send-keys`
  call — never split them across an agent's own non-interactive shell and a
  tmux ops pane.
