#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

# xclip for pbcopy and pbpaste aliases (not needed on macOS)
if ! $is_mac_os; then
	if ! command -v xclip > /dev/null; then
		if $(prompt_confirmation 'Do you want to install xclip (for pbcopy and pbpaste aliases)?'); then
			if is_installer_available; then
				install_package xclip
				log_success 'Dependency `xclip` installed successfully'
			else
				log_warn 'No package manager found. Please install xclip manually.'
			fi
		else
			log_info 'Skipping xclip installation'
		fi
	else
		log_success 'Dependency `xclip` already installed'
	fi
fi
