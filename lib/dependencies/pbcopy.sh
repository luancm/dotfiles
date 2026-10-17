#!/usr/bin/env bash

# xclip for pbcopy and pbpaste aliases (not needed on macOS)
if ! $is_mac_os; then
  if ! command -v xclip > /dev/null; then
    if remembered_confirmation xclip 'Do you want to install xclip (for pbcopy and pbpaste aliases)?'; then
      if ! is_installer_available; then
        log_warn 'No package manager found. Please install xclip manually.'
      elif install_package xclip; then
        log_success 'Dependency `xclip` installed successfully'
      else
        log_error 'Failed to install xclip'
      fi
    else
      log_info 'Skipping xclip installation'
    fi
  else
    log_success 'Dependency `xclip` already installed'
  fi
fi
