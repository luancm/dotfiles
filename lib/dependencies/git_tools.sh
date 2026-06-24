#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

# Git diff/review tools. delta renders readable line diffs (used as git's pager),
# difftastic gives on-demand structural diffs (`git dft`), lazygit is a git TUI.
# delta + difftastic make AUR PKGBUILD / supply-chain diff review legible.

# Ordered list of <package>; command name resolved by git_tool_cmd.
git_tool_pkgs=(git-delta difftastic lazygit)

git_tool_cmd() {
  case "$1" in
    git-delta)  echo delta ;;
    difftastic) echo difft ;;
    lazygit)    echo lazygit ;;
  esac
}

configure_delta() {
  command -v delta > /dev/null || return 0
  git config --global core.pager delta
  git config --global interactive.diffFilter 'delta --color-only'
  git config --global delta.navigate true
  log_success 'Configured `delta` as git pager'
}

configure_difftastic() {
  command -v difft > /dev/null || return 0
  git config --global difftool.difftastic.cmd 'difft "$LOCAL" "$REMOTE"'
  git config --global difftool.prompt false
  git config --global alias.dft 'difftool -t difftastic'
  log_success 'Configured `difftastic` as the `git dft` difftool'
}

# Install a single git tool, honouring 'some' mode (per-tool confirmation).
maybe_install_git_tool() {
  local pkg="$1" cmd
  cmd=$(git_tool_cmd "$pkg")

  if command -v "$cmd" > /dev/null; then
    log_success "Dependency \`$pkg\` already installed"
    return 0
  fi

  if [[ "$git_tools_mode" = 'some' ]] && ! prompt_confirmation "Install $pkg?"; then
    log_info "Skipping $pkg"
    return 0
  fi

  if ! is_installer_available; then
    log_warn "No package manager found. Please install $pkg manually."
    return 0
  fi

  if ! is_package_available "$pkg"; then
    log_warn "Package \`$pkg\` not available in $PKG_MANAGER repositories. Skipping."
    return 0
  fi

  if install_package "$pkg"; then
    log_success "Dependency \`$pkg\` installed successfully"
  fi
}

# All  -> install delta, difftastic and lazygit
# Some -> confirm each one individually
# No   -> install none
git_tools_mode=$(prompt_choice 'Install git diff tools (delta, difftastic, lazygit)?' All Some No)

if [[ "$git_tools_mode" = 'no' ]]; then
  log_info 'Skipping git tools installation'
  return 0
fi

for pkg in "${git_tool_pkgs[@]}"; do
  maybe_install_git_tool "$pkg"
done

# Configure whichever tools ended up installed.
configure_delta
configure_difftastic
