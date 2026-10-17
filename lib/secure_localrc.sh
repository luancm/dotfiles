#!/usr/bin/env bash
#
# ~/.localrc is sourced by every shell and holds machine-only settings, so it
# must not be readable by other users. Creates it from .localrc.example when
# missing and strips group/other permissions from it and its backups.
set -euo pipefail

source "$DOTFILES/lib/io_handlers.sh"

localrc="$HOME/.localrc"

if [[ ! -e "$localrc" ]]; then
  (umask 077 && cp "$DOTFILES/.localrc.example" "$localrc")
  log_success "Created $localrc from .localrc.example"
fi

for f in "$localrc" "$localrc".*; do
  [[ -f "$f" && ! -L "$f" ]] && chmod go-rwx "$f"
done
log_success "$localrc is private (go-rwx)"
