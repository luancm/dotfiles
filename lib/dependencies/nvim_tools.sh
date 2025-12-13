#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

# Packages required by Neovim plugins (e.g., Telescope, Luarocks-based tooling)
declare -A NVIM_DEPENDENCIES=(
  [ripgrep]="rg"
  [fd]="fd"
  [luarocks]="luarocks"
  [wget]="wget"
)

for package in "${!NVIM_DEPENDENCIES[@]}"; do
  binary="${NVIM_DEPENDENCIES[$package]}"

  if command -v "$binary" > /dev/null; then
    log_success "Neovim dependency \`$package\` already installed"
    continue
  fi

  if ! is_installer_available; then
    log_warn "Neovim dependency \`$package\` missing. Install it manually for full Neovim support."
    continue
  fi

  if $(prompt_confirmation "Install Neovim dependency '$package'? (required for Telescope and plugin tooling)"); then
    if install_package "$package"; then
      log_success "Neovim dependency \`$package\` installed successfully"
    else
      log_error "Failed to install Neovim dependency \`$package\`"
    fi
  else
    log_info "Skipping installation of \`$package\`"
  fi

done
