#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh

if ! command -v starship > /dev/null; then
	if command -v yay > /dev/null; then
		yay -S starship
		log_success 'Dependency `starship` installed successfully'
	elif command -v brew > /dev/null; then
		brew install starship
		log_success 'Dependency `starship` installed successfully'
	fi
else
	log_success 'Dependency `starship` already installed'
fi
