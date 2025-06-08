#!/usr/bin/env bash

# check and install dependencies

if [ -z $DOTFILES ]; then echo 'Dotfiles were not installed, to install run `~/.dotfiles/install`'; return 1; fi

source $DOTFILES/lib/io_handlers.sh

[ "${OSTYPE#*darwin}" = "$OSTYPE" ] && is_mac_os=false || is_mac_os=true

# Call installers
dependency_installers=( $(find -H "$DOTFILES/lib/dependencies" -name '*.sh') )
for installer in ${dependency_installers[@]}; do 
  source $installer
done

