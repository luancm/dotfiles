#!/usr/bin/env bash
# =============================================================================
# harden_ubuntu_dev_host.sh
#
# Baseline hardening for a fresh Debian/Ubuntu host (typically an LXC container
# on Proxmox) intended as a personal dev / "agentic workflow" box, reachable
# on a trusted LAN/Tailscale subnet only.
#
# WHAT IT DOES (and WHY)
# ----------------------
# 1. apt update/upgrade
#       Fresh images frequently ship with months of unpatched CVEs.
#
# 2. Installs fail2ban + unattended-upgrades
#       fail2ban: bans IPs that brute-force SSH (LAN is whitelisted).
#       unattended-upgrades: applies security updates automatically so the
#       host does not rot between manual sessions.
#
# 3. Creates a non-root sudo user with your SSH key
#       AI agents / dev tooling running as root is risky: a stray rm -rf or a
#       global package install touches the whole system. Non-root + sudo
#       contains blast radius and matches what most dev tools expect (brew,
#       nvm, asdf, pip --user, etc.). A sudo password also means a leaked
#       SSH key alone does not equal full root.
#
# 4. Configures UFW (default deny in / allow out)
#       SSH (22) and any --app-ports are opened only to --subnet. Even though
#       the host is not exposed to the internet, defense-in-depth keeps
#       things safe if the LAN ever gets compromised or reconfigured.
#
# 5. Hardens sshd
#       Disables passwords, empty passwords, root login, X11/TCP/agent
#       forwarding; caps auth attempts; sets sane keepalives. Standard
#       OpenSSH best practice for key-only access.
#
# 6. Enables fail2ban sshd jail (LAN ignored, 1h bantime, maxretry 5).
#
# 7. Enables unattended-upgrades daily.
#
# SAFETY
# ------
# - sshd config is validated with sshd -t before reload.
# - UFW SSH rule is added BEFORE enabling the firewall.
# - Root SSH is only disabled after the new user has a key + sudo password.
#
# USAGE
# -----
#   scp scripts/harden_ubuntu_dev_host.sh root@<host>:/tmp/
#   ssh root@<host> 'bash /tmp/harden_ubuntu_dev_host.sh \
#       --user luancm \
#       --pubkey "ssh-ed25519 AAAA... comment" \
#       --subnet 192.168.1.0/24 \
#       --app-ports 10101'
#
# Flags (all optional except --user):
#   --user        <name>    Non-root user to create (required)
#   --pubkey      <line>    SSH public key; if omitted, copies from
#                           /root/.ssh/authorized_keys
#   --subnet      <cidr>    Trusted source CIDR (default 192.168.1.0/24)
#   --app-ports   <list>    Comma-separated TCP ports to open to --subnet
#   --no-disable-root       Keep root SSH enabled (default: disable)
#   --skip-upgrade          Skip apt upgrade (faster re-runs)
# =============================================================================

set -euo pipefail

NEW_USER=""
SSH_PUBKEY=""
SUBNET="192.168.1.0/24"
APP_PORTS=""
DISABLE_ROOT=1
SKIP_UPGRADE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --user)            NEW_USER="$2"; shift 2 ;;
    --pubkey)          SSH_PUBKEY="$2"; shift 2 ;;
    --subnet)          SUBNET="$2"; shift 2 ;;
    --app-ports)       APP_PORTS="$2"; shift 2 ;;
    --no-disable-root) DISABLE_ROOT=0; shift ;;
    --skip-upgrade)    SKIP_UPGRADE=1; shift ;;
    -h|--help)         sed -n '2,63p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $1" >&2; exit 2 ;;
  esac
done

