#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DOTFILES:-}" ]]; then echo 'Dotfiles were not installed, to install run `bash ~/.dotfiles/install`'; exit 1; fi
source "$DOTFILES/lib/io_handlers.sh"

# Pulling: rebase instead of merge to avoid noisy "Merge branch ..." commits.
git config --global pull.rebase true
git config --global rebase.autoStash true
# Update dependent branch refs when rebasing a stack of branches.
git config --global rebase.updateRefs true

# Pushing: auto-set upstream on first push of a new branch; only push current branch.
git config --global push.autoSetupRemote true
git config --global push.default simple

git config --global init.defaultBranch main

# Conflict resolution: remember resolutions for replay during rebases.
git config --global rerere.enabled true

# Fetching: clean up remote-tracking branches/tags that no longer exist upstream.
git config --global fetch.prune true
git config --global fetch.prunetags true

# Branch listing: most-recent-first by default; multi-column output.
git config --global branch.sort -committerdate
git config --global tag.sort version:refname
git config --global column.ui auto

# Diffs: histogram algorithm produces cleaner diffs; highlight moved code.
git config --global diff.algorithm histogram
git config --global diff.colorMoved default

# Merge conflict markers: zdiff3 includes the common ancestor for context (git 2.35+).
git config --global merge.conflictStyle zdiff3

# Committing: show the full diff in the commit message editor.
git config --global commit.verbose true

# Typos: prompt to run the corrected command instead of erroring out.
git config --global help.autocorrect prompt

# Pager and diff tools, when installed (lib/dependencies/git_tools.sh puts
# release binaries in ~/.local/bin, which may not be on PATH yet).
tools_path="$HOME/.local/bin:$PATH"
if PATH="$tools_path" command -v delta > /dev/null; then
  git config --global core.pager delta
  git config --global interactive.diffFilter 'delta --color-only'
  git config --global delta.navigate true
fi
if PATH="$tools_path" command -v difft > /dev/null; then
  git config --global difftool.difftastic.cmd 'difft "$LOCAL" "$REMOTE"'
  git config --global difftool.prompt false
  git config --global alias.dft 'difftool -t difftastic'
fi
unset tools_path

# Identity per directory: repos under these paths load ~/.gitconfig-personal
# (machine-local). git skips include files that do not exist.
# shellcheck disable=SC2088 # git expands ~ in these values itself
for personal_dir in '~/Projects/personal/' '~/.dotfiles/' '~/.dotfiles-private/'; do
  git config --global "includeIf.gitdir:${personal_dir}.path" '~/.gitconfig-personal'
done
unset personal_dir

# Commit signing with SSH keys. On globally only when a key applies in every
# repository (user.signingkey or gpg.ssh.defaultKeyCommand in ~/.gitconfig or
# ~/.gitconfig.local), so commits never fail for lack of a key. A key that only
# an includeIf file sets (~/.gitconfig-personal) needs commit.gpgsign and
# tag.gpgsign in that same file.
git config --global gpg.format ssh
if [[ -f "$HOME/.config/git/allowed_signers" ]]; then
  # shellcheck disable=SC2088 # git expands ~ itself
  git config --global gpg.ssh.allowedSignersFile '~/.config/git/allowed_signers'
fi
# Read the config outside any repository, so includeIf sections do not match.
outside_repo="$(mktemp -d)"
global_signing_key() {
  (cd "$outside_repo" && GIT_CEILING_DIRECTORIES="$outside_repo" \
    git config --global --includes --get "$1") > /dev/null
}
if global_signing_key user.signingkey || global_signing_key gpg.ssh.defaultKeyCommand; then
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true
else
  git config --global --unset-all commit.gpgsign || true
  git config --global --unset-all tag.gpgsign || true
  log_info 'Git: SSH signing is off. Set user.signingkey in ~/.gitconfig.local to turn it on.'
fi
rmdir "$outside_repo"
unset outside_repo
unset -f global_signing_key
