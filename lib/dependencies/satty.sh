#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

# Screenshot stack for Wayland: grim (capture) + slurp (region) + satty (annotate).
# Not needed on macOS.
if $is_mac_os; then
  return 0
fi

ensure_cmd_pkg() {
  local cmd="$1" pkg="${2:-$1}"
  if command -v "$cmd" > /dev/null; then
    log_success "Dependency `$pkg` already installed"
    return 0
  fi
  if ! is_package_available "$pkg"; then
    log_warn "Package `$pkg` not available in $PKG_MANAGER repositories. Skipping."
    return 1
  fi
  install_package "$pkg" && log_success "Dependency `$pkg` installed successfully"
}

if command -v grim > /dev/null && command -v slurp > /dev/null && command -v satty > /dev/null; then
  log_success "Screenshot stack (grim + slurp + satty) already installed"
  return 0
fi

if ! remembered_confirmation satty "Do you want to install the screenshot stack (grim + slurp + satty)?"; then
  log_info "Skipping screenshot stack installation"
  return 0
fi

if ! is_installer_available; then
  log_warn "No package manager found. Please install grim, slurp, and satty manually."
  return 0
fi

ensure_cmd_pkg grim
ensure_cmd_pkg slurp
if ! ensure_cmd_pkg satty; then
  log_info "satty may need to be built from source: https://github.com/gabm/satty"
fi
