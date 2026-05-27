#!/usr/bin/env bash

source "$DOTFILES/lib/io_handlers.sh"

# If in arch, install yay
if command -v pacman > /dev/null; then
	if ! command -v yay > /dev/null; then
		log_info '(Arch) Installing `yay` for arch'
		sudo pacman -S --needed git base-devel
		# Build in a fresh tempdir inside a subshell so `cd` does not leak and
		# the EXIT trap cleans up even if `makepkg` fails.
		(
			tmpdir="$(mktemp -d)"
			trap 'rm -rf "$tmpdir"' EXIT
			git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
			cd "$tmpdir/yay"
			makepkg -si
		)
		log_success '(Arch) Installed `yay` for arch successfully'
	else
		log_success '(Arch) Dependency `yay` already installed'
	fi
fi
