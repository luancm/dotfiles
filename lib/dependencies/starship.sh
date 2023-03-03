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
