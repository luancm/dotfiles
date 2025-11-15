#!/usr/bin/env bash

source $DOTFILES/lib/io_handlers.sh

# Function to create a symlink, handling existing files/links
# Usage: create_symlink <source_file> <target_link>
create_symlink() {
  local source_path="$1"
  local target_path="$2"
  
  # Create target directory if it doesn't exist
  local target_dir="$(dirname "$target_path")"
  if [ ! -d "$target_dir" ]; then
      mkdir -p "$target_dir"
  fi
    
	if [ -L "${target_path}" ] || [ -e "${target_path}" ]; then
		if [[ "$(readlink "$target_path")" = "$source_path" ]]; then
			log_success "Skipping ${source_path}. Already linked"
			return 0
		else
			mv "$target_path" "$target_path.backup"
			log_success "Backed up $target_path to $target_path.backup"
		fi
	fi
	ln -sf "$source_path" "$target_path"
	log_success "Linked $source_path to $target_path"
}

# Function to check if a file should be skipped based on exclude patterns
# Usage: should_skip <file_path> <exclude_patterns>
should_skip() {
  local file_path="$1"
  local exclude_patterns=("${@:2}")
    
  # If no exclude patterns provided, don't skip
  if [ ${#exclude_patterns[@]} -eq 0 ]; then
      return 1 # false, don't skip
  fi
    
  # Check each pattern
  for pattern in "${exclude_patterns[@]}"; do
      if [[ "$file_path" == $pattern ]]; then
          return 0 # true, should skip
      fi
  done
    
  return 1 # false, don't skip
}

# Function to find files matching a pattern and create symlinks in ~/.config
# Usage: link_to_config <source_folder> <pattern> [exclude_pattern1] [exclude_pattern2] ...
# Example: link_to_config ~/dotfiles "*.conf" "*.bak" "*/.git/*" "*/secret*"
create_symlinks_for_folder() {
  local source_folder="$1"
  local destination_folder="$2"
  local pattern="$3"
    
  # Check if source folder exists
  if [ ! -d "$source_folder" ]; then
      log_info "Error: Source folder '$source_folder' does not exist"
      return 1
  fi

  # Check if config folder exists, create if not
  if [ ! -d "$destination_folder" ]; then
      log_info "Creating ~/.config directory"
      mkdir -p "$destination_folder"
  fi

  # Find all files matching the pattern
  log_info "Finding files matching '$pattern' in '$source_folder'..."
    
  # Find all files matching the pattern
  find $source_folder -type f -path "$pattern" | while read -r file; do
      # Get the relative path (without the leading ./)
      relative_path="${file#$source_folder/}"
      
      # Check if file should be skipped
      if should_skip "$relative_path" "${exclude_patterns[@]}"; then
          log_info "Skipping excluded file: $relative_path"
          continue
      fi
      
      # Create the symlink
      target_link="$destination_folder/$relative_path"
      source_file="$source_folder/$relative_path"
      
      create_symlink "$source_file" "$target_link"
      # echo "source=$source_file target=$target_link"
  done
    
  log_info "Finished creating symlinks in ~/.config"
}

create_symlink "$HOME/.dotfiles/zsh/zshrc.symlink" "$HOME/.zshrc"
create_symlinks_for_folder "$HOME/.dotfiles/.config" "$HOME/.config" "*"

