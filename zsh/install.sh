#!/usr/bin/env bash

if [[ -z $DOTFILES ]]; then echo 'Dotfiles were not installed, to install run `~/.dotfiles/install`'; return 1; fi
source $DOTFILES/lib/io_handlers.sh

if ! command -v zsh > /dev/null; then log_error 'Trying to configure zsh without it installed. Do not forget to run `~/.dotfiles/install` before'; exit; fi

# Check which shell is configured in passwd (this is because the $SHELL variable is only updated on login)
zsh_path=$(which zsh)
if [[ "${SHELL#*zsh}" = "$SHELL" ]]; then
    if command -v chsh >/dev/null; then
        chsh -s "$zsh_path" && log_success "set $("$zsh_path" --version) at $zsh_path as default shell"
    fi
else
    log_success 'ZSH Already the default shell'
fi

