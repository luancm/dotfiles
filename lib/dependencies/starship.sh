#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

if ! command -v starship > /dev/null; then
  if ! is_installer_available; then
    log_warn "Auto install not supported for your system, you will need to install it manually"
    return 0
  fi
  
  # Try to install via package manager first
  if is_package_installed starship; then
    log_success 'Dependency `starship` already installed'
  elif is_package_available starship; then
    # Package is available in repos
    install_package starship
    log_success 'Dependency `starship` installed successfully'
  else
    # Package not in repos - use official curl installer
    log_info "Starship not available in $PKG_MANAGER repos. Using official installer..."
    
    if prompt_confirmation "Install starship using official installer (curl -sS https://starship.rs/install.sh | sh)?"; then
      if ! command -v curl > /dev/null; then
        log_info "Starship installer requires curl; running curl dependency installer..."
        source "$DOTFILES/lib/dependencies/curl.sh"
      fi

      if ! command -v curl > /dev/null; then
        log_error 'curl is required but could not be installed; cannot install starship.'
        return 1
      fi

      curl -sS https://starship.rs/install.sh | sh

      if command -v starship > /dev/null; then
        log_success 'Dependency `starship` installed successfully'
      else
        log_error 'Starship installation failed'
      fi
    else
      log_info 'Skipping starship installation'
    fi
  fi
else
	log_success 'Dependency `starship` already installed'
fi
