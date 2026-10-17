#!/usr/bin/env bash

if command -v curl > /dev/null; then
  log_success 'Dependency `curl` already installed'
else
  if ! is_installer_available; then
    log_warn "Auto install not supported for your system, you will need to install curl manually"
    return 0
  fi

  if install_package curl; then
    log_success 'Dependency `curl` installed successfully'
  else
    log_error 'Failed to install curl'
  fi
fi
