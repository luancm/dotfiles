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
elif command -v apt > /dev/null; then
    PKG_MANAGER="apt"
    PKG_INSTALL="sudo apt install -y"
    PKG_CHECK="dpkg -s"
else
    # Check brew last since it can exist on Linux too
    if command -v brew > /dev/null; then
        PKG_MANAGER="brew"
        PKG_INSTALL="brew install"
        PKG_CHECK="brew ls --versions"
    else
        PKG_MANAGER=""
        PKG_INSTALL=""
        PKG_CHECK=""
    fi
fi


# Package name mapping between distros
# Usage: get_package_name <generic_name>
# Returns the distro-specific package name
get_package_name() {
    local package=$1
    
    case "$PKG_MANAGER" in
        apt)
            # Map Arch package names to Ubuntu/Debian equivalents
            case "$package" in
                openssh) echo "openssh-client" ;;
                # Most packages have the same name
                *) echo "$package" ;;
            esac
            ;;
        *)
            # For yay, pacman, brew - use original name
            echo "$package"
            ;;
    esac
}

# Check if a package is available in the repos
# This helps warn users about unavailable packages
is_package_available() {
    local package=$1
    local distro_package=$(get_package_name "$package")
    
    case "$PKG_MANAGER" in
        apt)
            # Check if package exists in apt cache
            apt-cache show "$distro_package" &>/dev/null
            ;;
        yay|pacman)
            # Arch repos - assume available
            return 0
            ;;
        brew)
            # Homebrew - assume available
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

is_installer_available() {
    [[ -n "$PKG_MANAGER" ]]
}

is_package_installed() {
    local package=$1
    local distro_package=$(get_package_name "$package")

    $PKG_CHECK $distro_package > /dev/null 2>&1
}

install_package() {
    local package=$1
    local distro_package=$(get_package_name "$package")
    
    if [[ -z "$PKG_MANAGER" ]]; then
        log_warn "No supported package manager found."
        return 1
    fi
    
    # Check if package is available
    if ! is_package_available "$package"; then
        log_warn "Package '$package' is not available in $PKG_MANAGER repositories."
        log_info "You may need to install it manually."
        return 1
    fi
    
    log_info "Installing $distro_package using $PKG_MANAGER..."
    
    # For apt, update cache if needed
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt update -qq
    fi
    
    $PKG_INSTALL $distro_package
}

