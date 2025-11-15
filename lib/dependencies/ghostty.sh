#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

if ! command -v ghostty > /dev/null; then # Installed in mac by default
  if ! is_installer_available; then
    log_warn "Auto install not supported for your system, you will need to install it manually"
    return 0
  fi
    
  install_package ghostty
	
	log_success 'Dependency `ghostty` installed successfully'
else
	log_success 'Dependency `ghostty` already installed'
fi
