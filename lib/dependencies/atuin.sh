#!/usr/bin/env bash

# Atuin: SQLite-backed shell history with a TUI search (Ctrl-R).
# Replaces fzf's history widget only; fzf stays for file/session pickers.
# Sync is optional and not configured here — stay local until you run
# `atuin register` / `atuin login` yourself.
#
# https://docs.atuin.sh/latest/

source \"$DOTFILES/lib/io_handlers.sh\"
source \"$DOTFILES/lib/package_installer.sh\"

if command -v atuin > /dev/null; then
  log_success 'Dependency `atuin` already installed'
else
  if ! remembered_confirmation atuin \
      'Do you want to install atuin (better shell history search on Ctrl-R)?'; then
    log_info 'Skipping atuin installation'
    return 0
  fi

  if ! is_installer_available; then
    log_warn 'Auto install not supported for your system; install atuin manually'
    return 0
  fi

  if ! is_package_available atuin; then
    log_warn "Package \`atuin\` not available in $PKG_MANAGER repositories."
    log_info 'Install via https://docs.atuin.sh/latest/guide/installation/ or `cargo install atuin --locked`'
    return 0
  fi

  if install_package atuin; then
    log_success 'Dependency `atuin` installed successfully'
  else
    log_error 'Failed to install atuin'
    return 0
  fi
fi

# Import existing shell history into Atuin once. Marks done with a stamp file
# so re-runs stay quiet. Safe to re-import later: `atuin import auto`.
atuin_stamp="${XDG_DATA_HOME:-$HOME/.local/share}/atuin/.dotfiles-imported"
if command -v atuin > /dev/null && [[ ! -f "$atuin_stamp" ]]; then
  if remembered_confirmation atuin_import \
      'Import existing shell history into atuin?'; then
    if atuin import auto; then
      mkdir -p "$(dirname "$atuin_stamp")"
      : > "$atuin_stamp"
      log_success 'Imported shell history into atuin'
    else
      log_warn 'atuin import failed; re-run `atuin import auto` later'
    fi
  else
    mkdir -p "$(dirname "$atuin_stamp")"
    : > "$atuin_stamp"
    log_info 'Skipping history import (stamp written so we will not ask again)'
  fi
fi
