#!/usr/bin/env bash
# Set up the greetd login screen (ReGreet) and keyring auto-unlock.
# This script modifies SYSTEM files and asks for sudo.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES

if [ -f "$DOTFILES/lib/io_handlers.sh" ]; then
    source "$DOTFILES/lib/io_handlers.sh"
else
    echo "Error: Could not find lib/io_handlers.sh at $DOTFILES/lib/io_handlers.sh"
    exit 1
fi

if [ "$EUID" -ne 0 ]; then
    log_info "This script requires root privileges to modify system files."
    if ! sudo -v; then
        log_error "This script must be run with sudo privileges. Aborting."
        exit 1
    fi
fi

log_info "This script will modify system configuration files:"
echo "  - /etc/greetd/{config.toml,regreet.toml,regreet.css,wallpaper} (greeter)"
echo "  - /etc/pam.d/greetd (keyring auto-unlock)"
echo "  - Enable 'greetd' systemd service"
echo "Changed files are backed up as <file>.bak.<timestamp>."
echo ""

if ! prompt_confirmation "Do you want to proceed?"; then
    log_warn "Aborted."
    exit 0
fi

STAMP="$(date +%Y%m%d%H%M%S)"

# Copy SRC to DEST. Back up DEST first if it exists and is different.
install_system_file() {
    local src="$1" dest="$2" mode="${3:-644}"
    if [ -f "$dest" ] && sudo cmp -s "$src" "$dest"; then
        log_success "$dest is up to date"
        return 0
    fi
    if [ -f "$dest" ]; then
        sudo cp -p "$dest" "$dest.bak.$STAMP"
        log_info "Backed up $dest to $dest.bak.$STAMP"
    fi
    sudo install -m "$mode" "$src" "$dest"
    log_success "Updated $dest"
}

# Append LINE to FILE once.
add_line_once() {
    local file="$1" line="$2"
    if sudo grep -qxF "$line" "$file"; then
        return 0
    fi
    if [ ! -f "$file.bak.$STAMP" ]; then
        sudo cp -p "$file" "$file.bak.$STAMP"
        log_info "Backed up $file to $file.bak.$STAMP"
    fi
    printf '%s\n' "$line" | sudo tee -a "$file" > /dev/null
    log_success "Added to $file: $line"
}

log_info ">>> Setting up greetd and PAM"

GREETD_DIR="/etc/greetd"
SOURCE_DIR="$DOTFILES/system_configs/etc/greetd"
WALLPAPER_SRC="$HOME/.cache/current_wallpaper"

if [ -d "$GREETD_DIR" ]; then
    for name in config.toml regreet.toml regreet.css; do
        if [ -f "$SOURCE_DIR/$name" ]; then
            install_system_file "$SOURCE_DIR/$name" "$GREETD_DIR/$name"
        fi
    done

    # The wallpaper link can point to any image type; copy its content.
    if [ -e "$WALLPAPER_SRC" ]; then
        install_system_file "$WALLPAPER_SRC" "$GREETD_DIR/wallpaper"
    else
        log_warn "Current wallpaper not found at $WALLPAPER_SRC, skipping wallpaper update."
    fi
else
    log_warn "$GREETD_DIR not found. Is greetd installed?"
fi

# The login password unlocks the GNOME keyring.
PAM_FILE="/etc/pam.d/greetd"
if [ -f "$PAM_FILE" ]; then
    add_line_once "$PAM_FILE" 'auth       optional     pam_gnome_keyring.so'
    add_line_once "$PAM_FILE" 'session    optional     pam_gnome_keyring.so auto_start'
else
    log_warn "$PAM_FILE not found; skipping keyring auto-unlock."
fi

log_info "Enabling greetd service..."
sudo systemctl enable greetd.service

log_success ">>> System setup complete. Please reboot to see changes."
