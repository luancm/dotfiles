#!/usr/bin/env bash

# Installs a persistent Wayland clipboard manager.
#   - wl-clipboard: provides wl-copy / wl-paste.
#   - cliphist:     stores clipboard history on disk so copies survive and
#                   are recoverable later (the Walker builtin clipboard kept
#                   no persistent history).
#
# Linux/Wayland only. On macOS clipboard history is handled by Raycast, so
# this installer is a no-op there.
#
# History is captured by `wl-paste --watch cliphist store` lines in
# hypr/hyprland/autostart.conf, and browsed via a Walker dmenu keybind in
# hypr/hyprland/input.conf.

source \"$DOTFILES/lib/io_handlers.sh\"
source \"$DOTFILES/lib/package_installer.sh\"

# macOS uses Raycast for clipboard history; nothing to do here.
if [ "${is_mac_os:-false}" = true ]; then
  return 0
fi

# Both tools talk the Wayland protocol; on X11 they install fine but never
# work, so skip rather than leave a broken autostart entry behind.
#
# Only a positively identified X11 session is skipped. Bootstrapping from a
# bare TTY reports no session type at all, and that is a normal first-install
# path here, so an unknown session still installs.
if [ "${XDG_SESSION_TYPE:-}" = "x11" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
  log_warn 'X11 session detected; skipping Wayland clipboard manager'
  return 0
fi

ensure_package() {
  local pkg=$1
  if is_package_installed "$pkg"; then
    log_success "Dependency \`$pkg\` already installed"
  else
    install_package "$pkg" && log_success "Dependency \`$pkg\` installed successfully"
  fi
}

# Idempotency: skip the whole installer if both tools are already present.
if command -v cliphist > /dev/null && command -v wl-copy > /dev/null; then
  log_success 'Dependency `cliphist` already installed'
  log_success 'Dependency `wl-clipboard` already installed'
  return 0
fi

if ! is_installer_available; then
  log_warn 'Auto install not supported for your system; install cliphist/wl-clipboard manually.'
  return 0
fi

if ! remembered_confirmation clipboard \
    'Do you want to install the clipboard manager (cliphist + wl-clipboard)?'; then
  log_info 'Skipping clipboard manager installation'
  return 0
fi

if [[ "$PKG_MANAGER" == "yay" || "$PKG_MANAGER" == "pacman" ]]; then
  ensure_package wl-clipboard
  ensure_package cliphist
else
  log_warn "Don't know how to install cliphist/wl-clipboard on $PKG_MANAGER automatically; install manually."
  return 0
fi
