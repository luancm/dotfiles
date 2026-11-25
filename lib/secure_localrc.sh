#!/usr/bin/env bash
#
# ~/.localrc is sourced by every shell and holds machine-only settings, so it
# must not be readable by other users. Creates it from .localrc.example when
# missing and strips group/other permissions from it and its backups. When
# ~/.localrc is a link, the file it points to is the one secured.
set -euo pipefail

source "$DOTFILES/lib/io_handlers.sh"

localrc="$HOME/.localrc"

if [[ ! -e "$localrc" ]]; then
  (umask 077 && cp "$DOTFILES/.localrc.example" "$localrc")
  log_success "Created $localrc from .localrc.example"
fi

mode_of() { stat -c %a "$1" 2> /dev/null || stat -f %Lp "$1"; }

resolve() {
  realpath "$1" 2> /dev/null || readlink -f "$1" 2> /dev/null
}

status=0
for f in "$localrc" "$localrc".*; do
  [[ -e "$f" || -L "$f" ]] || continue
  target="$f"
  if [[ -L "$f" ]] && ! target="$(resolve "$f")"; then
    log_error "Cannot resolve the link $f; secure its target by hand"
    status=1
    continue
  fi
  [[ -f "$target" ]] || continue
  chmod go-rwx "$target" 2> /dev/null || true
  mode="$(mode_of "$target")"
  if (( 8#$mode & 8#077 )); then
    log_error "$target is still readable by other users (mode $mode); run: chmod go-rwx $target"
    status=1
  fi
done

if ((status == 0)); then
  log_success "$localrc is private (go-rwx)"
fi
exit "$status"
