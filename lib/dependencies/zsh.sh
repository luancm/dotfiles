#!/usr/bin/env bash

# zsh plugins (syntax-highlighting, autosuggestions, completions) are managed
# by antidote via zsh/zsh_plugins.txt, not the system package manager.

if command -v zsh > /dev/null && grep -q "$(command -v zsh)" /etc/shells; then
  log_success 'Dependency `zsh` already installed'
elif ! is_installer_available; then
  log_warn 'Auto install not supported for your system, you will need to install zsh manually'
elif install_package zsh; then
  log_success 'Dependency `zsh` installed successfully'
else
  log_error 'Failed to install zsh'
fi
