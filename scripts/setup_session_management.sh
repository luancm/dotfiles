#!/usr/bin/env bash
# This script modifies SYSTEM files. Run with sudo/root privileges.

# Determine DOTFILES path (assuming script is in scripts/ subdir)
export DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source IO handlers
if [ -f "$DOTFILES/lib/io_handlers.sh" ]; then
    source "$DOTFILES/lib/io_handlers.sh"
else
    echo "Error: Could not find lib/io_handlers.sh at $DOTFILES/lib/io_handlers.sh"
    exit 1
fi

# Ask for sudo upfront if not running as root
if [ "$EUID" -ne 0 ]; then
    log_info "This script requires root privileges to modify system files."
    sudo -v
    if [ $? -ne 0 ]; then
        log_error "This script must be run with sudo privileges. Aborting."
        exit 1
    fi
fi

# Confirmation prompt
log_info "This script will modify system configuration files:"
echo "  - /etc/greetd/config.toml (Greeter configuration)"
echo "  - /etc/pam.d/greetd (Keyring auto-unlock)"
echo "  - Enable 'greetd' systemd service"
echo ""

if ! prompt_confirmation "Do you want to proceed?"; then
    log_warn "Aborted."
    exit 0
fi

log_info ">>> Setting up System Services (Greetd & PAM)"

# 1. Setup Greetd Config (Login Manager)
GREETD_CONFIG="/etc/greetd/config.toml"
SOURCE_CONFIG="$DOTFILES/system_configs/etc/greetd/config.toml"

if [ -f "$GREETD_CONFIG" ]; then
    log_info "Backing up $GREETD_CONFIG to $GREETD_CONFIG.bak"
    sudo cp $GREETD_CONFIG "$GREETD_CONFIG.bak"
    
    # Use the source file if it exists
    if [ -f "$SOURCE_CONFIG" ]; then
        log_info "Copying configuration from $SOURCE_CONFIG"
        sudo cp "$SOURCE_CONFIG" "$GREETD_CONFIG"
        log_success "Updated $GREETD_CONFIG"
    else
        log_error "Source config not found at $SOURCE_CONFIG"
    fi
else
    log_warn "Warning: $GREETD_CONFIG not found. Is greetd installed?"
fi

# 2. Setup PAM for Keyring Auto-unlock
# This allows the login password to unlock the keyring automatically
PAM_FILE="/etc/pam.d/greetd"
if [ -f "$PAM_FILE" ]; then
    # Check if we already added it to avoid duplicates
    if ! grep -q "pam_gnome_keyring.so" "$PAM_FILE"; then
        log_info "Backing up $PAM_FILE to $PAM_FILE.bak"
        sudo cp "$PAM_FILE" "$PAM_FILE.bak"
        
        # Add auth optional at the end of auth section (simplified)
        sudo bash -c "echo 'auth       optional     pam_gnome_keyring.so' >> '$PAM_FILE'"
        sudo bash -c "echo 'session    optional     pam_gnome_keyring.so auto_start' >> '$PAM_FILE'"
        
        log_success "Updated $PAM_FILE for keyring auto-unlock"
    else
        log_info "PAM config already has gnome-keyring entries. Skipping."
    fi
fi

# 3. Enable Greetd Service
log_info "Enabling greetd service..."
sudo systemctl enable greetd.service

log_success ">>> System setup complete. Please reboot to see changes."

