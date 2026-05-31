#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

if  command -v zsh > /dev/null && grep "$(command -v zsh)" /etc/shells > /dev/null; then
	log_success 'Dependency `zsh` already installed'
else
  install_package zsh
fi

# zsh plugins (syntax-highlighting, autosuggestions, completions) are managed
# by antidote via zsh/zsh_plugins.txt, not the system package manager.

log_success 'Dependency `zsh` installed successfully'
