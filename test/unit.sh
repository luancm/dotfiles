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
# Cases run in a subshell, so exit ends only the current case.
fail() { echo "    $*" >&2; exit 1; }

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

case_install_release_binary_reports_install_failure() {
  load_download
  local tarball
  tarball="$(make_release mytool)"
  install() { return 1; }
  if install_release_binary mytool "file://$tarball" "$(sha256_of "$tarball")"; then
    fail "returned 0 when install failed"
  fi
}

case_install_release_binary_reports_mkdir_failure() {
  load_download
  local tarball
  tarball="$(make_release mytool)"
  touch "$HOME/.local"
  if install_release_binary mytool "file://$tarball" "$(sha256_of "$tarball")"; then
    fail "returned 0 when ~/.local/bin could not be created"
  fi
}

# --- lib/secure_localrc.sh ---------------------------------------------------

mode_of() { stat -c %a "$1" 2> /dev/null || stat -f %Lp "$1"; }

case_secure_localrc_creates_private_file() {
  bash "$DOTFILES/lib/secure_localrc.sh" || fail "exit status $?"
  [[ "$(mode_of "$HOME/.localrc")" == 600 ]] || fail "mode is $(mode_of "$HOME/.localrc")"
}

case_secure_localrc_fixes_regular_file_and_backups() {
  echo 'export A=1' > "$HOME/.localrc"
  echo 'export A=0' > "$HOME/.localrc.bak.1"
  chmod 644 "$HOME/.localrc" "$HOME/.localrc.bak.1"
  bash "$DOTFILES/lib/secure_localrc.sh" || fail "exit status $?"
  for f in "$HOME/.localrc" "$HOME/.localrc.bak.1"; do
    [[ "$(mode_of "$f")" == 600 ]] || fail "$f mode is $(mode_of "$f")"
  done
}

case_secure_localrc_fixes_symlink_target() {
  mkdir -p "$TEST_ROOT/private"
  echo 'export A=1' > "$TEST_ROOT/private/localrc"
  chmod 644 "$TEST_ROOT/private/localrc"
  ln -s "$TEST_ROOT/private/localrc" "$HOME/.localrc"
  bash "$DOTFILES/lib/secure_localrc.sh" || fail "exit status $?"
  [[ -L "$HOME/.localrc" ]] || fail "replaced the link"
  [[ "$(mode_of "$TEST_ROOT/private/localrc")" == 600 ]] ||
    fail "target mode is $(mode_of "$TEST_ROOT/private/localrc")"
}

case_secure_localrc_fails_when_target_stays_readable() {
  echo 'export A=1' > "$HOME/.localrc"
  chmod 644 "$HOME/.localrc"
  chmod() { return 1; }
  export -f chmod
  if bash "$DOTFILES/lib/secure_localrc.sh"; then
    fail "reported success while ~/.localrc stayed readable"
  fi
}

# --- scripts/harden_ubuntu_dev_host.sh: add_keys -----------------------------

load_add_keys() {
  ok() { :; }
  warn() { :; }
  eval "$(sed -n '/^add_keys() {/,/^}/p' "$DOTFILES/scripts/harden_ubuntu_dev_host.sh")"
  declare -F add_keys > /dev/null || fail "add_keys not found in the hardening script"
}

# Print a new public key line; extra args are passed to ssh-keygen (-C ...).
new_pubkey() {
  local f="$TEST_ROOT/key.$RANDOM$RANDOM"
  ssh-keygen -q -t ed25519 -N '' -f "$f" "$@" > /dev/null
  cat "$f.pub"
}

key_count() { ssh-keygen -lf "$1" 2> /dev/null | wc -l | tr -d ' '; }

case_add_keys_separates_key_from_unterminated_last_line() {
  load_add_keys
  local file="$TEST_ROOT/authorized_keys" old new
  old="$(new_pubkey -C old)"
  new="$(new_pubkey -C new)"
  printf '%s' "$old" > "$file"
  add_keys "$file" <<< "$new" || fail "add_keys returned nonzero"
  [[ "$(key_count "$file")" == 2 ]] || fail "ssh-keygen sees $(key_count "$file") keys, want 2"
  grep -qxF -- "$new" "$file" || fail "new key is not on its own line"
}

