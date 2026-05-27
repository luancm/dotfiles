#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh

NVM_VERSION="v0.40.1"
NVM_DIR_PATH="${NVM_DIR:-$HOME/.nvm}"

# Load nvm into the current shell if it's already installed, so the
# `command -v nvm` check below works in non-interactive shells too.
if [[ -s "$NVM_DIR_PATH/nvm.sh" ]]; then
  export NVM_DIR="$NVM_DIR_PATH"
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
fi

if command -v nvm > /dev/null || [[ -d "$NVM_DIR_PATH" ]]; then
  log_success 'Dependency `nvm` already installed'
else
  if prompt_confirmation 'Install nvm (Node Version Manager)?'; then
    if ! command -v curl > /dev/null; then
      log_info 'nvm installer requires curl; running curl dependency installer...'
      source "$DOTFILES/lib/dependencies/curl.sh"
    fi

    if ! command -v curl > /dev/null; then
      log_error 'curl is required but could not be installed; cannot install nvm.'
      return 1
    fi

    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash

    if [[ -s "$NVM_DIR_PATH/nvm.sh" ]]; then
      log_success 'Dependency `nvm` installed successfully'
      log_info 'Restart your shell (or `source ~/.zshrc`), then run `nvm install --lts` to install Node.'
    else
      log_error 'nvm installation failed'
    fi
  else
    log_info 'Skipping nvm installation'
  fi
fi
