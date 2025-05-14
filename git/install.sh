#!/usr/bin/env bash

if [[ -z $DOTFILES ]]; then echo 'Dotfiles were not installed, to install run `source ~/.dotfiles/install`'; return 1; fi
source $DOTFILES/lib/io_handlers.sh

setup_git() {
	if [[ "$(git config --global --get dotfiles.managed)" = "true" ]]; then
		log_success "Git: Already managed by dotfiles"
		return 0
	fi

	log_info 'Git: Setting up gitconfig'
	if [[ -f ~/.gitconfig ]]; then
		log_info 'Git: You already have a .gitconfig. Making a backup...'
		mv ~/.gitconfig ~/.gitconfig.backup
		log_success "Git: Moved ~/.gitconfig to ~/.gitconfig.backup"
	fi

	git config --global user.name "$(get_input 'Git: What is your author name?')"
	git config --global user.email "$(get_input 'Git: What is your author email?')"
	git config --global include.path ~/.gitconfig.local
	git config --global dotfiles.managed true
}

setup_git

log_info 'Git: Creating aliases'

source $DOTFILES/git/aliases.sh

log_success 'Git: Successfully configured'