case_add_keys_handles_unterminated_key_without_comment() {
  load_add_keys
  local file="$TEST_ROOT/authorized_keys" old new
  old="$(new_pubkey -C '')"
  old="${old% }"
  new="$(new_pubkey -C new)"
  printf '%s' "$old" > "$file"
  add_keys "$file" <<< "$new" || fail "add_keys returned nonzero"
  [[ "$(key_count "$file")" == 2 ]] || fail "ssh-keygen sees $(key_count "$file") keys, want 2"
}

case_add_keys_skips_duplicates() {
  load_add_keys
  local file="$TEST_ROOT/authorized_keys" key
  key="$(new_pubkey -C k)"
  printf '%s\n' "$key" > "$file"
  add_keys "$file" <<< "$key" || fail "add_keys returned nonzero"
  [[ "$(wc -l < "$file" | tr -d ' ')" == 1 ]] || fail "duplicate key added"
}

case_add_keys_rejects_invalid_key() {
  load_add_keys
  local file="$TEST_ROOT/authorized_keys"
  : > "$file"
  if add_keys "$file" <<< "ssh-ed25519 not-a-key comment"; then
    fail "accepted an invalid key"
  fi
  [[ ! -s "$file" ]] || fail "wrote an invalid key"
}

# --- harden_ubuntu_dev_host.sh: sshd Match blocks ----------------------------

load_sshd_checks() {
  die() { printf '%s\n' "$*" >&2; exit 1; }
  eval "$(sed -n -e '/^match_auth_overrides() {/,/^}/p' -e '/^verify_sshd_effective() {/,/^}/p' \
    "$DOTFILES/scripts/harden_ubuntu_dev_host.sh")"
  declare -F verify_sshd_effective > /dev/null || fail "sshd checks not found in the hardening script"
  # shellcheck disable=SC2034 # read by the eval'd functions
  NEW_USER="$(id -un)" SUBNETS=(192.168.1.0/24) TAILSCALE=no ROOT_LOGIN_VALUE=prohibit-password
  # shellcheck disable=SC2034
  SSHD_DROPIN=00-hardening.conf SSHD_CONFIG="$TEST_ROOT/sshd_config"
  ssh-keygen -q -t ed25519 -N '' -f "$TEST_ROOT/host_key"
}

# sshd_config with the drop-in's auth settings, then the given extra lines.
write_sshd_config() {
  printf '%s\n' "HostKey $TEST_ROOT/host_key" 'PermitRootLogin prohibit-password' \
    'PasswordAuthentication no' 'KbdInteractiveAuthentication no' "$@" > "$SSHD_CONFIG"
}

need_sshd() {
  PATH="$PATH:/usr/sbin" command -v sshd > /dev/null || { echo "  (skipped: no sshd)"; exit 0; }
  PATH="$PATH:/usr/sbin"
}

case_sshd_match_overrides_flags_weakened_auth() {
  load_sshd_checks
  write_sshd_config 'Match Address 10.0.0.0/8' '  PasswordAuthentication yes' \
    'Match User deploy' '  PermitRootLogin=yes' '  KbdInteractiveAuthentication no'
  local out
  out="$(match_auth_overrides "$SSHD_CONFIG")"
  [[ "$(wc -l <<< "$out")" -eq 2 ]] || fail "expected 2 overrides, got: $out"
  [[ "$out" == *":6: PasswordAuthentication yes"* && "$out" == *":8: PermitRootLogin=yes"* ]] \
    || fail "wrong overrides: $out"
}

case_sshd_match_overrides_ignores_global_and_no() {
  load_sshd_checks
  write_sshd_config 'Match Address 10.0.0.0/8' '  PasswordAuthentication no' '  X11Forwarding yes'
  [[ -z "$(match_auth_overrides "$SSHD_CONFIG")" ]] || fail "flagged a safe Match block"
}

