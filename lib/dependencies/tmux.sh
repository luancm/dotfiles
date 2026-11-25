#!/usr/bin/env bash

# TPM (Tmux Plugin Manager) lives under XDG so it sits next to the symlinked
# ~/.config/tmux/tmux.conf and powers the `@plugin` lines in that config.
# tmux itself comes from lib/tools.list.
TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if ! command -v tmux > /dev/null; then
  return 0
fi

# Clone TPM so `prefix + I` can install the plugins declared in tmux.conf.
# Skipped if git is missing or TPM is already present (idempotent).
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
