#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DOTFILES:-}" ]]; then echo 'Dotfiles were not installed, to install run `~/.dotfiles/install`'; exit 1; fi
source "$DOTFILES/lib/io_handlers.sh"

[[ "$(uname -s)" == Darwin ]] || exit 0
command -v brew > /dev/null || exit 0

brewfile="$DOTFILES/homebrew/Brewfile"

if ! remembered_confirmation brewfile \
    'Homebrew: Install all packages from homebrew/Brewfile?' n; then
  log_info 'Homebrew: Skipping Brewfile (run `brew bundle --file homebrew/Brewfile` later)'
  exit 0
fi

if brew bundle --file "$brewfile"; then
  log_success 'Homebrew: Brewfile packages installed'
else
  log_warn 'Homebrew: Some Brewfile packages failed; see the output above'
fi
