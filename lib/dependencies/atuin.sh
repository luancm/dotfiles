#!/usr/bin/env bash

# Atuin: SQLite-backed shell history with a TUI search (Ctrl-R); the package
# comes from lib/tools.list. Sync is optional and not configured here — stay
# local until you run `atuin register` / `atuin login` yourself.
#
# https://docs.atuin.sh/latest/

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
