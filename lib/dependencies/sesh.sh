#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

# sesh is a smart tmux session manager. It is fzf-driven (already a dotfiles
# dependency) and integrates with zoxide for directory suggestions. The tmux
# config binds `prefix + T` to a sesh picker popup.
if command -v sesh > /dev/null; then
  log_success 'Dependency `sesh` already installed'
  return 0
fi

if ! prompt_confirmation 'Do you want to install sesh (smart, fzf-powered tmux session manager)?'; then
  log_info 'Skipping sesh installation'
  return 0
fi

# sesh has no first-party pacman/apt package; fall back to `go install`.
install_sesh_via_go() {
  if ! command -v go > /dev/null; then
    log_warn 'sesh has no native package here and Go is not installed.'
    log_info 'Install Go (rerun the installer) or install sesh manually from https://github.com/joshmedeski/sesh'
    return 1
  fi
  log_info 'Installing sesh via `go install`...'
  GOBIN="$HOME/go/bin" go install github.com/joshmedeski/sesh/v2@latest
}

case "$PKG_MANAGER" in
  brew)
    install_package sesh ;;
  yay)
    # AUR package (Provides/Conflicts: sesh).
    yay -S --needed sesh-bin ;;
  *)
    # pacman-only, apt, or no package manager: build from source via Go.
    install_sesh_via_go ;;
esac

if command -v sesh > /dev/null || [ -x "$HOME/go/bin/sesh" ]; then
  log_success 'Dependency `sesh` installed successfully'
  if ! command -v sesh > /dev/null; then
    log_info 'Ensure $HOME/go/bin is on your PATH (handled by the dotfiles zshrc).'
  fi
else
  log_error 'Failed to install sesh'
fi
