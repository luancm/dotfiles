#!/usr/bin/env bash

if ! command -v ssh-keygen > /dev/null; then # Installed in mac by default
  if ! is_installer_available; then
    log_warn "Auto install not supported for your system, you will need to install it manually"
    return 0
  fi

  if install_package openssh; then
    log_success 'Dependency `ssh-keygen` installed successfully through `openssh` package'
  else
    log_error 'Failed to install openssh'
  fi
else
  log_success 'Dependency `ssh-keygen` already installed'
fi
