#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

if ! command -v ghostty > /dev/null; then
  if ! is_installer_available; then
    log_warn "Auto install not supported for your system, you will need to install it manually"
    return 0
  fi
  
  # Check if package is available in repos
  if is_package_available ghostty; then
    install_package ghostty
    log_success 'Dependency `ghostty` installed successfully'
  else
    log_warn "Package 'ghostty' is not available in $PKG_MANAGER repositories."
  fi
else
	log_success 'Dependency `ghostty` already installed'
fi
