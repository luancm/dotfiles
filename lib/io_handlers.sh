#!/usr/bin/env bash

# Try to use tput for colors, fallback to ANSI codes if terminal is unknown
if tput sgr0 &>/dev/null; then
	# tput works - use it
	reset=$(tput sgr0)
	bold=$(tput bold)
	rcolor=$(tput setaf 7) # Default color (white)
	red=$(tput setaf 1)
	green=$(tput setaf 2)
	blue=$(tput setaf 4)
	yellow=$(tput setaf 3)
	USE_TPUT=true
else
	# tput failed (unknown terminal) - use ANSI escape codes
	reset=$'\033[0m'
	bold=$'\033[1m'
	rcolor=$'\033[37m'  # White
	red=$'\033[31m'
	green=$'\033[32m'
	blue=$'\033[34m'
	yellow=$'\033[33m'
	USE_TPUT=false
fi

indent_prefix() {
	# Insert tab for each shell interpreted created (calling (bash/sh -c/zsh) <file>). REF=https://unix.stackexchange.com/questions/232384/argument-string-to-integer-in-bash
	local tab_count=$(($SHLVL - 1))
	local prefix=''
	local i=0
	if [ $tab_count -le 0 ]; then
		echo $prefix
	else
		while [ $(( ( i += 1 ) <= $tab_count )) -ne 0 ]; do prefix+="  "; done
		echo $prefix
	fi
}

log_info() {
	prefix=$(IFS= indent_prefix)
	printf "%s%s[%s .. %s]%s %s\n" "${prefix}" "${bold}" "${blue}" "${rcolor}" "${reset}" "$1"
}

log_success() {
	prefix=$(IFS= indent_prefix)
	printf "%s%s[%s OK %s]%s %s\n" "${prefix}" "${bold}" "${green}" "${rcolor}" "${reset}" "$1"
}

log_warn() {
	prefix=$(IFS= indent_prefix)
	printf "%s%s[%s !! %s]%s %s\n" "${prefix}" "${bold}" "${blue}" "${rcolor}" "${reset}" "$1"
}

log_error() {
	prefix=$(IFS= indent_prefix)
	printf "%s%s[%sFAIL%s]%s %s\n" "${prefix}" "${bold}" "${red}" "${rcolor}" "${reset}" "$1"
	echo ''
}

get_input() {
	prefix=$(IFS= indent_prefix)
	local result
	printf "%s%s[%s ?? %s]%s %s " "${prefix}" "${bold}" "${yellow}" "${rcolor}" "${reset}" "$1" >&2
	read -r result
	echo "$result"
}

# Ask a yes/no question, yay-style: the default choice is shown capitalised in
# the hint (e.g. [Y/n]) and hitting Enter with no input selects it.
# Usage: prompt_confirmation <question> [default]
#   default: 'y' (the default when omitted) or 'n'.
prompt_confirmation() {
    local question="$1"
    local default="${2:-y}"
    local hint answer
    if [[ "${default,,}" == "n" ]]; then
        default="n"; hint="[y/N]"
    else
        default="y"; hint="[Y/n]"
    fi
    while true; do
        answer=$(get_input "$question $hint")
        [[ -z "$answer" ]] && answer="$default"
        case $answer in
            Y|y|Yes|yes) return 0;;
            N|n|No|no) return 1;;
            *) log_warn "Please answer yes or no.";;
        esac
    done
}

