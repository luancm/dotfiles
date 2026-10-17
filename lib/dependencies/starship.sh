#!/usr/bin/env bash

# Starship prompt: from the package manager, or else the pinned release
# binary (STARSHIP_VERSION in lib/versions.env) into ~/.local/bin.
if command -v starship > /dev/null; then
  log_success 'Dependency `starship` already installed'
  return 0
fi

if is_installer_available && is_package_available starship; then
  if install_package starship; then
    log_success 'Dependency `starship` installed successfully'
  else
    log_error 'Failed to install starship'
  fi
  return 0
fi

arch="$(release_arch)"
if [[ "$(uname -s)" != Linux || -z "$arch" ]]; then
  log_warn 'No starship package or release binary for this system; install it manually: https://starship.rs'
  return 0
fi

if ! remembered_confirmation starship_official \
    "Install starship ${STARSHIP_VERSION} from its GitHub release (checksum verified)?"; then
  log_info 'Skipping starship installation'
  return 0
fi

sha_var="STARSHIP_SHA256_${arch^^}"
if install_release_binary starship \
    "https://github.com/starship/starship/releases/download/${STARSHIP_VERSION}/starship-${arch}-unknown-linux-musl.tar.gz" \
    "${!sha_var}"; then
  log_success 'Dependency `starship` installed successfully'
else
  log_error 'Starship installation failed'
fi
