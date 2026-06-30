#!/bin/sh

alias l="ls -lAh"
alias la="ls -A"
alias ll="ls -lSh"

alias grep="grep --color=auto"
alias duf="du -sh * | sort -hr"

alias docker_clean_images='docker rmi $(docker images -a --filter=dangling=true -q)'
alias docker_clean_ps='docker rm $(docker ps --filter=status=exited --filter=status=created -q)'
alias docker_killall_ps='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'

alias pxmlab='ssh -t homelab \~/.local/bin/pxm'

# tmux
alias tma="tmux attach"                  # attach to the most-recent session
alias tmat="tmux attach -t"              # attach to a named one: tmat work
alias tms="tmux new-session -s"          # new named session: tms work
alias tml="tmux ls"                      # list sessions
alias tmk="tmux kill-session -t"         # kill a named session: tmk work
alias tmm="tmux new-session -A -s main"  # jump to (or create) the main session

if ! $is_mac_os; then
    alias reload!="exec $(getent passwd $(id -un) | awk -F : '{print $NF}') -l"
    alias ls="ls -F --color"
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
else
    alias ls="ls -G"
    alias reload!="exec $SHELL -l"
fi
