#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

# zoxide is a smarter `cd` (provides `z`/`zi`). It also backs sesh's directory
# suggestions, so it pairs well with the tmux session switcher.
if command -v zoxide > /dev/null; then
  log_success 'Dependency `zoxide` already installed'
  return 0
fi

if ! prompt_confirmation 'Do you want to install zoxide (smarter cd; powers `z` and sesh)?'; then
  log_info 'Skipping zoxide installation'
  return 0
fi

if ! is_installer_available; then
  log_warn 'Auto install not supported for your system; install zoxide manually'
  return 0
fi

if install_package zoxide; then
  log_success 'Dependency `zoxide` installed successfully'
else
  log_error 'Failed to install zoxide'
fi
