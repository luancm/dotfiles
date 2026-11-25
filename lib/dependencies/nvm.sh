#!/usr/bin/env bash

NVM_DIR_PATH="${NVM_DIR:-$HOME/.nvm}"

if command -v mise > /dev/null && [[ ! -d "$NVM_DIR_PATH" ]]; then
  log_success 'Node is managed by mise; skipping nvm'
  return 0
fi

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
  if remembered_confirmation nvm 'Install nvm (Node Version Manager)?'; then
    # The pinned install script (NVM_VERSION in lib/versions.env) runs only
    # after its sha256 matches.
    nvm_installer="$(mktemp)"
    if download_verified \
        "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" \
        "$NVM_INSTALL_SHA256" "$nvm_installer"; then
      PROFILE=/dev/null bash "$nvm_installer"
    fi
    rm -f "$nvm_installer"

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
