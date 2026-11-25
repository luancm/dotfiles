#!/bin/sh

alias l="ls -lAh"
alias la="ls -A"
alias ll="ls -lh"
alias lS="ls -lSh"                      # largest first

alias grep="grep --color=auto"
alias dus="du -sh * | sort -hr"         # folder sizes, largest first

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
    if [[ -n "$WAYLAND_DISPLAY" ]] && (( $+commands[wl-copy] )); then
        alias pbcopy='wl-copy'
        alias pbpaste='wl-paste --no-newline'
    else
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
    fi
else
    alias ls="ls -G"
    alias reload!="exec $SHELL -l"
fi
