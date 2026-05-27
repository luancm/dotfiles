#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DOTFILES:-}" ]]; then echo 'Dotfiles were not installed, to install run `bash ~/.dotfiles/install`'; exit 1; fi

# Pulling: rebase instead of merge to avoid noisy "Merge branch ..." commits.
git config --global pull.rebase true
git config --global rebase.autoStash true

# Pushing: auto-set upstream on first push of a new branch; only push current branch.
git config --global push.autoSetupRemote true
git config --global push.default simple

git config --global init.defaultBranch main

# Conflict resolution: remember resolutions for replay during rebases.
# git config --global rerere.enabled true

# Fetching: clean up remote-tracking branches/tags that no longer exist upstream.
# git config --global fetch.prune true
# git config --global fetch.prunetags true

# Branch listing: most-recent-first by default; multi-column output.
git config --global branch.sort -committerdate
git config --global column.ui auto

# Diffs: histogram algorithm produces cleaner diffs; highlight moved code.
git config --global diff.algorithm histogram
git config --global diff.colorMoved default

# Merge conflict markers: zdiff3 includes the common ancestor for context (git 2.35+).
git config --global merge.conflictStyle zdiff3