case_sshd_effective_passes_hardened_config() {
  need_sshd
  load_sshd_checks
  write_sshd_config
  verify_sshd_effective 2> "$TEST_ROOT/err" || fail "rejected a hardened config: $(< "$TEST_ROOT/err")"
}

case_sshd_effective_rejects_match_on_trusted_subnet() {
  need_sshd
  load_sshd_checks
  write_sshd_config 'Match Address 192.168.1.0/24' '  PasswordAuthentication yes'
  if (verify_sshd_effective 2> "$TEST_ROOT/err"); then
    fail "accepted passwords from a trusted subnet"
  fi
  grep -q 'allows passwords' "$TEST_ROOT/err" || fail "wrong error: $(< "$TEST_ROOT/err")"
}

# --- git/defaults.sh: SSH signing --------------------------------------------

# Run git/defaults.sh from DIR, like ./install does from ~/.dotfiles.
run_git_defaults() { (cd "$1" && bash "$DOTFILES/git/defaults.sh" > /dev/null); }

# Commit in a new repository outside the personal paths; print git's status.
commit_elsewhere() {
  local repo="$TEST_ROOT/elsewhere.$RANDOM"
  git init -q "$repo"
  git -C "$repo" -c user.name=t -c user.email=t@example.com \
    commit -q --allow-empty -m test > /dev/null 2>&1
}

case_git_signing_ignores_key_from_includeif() {
  local key
  ssh-keygen -q -t ed25519 -N '' -f "$TEST_ROOT/sign" > /dev/null
  git init -q "$HOME/.dotfiles"
  git config -f "$HOME/.gitconfig-personal" user.signingkey "$TEST_ROOT/sign.pub"
  run_git_defaults "$HOME/.dotfiles" || fail "defaults.sh failed"
  key="$(git config --global --get commit.gpgsign || true)"
  [[ "$key" != true ]] || fail "commit.gpgsign=true globally for a personal-only key"
  commit_elsewhere || fail "commit in an unrelated repository failed"
}

case_git_signing_on_for_global_key() {
  ssh-keygen -q -t ed25519 -N '' -f "$TEST_ROOT/sign" > /dev/null
  git config --global include.path "$HOME/.gitconfig.local"
  git config -f "$HOME/.gitconfig.local" user.signingkey "$TEST_ROOT/sign.pub"
  run_git_defaults "$HOME" || fail "defaults.sh failed"
  [[ "$(git config --global --get commit.gpgsign)" == true ]] || fail "commit.gpgsign not set"
  [[ "$(git config --global --get tag.gpgsign)" == true ]] || fail "tag.gpgsign not set"
}

case_git_signing_off_after_key_removed() {
  ssh-keygen -q -t ed25519 -N '' -f "$TEST_ROOT/sign" > /dev/null
  git config --global include.path "$HOME/.gitconfig.local"
  git config -f "$HOME/.gitconfig.local" user.signingkey "$TEST_ROOT/sign.pub"
  run_git_defaults "$HOME" || fail "defaults.sh failed (first run)"
  git config -f "$HOME/.gitconfig.local" --unset user.signingkey
  run_git_defaults "$HOME" || fail "defaults.sh failed (second run)"
  [[ -z "$(git config --global --get commit.gpgsign || true)" ]] || fail "commit.gpgsign still set"
  [[ -z "$(git config --global --get tag.gpgsign || true)" ]] || fail "tag.gpgsign still set"
  commit_elsewhere || fail "commit failed after the key was removed"
}

# --- run ---------------------------------------------------------------------

pattern="${1:-}"
while read -r name; do
  [[ -z "$pattern" || "$name" == *"$pattern"* ]] && run_case "$name"
done < <(declare -F | awk '{print $3}' | grep '^case_')

echo "$passed passed, $failed failed"
((failed == 0))
