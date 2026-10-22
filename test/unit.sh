#!/usr/bin/env bash
# Offline unit tests for installer helpers. Each case runs in a subshell with
# a temporary HOME, so nothing touches the real home folder.
#   test/unit.sh            run all cases
#   test/unit.sh <pattern>  run cases whose name contains <pattern>
set -uo pipefail

if ((BASH_VERSINFO[0] < 4)); then
  echo "Bash 4+ is required (found $BASH_VERSION)" >&2
  exit 1
fi

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
export DOTFILES
# Inherited git settings (e.g. GIT_CONFIG_COUNT from locstat) would leak into
# the git cases.
while IFS= read -r var; do unset "$var"; done < <(compgen -e | grep -E '^GIT_CONFIG_')
export DOTFILES_YES=1 DOTFILES_NONINTERACTIVE=1

passed=0
failed=0
fail() { echo "    $*" >&2; return 1; }

# Set up a fresh HOME and run one case.
run_case() {
  local name="$1" out
  out="$(
    TEST_ROOT="$(mktemp -d)"
    trap 'rm -rf "$TEST_ROOT"' EXIT
    export HOME="$TEST_ROOT/home"
    mkdir -p "$HOME"
    export DOTFILES_ANSWERS_FILE="$TEST_ROOT/answers"
    "$name" 2>&1
  )"
  local status=$?
  if ((status == 0)); then
    passed=$((passed + 1))
    echo "ok   ${name#case_}"
  else
    failed=$((failed + 1))
    echo "FAIL ${name#case_}"
    [[ -n "$out" ]] && sed 's/^/    /' <<< "$out"
  fi
}

# --- lib/download.sh ---------------------------------------------------------

load_download() {
  source "$DOTFILES/lib/io_handlers.sh"
  source "$DOTFILES/lib/download.sh"
}

# Make a tar.gz holding an executable NAME; print its path.
make_release() {
  local name="$1" dir="$TEST_ROOT/release-src"
  mkdir -p "$dir"
  printf '#!/bin/sh\necho %s\n' "$name" > "$dir/$name"
  chmod +x "$dir/$name"
  tar -czf "$TEST_ROOT/$name.tar.gz" -C "$dir" "$name"
  echo "$TEST_ROOT/$name.tar.gz"
}

case_download_verified_accepts_matching_sum() {
  load_download
  local src="$TEST_ROOT/file"
  echo data > "$src"
  download_verified "file://$src" "$(sha256_of "$src")" "$TEST_ROOT/out" ||
    fail "download_verified returned nonzero"
  cmp -s "$src" "$TEST_ROOT/out" || fail "file not saved"
}

case_download_verified_rejects_wrong_sum() {
  load_download
  local src="$TEST_ROOT/file"
  echo data > "$src"
  if download_verified "file://$src" "$(printf '0%.0s' {1..64})" "$TEST_ROOT/out"; then
    fail "accepted a wrong sum"
  fi
  [[ ! -e "$TEST_ROOT/out" ]] || fail "kept a file with a wrong sum"
}

case_download_verified_rejects_missing_sum() {
  load_download
  if download_verified "file://$TEST_ROOT/none" "" "$TEST_ROOT/out"; then
    fail "accepted an empty sum"
  fi
}

case_install_release_binary_installs() {
  load_download
  local tarball
  tarball="$(make_release mytool)"
  install_release_binary mytool "file://$tarball" "$(sha256_of "$tarball")" ||
    fail "install_release_binary returned nonzero"
  [[ -x "$HOME/.local/bin/mytool" ]] || fail "binary not installed"
}

# --- run ---------------------------------------------------------------------

pattern="${1:-}"
while read -r name; do
  [[ -z "$pattern" || "$name" == *"$pattern"* ]] && run_case "$name"
done < <(declare -F | awk '{print $3}' | grep '^case_')

echo "$passed passed, $failed failed"
((failed == 0))
