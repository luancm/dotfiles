#!/usr/bin/env bash
#
# Expose the shared agent configuration to clients that support local skills
# and guidance files.  ~/.agents is the canonical cross-agent entrypoint;
# provider-specific directories contain only symlinks.
#
# Cursor and opencode read ~/.agents/skills themselves (Cursor also reads the
# Claude and Codex skill folders), so they get no skill links: extra links
# would only list each skill again.
set -euo pipefail

source "${DOTFILES:?DOTFILES must be set}/lib/io_handlers.sh"

agents_dir="$HOME/.agents"
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

  mkdir -p "$(dirname "$target_path")"
  ln -s "$source_path" "$target_path"
  log_success "Linked $target_path to $source_path"
}

# One link per shared skill inside a real folder that the tool also writes to.
# Links to skills that no longer exist are removed.
link_each_skill() {
  local skills_dir="$1" skill_dir link
  mkdir -p "$skills_dir"
  for skill_dir in "$shared_skills"/*; do
    [ -d "$skill_dir" ] || continue
    link_if_safe "$skill_dir" "$skills_dir/$(basename "$skill_dir")"
  done
  for link in "$skills_dir"/*; do
    if [ ! -L "$link" ] || [ -e "$link" ]; then continue; fi
    [[ "$(readlink "$link")" == "$shared_skills/"* ]] || continue
    rm "$link"
    log_info "Removed link to a deleted skill: $link"
  done
}

if [ ! -f "$shared_guidance" ] || [ ! -d "$shared_skills" ]; then
  log_warn 'Shared agent configuration is unavailable; skipping agent links'
  exit 0
fi

# Claude Code
link_if_safe "$shared_guidance" "$HOME/.claude/CLAUDE.md"
if [ -d "$HOME/.claude/skills" ] && [ ! -L "$HOME/.claude/skills" ]; then
  link_each_skill "$HOME/.claude/skills"
else
  link_if_safe "$shared_skills" "$HOME/.claude/skills"
fi

# Codex keeps its own system skills in ~/.codex/skills, so link each skill.
link_if_safe "$shared_guidance" "$HOME/.codex/AGENTS.md"
link_each_skill "$HOME/.codex/skills"

# opencode
link_if_safe "$shared_guidance" "$HOME/.config/opencode/AGENTS.md"
