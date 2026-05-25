# KπX phones — idempotent source from $HOME/.kshrc. Skill: k-phones

[[ -n "${_KPHONES_PHONES_KSH_SOURCED:-}" ]] && return 0
_KPHONES_PHONES_KSH_SOURCED=1

export KPHONES_ASSETS="${HOME}/.agents/skills/k-phones/assets"
export KPHONES_CONFIG_DIR="${HOME}/.config/kpihx/phones"
export PATH="${KPHONES_ASSETS}:${PATH}"

alias s25='ssh kpihx-s25'
