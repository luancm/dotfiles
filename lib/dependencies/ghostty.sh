#!/usr/bin/env bash

source "$DOTFILES/lib/io_handlers.sh"
source "$DOTFILES/lib/package_installer.sh"

if command -v ghostty > /dev/null; then
  log_success 'Dependency `ghostty` already installed'
  return 0
fi

if ! is_installer_available; then
  log_warn "Auto install not supported for your system, you will need to install ghostty manually"
  return 0
fi

if ! is_package_available ghostty; then
  log_warn "Package 'ghostty' is not available in $PKG_MANAGER repositories."
  return 0
fi

if ! remembered_confirmation ghostty 'Do you want to install ghostty (terminal emulator)?'; then
  log_info 'Skipping ghostty installation'
  return 0
fi

if install_package ghostty; then
  log_success 'Dependency `ghostty` installed successfully'
else
  log_error 'Failed to install ghostty'
fi
