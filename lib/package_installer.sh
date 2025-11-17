#!/bin/bash

source $DOTFILES/lib/io_handlers.sh

# Detect package manager and set variable
if command -v yay > /dev/null; then
    PKG_MANAGER="yay"
    PKG_INSTALL="yay -S"
    PKG_CHECK="yay -Qi"
elif command -v pacman > /dev/null; then
    PKG_MANAGER="pacman"
    PKG_INSTALL="sudo pacman -S"
    PKG_CHECK="sudo pacman -Qi"
elif command -v brew > /dev/null; then
    PKG_MANAGER="brew"
    PKG_INSTALL="brew install"
    PKG_CHECK="brew ls --versions"
else
    PKG_MANAGER=""
    PKG_INSTALL=""
    PKG_CHECK=""
fi


is_installer_available() {
    [[ -n "$PKG_MANAGER" ]]
}

is_package_installed() {
  local package=$1

  $PKG_CHECK $package > /dev/null
}

install_package() {
    local package=$1
    
    if [[ -z "$PKG_MANAGER" ]]; then
        log_warn "No supported package manager found."
        return 1
    fi
    
    log_info "Installing $package using $PKG_MANAGER..."
    $PKG_INSTALL $package
}

