#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DOTFILES:-}" ]]; then echo 'Dotfiles were not installed, to install run `~/.dotfiles/install`'; exit 1; fi
source "$DOTFILES/lib/io_handlers.sh"

if ! command -v zsh > /dev/null; then log_error 'Trying to configure zsh without it installed. Do not forget to run `~/.dotfiles/install` before'; exit 1; fi

# Check which shell is configured in passwd (this is because the $SHELL variable is only updated on login)
zsh_path="$(which zsh)"
if [[ "${SHELL#*zsh}" = "$SHELL" ]]; then
    if command -v chsh >/dev/null; then
        if chsh -s "$zsh_path"; then
            log_success "set $("$zsh_path" --version) at $zsh_path as default shell"
        else
            log_warn "chsh failed; set the default shell manually with: chsh -s $zsh_path"
        fi
    fi
else
    log_success 'ZSH Already the default shell'
fi

