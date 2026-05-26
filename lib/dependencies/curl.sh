#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

if command -v curl > /dev/null; then
  log_success 'Dependency `curl` already installed'
else
  if ! is_installer_available; then
    log_warn "Auto install not supported for your system, you will need to install curl manually"
    return 0
  fi

  install_package curl
  log_success 'Dependency `curl` installed successfully'
fi
