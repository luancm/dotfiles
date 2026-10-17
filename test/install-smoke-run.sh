#!/usr/bin/env bash
# Runs inside the smoke-test container (see test/install-smoke.sh).
set -euo pipefail
cd "$HOME/.dotfiles"

# Answer "no" to each optional bundle so the run covers the core path.
answers="$HOME/.dotfiles/cache/install-answers"
mkdir -p "$(dirname "$answers")"
grep -ohE 'remembered_(confirmation|choice) [a-z_]+' lib/dependencies/*.sh \
  | awk '{print $2 "=no"}' | sort -u > "$answers"

./install --yes

fail() { echo "FAIL: $*" >&2; exit 1; }
echo '== checks'
[[ -f ~/.zshrc && ! -L ~/.zshrc ]] || fail "$HOME/.zshrc is not a local file"
grep -q 'zsh/zshrc.symlink' ~/.zshrc || fail "$HOME/.zshrc does not load zsh/zshrc.symlink"
[[ "$(stat -c %a ~/.localrc)" == 600 ]] || fail "$HOME/.localrc is not mode 600"
[[ "$(git config --global --get dotfiles.managed)" == true ]] || fail 'git settings not applied'
[[ -L ~/.config/nvim/init.lua ]] || fail "$HOME/.config/nvim/init.lua is not linked"
for cmd in curl zsh ssh-keygen; do
  command -v "$cmd" > /dev/null || fail "$cmd is not installed"
done
out=$(zsh -i -c 'print -r -- zsh-start-ok' 2>&1) || fail "interactive zsh failed: $out"
grep -q zsh-start-ok <<< "$out" || fail "interactive zsh did not finish: $out"
echo 'smoke test OK'
