#!/usr/bin/env bash
# Lint the tracked scripts: shellcheck (warning level) for bash and sh files,
# zsh -n for zsh files. Needs shellcheck and zsh on PATH. With whiskers on
# PATH, also checks that the generated theme files are up to date.
# Usage: test/lint.sh
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

bash_files=()
zsh_files=()
while IFS= read -r -d '' f; do
  [[ -f "$f" ]] || continue
  case "$f" in
    *.zsh | zsh/zshrc.symlink) zsh_files+=("$f") ;;
    *.sh) bash_files+=("$f") ;;
    *)
      first=''
      IFS= read -r first < "$f" || true
      if [[ "$first" =~ ^#!.*[/[:space:]](ba)?sh([[:space:]]|$) ]]; then
        bash_files+=("$f")
      fi
      ;;
  esac
done < <(git ls-files -z)

echo "shellcheck: ${#bash_files[@]} files"
shellcheck -x -S warning "${bash_files[@]}"

echo "zsh -n: ${#zsh_files[@]} files"
for f in "${zsh_files[@]}"; do
  zsh -n "$f"
done

if command -v whiskers > /dev/null; then
  echo 'themes: themes/render.sh --check'
  themes/render.sh --check
else
  echo 'themes: skipped (whiskers not on PATH)'
fi

echo 'lint OK'