log()  { printf '\033[1;34m[..]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[OK]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[FAIL]\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "Must run as root."
[ -n "$NEW_USER" ]   || die "--user is required."
command -v apt-get >/dev/null || die "Debian/Ubuntu only (no apt-get found)."

if [ -z "$SSH_PUBKEY" ] && [ ! -s /root/.ssh/authorized_keys ]; then
  die "No --pubkey provided and /root/.ssh/authorized_keys is empty."
fi

log "apt update"
DEBIAN_FRONTEND=noninteractive apt-get update -qq
if [ "$SKIP_UPGRADE" -eq 0 ]; then
  log "apt upgrade (this may take a while)"
  DEBIAN_FRONTEND=noninteractive apt-get -y -qq \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" upgrade
fi

log "Installing ufw, fail2ban, unattended-upgrades"
DEBIAN_FRONTEND=noninteractive apt-get -y -qq install \
  ufw fail2ban unattended-upgrades

# ---- non-root user ----------------------------------------------------------
if id "$NEW_USER" >/dev/null 2>&1; then
  ok "User $NEW_USER already exists."
else
  log "Creating user $NEW_USER (will prompt for sudo password)"
  adduser --disabled-password --gecos "" "$NEW_USER"
  warn "Set a password for $NEW_USER now (needed for sudo):"
  passwd "$NEW_USER"
fi
usermod -aG sudo "$NEW_USER"

USER_HOME=$(getent passwd "$NEW_USER" | cut -d: -f6)
install -d -m 700 -o "$NEW_USER" -g "$NEW_USER" "$USER_HOME/.ssh"
if [ -n "$SSH_PUBKEY" ]; then
  printf '%s\n' "$SSH_PUBKEY" > "$USER_HOME/.ssh/authorized_keys"
else
  cp /root/.ssh/authorized_keys "$USER_HOME/.ssh/authorized_keys"
fi
chown "$NEW_USER:$NEW_USER" "$USER_HOME/.ssh/authorized_keys"
chmod 600 "$USER_HOME/.ssh/authorized_keys"
ok "SSH key installed at $USER_HOME/.ssh/authorized_keys"

# ---- UFW --------------------------------------------------------------------
log "Configuring UFW (allow 22 and app-ports from $SUBNET)"
ufw --force reset >/dev/null
ufw default deny incoming >/dev/null
ufw default allow outgoing >/dev/null
ufw allow from "$SUBNET" to any port 22 proto tcp comment "SSH from $SUBNET" >/dev/null
if [ -n "$APP_PORTS" ]; then
  IFS=',' read -ra PORTS <<< "$APP_PORTS"
  for p in "${PORTS[@]}"; do
    p_trimmed=$(echo "$p" | tr -d '[:space:]')
    [ -z "$p_trimmed" ] && continue
    ufw allow from "$SUBNET" to any port "$p_trimmed" proto tcp \
      comment "App $p_trimmed from $SUBNET" >/dev/null
    ok "Opened ${p_trimmed}/tcp from $SUBNET"
  done
fi
ufw logging low >/dev/null
yes | ufw enable >/dev/null
ok "UFW enabled."

# ---- sshd hardening ---------------------------------------------------------
log "Writing /etc/ssh/sshd_config.d/99-hardening.conf"
mkdir -p /etc/ssh/sshd_config.d
ROOT_LOGIN_VALUE="prohibit-password"
[ "$DISABLE_ROOT" -eq 1 ] && ROOT_LOGIN_VALUE="no"

cat > /etc/ssh/sshd_config.d/99-hardening.conf <<EOF
# Managed by harden_ubuntu_dev_host.sh
PermitRootLogin ${ROOT_LOGIN_VALUE}
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
MaxAuthTries 3
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
AllowTcpForwarding no
AllowAgentForwarding no
EOF
chmod 644 /etc/ssh/sshd_config.d/99-hardening.conf

if [ "$DISABLE_ROOT" -eq 1 ]; then
  # Safety: refuse to disable root unless the new user has a key AND a password.
  if ! [ -s "$USER_HOME/.ssh/authorized_keys" ]; then
    die "Refusing to disable root SSH: $NEW_USER has no authorized_keys."
  fi
  PW_STATUS=$(passwd -S "$NEW_USER" | awk '{print $2}')
  if [ "$PW_STATUS" != "P" ]; then
    die "Refusing to disable root SSH: $NEW_USER has no password set (status=$PW_STATUS). Run: passwd $NEW_USER"
  fi
fi

sshd -t && ok "sshd config valid"
systemctl reload ssh
ok "sshd reloaded"

# ---- fail2ban ---------------------------------------------------------------
log "Configuring fail2ban (LAN $SUBNET ignored)"
cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd
ignoreip = 127.0.0.1/8 ::1 ${SUBNET}

[sshd]
enabled  = true
port     = ssh
backend  = systemd
EOF
systemctl enable --now fail2ban >/dev/null
ok "fail2ban active"

# ---- unattended-upgrades ----------------------------------------------------
log "Enabling daily security updates"
cat > /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Download-Upgradeable-Packages "1";
EOF
systemctl enable --now unattended-upgrades >/dev/null
ok "unattended-upgrades enabled"

# ---- summary ----------------------------------------------------------------
echo
ok "Hardening complete."
echo "  User:           $NEW_USER (sudo, key-only SSH)"
echo "  Root SSH:       $([ "$DISABLE_ROOT" -eq 1 ] && echo disabled || echo key-only)"
echo "  Allowed in:     22/tcp from $SUBNET${APP_PORTS:+, $APP_PORTS/tcp from $SUBNET}"
echo "  Services:       ssh, ufw, fail2ban, unattended-upgrades"
echo
warn "Before closing this root session, test from your workstation:"
echo "    ssh ${NEW_USER}@<host> 'whoami && sudo -n true 2>&1 || echo sudo-needs-password-OK'"
