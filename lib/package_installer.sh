#!/usr/bin/env bash

source "$DOTFILES/lib/io_handlers.sh"

# Detect package manager and set variable.
# Priority: yay > pacman > apt > brew (Linuxbrew loses to apt intentionally).
if command -v yay > /dev/null; then
    PKG_MANAGER="yay"
    PKG_INSTALL="yay -S --needed --noconfirm"
    PKG_CHECK="yay -Qi"
elif command -v pacman > /dev/null; then
    PKG_MANAGER="pacman"
    PKG_INSTALL="sudo pacman -S --needed --noconfirm"
    PKG_CHECK="pacman -Qi"
elif command -v apt > /dev/null; then
    PKG_MANAGER="apt"
    PKG_INSTALL="sudo DEBIAN_FRONTEND=noninteractive apt install -y"
    PKG_CHECK="dpkg -s"
elif command -v brew > /dev/null; then
    PKG_MANAGER="brew"
    PKG_INSTALL="brew install"
    PKG_CHECK="brew ls --versions"
else
    PKG_MANAGER=""
    PKG_INSTALL=""
    PKG_CHECK=""
fi

# Once-per-run apt update marker.
_DOTFILES_APT_UPDATED_FLAG="${TMPDIR:-/tmp}/dotfiles-apt-updated-$$"

get_package_name() {
    local package=$1

    case "$PKG_MANAGER" in
        apt)
            case "$package" in
                openssh) echo "openssh-client" ;;
                fd) echo "fd-find" ;;
                *) echo "$package" ;;
            esac
            ;;
        *)
            echo "$package"
            ;;
    esac
}

is_package_available() {
    local package=$1
    local distro_package
    distro_package=$(get_package_name "$package")

    case "$PKG_MANAGER" in
        apt)
            apt-cache show "$distro_package" &>/dev/null
            ;;
        yay)
            yay -Si "$distro_package" &>/dev/null
            ;;
        pacman)
            pacman -Si "$distro_package" &>/dev/null
            ;;
        brew)
            brew info --json=v2 "$distro_package" &>/dev/null || brew info "$distro_package" &>/dev/null
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
    local distro_package
    distro_package=$(get_package_name "$package")
    $PKG_CHECK $distro_package > /dev/null 2>&1
}

_ensure_apt_updated() {
    if [[ "$PKG_MANAGER" != "apt" ]]; then
        return 0
    fi
    if [[ -f "$_DOTFILES_APT_UPDATED_FLAG" ]]; then
        return 0
    fi
    log_info "Updating apt package index (once this run)..."
    sudo apt update -qq
    : > "$_DOTFILES_APT_UPDATED_FLAG"
}

install_package() {
    local package=$1
    local distro_package
    distro_package=$(get_package_name "$package")

    if [[ -z "$PKG_MANAGER" ]]; then
        log_warn "No supported package manager found."
        return 1
    fi

    if ! is_package_available "$package"; then
        log_warn "Package '$package' is not available in $PKG_MANAGER repositories."
        log_info "You may need to install it manually."
        return 1
    fi

    log_info "Installing $distro_package using $PKG_MANAGER..."
    _ensure_apt_updated

    # shellcheck disable=SC2086
    if $PKG_INSTALL $distro_package; then
        return 0
    fi
    return 1
}
