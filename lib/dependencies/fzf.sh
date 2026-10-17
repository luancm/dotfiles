#!/usr/bin/env bash

if ! command -v fzf > /dev/null; then
  if remembered_confirmation fzf 'Do you want to install fzf (fuzzy finder)?'; then

    if ! is_installer_available; then
      log_warn "Auto install not supported for your system, you will need to install it manually"
      return 0
    fi

    if ! install_package fzf; then
      log_error 'Failed to install fzf'
      return 0
    fi

    # zshrc loads fzf itself; never let fzf's script edit rc files.
    if [[ "$PKG_MANAGER" = "brew" ]]; then
      "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
    fi

    log_success 'Dependency `fzf` installed successfully'
  else
    log_info 'Skipping fzf installation'
  fi
else
  log_success 'Dependency `fzf` already installed'
fi
