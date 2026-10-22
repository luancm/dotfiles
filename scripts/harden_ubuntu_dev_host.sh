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
#       SSH (22) and any --app-ports are opened only to each --subnet and,
#       when Tailscale is present, to the tailscale0 interface. Even though
#       the host is not exposed to the internet, defense-in-depth keeps
#       things safe if the LAN ever gets compromised or reconfigured.
#       Existing UFW rules are reset (ufw keeps a timestamped backup).
#
# 5. Hardens sshd
#       Disables passwords, empty passwords, root login, X11 and agent
#       forwarding; caps auth attempts (6, the OpenSSH default, so a few
#       agent keys still fit); sets sane keepalives. TCP forwarding stays on
#       for remote editors (VS Code / Cursor Remote-SSH).
#
# 6. Enables fail2ban sshd jail (trusted subnets ignored, 1h bantime,
#    maxretry 5).
#
# 7. Enables unattended-upgrades daily.
#
# SAFETY
# ------
# - sshd uses the first value it reads and loads sshd_config.d/ in lexical
#   order, so the drop-in is 00-hardening.conf (before 50-cloud-init.conf).
# - sshd config is validated with sshd -t before reload. Match blocks may not
#   re-enable password, keyboard-interactive or root login, and the effective
#   values are checked with sshd -T -C for the new user and root from each
#   trusted network and an outside address.
# - UFW SSH rules are added BEFORE enabling the firewall.
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
#   --pubkey      <line>    SSH public key to add; if omitted, adds the keys
#                           from /root/.ssh/authorized_keys. Existing keys
#                           are kept.
#   --subnet      <cidr>    Trusted source CIDR; repeatable
#                           (default 192.168.1.0/24)
#   --app-ports   <list>    Comma-separated TCP ports to open to the trusted
#                           sources
#   --tailscale   auto|yes|no
#                           Allow SSH/app ports on tailscale0 (default auto:
#                           yes when the tailscale0 interface exists)
#   --no-disable-root       Keep root SSH enabled (default: disable)
#   --skip-upgrade          Skip apt upgrade (faster re-runs)
# =============================================================================

set -euo pipefail

NEW_USER=""
SSH_PUBKEY=""
SUBNETS=()
APP_PORTS=""
TAILSCALE="auto"
DISABLE_ROOT=1
SKIP_UPGRADE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --user)            NEW_USER="$2"; shift 2 ;;
    --pubkey)          SSH_PUBKEY="$2"; shift 2 ;;
    --subnet)          SUBNETS+=("$2"); shift 2 ;;
    --app-ports)       APP_PORTS="$2"; shift 2 ;;
    --tailscale)       TAILSCALE="$2"; shift 2 ;;
    --no-disable-root) DISABLE_ROOT=0; shift ;;
    --skip-upgrade)    SKIP_UPGRADE=1; shift ;;
    -h|--help)         sed -n '2,74p' "$0"; exit 0 ;;
    *) echo "Unknown flag: $1" >&2; exit 2 ;;
  esac
done
[ "${#SUBNETS[@]}" -gt 0 ] || SUBNETS=("192.168.1.0/24")

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

for s in "${SUBNETS[@]}"; do
  [[ "$s" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]{1,2}$ ]] || die "Invalid --subnet: $s (expected CIDR, e.g. 192.168.1.0/24)"
done

case "$TAILSCALE" in
  yes|no) ;;
  auto) ip link show tailscale0 >/dev/null 2>&1 && TAILSCALE=yes || TAILSCALE=no ;;
  *) die "Invalid --tailscale: $TAILSCALE (expected auto, yes or no)" ;;
