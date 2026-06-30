#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

# TPM (Tmux Plugin Manager) lives under XDG so it sits next to the symlinked
# ~/.config/tmux/tmux.conf and powers the `@plugin` lines in that config.
TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if command -v tmux > /dev/null; then
  log_success 'Dependency `tmux` already installed'
else
  if prompt_confirmation 'Do you want to install tmux (terminal multiplexer)?'; then
    if ! is_installer_available; then
      log_warn "Auto install not supported for your system, you will need to install tmux manually"
      return 0
    fi

    if install_package tmux; then
      log_success 'Dependency `tmux` installed successfully'
    else
      log_error 'Failed to install tmux'
      return 0
    fi
  else
    log_info 'Skipping tmux installation'
    return 0
  fi
fi

# Clone TPM so `prefix + I` can install the plugins declared in tmux.conf.
# Skipped if tmux/git are missing or TPM is already present (idempotent).
if command -v git > /dev/null; then
  if [ -d "$TPM_DIR" ]; then
    log_success 'tmux plugin manager (tpm) already present'
  else
    log_info 'Installing tmux plugin manager (tpm)...'
    if git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
      log_success "tpm installed to $TPM_DIR"
      log_info 'In tmux, press `prefix + I` (capital i) to install plugins'
    else
      log_warn 'Failed to clone tpm; install it manually to enable tmux plugins'
    fi
  fi
fi
