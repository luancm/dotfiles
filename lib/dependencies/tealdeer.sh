#!/usr/bin/env bash

# Installs tealdeer, a fast Rust implementation of tldr (simplified,
# community-driven man pages). Provides the `tldr` command.
#
# Available on Homebrew (macOS) and the Arch repos (pacman/yay) as `tealdeer`.

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

if command -v tldr > /dev/null; then
	log_success 'Dependency `tealdeer` already installed'
	return 0
fi

if prompt_confirmation 'Do you want to install tealdeer (a fast tldr client)?'; then
	if ! is_installer_available; then
		log_warn 'Auto install not supported for your system, you will need to install it manually'
		return 0
	fi

	install_package tealdeer && log_success 'Dependency `tealdeer` installed successfully'
else
	log_info 'Skipping tealdeer installation'
fi
