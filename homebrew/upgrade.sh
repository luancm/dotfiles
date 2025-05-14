#!/usr/bin/env bash

if [[ -z $DOTFILES ]]; then echo 'Dotfiles were not installed, to install run `source ~/.dotfiles/install`'; return 1; fi
source $DOTFILES/lib/io_handlers.sh;

opts=$1

log_info 'Homebrew: Updating';
brew update;
log_info 'Homebrew: Upgrading';
if [[ "$(brew outdated --quiet $opts | grep -v gamemaker | grep -v slack)" ]]; then
    brew upgrade $(brew outdated --quiet $opts | grep -v gamemaker | grep -v slack);
    log_success 'Homebrew: Successfully upgraded';
else
    log_success 'Homebrew: Nothing to upgrade';
fi
