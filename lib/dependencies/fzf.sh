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