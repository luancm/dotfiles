#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh

# Session management tools are Arch Linux + Hyprland specific
# Skip on other distributions (packages not available in Ubuntu repos)
if ! command -v pacman > /dev/null; then
    log_info 'Session Management tools are Arch Linux specific. Skipping.'
    return 0
fi

# If in arch, install session management tools
if command -v Hyprland > /dev/null; then
     if ! prompt_confirmation "Hyprland detected. Install Session Management tools (greetd, hyprlock, etc)?"; then
        log_info '(Arch) Skipping Session Management tools installation.'
        return 0
    fi
else
    log_info '(Arch) Hyprland not detected. Skipping Session Management tools.'
    return 0
fi


log_info '(Arch) Installing Session Management tools...'

# Core tools: greetd (login), hyprlock (lock), hypridle (idle), wlogout (logout menu)
# gnome-keyring (secrets), wget (asset downloading), cage (compositor for greeter)
PACKAGES="greetd greetd-regreet hyprlock hypridle wlogout gnome-keyring wget cage"

if command -v yay > /dev/null; then
    yay -S --needed --noconfirm $PACKAGES
    log_success '(Arch) Installed Session Management tools successfully'
    
    # Bootstrap Wallpaper
    WALLPAPER_DIR="$HOME/Pictures/wallpapers"
    WALLPAPER_PATH="$WALLPAPER_DIR/landscape.jpg"
    CACHE_WALLPAPER="$HOME/.cache/current_wallpaper.jpg"
    
    if [ ! -f "$WALLPAPER_PATH" ]; then
         log_info "Bootstrapping wallpaper..."
         mkdir -p "$WALLPAPER_DIR"
         # High quality landscape from Unsplash
         wget -O "$WALLPAPER_PATH" "https://images.unsplash.com/photo-1472214103451-9374bd1c798e?q=80&w=2070&auto=format&fit=crop"
         log_success "Wallpaper downloaded to $WALLPAPER_PATH"
    fi

    # Ensure symlink for lockscreen/greeter stability
    mkdir -p "$HOME/.cache"
    if [ ! -L "$CACHE_WALLPAPER" ]; then
         ln -sf "$WALLPAPER_PATH" "$CACHE_WALLPAPER"
         log_success "Wallpaper symlinked to $CACHE_WALLPAPER"
    fi

    log_info "To complete the setup (Enable greetd & PAM auto-unlock), run:"
    log_info "bash scripts/setup_session_management.sh"

else
    log_error '(Arch) `yay` not found. Please install `yay` first.'
fi
