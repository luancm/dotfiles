#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DOTFILES:-}" ]]; then echo 'Dotfiles were not installed, to install run `~/.dotfiles/install`'; exit 1; fi
source "$DOTFILES/lib/io_handlers.sh"

opts="${1:-}"

# Machine-specific list of packages to skip on upgrade. One substring per line;
# blank lines and `#` comments are ignored. File is gitignored.
exclude_file="$DOTFILES/homebrew/exclude.local"
exclude=""
if [[ -f "$exclude_file" ]]; then
    exclude="$(grep -Ev '^[[:space:]]*(#|$)' "$exclude_file" | paste -sd '|' -)"
fi

log_info 'Homebrew: Updating'
brew update
log_info 'Homebrew: Upgrading'

# grep returns 1 when nothing matches; `|| true` keeps pipefail happy in that case.
if [[ -n "$exclude" ]]; then
    outdated="$(brew outdated --quiet $opts | grep -Ev "$exclude" || true)"
else
    outdated="$(brew outdated --quiet $opts)"
fi
if [[ -n "$outdated" ]]; then
    # shellcheck disable=SC2086  # intentional word-splitting on package list
    brew upgrade $outdated
    log_success 'Homebrew: Successfully upgraded'
else
    log_success 'Homebrew: Nothing to upgrade'
fi
