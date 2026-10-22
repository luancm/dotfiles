#!/usr/bin/env bash
# Downloads for tools that the package manager does not provide. Each file is
# checked against a pinned sha256 from lib/versions.env before it is used.

# shellcheck source=lib/versions.env
source "$DOTFILES/lib/versions.env"

# CPU type as release file names spell it: x86_64 or aarch64 (empty if other).
release_arch() {
  case "$(uname -m)" in
    x86_64 | amd64) echo x86_64 ;;
    aarch64 | arm64) echo aarch64 ;;
  esac
}

sha256_of() {
  if command -v sha256sum > /dev/null; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

# download_verified URL SHA256 DEST: save URL as DEST only if the sha256 matches.
download_verified() {
  local url="$1" expected="$2" dest="$3" tmp actual
  if [[ -z "$expected" ]]; then
    log_error "No pinned sha256 for $url (see lib/versions.env)"
    return 1
  fi
  if ! command -v curl > /dev/null; then
    log_error "curl is required to download $url"
    return 1
  fi
  tmp="$(mktemp)" || return 1
  log_info "Downloading $url"
  if ! curl -fsSL --retry 2 -o "$tmp" "$url"; then
    log_error "Download failed: $url"
    rm -f "$tmp"
    return 1
  fi
  actual="$(sha256_of "$tmp")"
  if [[ "$actual" != "$expected" ]]; then
    log_error "Checksum mismatch for $url (expected $expected, got $actual)"
    rm -f "$tmp"
    return 1
  fi
  mv "$tmp" "$dest"
}

# install_release_binary NAME URL SHA256: put the NAME binary from a verified
# .tar.gz into ~/.local/bin (the zshrc puts it on PATH).
install_release_binary() {
  local name="$1" url="$2" expected="$3" tmp binary
  tmp="$(mktemp -d)" || return 1
  if ! download_verified "$url" "$expected" "$tmp/release.tar.gz" ||
    ! tar -xzf "$tmp/release.tar.gz" -C "$tmp"; then
    rm -rf "$tmp"
    return 1
  fi
  binary="$(find "$tmp" -type f -name "$name" | head -1)"
  if [[ -z "$binary" ]]; then
    log_error "No \`$name\` binary in $url"
    rm -rf "$tmp"
    return 1
  fi
  if ! mkdir -p "$HOME/.local/bin" || ! install -m 755 "$binary" "$HOME/.local/bin/$name"; then
    log_error "Could not install \`$name\` to ~/.local/bin"
    rm -rf "$tmp"
    return 1
  fi
  rm -rf "$tmp"
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
  log_info "Installed \`$name\` to ~/.local/bin"
}
