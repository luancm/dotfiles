#!/usr/bin/env bash

# Wayle is a Linux/Hyprland bar. The supported automatic install path is the
# Arch Linux AUR binary package; other systems can install it manually.
source "$DOTFILES/lib/io_handlers.sh"

if [[ "${OSTYPE:-}" != linux-* ]]; then
  log_warn 'Wayle is Linux/Hyprland-only; skipping on this OS.'
  return 0
fi

if command -v wayle > /dev/null; then
  log_success 'Dependency `wayle` already installed'
  return 0
fi

if ! command -v Hyprland > /dev/null; then
  log_warn 'Hyprland not detected; skipping Wayle.'
  return 0
fi

if ! command -v pacman > /dev/null || ! command -v yay > /dev/null; then
  log_warn 'Wayle auto-install requires Arch Linux with `yay`; skipping.'
  return 0
fi

if ! remembered_confirmation wayle \
    'Do you want to install Wayle (the Hyprland bar)?'; then
  log_info 'Skipping Wayle installation'
  return 0
fi

if yay -S --needed wayle-bin; then
  if command -v wayle > /dev/null; then
    log_success 'Dependency `wayle` installed successfully'
  else
    log_warn 'yay completed but `wayle` is not on PATH; skipping.'
  fi
else
  log_warn 'Could not install `wayle-bin` via yay; continuing without Wayle.'
fi

return 0
