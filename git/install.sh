#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DOTFILES:-}" ]]; then echo 'Dotfiles were not installed, to install run `bash ~/.dotfiles/install`'; exit 1; fi
source "$DOTFILES/lib/io_handlers.sh"

setup_git() {
	# `git config --get` returns 1 when the key is missing; tolerate that under set -e.
	if [[ "$(git config --global --get dotfiles.managed || true)" = "true" ]]; then
		log_success "Git: Already managed by dotfiles"
		return 0
	fi

	log_info 'Git: Setting up gitconfig'
	if [[ -f ~/.gitconfig ]]; then
		local backup
		backup="$HOME/.gitconfig.backup.$(date +%Y%m%d%H%M%S)"
		log_info 'Git: You already have a .gitconfig. Making a backup...'
		mv ~/.gitconfig "$backup"
		log_success "Git: Moved ~/.gitconfig to $backup"
	fi

	local name email
	name="$(get_input 'Git: What is your author name?')"
	email="$(get_input 'Git: What is your author email?')"
	if [[ -n "$name" ]]; then
		git config --global user.name "$name"
	else
		log_warn 'Git: user.name not set. Run: git config --global user.name "Your Name"'
	fi
	if [[ -n "$email" ]]; then
		git config --global user.email "$email"
	else
		log_warn 'Git: user.email not set. Run: git config --global user.email "you@example.com"'
	fi
	git config --global include.path ~/.gitconfig.local
	git config --global dotfiles.managed true
}

# Machine-local git settings (untracked), loaded through include.path.
ensure_gitconfig_local() {
	local f="$HOME/.gitconfig.local"
	[[ -e "$f" ]] && return 0
	cat > "$f" <<'EOF'
# Machine-local git settings (untracked). Loaded from ~/.gitconfig.
#
# SSH commit signing: set the key here, then run ./update. git/defaults.sh
# turns on commit.gpgsign and tag.gpgsign when user.signingkey is set.
# [user]
# 	signingkey = ~/.ssh/id_ed25519.pub
#
# A key for one identity only (e.g. ~/.gitconfig-personal) also needs
# [commit] gpgsign = true in that file.
EOF
	log_success 'Git: Created ~/.gitconfig.local'
}

setup_git
ensure_gitconfig_local

log_info 'Git: Creating aliases'
source "$DOTFILES/git/aliases.sh"

log_info 'Git: Applying defaults'
source "$DOTFILES/git/defaults.sh"

log_success 'Git: Successfully configured'
