#!/usr/bin/env bash
#
# Machine declaration helpers — facts about this device, not install choices.
#
# ~/.config/dotfiles/machine.conf declares profile=work|personal. It is
# hand-editable, bootstrapped once by ./install (ensure_machine_profile),
# and never touched by --forget-answers or update. Derived values are
# computed here so shells, create_symlinks.sh, and nvim stay in sync — keep
# the profile→backend mapping in sync with lua/config/profile.lua.

machine_conf_path() {
    echo "${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/machine.conf"
}

# Echo the value for KEY from machine.conf, or return 1 when file/key is missing.
machine_fact() {
    local key="$1" conf value
    conf=$(machine_conf_path)
    [[ -f "$conf" ]] || return 1
    value=$(sed -n "s/^${key}=//p" "$conf" | tail -1)
    [[ -n "$value" ]] || return 1
    echo "$value"
}

# Echo the declared profile (work|personal), or return 1 when unclassified.
machine_profile() {
    local profile
    profile=$(machine_fact profile) || return 1
    case "$profile" in
        work|personal) echo "$profile" ;;
        *) return 1 ;;
    esac
}

# AI backend: explicit ai_backend= line wins; else derived from the profile;
# unclassified machines resolve to none.
machine_ai_backend() {
    local backend
    backend=$(machine_fact ai_backend) || backend=''
    case "$backend" in
        opencode|copilot|none) echo "$backend"; return 0 ;;
    esac
    case "$(machine_profile 2> /dev/null)" in
        personal) echo opencode ;;
        work) echo copilot ;;
        *) echo none ;;
    esac
}

# Ask once when unclassified; never overwrite a valid machine.conf. Requires
# io_helpers.sh (log_*, prompt_choice, dotfiles_noninteractive).
ensure_machine_profile() {
    local conf profile
    machine_profile > /dev/null && return 0
    conf=$(machine_conf_path)
    mkdir -p "$(dirname "$conf")"
    if dotfiles_noninteractive; then
        printf 'profile=unknown\n' > "$conf"
        log_warn "Machine unclassified (non-interactive): wrote profile=unknown to $conf"
        return 0
    fi
    profile=$(prompt_choice 'Is this a work or personal machine?' Personal Work)
    printf 'profile=%s\n' "$profile" > "$conf"
    log_success "Machine classified as '$profile' ($conf)"
}
