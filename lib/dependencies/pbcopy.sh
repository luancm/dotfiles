# xclip for pbcopy and pbpaste aliases
if [ ! is_mac_os ]; then
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