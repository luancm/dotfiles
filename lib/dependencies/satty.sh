#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

# satty for screen shots (not needed on macOS)
if ! $is_mac_os; then
  if command -v grim > /dev/null && command -v satty > /dev/null; then
    log_success 'Dependency `satty` and subdependencies `grim` already installed'
    return 0
  fi

  if $(prompt_confirmation 'Do you want to install satty (for screen shots)?'); then
    if ! is_installer_available; then
      log_warn 'No package manager found. Please install grim and satty manually.'
      return 0
    fi
    
    # Install grim first (subdependency)
    if ! command -v grim > /dev/null; then
      if is_package_available grim; then
        install_package grim
        log_success 'SubDependency `grim` installed successfully'
      else
        log_warn 'Package `grim` not available in repositories. Skipping.'
        log_info 'grim is required for satty. Please install it manually.'
        return 0
      fi
    else
      log_success 'SubDependency `grim` already installed'
    fi

    # Install satty
    if ! command -v satty > /dev/null; then
      if is_package_available satty; then
        install_package satty
        log_success 'Dependency `satty` installed successfully'
      else
        log_warn 'Package `satty` not available in repositories. Skipping.'
        log_info 'satty may need to be built from source: https://github.com/gabm/satty'
      fi
    else
      log_success 'Dependency `satty` already installed'
    fi
  else
    log_info 'Skipping satty installation'
  fi
fi
