#!/usr/bin/env bash
#
# Expose the shared agent configuration to clients that support local skills
# and guidance files.  ~/.agents is the canonical cross-agent entrypoint;
# provider-specific directories contain only symlinks.
set -euo pipefail

source "${DOTFILES:?DOTFILES must be set}/lib/io_handlers.sh"

agents_dir="$HOME/.agents"
codex_dir="$HOME/.codex"
shared_guidance="$agents_dir/AGENTS.md"
shared_skills="$agents_dir/skills"

link_if_safe() {
  local source_path="$1"
  local target_path="$2"

  if [ -L "$target_path" ]; then
    if [ "$(readlink "$target_path")" = "$source_path" ]; then
      log_success "Skipping $target_path. Already linked"
      return 0
    fi

    log_warn "Skipping $target_path; it links to a different target"
    return 0
  fi

  if [ -e "$target_path" ]; then
    log_warn "Skipping $target_path; it is not a symlink"
    return 0
  fi

  ln -s "$source_path" "$target_path"
  log_success "Linked $target_path to $source_path"
}

if [ ! -f "$shared_guidance" ] || [ ! -d "$shared_skills" ]; then
  log_warn 'Shared agent configuration is unavailable; skipping Codex links'
  exit 0
fi

mkdir -p "$codex_dir/skills"
link_if_safe "$shared_guidance" "$codex_dir/AGENTS.md"

for skill_dir in "$shared_skills"/*; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  link_if_safe "$skill_dir" "$codex_dir/skills/$skill_name"
done
