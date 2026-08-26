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
