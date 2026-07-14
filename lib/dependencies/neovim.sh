#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

if ! command -v nvim > /dev/null; then
	if prompt_confirmation 'Do you want to install neovim?'; then

    if ! is_installer_available; then
      log_warn "Auto install not supported for your system, you will need to install it manually"
      return 0
    fi

    install_package neovim

		log_success 'Dependency `neovim` installed successfully'
	else
		log_info 'Skipping neovim installation'
	fi
else
	log_success 'Dependency `neovim` already installed'
fi
