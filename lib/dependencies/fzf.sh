#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

if ! command -v fzf > /dev/null; then
	if $(prompt_confirmation 'Do you want to install fzf (fuzzy finder)?'); then

    if ! is_installer_available; then
      log_warn "Auto install not supported for your system, you will need to install it manually"
      return 0
    fi
    
    install_package fzf
    
    if [[ "$PKG_MANAGER" = "brew" ]]; then
      sh -c "$(brew --prefix)/opt/fzf/install"
    fi

		log_success 'Dependency `fzf` installed successfully'
	else
		log_info 'Skipping fzf installation'
	fi
else
	log_success 'Dependency `fzf` already installed'
fi
