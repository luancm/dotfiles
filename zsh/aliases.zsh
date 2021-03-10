#!/bin/sh

alias l="ls -lAh"
alias la="ls -A"
alias ll="ls -l"

alias grep="grep --color=auto"
alias duf="du -sh * | sort -hr"

alias docker_clean_images='docker rmi $(docker images -a --filter=dangling=true -q)'
alias docker_clean_ps='docker rm $(docker ps --filter=status=exited --filter=status=created -q)'

if [ "${OSTYPE#*darwin}" = "$OSTYPE" ]; then
    alias reload!="exec $(getent passwd $(id -un) | awk -F : '{print $NF}') -l"
    alias ls="ls -F --color"
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
else
    alias ls="ls -G"
    alias reload!="exec $SHELL -l"
fi