esac
TRUSTED_DESC="${SUBNETS[*]}"
[ "$TAILSCALE" = yes ] && TRUSTED_DESC="$TRUSTED_DESC tailscale0"

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
AUTH_KEYS="$USER_HOME/.ssh/authorized_keys"
touch "$AUTH_KEYS"
# add_keys FILE: append each valid public key read from stdin to FILE once.
# Returns 1 if any line was not a valid key (those lines are not written).
add_keys() {
  local file="$1" line added=0 invalid=0
  # Without a final newline, the next key would join the last line.
  if [ -s "$file" ] && [ -n "$(tail -c 1 "$file")" ]; then
    printf '\n' >> "$file"
  fi
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in '' | '#'*) continue ;; esac
    if ! printf '%s\n' "$line" | ssh-keygen -lf /dev/stdin > /dev/null 2>&1; then
      warn "Not a valid public key, skipped: ${line:0:40}..."
      invalid=$((invalid + 1))
      continue
    fi
    grep -qxF -- "$line" "$file" && continue
    printf '%s\n' "$line" >> "$file"
    added=$((added + 1))
  done
  ok "Added $added new key(s) to $file"
  [ "$invalid" -eq 0 ]
}
if [ -n "$SSH_PUBKEY" ]; then
  printf '%s\n' "$SSH_PUBKEY" | add_keys "$AUTH_KEYS" || die "--pubkey is not a valid SSH public key."
else
  add_keys "$AUTH_KEYS" < /root/.ssh/authorized_keys || warn "Some lines in /root/.ssh/authorized_keys were skipped."
fi
ssh-keygen -lf "$AUTH_KEYS" > /dev/null 2>&1 || die "$AUTH_KEYS has no valid keys after the update."
chown "$NEW_USER:$NEW_USER" "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"

# ---- UFW --------------------------------------------------------------------
log "Configuring UFW (allow 22 and app-ports from $TRUSTED_DESC)"
log "Resetting existing UFW rules (ufw keeps a backup in /etc/ufw)"
ufw --force reset >/dev/null
ufw default deny incoming >/dev/null
ufw default allow outgoing >/dev/null

PORTS=(22)
if [ -n "$APP_PORTS" ]; then
  IFS=',' read -ra APP_PORT_LIST <<< "$APP_PORTS"
  for p in "${APP_PORT_LIST[@]}"; do
    p_trimmed=$(echo "$p" | tr -d '[:space:]')
    [ -z "$p_trimmed" ] && continue
    [[ "$p_trimmed" =~ ^[0-9]+$ ]] || die "Invalid --app-ports entry: $p_trimmed"
    PORTS+=("$p_trimmed")
  done
fi

for port in "${PORTS[@]}"; do
  label="App $port"
  [ "$port" = 22 ] && label="SSH"
  for s in "${SUBNETS[@]}"; do
    ufw allow from "$s" to any port "$port" proto tcp comment "$label from $s" >/dev/null
    ok "Opened ${port}/tcp from $s"
  done
  if [ "$TAILSCALE" = yes ]; then
    ufw allow in on tailscale0 to any port "$port" proto tcp comment "$label via Tailscale" >/dev/null
    ok "Opened ${port}/tcp on tailscale0"
  fi
done
ufw logging low >/dev/null
ufw --force enable >/dev/null
ok "UFW enabled."

# ---- sshd hardening ---------------------------------------------------------
SSHD_CONFIG=/etc/ssh/sshd_config
SSHD_DROPIN=/etc/ssh/sshd_config.d/00-hardening.conf

# Match blocks can key on any address, user or group, which no fixed set of
# sshd -T -C probes covers, so reject auth settings inside them that are not
# "no". Prints one FILE:LINE: entry per offending line.
match_auth_overrides() {
  awk -F'[ \t=]+' '
    FNR == 1 { in_match = 0 }
    { sub(/^[ \t]+/, "") }
    tolower($1) == "match" { in_match = 1; next }
    in_match && tolower($1) ~ /^(passwordauthentication|kbdinteractiveauthentication|challengeresponseauthentication|permitemptypasswords|permitrootlogin)$/ && tolower($2) != "no" {
      print FILENAME ":" FNR ": " $0
    }
  ' "$@" 2>/dev/null
}

