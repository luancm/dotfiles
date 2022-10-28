#!/bin/sh
#
# config for homebrew

# always use a Homebrew-installed curl rather than the system version.
# https://github.com/Homebrew/brew/issues/5563
export HOMEBREW_FORCE_BREWED_CURL=1
eval $(/opt/homebrew/bin/brew shellenv)
