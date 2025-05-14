#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh

if  command -v zsh > /dev/null && grep "$(command -v zsh)" /etc/shells > /dev/null; then
	log_success 'Dependency `zsh` already installed'
else
	if command -v pacman > /dev/null; then
		sudo pacman -S zsh
		log_success 'Dependency `zsh` installed successfully'
	elif command -v brew > /dev/null; then
		brew install zsh
		log_success 'Dependency `zsh` installed successfully'
	fi
fi
