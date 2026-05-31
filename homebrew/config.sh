#!/usr/bin/env bash
#
# config for homebrew

# always use a Homebrew-installed curl rather than the system version.
# https://github.com/Homebrew/brew/issues/5563
export HOMEBREW_FORCE_BREWED_CURL=1

# Apple Silicon installs to /opt/homebrew, Intel to /usr/local.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

source "$DOTFILES/homebrew/aliases.sh"
