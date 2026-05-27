#!/usr/bin/env bash
# =============================================================================
# bootstrap_dev_env.sh
#
# Bootstraps a personal dev environment on a freshly-hardened Debian/Ubuntu
# host. Run AFTER scripts/harden_ubuntu_dev_host.sh, as the non-root dev user.
#
# WHAT IT DOES
# ------------
# 1. Installs git (apt) if missing.
# 2. Clones the dotfiles repo over HTTPS into --dest (default ~/.dotfiles).
#    HTTPS avoids the chicken-and-egg of needing an SSH key on GitHub first;
#    the repo is public, so a read-only HTTPS clone is fine for bootstrap.
# 3. Runs the dotfiles install script (which installs zsh, starship, antidote,
#    symlinks, and generates ~/.ssh/id_ed25519 via its own setup_ssh).
# 4. Prints the generated SSH public key with a link to GitHub's SSH-key
#    settings page, so you can add it.
# 5. After you confirm the key is added, swaps the origin remote from HTTPS
#    to SSH and verifies the connection. On failure it reverts to HTTPS so
#    you are not left with a broken remote.
#
# USAGE
# -----
#   ./bootstrap_dev_env.sh \
#       [--repo-https https://github.com/luancm/dotfiles] \
#       [--repo-ssh   git@github.com:luancm/dotfiles.git] \
#       [--dest       ~/.dotfiles] \
#       [--no-install] [--no-swap-remote]
# =============================================================================

set -euo pipefail

REPO_HTTPS="https://github.com/luancm/dotfiles"
REPO_SSH="git@github.com:luancm/dotfiles.git"
DEST="$HOME/.dotfiles"
RUN_INSTALL=1
SWAP_REMOTE=1

while [ $# -gt 0 ]; do
  case "$1" in
    --repo-https)     REPO_HTTPS="$2"; shift 2 ;;
    --repo-ssh)       REPO_SSH="$2"; shift 2 ;;
    --dest)           DEST="$2"; shift 2 ;;
    --no-install)     RUN_INSTALL=0; shift ;;
    --no-swap-remote) SWAP_REMOTE=0; shift ;;
    -h|--help)        sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $1" >&2; exit 2 ;;
  esac
done

log()  { printf '\033[1;34m[..]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[OK]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[FAIL]\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "Do not run as root. Run as the dev user (sudo is invoked only for apt)."

# 1. git -----------------------------------------------------------------
if command -v git >/dev/null 2>&1; then
  ok "git already installed ($(git --version))"
else
  log "Installing git via apt"
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git
  ok "git installed"
fi

# 2. clone (HTTPS) -------------------------------------------------------
if [ -d "$DEST/.git" ]; then
  ok "Dotfiles repo already present at $DEST"
elif [ -e "$DEST" ]; then
  die "$DEST exists but is not a git repo. Remove or rename it first."
else
  log "Cloning $REPO_HTTPS -> $DEST"
  git clone "$REPO_HTTPS" "$DEST"
  ok "Cloned dotfiles"
fi

# 3. install (zsh, starship, antidote, symlinks, ssh-keygen) -----------------
if [ "$RUN_INSTALL" -eq 1 ]; then
  if [ -f "$DEST/install" ]; then
    log "Running $DEST/install (interactive)"
    bash "$DEST/install"
    ok "Install script finished"
  else
    warn "No $DEST/install found; skipping"
  fi
fi

# 4. show pubkey ---------------------------------------------------------
PUBKEY="$HOME/.ssh/id_ed25519.pub"
if [ ! -f "$PUBKEY" ]; then
  warn "$PUBKEY not found. Generate it (ssh-keygen -t ed25519) and re-run with --no-install."
  exit 0
fi

echo
echo "============ ADD THIS KEY TO GITHUB ============"
echo "  https://github.com/settings/ssh/new"
echo
cat "$PUBKEY"
echo "================================================"
echo

# 5. swap remote to SSH --------------------------------------------------
if [ "$SWAP_REMOTE" -eq 1 ]; then
  read -r -p "Have you added the key to GitHub? Swap origin to SSH now? [y/N] " ans
  case "$ans" in
    y|Y|yes|YES)
      git -C "$DEST" remote set-url origin "$REPO_SSH"
      log "Accepting github.com host key (if new)"
      ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true
      log "Verifying SSH fetch from origin"
      if git -C "$DEST" fetch origin >/dev/null 2>&1; then
        ok "Remote swapped to SSH; fetch works"
      else
        warn "SSH fetch failed. Reverting origin to HTTPS so you are not stuck."
        git -C "$DEST" remote set-url origin "$REPO_HTTPS"
        warn "Fix the GitHub key, then run: git -C $DEST remote set-url origin $REPO_SSH"
      fi
      ;;
    *)
      warn "Skipped remote swap. To do it later:"
      echo "    git -C $DEST remote set-url origin $REPO_SSH"
      ;;
  esac
fi

ok "Bootstrap complete."
