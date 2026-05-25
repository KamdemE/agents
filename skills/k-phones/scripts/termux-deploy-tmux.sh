#!/usr/bin/env zsh
# Deploy Termux tmux + zsh aliases on kpihx-s25 via SSH. Run from Ubuntu.
# Skill: k-phones

set -euo pipefail

readonly SKILL_ASSETS="${HOME}/.agents/skills/k-phones/assets"
readonly REMOTE='s25'
readonly MARKER='# k-phones termux remote'
readonly REMOTE_SNIPPET='.kphones-remote.zsh'

echo "==> pkg install tmux + termux-api (clipboard)"
ssh "$REMOTE" 'pkg install -y tmux termux-api 2>/dev/null || pkg install tmux termux-api'

echo "==> TPM"
ssh "$REMOTE" 'mkdir -p ~/.tmux/plugins; test -d ~/.tmux/plugins/tpm/.git || git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'

echo "==> ~/.tmux.conf"
scp "${SKILL_ASSETS}/termux-tmux.conf" "${REMOTE}:.tmux.conf"

echo "==> ~/${REMOTE_SNIPPET} + ~/.zshrc hook"
scp "${SKILL_ASSETS}/termux-zshrc-snippet.sh" "${REMOTE}:${REMOTE_SNIPPET}"
ssh "$REMOTE" "chmod 644 ~/${REMOTE_SNIPPET}"
ssh "$REMOTE" "MARKER='${MARKER}'; SNIPPET='${REMOTE_SNIPPET}'; ZSHRC=\$HOME/.zshrc
touch \"\$ZSHRC\"
if grep -qF \"\$MARKER\" \"\$ZSHRC\" 2>/dev/null; then
  grep -vF \"\$MARKER\" \"\$ZSHRC\" | grep -v '^alias ubuntu=' | grep -v 'kphones-remote.zsh' > \"\${ZSHRC}.tmp\"
  mv \"\${ZSHRC}.tmp\" \"\$ZSHRC\"
fi
printf '%s\n[[ -f ~/%s ]] && . ~/%s\n' \"\$MARKER\" \"\$SNIPPET\" \"\$SNIPPET\" >> \"\$ZSHRC\""

echo "==> tpm install_plugins"
ssh "$REMOTE" 'bash ~/.tmux/plugins/tpm/bin/install_plugins 2>/dev/null; tmux kill-server 2>/dev/null; true'

echo "==> done — Termux: ubuntu → PC tmux attach default | tmux (local) | termux-clipboard-set"
