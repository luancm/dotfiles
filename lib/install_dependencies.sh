#!/bin/sh
#
# check and install dependencies

if [ -z $DOTFILES ]; then echo 'Dotfiles were not installed, to install run `~/.dotfiles/install`'; return 1; fi
source $DOTFILES/lib/io_handlers.sh
autoinstall_error_message='Auto install not supported for your system, you will need to install it manually'

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

if  command -v zsh > /dev/null && grep "$(command -v zsh)" /etc/shells > /dev/null; then
	log_success 'Dependency `zsh` already installed'
else
	if command -v pacman > /dev/null; then
		sudo pacman -S zsh
		log_success 'Dependency `zsh` installed successfully'
	elif command -v brew > /dev/null; then
		brew install zsh
		log_success 'Dependency `zsh` installed successfully'
	else
		log_error $autoinstall_error_message
		exit
	fi
fi

if ! command -v ssh-keygen > /dev/null; then # Installed in mac by default
	if command -v pacman > /dev/null; then
		sudo pacman -S openssh
		log_success 'Dependency `ssh-keygen` installed successfully through `openssh` package'
	else
		log_error $autoinstall_error_message
		exit
	fi
else
	log_success 'Dependency `ssh-keygen` already installed'
fi

if ! command -v starship > /dev/null; then
	if command -v yay > /dev/null; then
		yay -S starship
		log_success 'Dependency `starship` installed successfully'
	elif command -v brew > /dev/null; then
		brew install starship
		log_success 'Dependency `starship` installed successfully'
	else
		log_error $autoinstall_error_message
		exit
	fi
else
	log_success 'Dependency `starship` already installed'
fi

# xclip for pbcopy and pbpaste aliases
if [ "${OSTYPE#*darwin}" = "$OSTYPE" ]; then
	if ! command -v xclip > /dev/null; then
		if $(prompt_confirmation 'Do you want to install xclip (for pbcopy and pbpaste aliases)?'); then
			if command -v pacman > /dev/null; then
				sudo pacman -S xclip
				log_success 'Dependency `xclip` installed successfully'
			else
				log_error $autoinstall_error_message
			fi
		else
			log_info 'Skipping xclip installation'
		fi
	else
		log_success 'Dependency `xclip` already installed'
	fi
fi

if ! command -v fzf > /dev/null; then
	if $(prompt_confirmation 'Do you want to install fzf (fuzzy finder)?'); then
		if command -v pacman > /dev/null; then
			sudo pacman -S fzf
			log_success 'Dependency `fzf` installed successfully'
		elif command -v brew > /dev/null; then
			brew install fzf
			log_info 'Installing fzf, please choose to NOT update your shell configuration files'
			sh -c "/usr/local/opt/fzf/install"
			log_success 'Dependency `fzf` installed successfully'
		else
			log_error $autoinstall_error_message
		fi
	else
		log_info 'Skipping fzf installation'
	fi
else
	log_success 'Dependency `fzf` already installed'
fi


if [ ! -d $DOTFILES/zsh/znap/zsh-snap ]; then
	git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git $DOTFILES/zsh/znap/zsh-snap
	log_success 'Dependency `znap` installed successfully'
else
	log_success 'Dependency `znap` already installed'
fi