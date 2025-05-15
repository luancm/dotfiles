#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

ensure_installer() {
  if ! is_installer_available; then
    log_warn "Auto install not supported for your system, you will need to install it manually"
    exit 0
  fi
}

if  command -v zsh > /dev/null && grep "$(command -v zsh)" /etc/shells > /dev/null; then
	log_success 'Dependency `zsh` already installed'
else
  install_package zsh
fi

if ! is_package_installed  zsh-syntax-highlighting; then
  install_package zsh-syntax-highlighting
  log_success "> zsh-syntax-highlighting installed"
else
  log_info "> zsh-syntax-highlighting already installed"
fi

if ! is_package_installed zsh-autosuggestions; then
  install_package zsh-autosuggestions
  log_success "> zsh-autosuggestions installed"
else
  log_info "> zsh-autosuggestions already installed"
fi

if ! is_package_installed  zsh-completions; then
  install_package zsh-completions
  log_success "> zsh-completions installed"
else
  log_info "> zsh-completions already installed"
fi

log_success 'Dependency `zsh` installed successfully'
