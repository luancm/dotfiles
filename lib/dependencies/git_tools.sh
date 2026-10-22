#!/usr/bin/env bash

# Git diff/review tools. delta renders readable line diffs (used as git's pager),
# difftastic gives on-demand structural diffs (`git dft`), lazygit is a git TUI.
# delta + difftastic make AUR PKGBUILD / supply-chain diff review legible.
# Their git config lives in git/defaults.sh.

# Ordered list of <package>; command name resolved by git_tool_cmd.
git_tool_pkgs=(git-delta difftastic lazygit)

git_tool_cmd() {
  case "$1" in
    git-delta)  echo delta ;;
    difftastic) echo difft ;;
    lazygit)    echo lazygit ;;
  esac
}

# difftastic and lazygit are missing from some distro repos (e.g. Ubuntu noble).
# Their upstreams ship Linux binaries, so fall back to the pinned GitHub
# release (lib/versions.env), installed into ~/.local/bin.

# Release URL for this system; empty when there is no binary to get.
git_tool_release_url() {
  local pkg="$1" arch
  arch="$(release_arch)"
  [[ "$(uname -s)" == Linux && -n "$arch" ]] || return 0

  case "$pkg" in
    git-delta)
      echo "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-${arch}-unknown-linux-gnu.tar.gz" ;;
    difftastic)
      echo "https://github.com/Wilfred/difftastic/releases/download/${DIFFTASTIC_VERSION}/difft-${DIFFTASTIC_VERSION}-${arch}-unknown-linux-gnu.tar.gz" ;;
    lazygit)
      [[ "$arch" == aarch64 ]] && arch=arm64
      echo "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_${arch}.tar.gz" ;;
  esac
}

install_git_tool_from_release() {
  local pkg="$1" cmd="$2" url name arch sha_var
  url="$(git_tool_release_url "$pkg")"
  if [[ -z "$url" ]]; then
    log_warn "No prebuilt $pkg release for this platform. Please install it manually."
    return 1
  fi
  name="${pkg#git-}"
  arch="$(release_arch)"
  sha_var="${name^^}_SHA256_${arch^^}"
  install_release_binary "$cmd" "$url" "${!sha_var}"
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

  if ! is_installer_available || ! is_package_available "$pkg"; then
    if is_installer_available; then
      log_info "Package \`$pkg\` not available in $PKG_MANAGER repositories."
    else
      log_info "No package manager found."
    fi

    if install_git_tool_from_release "$pkg" "$cmd"; then
      log_success "Dependency \`$pkg\` installed successfully"
    fi
    return 0
  fi

  if install_package "$pkg"; then
    log_success "Dependency \`$pkg\` installed successfully"
  fi
}

# Skip the prompt entirely when every tool is already present.
git_tools_missing=()
for pkg in "${git_tool_pkgs[@]}"; do
  cmd=$(git_tool_cmd "$pkg")
  if command -v "$cmd" > /dev/null; then
    log_success "Dependency \`$pkg\` already installed"
  else
    git_tools_missing+=("$pkg")
  fi
done

if [[ ${#git_tools_missing[@]} -eq 0 ]]; then
  return 0
fi

# All  -> install delta, difftastic and lazygit
# Some -> confirm each one individually
# No   -> install none
# Default = ALL (Enter accepts). Answer is remembered across install/update runs.
git_tools_mode=$(remembered_choice git_tools \
  'Install git diff tools (delta, difftastic, lazygit)?' All Some No)

if [[ "$git_tools_mode" = 'no' ]]; then
  log_info 'Skipping git tools installation'
  return 0
fi

for pkg in "${git_tool_pkgs[@]}"; do
  maybe_install_git_tool "$pkg"
done
