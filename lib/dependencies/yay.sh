#!/usr/bin/env bash

source "$DOTFILES/lib/io_handlers.sh"

# If on Arch, optionally install yay (AUR helper).
if ! command -v pacman > /dev/null; then
	return 0
fi

if command -v yay > /dev/null; then
	log_success '(Arch) Dependency `yay` already installed'
	return 0
fi

if ! remembered_confirmation yay 'Install yay (AUR helper)?'; then
	log_info 'Skipping yay installation'
	return 0
fi

log_info '(Arch) Installing `yay`'
sudo pacman -S --needed --noconfirm git base-devel
# Build in a fresh tempdir inside a subshell so `cd` does not leak and
# the EXIT trap cleans up even if `makepkg` fails.
(
	tmpdir="$(mktemp -d)"
	trap 'rm -rf "$tmpdir"' EXIT
	git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
	cd "$tmpdir/yay"
	makepkg -si --noconfirm
)
if command -v yay > /dev/null; then
	log_success '(Arch) Installed `yay` successfully'
else
	log_error '(Arch) Failed to install yay'
fi