# Prompt a multi-choice question, re-asking until the answer matches one of the
# given choices (by full word or first letter, case-insensitive). Echoes the
# matched choice lowercased to stdout; prompts and warnings go to stderr so the
# result can be captured via command substitution.
#
# The first choice is the default: shown UPPERCASED in the hint (e.g. [ALL/some/no])
# and selected when the user hits Enter with no input.
# Usage: answer=$(prompt_choice 'Install git tools?' All Some No)
prompt_choice() {
    local question="$1"; shift
    local choices=("$@")
    local default="${choices[0]}"
    local labels=() choice c lc label
    for c in "${choices[@]}"; do
        if [[ "${c,,}" == "${default,,}" ]]; then
            labels+=("${c^^}")
        else
            labels+=("${c,,}")
        fi
    done
    local labels_joined
    labels_joined=$(IFS=/; echo "${labels[*]}")
    while true; do
        choice=$(get_input "$question [$labels_joined]")
        if [[ -z "$choice" ]]; then
            echo "${default,,}"
            return 0
        fi
        choice=${choice,,}
        for c in "${choices[@]}"; do
            lc=${c,,}
            if [[ "$choice" == "$lc" || "$choice" == "${lc:0:1}" ]]; then
                echo "$lc"
                return 0
            fi
        done
        log_warn "Please answer one of: $labels_joined" >&2
    done
}

# ---------------------------------------------------------------------------
# Remembered install answers
#
# Optional bundles (kubernetes, clipboard, docker, git tools, …) store the
# user's choice under $DOTFILES/cache/install-answers so re-running
# ./install or ./update does not re-prompt. `./install --forget-answers`
# clears the file and forces every prompt again.
# Format: one KEY=value line per answer (value is lowercase yes/no or choice).
# ---------------------------------------------------------------------------

install_answers_path() {
    echo "${DOTFILES_ANSWERS_FILE:-${DOTFILES}/cache/install-answers}"
}

clear_install_answers() {
    local f
    f=$(install_answers_path)
    if [[ -f "$f" ]]; then
        rm -f "$f"
        log_info "Cleared remembered install answers ($f)"
    else
        log_info 'No remembered install answers to clear'
    fi
}

# Echo the stored value for KEY, or return 1 if unset.
get_install_answer() {
    local key="$1" f line
    f=$(install_answers_path)
    [[ -f "$f" ]] || return 1
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" == "$key="* ]] || continue
        echo "${line#*=}"
        return 0
    done < "$f"
    return 1
}

# Persist KEY=VALUE, replacing any previous value for KEY.
set_install_answer() {
    local key="$1" value="$2" f tmp dir
    f=$(install_answers_path)
    dir=$(dirname "$f")
    mkdir -p "$dir"
    tmp=$(mktemp "${dir}/.install-answers.XXXXXX")
    if [[ -f "$f" ]]; then
        # Drop any existing line for this key (exact match on key=).
        grep -v "^${key}=" "$f" > "$tmp" || true
    fi
    printf '%s=%s\n' "$key" "$value" >> "$tmp"
    mv "$tmp" "$f"
}

# Like prompt_confirmation, but caches the answer under KEY.
# Usage: remembered_confirmation <key> <question> [default]
remembered_confirmation() {
    local key="$1" question="$2" default="${3:-y}"
    local stored
    if stored=$(get_install_answer "$key"); then
        case "${stored,,}" in
            y|yes)
                log_info "Using remembered answer for \`$key\`: yes"
                return 0
                ;;
            n|no)
                log_info "Using remembered answer for \`$key\`: no"
                return 1
                ;;
        esac
    fi
    if prompt_confirmation "$question" "$default"; then
        set_install_answer "$key" "yes"
        return 0
    fi
    set_install_answer "$key" "no"
    return 1
}

# Like prompt_choice, but caches the answer under KEY.
# Usage: answer=$(remembered_choice <key> <question> Choice1 Choice2 ...)
remembered_choice() {
    local key="$1" question="$2"
    shift 2
    local choices=("$@")
    local stored c lc choice
    if stored=$(get_install_answer "$key"); then
        stored=${stored,,}
        for c in "${choices[@]}"; do
            lc=${c,,}
            if [[ "$stored" == "$lc" ]]; then
                log_info "Using remembered answer for \`$key\`: $stored" >&2
                echo "$stored"
                return 0
            fi
        done
        # Stale/invalid cached value — fall through and re-prompt.
        log_warn "Ignoring invalid remembered answer for \`$key\`: $stored" >&2
    fi
    choice=$(prompt_choice "$question" "${choices[@]}")
    set_install_answer "$key" "$choice"
    echo "$choice"
}
