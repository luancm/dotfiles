#!/usr/bin/env bash

# Installs the Docker CLI + Compose v2 without Docker Desktop.
#   - macOS (brew):  Colima (free, lightweight Lima-based runtime) + docker
#     CLI + docker-compose. Colima provides the Docker socket the CLI talks
#     to; start it with `colima start`. The Compose binary is linked into
#     ~/.docker/cli-plugins so the `docker compose` (v2, space) subcommand
#     resolves, not just standalone `docker-compose`.
#   - Linux (pacman/yay): native Docker engine + docker-compose. Docker runs
#     natively here, so Colima is unnecessary; prints daemon/group hints.
#
# Avoids Docker Desktop (its license is paid for larger orgs) and the GUI.

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

ensure_package() {
  local pkg=$1
  if is_package_installed "$pkg"; then
    log_success "Dependency \`$pkg\` already installed"
  else
    install_package "$pkg" && log_success "Dependency \`$pkg\` installed successfully"
  fi
}

# Homebrew installs docker-compose as a standalone binary; symlink it into the
# Docker CLI plugins dir so `docker compose` works as a subcommand.
link_compose_plugin() {
  command -v brew > /dev/null || return 0
  local src="$(brew --prefix)/opt/docker-compose/bin/docker-compose"
  [ -x "$src" ] || return 0
  mkdir -p "$HOME/.docker/cli-plugins"
  ln -sfn "$src" "$HOME/.docker/cli-plugins/docker-compose"
  log_info 'Linked docker-compose into ~/.docker/cli-plugins (enables `docker compose`)'
}

# Idempotency: skip if the docker CLI is present. On macOS the CLI is useless
# without a runtime, so also require colima before considering it done.
if command -v docker > /dev/null; then
  if [[ "$PKG_MANAGER" != "brew" ]] || command -v colima > /dev/null; then
    log_success 'Dependency `docker` already installed'
    return 0
  fi
fi

if ! is_installer_available; then
  log_warn 'Auto install not supported for your system; install Docker manually.'
  return 0
fi

if ! prompt_confirmation 'Do you want to install Docker (Colima + docker + compose)?'; then
  log_info 'Skipping Docker installation'
  return 0
fi

if [[ "$PKG_MANAGER" == "brew" ]]; then
  ensure_package colima
  ensure_package docker
  ensure_package docker-compose
  link_compose_plugin
  log_info 'Start the runtime with `colima start`, then `docker`/`docker compose` work.'
elif [[ "$PKG_MANAGER" == "yay" || "$PKG_MANAGER" == "pacman" ]]; then
  # Docker runs natively on Linux; no Colima needed.
  ensure_package docker
  ensure_package docker-compose
  if command -v systemctl > /dev/null; then
    log_info 'Enable the daemon: `sudo systemctl enable --now docker`'
  fi
  log_info 'Add yourself to the docker group: `sudo usermod -aG docker $USER` (re-login after)'
else
  log_warn "Don't know how to install Docker on $PKG_MANAGER automatically; install manually."
  return 0
fi

# lazydocker: optional terminal UI for managing containers, images and logs.
# Available on both Homebrew and the Arch repos as `lazydocker`.
if command -v lazydocker > /dev/null; then
  log_success 'Dependency `lazydocker` already installed'
elif prompt_confirmation 'Also install lazydocker (a terminal UI for Docker)?'; then
  ensure_package lazydocker
else
  log_info 'Skipping lazydocker installation'
fi
