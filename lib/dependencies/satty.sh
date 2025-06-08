#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh

# satty for screen shots
if ! $is_mac_os; then
  if command -v grim > /dev/null && command -v satty > /dev/null; then
    log_success 'Dependency `satty` and subdependencies `grim` already installed'
    return 0
  fi

  if $(prompt_confirmation 'Do you want to install satty (for screen shots)?'); then
    if ! command -v grim > /dev/null; then
      if command -v pacman > /dev/null; then
        sudo pacman -S grim
        log_success 'SubDependency `grim` installed successfully'
      fi
    else
      log_success 'SubDependency `grim` already installed'
    fi

    if ! command -v satty > /dev/null; then
      if command -v pacman > /dev/null; then
        sudo pacman -S grim satty
        log_success 'Dependency `satty` installed successfully'
      fi
    else
      log_success 'Dependency `satty` already installed'
    fi
  else
    log_info 'Skipping satty installation'
  fi
fi
