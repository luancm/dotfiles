#!/usr/bin/env bash
#
# Run the private dotfiles hook.
#
# The private dotfiles live in a sibling repo (default ~/.dotfiles-private),
# overridable via the DOTFILES_PRIVATE env var. The private repo is expected
# to provide an executable `install` script and may optionally provide an
# `update` script. This helper is invoked at the end of the public install /
# update flows.
#
# Usage: bash lib/run_private_hook.sh install|update
set -euo pipefail

if [[ -z "${DOTFILES:-}" ]]; then
    echo "DOTFILES must be set" >&2
    exit 1
fi
source "$DOTFILES/lib/io_handlers.sh"

mode="${1:-install}"
private_dir="${DOTFILES_PRIVATE:-$HOME/.dotfiles-private}"

if [[ ! -d "$private_dir" ]]; then
    log_info "Private dotfiles: no repo at $private_dir, skipping"
    exit 0
fi

# Pull latest if it's a git repo and we're updating.
if [[ "$mode" == "update" && -d "$private_dir/.git" ]]; then
    log_info "Private dotfiles: pulling latest"
    git -C "$private_dir" pull --ff-only
fi

# Prefer mode-specific script, fall back to install.
script="$private_dir/$mode"
if [[ ! -x "$script" ]]; then
    script="$private_dir/install"
fi

if [[ ! -x "$script" ]]; then
    log_info "Private dotfiles: no $mode or install script at $private_dir, skipping"
    exit 0
fi

log_info "❯❯ Running private dotfiles ($mode)"
DOTFILES="$DOTFILES" DOTFILES_PRIVATE="$private_dir" bash "$script"
