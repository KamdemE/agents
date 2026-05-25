# k-phones — sourced from Termux ~/.kphones-remote.zsh
# Start sshd when a Termux shell opens (covers app reopen; not only device boot).

_kphones_sshd_autostart() {
  command -v sshd >/dev/null 2>&1 || return 0
  if pgrep -x sshd >/dev/null 2>&1; then
    return 0
  fi
  sshd 2>/dev/null || true
}

_kphones_sshd_autostart
