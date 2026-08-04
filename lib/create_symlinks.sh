#!/usr/bin/env bash
set -eo pipefail

if [[ -z "${DOTFILES:-}" ]]; then
  echo "DOTFILES is unset; run via the install/update entrypoint" >&2
  exit 1
fi

source "$DOTFILES/lib/io_handlers.sh"

[ "${OSTYPE#*darwin}" = "$OSTYPE" ] && is_mac_os=false || is_mac_os=true

# Linux/Wayland-only app configs that have no meaning on macOS.
config_excludes=()
if $is_mac_os; then
  config_excludes+=("hypr/*" "waybar/*" "wlogout/*" "walker/*" "satty/*")
fi

create_symlink() {
  local source_path="$1"
  local target_path="$2"
  local target_dir
  target_dir="$(dirname "$target_path")"
  if [ ! -d "$target_dir" ]; then
      mkdir -p "$target_dir"
  fi

  if [ -L "${target_path}" ] || [ -e "${target_path}" ]; then
    if [[ "$(readlink "$target_path")" = "$source_path" ]]; then
      log_success "Skipping ${source_path}. Already linked"
      return 0
    else
      local backup="${target_path}.backup.$(date +%Y%m%d%H%M%S)"
      mv "$target_path" "$backup"
      log_success "Backed up $target_path to $backup"
    fi
  fi
  ln -sf "$source_path" "$target_path"
  log_success "Linked $source_path to $target_path"
}

should_skip() {
  local file_path="$1"
  local exclude_patterns=("${@:2}")
  if [ ${#exclude_patterns[@]} -eq 0 ]; then
      return 1
  fi
  for pattern in "${exclude_patterns[@]}"; do
      if [[ "$file_path" == $pattern ]]; then
          return 0
      fi
  done
  return 1
}

create_symlinks_for_folder() {
  local source_folder="$1"
  local destination_folder="$2"
  local exclude_patterns=("${@:3}")
  if [ ! -d "$source_folder" ]; then
      log_info "Error: Source folder '$source_folder' does not exist"
      return 1
  fi
  if [ ! -d "$destination_folder" ]; then
      log_info "Creating $destination_folder"
      mkdir -p "$destination_folder"
  fi
  log_info "Linking files from '$source_folder' -> '$destination_folder'..."
  local file relative_path target_link source_file
  while IFS= read -r -d '' file; do
      relative_path="${file#"$source_folder"/}"
      if should_skip "$relative_path" "${exclude_patterns[@]}"; then
          log_info "Skipping excluded file: $relative_path"
          continue
      fi
      target_link="$destination_folder/$relative_path"
      source_file="$source_folder/$relative_path"
      create_symlink "$source_file" "$target_link"
  done < <(find "$source_folder" -type f ! -name "*.backup*" -print0)
  log_info "Finished creating symlinks in $destination_folder"
}

create_symlink "$DOTFILES/zsh/zshrc.symlink" "$HOME/.zshrc"
create_symlinks_for_folder "$DOTFILES/.config" "$HOME/.config" "${config_excludes[@]}"
