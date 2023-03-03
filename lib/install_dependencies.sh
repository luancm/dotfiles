#!/bin/sh
#
# check and install dependencies

if [ -z $DOTFILES ]; then echo 'Dotfiles were not installed, to install run `~/.dotfiles/install`'; return 1; fi
source $DOTFILES/lib/io_handlers.sh
autoinstall_error_message='Auto install not supported for your system, you will need to install it manually'

source $DOTFILES/lib/dependencies/yay.sh
source $DOTFILES/lib/dependencies/zsh.sh
source $DOTFILES/lib/dependencies/openssh.sh
source $DOTFILES/lib/dependencies/starship.sh
source $DOTFILES/lib/dependencies/pbcopy.sh
source $DOTFILES/lib/dependencies/fzf.sh
source $DOTFILES/lib/dependencies/znap.sh