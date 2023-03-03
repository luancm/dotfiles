if [ ! -d $DOTFILES/zsh/znap/zsh-snap ]; then
	git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git $DOTFILES/zsh/znap/zsh-snap
	log_success 'Dependency `znap` installed successfully'
else
	log_success 'Dependency `znap` already installed'
fi