# sshd -T alone skips Match blocks; -C evaluates them for one connection.
# Probe the new user and root from localhost, each trusted subnet, Tailscale
# and an outside address.
verify_sshd_effective() {
  local user addr effective root_pattern="$ROOT_LOGIN_VALUE"
  local addrs=(127.0.0.1 "${SUBNETS[@]%/*}" 203.0.113.1)
  [ "$TAILSCALE" = yes ] && addrs+=(100.64.0.1)
  # sshd -T prints prohibit-password under its older alias, without-password.
  [ "$ROOT_LOGIN_VALUE" = prohibit-password ] && root_pattern="(prohibit|without)-password"
  for user in "$NEW_USER" root; do
    for addr in "${addrs[@]}"; do
      effective=$(sshd -T -f "$SSHD_CONFIG" -C "user=$user,host=$addr,addr=$addr" 2>/dev/null) \
        || die "sshd -T failed for user=$user addr=$addr"
      grep -qx 'passwordauthentication no' <<< "$effective" \
        || die "sshd allows passwords for $user from $addr; another setting overrides $SSHD_DROPIN"
      grep -qx 'kbdinteractiveauthentication no' <<< "$effective" \
        || die "sshd allows keyboard-interactive auth for $user from $addr; another setting overrides $SSHD_DROPIN"
      grep -Eqx "permitrootlogin ${root_pattern}" <<< "$effective" \
        || die "sshd PermitRootLogin is not '${ROOT_LOGIN_VALUE}' for $user from $addr; another setting overrides $SSHD_DROPIN"
    done
  done
}

log "Writing $SSHD_DROPIN"
mkdir -p /etc/ssh/sshd_config.d
rm -f /etc/ssh/sshd_config.d/99-hardening.conf
ROOT_LOGIN_VALUE="prohibit-password"
[ "$DISABLE_ROOT" -eq 1 ] && ROOT_LOGIN_VALUE="no"

cat > "$SSHD_DROPIN" <<EOF
# Managed by harden_ubuntu_dev_host.sh
PermitRootLogin ${ROOT_LOGIN_VALUE}
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
MaxAuthTries 6
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
# Remote editors (VS Code / Cursor Remote-SSH) tunnel through TCP forwarding.
AllowTcpForwarding yes
AllowAgentForwarding no
EOF
chmod 644 "$SSHD_DROPIN"

if [ "$DISABLE_ROOT" -eq 1 ]; then
  # Safety: refuse to disable root unless the new user has a key AND a password.
  if ! ssh-keygen -lf "$AUTH_KEYS" > /dev/null 2>&1; then
    die "Refusing to disable root SSH: $NEW_USER has no valid authorized_keys."
  fi
  PW_STATUS=$(passwd -S "$NEW_USER" | awk '{print $2}')
  if [ "$PW_STATUS" != "P" ]; then
    die "Refusing to disable root SSH: $NEW_USER has no password set (status=$PW_STATUS). Run: passwd $NEW_USER"
  fi
fi

sshd -t && ok "sshd config valid"
OVERRIDES=$(match_auth_overrides "$SSHD_CONFIG" /etc/ssh/sshd_config.d/*.conf)
[ -z "$OVERRIDES" ] \
  || die "Match blocks weaken SSH authentication; remove or set them to 'no':"$'\n'"$OVERRIDES"
verify_sshd_effective
ok "sshd effective config verified (sshd -T -C for $NEW_USER and root)"
systemctl reload ssh
ok "sshd reloaded"

# ---- fail2ban ---------------------------------------------------------------
IGNORE_IPS="127.0.0.1/8 ::1 ${SUBNETS[*]}"
[ "$TAILSCALE" = yes ] && IGNORE_IPS="$IGNORE_IPS 100.64.0.0/10"
log "Configuring fail2ban (ignoring $IGNORE_IPS)"
cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd
ignoreip = ${IGNORE_IPS}

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
echo "  Allowed in:     ${PORTS[*]}/tcp from $TRUSTED_DESC"
echo "  Services:       ssh, ufw, fail2ban, unattended-upgrades"
echo
warn "Before closing this root session, test from your workstation:"
echo "    ssh ${NEW_USER}@<host> 'whoami && sudo -n true 2>&1 || echo sudo-needs-password-OK'"
