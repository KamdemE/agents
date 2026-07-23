# KπX phones — idempotent source from $HOME/.kshrc. Skill: k-25

[[ -n "${_K25_PHONES_KSH_SOURCED:-}" ]] && return 0
_K25_PHONES_KSH_SOURCED=1

export K25_ASSETS="${HOME}/.agents/skills/k-25/assets"
export K25_CONFIG_DIR="${HOME}/.config/kpihx/phones"
export PATH="${K25_ASSETS}:${PATH}"

alias s25='ssh kpihx-s25'
