# Sourced from Termux ~/.zshrc via ~/.kphones-remote.zsh — skill: k-phones
# Attaches to the always-on PC tmux session "default" (never spawns session "ubuntu").

alias ubuntu='ssh ubuntu -t tmux attach -t default'
