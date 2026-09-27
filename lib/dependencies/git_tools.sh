#!/usr/bin/env bash

source "$DOTFILES/lib/io_handlers.sh"
source "$DOTFILES/lib/package_installer.sh"

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

# difftastic and lazygit are missing from some distro repos (e.g. Ubuntu noble).
# Both upstreams ship static Linux binaries, so fall back to the latest GitHub
# release, dropped into ~/.local/bin (already on PATH via the dotfiles zshrc).
git_tools_bin_dir="$HOME/.local/bin"

git_tool_repo() {
  case "$1" in
    git-delta)  echo dandavison/delta ;;
    difftastic) echo Wilfred/difftastic ;;
    lazygit)    echo jesseduffield/lazygit ;;
  esac
}

# Release asset name fragment for this arch; empty when there is no binary to grab.
git_tool_release_asset() {
  local pkg="$1" arch
  [[ "$(uname -s)" = 'Linux' ]] || return 0
  arch=$(uname -m)

  case "$pkg:$arch" in
    git-delta:x86_64)   echo '-x86_64-unknown-linux-gnu.tar.gz' ;;
    git-delta:aarch64)  echo '-aarch64-unknown-linux-gnu.tar.gz' ;;
    difftastic:x86_64)  echo 'difft-x86_64-unknown-linux-gnu.tar.gz' ;;
    difftastic:aarch64) echo 'difft-aarch64-unknown-linux-gnu.tar.gz' ;;
    lazygit:x86_64)     echo 'linux_x86_64.tar.gz' ;;
    lazygit:aarch64)    echo 'linux_arm64.tar.gz' ;;
  esac
}

install_git_tool_from_release() {
  local pkg="$1" cmd="$2" repo asset url tmp binary
  repo=$(git_tool_repo "$pkg")
  asset=$(git_tool_release_asset "$pkg")

  if [[ -z "$repo" || -z "$asset" ]]; then
    log_warn "No prebuilt $pkg release for this platform. Please install it manually."
    return 1
  fi

  if ! command -v curl > /dev/null; then
    log_warn "curl is required to install $pkg from its GitHub release."
    return 1
  fi

  url=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
    | grep -o '"browser_download_url": *"[^"]*"' \
    | sed 's/.*"\(https[^"]*\)"/\1/' \
    | grep -m1 -F "$asset")

  if [[ -z "$url" ]]; then
    log_warn "Could not find a \`$asset\` asset in the latest $repo release."
    return 1
  fi

  tmp=$(mktemp -d) || return 1
  log_info "Installing $pkg from $url"

  if ! curl -fsSL "$url" | tar -xz -C "$tmp"; then
    log_warn "Failed to download or extract the $pkg release archive."
    rm -rf "$tmp"
    return 1
  fi

  binary=$(find "$tmp" -type f -name "$cmd" | head -1)
  if [[ -z "$binary" ]]; then
    log_warn "No \`$cmd\` binary inside the $pkg release archive."
    rm -rf "$tmp"
    return 1
  fi

  mkdir -p "$git_tools_bin_dir"
  install -m 755 "$binary" "$git_tools_bin_dir/$cmd"
  rm -rf "$tmp"

  log_info "Installed \`$cmd\` to $git_tools_bin_dir"
  # Make the fresh binary visible to the configure_* steps below; the dotfiles
  # zshrc puts ~/.local/bin on PATH for interactive shells.
  case ":$PATH:" in
    *":$git_tools_bin_dir:"*) ;;
    *) export PATH="$PATH:$git_tools_bin_dir" ;;
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
  configure_delta
  configure_difftastic
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

# Configure whichever tools ended up installed.
configure_delta
configure_difftastic
