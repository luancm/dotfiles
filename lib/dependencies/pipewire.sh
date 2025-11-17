#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

packages=(
  pipewire
  pipewire-alsa
  pipewire-pulse
  pipewire-jack
  pipewire-v4l2
  wireplumber
  pwvucontrol
)

if ! is_installer_available; then
  log_warn "Auto install not supported for your system, please install: ${packages[*]}"
  return 0
fi

for pkg in "${packages[@]}"; do
  if is_package_installed "$pkg"; then
    log_success "Dependency \`$pkg\` already installed"
  else
    install_package "$pkg"
    log_success "Dependency \`$pkg\` installed successfully"
  fi
done

if command -v systemctl >/dev/null 2>&1; then
  if systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service >/dev/null 2>&1; then
    log_success 'Enabled PipeWire + WirePlumber user services'
  else
    log_warn 'Could not enable PipeWire services automatically; run `systemctl --user enable --now pipewire pipewire-pulse wireplumber`'
  fi
else
  log_warn 'systemctl not detected; enable PipeWire services manually'
fi
