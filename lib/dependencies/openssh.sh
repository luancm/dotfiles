#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

if ! command -v ssh-keygen > /dev/null; then # Installed in mac by default
  if ! is_installer_available; then
    log_warn "Auto install not supported for your system, you will need to install it manually"
    exit 0
  fi
    
  install_package openssh
	
	log_success 'Dependency `ssh-keygen` installed successfully through `openssh` package'
else
	log_success 'Dependency `ssh-keygen` already installed'
fi
