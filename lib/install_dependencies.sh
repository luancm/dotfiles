#!/usr/bin/env bash

# check and install dependencies

if [ -z "${DOTFILES:-}" ]; then echo 'Dotfiles were not installed, to install run `~/.dotfiles/install`'; exit 1; fi

source "$DOTFILES/lib/io_handlers.sh"

[ "${OSTYPE#*darwin}" = "$OSTYPE" ] && is_mac_os=false || is_mac_os=true

# Call installers. Each installer is sourced (so it can `return` on early exit).
# Failures in individual installers are tolerated so one bad dep does not
# block the rest from being attempted.
mapfile -t dependency_installers < <(find -H "$DOTFILES/lib/dependencies" -name '*.sh')
for installer in "${dependency_installers[@]}"; do
  source "$installer" || log_warn "Dependency installer failed: $installer"
done

# Normalize exit code: the last-sourced installer's return value would
# otherwise become this script's exit status, which is non-deterministic
# (find order) and trips `set -e` in the parent.
exit 0

