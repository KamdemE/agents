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
