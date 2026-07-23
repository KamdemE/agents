# Sourced from Termux ~/.zshrc via ~/.k25-remote.zsh — skill: k-25
# Attaches to the always-on PC tmux session "default" (never spawns session "ubuntu").

alias ubuntu='ssh ubuntu -t tmux attach -t default'
