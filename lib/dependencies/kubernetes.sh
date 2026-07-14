#!/usr/bin/env bash

# Installs Kubernetes CLI tooling.
#   - kubectl: the Kubernetes command-line client.
#   - k9s:     a terminal UI for interacting with clusters.
#
# Both are available on Homebrew (macOS) and the Arch repos (pacman/yay).
# The whole installer is opt-in behind a confirmation prompt.

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

ensure_package() {
  local pkg=$1
  if is_package_installed "$pkg"; then
    log_success "Dependency \`$pkg\` already installed"
  else
    install_package "$pkg" && log_success "Dependency \`$pkg\` installed successfully"
  fi
}

# Idempotency: skip the whole installer if both tools are already present.
if command -v kubectl > /dev/null && command -v k9s > /dev/null; then
  log_success 'Dependency `kubectl` already installed'
  log_success 'Dependency `k9s` already installed'
  return 0
fi

if ! is_installer_available; then
  log_warn 'Auto install not supported for your system; install kubectl/k9s manually.'
  return 0
fi

if ! prompt_confirmation 'Do you want to install Kubernetes tools (kubectl + k9s)?'; then
  log_info 'Skipping Kubernetes tools installation'
  return 0
fi

if [[ "$PKG_MANAGER" == "brew" || "$PKG_MANAGER" == "yay" || "$PKG_MANAGER" == "pacman" ]]; then
  ensure_package kubectl
  ensure_package k9s
else
  log_warn "Don't know how to install kubectl/k9s on $PKG_MANAGER automatically; install manually."
  return 0
fi
