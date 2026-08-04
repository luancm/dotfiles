#!/usr/bin/env bash

source \"$DOTFILES/lib/io_handlers.sh\"
source \"$DOTFILES/lib/package_installer.sh\"

# playerctl: MPRIS media keys (play/pause/next/prev) used by Hyprland binds.
if $is_mac_os; then
  return 0
fi

if command -v playerctl > /dev/null; then
  log_success "Dependency `playerctl` already installed"
  return 0
fi

if ! remembered_confirmation playerctl \
    "Do you want to install playerctl (media play/pause keys for Hyprland)?"; then
  log_info "Skipping playerctl installation"
  return 0
fi

if ! is_installer_available; then
  log_warn "Auto install not supported; install playerctl manually"
  return 0
fi

if install_package playerctl; then
  log_success "Dependency `playerctl` installed successfully"
else
  log_error "Failed to install playerctl"
fi
