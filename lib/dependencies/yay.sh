#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh

# If in arch, install yay
if command -v pacman > /dev/null; then
	if ! command -v yay > /dev/null; then
		log_info '(Arch) Installing `yay` for arch'
		sudo pacman -S --needed git base-devel
		git clone https://aur.archlinux.org/yay.git $DOTFILES/temporary/yay
		cd $DOTFILES/temporary/yay
		makepkg -si
		cd $DOTFILES
		rm -rf $DOTFILES/temporary/yay
		log_success '(Arch) Installed `yay` for arch successfully'
	else
		log_success '(Arch) Dependency `yay` already installed'
	fi
fi
