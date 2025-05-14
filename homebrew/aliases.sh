#!/usr/bin/env bash

if [[ -z $DOTFILES ]]; then echo 'Dotfiles were not installed, to install run `source ~/.dotfiles/install`'; return 1; fi
source $DOTFILES/lib/io_handlers.sh

alias brew_upgrade="bash $DOTFILES/homebrew/upgrade.sh"
