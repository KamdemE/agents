#!/usr/bin/env zsh
# Full S25 Termux deploy: sshd persistence + tmux. Requires working ssh s25 once.
set -euo pipefail
DIR="${HOME}/.agents/skills/k-25/scripts"
zsh "${DIR}/termux-deploy-sshd.sh"
zsh "${DIR}/termux-deploy-tmux.sh"
echo "==> all deploy steps finished"
