#!/usr/bin/env bash

# sesh is a smart tmux session manager. It is fzf-driven (already a dotfiles
# dependency) and integrates with zoxide for directory suggestions. The tmux
# config binds `prefix + T` to a sesh picker popup.
if command -v sesh > /dev/null; then
  log_success 'Dependency `sesh` already installed'
  return 0
fi

if ! remembered_confirmation sesh \
    'Do you want to install sesh (smart, fzf-powered tmux session manager)?'; then
  log_info 'Skipping sesh installation'
  return 0
fi

# sesh has no pacman/apt package: use the pinned release binary
# (SESH_VERSION in lib/versions.env).
install_sesh_release() {
  local arch sha_var
  arch="$(release_arch)"
  if [[ "$(uname -s)" != Linux || -z "$arch" ]]; then
    log_warn 'No sesh release binary for this system; install it manually from https://github.com/joshmedeski/sesh'
    return 1
  fi
  sha_var="SESH_SHA256_${arch^^}"
  [[ "$arch" == aarch64 ]] && arch=arm64
  install_release_binary sesh \
    "https://github.com/joshmedeski/sesh/releases/download/${SESH_VERSION}/sesh_Linux_${arch}.tar.gz" \
    "${!sha_var}"
}

case "$PKG_MANAGER" in
  brew)
    install_package sesh ;;
  yay)
    # AUR package (Provides/Conflicts: sesh).
    yay -S --needed sesh-bin ;;
  *)
    install_sesh_release ;;
esac

if command -v sesh > /dev/null; then
  log_success 'Dependency `sesh` installed successfully'
else
  log_error 'Failed to install sesh'
fi
