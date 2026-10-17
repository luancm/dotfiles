#!/usr/bin/env bash

# mise manages Node and Java versions (global config: .config/mise/config.toml).
# When mise is on PATH, zshrc activates it and skips nvm and sdkman.
if command -v mise > /dev/null; then
  log_success 'Dependency `mise` already installed'
  return 0
fi

if ! remembered_confirmation mise \
    'Do you want to install mise (Node and Java versions; replaces nvm and sdkman)?'; then
  log_info 'Skipping mise installation'
  return 0
fi

if ! is_installer_available || ! is_package_available mise; then
  log_warn 'mise is not in your package manager. Install it manually: https://mise.jdx.dev/installing-mise.html'
  return 0
fi

if install_package mise; then
  log_success 'Dependency `mise` installed successfully'
  log_info 'Run `mise install` for the global Node and Java versions, then remove nvm/sdkman lines from ~/.localrc.'
else
  log_error 'Failed to install mise'
fi
