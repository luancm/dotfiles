#!/usr/bin/env bash

# Installs the platform's "essential build tools" meta-package:
#   - apt          -> build-essential (gcc, g++, make, libc-dev, dpkg-dev)
#   - pacman/yay   -> base-devel      (gcc, make, patch, pkg-config, ...)
#   - brew (macOS) -> Xcode Command Line Tools (xcode-select --install)
#
# This is the cross-platform answer to "I need to compile something /
# run a Makefile that calls gcc/cc".

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

build_tools_already_installed() {
  case "$PKG_MANAGER" in
    apt)
      dpkg -s build-essential > /dev/null 2>&1
      ;;
    pacman|yay)
      # base-devel is a group; check via a representative member.
      pacman -Qi gcc > /dev/null 2>&1 && pacman -Qi make > /dev/null 2>&1
      ;;
    brew)
      # On macOS, "build tools" == Xcode Command Line Tools.
      xcode-select -p > /dev/null 2>&1
      ;;
    *)
      # Fallback: assume present if both make and a C compiler exist.
      command -v make > /dev/null && (command -v gcc > /dev/null || command -v cc > /dev/null)
      ;;
  esac
}

install_build_tools() {
  case "$PKG_MANAGER" in
    apt)
      sudo apt update -qq
      sudo apt install -y build-essential
      ;;
    pacman|yay)
      sudo pacman -S --needed --noconfirm base-devel
      ;;
    brew)
      # `xcode-select --install` opens a GUI dialog and exits; the
      # actual install proceeds in the background. We can't reliably
      # wait for it from a script.
      xcode-select --install 2>&1 | grep -v "already installed" || true
      log_info 'Xcode Command Line Tools installer launched; finish it via the GUI prompt.'
      ;;
    *)
      log_warn "Don't know how to install build tools for PKG_MANAGER='$PKG_MANAGER'"
      return 1
      ;;
  esac
}

if ! is_installer_available; then
  log_warn 'Auto install not supported for your system, you will need to install build tools manually'
  return 0
fi

if build_tools_already_installed; then
  log_success 'Dependency `build tools` already installed'
else
  if $(prompt_confirmation 'Install essential build tools (gcc, make, headers)? Required for compiling C/C++ and most Makefile projects.'); then
    if install_build_tools; then
      log_success 'Dependency `build tools` installed successfully'
    else
      log_error 'Failed to install build tools'
    fi
  else
    log_info 'Skipping build tools installation'
  fi
fi
