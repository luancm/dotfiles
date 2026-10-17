#!/usr/bin/env bash

if ! command -v nvim > /dev/null; then
  if remembered_confirmation neovim 'Do you want to install neovim?'; then

    if ! is_installer_available; then
      log_warn "Auto install not supported for your system, you will need to install it manually"
      return 0
    fi

    if install_package neovim; then
      log_success 'Dependency `neovim` installed successfully'
    else
      log_error 'Failed to install neovim'
    fi
  else
    log_info 'Skipping neovim installation'
  fi
else
  log_success 'Dependency `neovim` already installed'
fi
