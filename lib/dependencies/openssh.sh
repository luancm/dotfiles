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
