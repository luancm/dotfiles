#!/usr/bin/env bash

# Installs Go.
#   - macOS (brew):  delegated to Homebrew (`brew install go`).
#   - Linux:         official tarball from go.dev into /usr/local/go.
#
# Apt's `golang-go` is intentionally avoided: it ships an older toolchain.
#
# PATH note: /usr/local/go/bin and $HOME/go/bin must be on PATH for the
# `go` command and tools installed via `go install` to be available.
# This script does not modify your shell rc.

source $DOTFILES/lib/io_handlers.sh
source $DOTFILES/lib/package_installer.sh

GO_VERSION="1.26.3"
GO_INSTALL_DIR="/usr/local/go"

detect_go_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    armv6l) echo "armv6l" ;;
    *) echo "" ;;
  esac
}

install_go_tarball() {
  local arch
  arch=$(detect_go_arch)
  if [[ -z "$arch" ]]; then
    log_error "Unsupported architecture: $(uname -m)"
    return 1
  fi

  if ! command -v curl > /dev/null; then
    log_info 'Go installer requires curl; running curl dependency installer...'
    source "$DOTFILES/lib/dependencies/curl.sh"
  fi
  if ! command -v curl > /dev/null; then
    log_error 'curl is required but could not be installed; cannot install Go.'
    return 1
  fi

  local tarball="go${GO_VERSION}.linux-${arch}.tar.gz"
  local url="https://go.dev/dl/${tarball}"
  local tmpfile
  tmpfile=$(mktemp -t go-tarball.XXXXXX) || return 1

  log_info "Downloading ${url}"
  if ! curl -fSL --progress-bar -o "$tmpfile" "$url"; then
    log_error "Failed to download $url"
    rm -f "$tmpfile"
    return 1
  fi

  log_info "Installing Go ${GO_VERSION} to ${GO_INSTALL_DIR} (requires sudo)"
  sudo rm -rf "$GO_INSTALL_DIR"
  sudo tar -C /usr/local -xzf "$tmpfile"
  rm -f "$tmpfile"
}

# Idempotency: skip if any Go is already installed, regardless of version.
if command -v go > /dev/null; then
  current="$(go version 2>/dev/null | awk '{print $3}' | sed 's/^go//')"
  log_success "Dependency \`go\` already installed (go${current})"
  return 0
fi

if ! prompt_confirmation "Install Go ${GO_VERSION}?"; then
  log_info 'Skipping Go installation'
  return 0
fi

if [[ "$PKG_MANAGER" == "brew" ]]; then
  install_package go
elif [[ "$(uname -s)" == "Linux" ]]; then
  install_go_tarball || { log_error 'Go installation failed'; return 1; }
else
  log_warn "Don't know how to install Go on $(uname -s); install manually."
  return 0
fi

# Verify
if command -v go > /dev/null || [[ -x "$GO_INSTALL_DIR/bin/go" ]]; then
  installed="$("${GO_INSTALL_DIR}/bin/go" version 2>/dev/null || go version 2>/dev/null | awk '{print $3}')"
  log_success "Dependency \`go\` installed successfully (${installed})"
  if ! command -v go > /dev/null; then
    log_info "Add the following to your shell rc and restart your shell:"
    log_info '  export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"'
  fi
else
  log_error 'Go installation failed'
fi
