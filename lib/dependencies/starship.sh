#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

if ! command -v starship > /dev/null; then
  if ! is_installer_available; then
    log_warn "Auto install not supported for your system, you will need to install it manually"
    return 0
  fi
    
  install_package starship

	log_success 'Dependency `starship` installed successfully'
else
	log_success 'Dependency `starship` already installed'
fi
