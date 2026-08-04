#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

# gpg (GnuPG) provides encryption and signing; commonly used to sign git
# commits and manage keys. The binary is `gpg`, shipped by the `gnupg` package
# on pacman/apt/brew alike.
if command -v gpg > /dev/null; then
  log_success 'Dependency `gpg` already installed'
  return 0
fi

if ! remembered_confirmation gpg \
    'Do you want to install gpg (GnuPG; encryption and commit signing)?'; then
  log_info 'Skipping gpg installation'
  return 0
fi

if ! is_installer_available; then
  log_warn 'Auto install not supported for your system; install gnupg manually'
  return 0
fi

if install_package gnupg; then
  log_success 'Dependency `gpg` installed successfully through `gnupg` package'
else
  log_error 'Failed to install gpg'
fi
