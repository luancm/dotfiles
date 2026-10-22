#!/usr/bin/env bash

# check and install dependencies

if [ -z "${DOTFILES:-}" ]; then echo 'Dotfiles were not installed, to install run `~/.dotfiles/install`'; exit 1; fi

# Installers are sourced into this shell and rely on these helpers.
source "$DOTFILES/lib/io_handlers.sh"
source "$DOTFILES/lib/package_installer.sh"
source "$DOTFILES/lib/download.sh"

# shellcheck disable=SC2034 # read by the sourced installers
[ "${OSTYPE#*darwin}" = "$OSTYPE" ] && is_mac_os=false || is_mac_os=true

deps_dir="$DOTFILES/lib/dependencies"

# Plain package installs, one line per tool in lib/tools.list. The list is
# read on fd 3 because the prompts read stdin.
install_listed_tools() {
  local key cmd pkg os question
  while read -r key cmd pkg os question <&3; do
    [[ -z "$key" || "$key" == '#'* ]] && continue
    case "$os" in
      linux) $is_mac_os && continue ;;
      mac) $is_mac_os || continue ;;
    esac
    if command -v "$cmd" > /dev/null; then
      log_success "Dependency \`$pkg\` already installed"
      continue
    fi
    if ! is_installer_available || ! is_package_available "$pkg"; then
      log_warn "\`$pkg\` is not available from ${PKG_MANAGER:-a package manager} here; install it manually"
      continue
    fi
    if [[ "$question" != '-' ]] &&
      ! remembered_confirmation "$key" "Do you want to install $question?"; then
      log_info "Skipping $pkg installation"
      continue
    fi
    if install_package "$pkg"; then
      log_success "Dependency \`$pkg\` installed successfully"
    else
      log_error "Failed to install $pkg"
    fi
  done 3< "$DOTFILES/lib/tools.list"

  # Debian and Ubuntu name the fd command fdfind; Neovim plugins call fd.
  if ! command -v fd > /dev/null && command -v fdfind > /dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    log_info "Linked ~/.local/bin/fd to $(command -v fdfind)"
  fi
}

install_listed_tools

# Explicit order: package-manager bootstrap first, then the rest
# alphabetically. Unknown files still run (appended sorted).
ordered=(
  build_tools.sh
  yay.sh
)

run_installer() {
  local installer="$1"
  # shellcheck disable=SC1090
  source "$installer" || log_warn "Dependency installer failed: $installer"
}

declare -A seen=()
for name in "${ordered[@]}"; do
  path="$deps_dir/$name"
  if [[ -f "$path" ]]; then
    seen["$name"]=1
    run_installer "$path"
  fi
done

while IFS= read -r path; do
  name="$(basename "$path")"
  [[ -n "${seen[$name]:-}" ]] && continue
  run_installer "$path"
done < <(find -H "$deps_dir" -name "*.sh" | sort)

exit 0
