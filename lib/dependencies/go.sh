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
#
# GO_VERSION and the tarball sums are pinned in lib/versions.env.

GO_INSTALL_DIR="/usr/local/go"

install_go_tarball() {
  local arch go_arch sha_var tmpfile
  arch="$(release_arch)"
  if [[ -z "$arch" ]]; then
    log_error "Unsupported architecture: $(uname -m)"
    return 1
  fi
  go_arch=amd64
  [[ "$arch" == aarch64 ]] && go_arch=arm64
  sha_var="GO_SHA256_${arch^^}"

  tmpfile=$(mktemp -t go-tarball.XXXXXX) || return 1
  if ! download_verified "https://go.dev/dl/go${GO_VERSION}.linux-${go_arch}.tar.gz" \
      "${!sha_var}" "$tmpfile"; then
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

if ! remembered_confirmation go "Install Go ${GO_VERSION}?"; then
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
