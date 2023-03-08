#!/bin/sh
if [ -z $DOTFILES ]; then echo 'Dotfiles were not installed, to install run `source ~/.dotfiles/install`'; return 1; fi
source $DOTFILES/lib/io_handlers.sh;

log_info 'Homebrew: Updating';
brew update --verbose;
log_info 'Homebrew: Upgrading';
if [ $(brew outdated --quiet | grep -v gamemaker) ]; then
    brew upgrade $(brew outdated --quiet | grep -v gamemaker);
    log_success 'Homebrew: Successfully upgraded';
else
    log_success 'Homebrew: Nothing to upgrade';
fi
