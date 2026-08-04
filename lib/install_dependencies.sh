#!/usr/bin/env bash

# check and install dependencies

if [ -z "${DOTFILES:-}" ]; then echo "Dotfiles were not installed, to install run `~/.dotfiles/install`"; exit 1; fi

source "$DOTFILES/lib/io_handlers.sh"

[ "${OSTYPE#*darwin}" = "$OSTYPE" ] && is_mac_os=false || is_mac_os=true

deps_dir="$DOTFILES/lib/dependencies"

# Explicit order: core tools and package-manager bootstrap first, then the
# rest alphabetically. Unknown files still run (appended sorted).
ordered=(
  curl.sh
  openssh.sh
  zsh.sh
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
