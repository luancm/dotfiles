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
# Usage: answer=$(prompt_choice 'Install git tools?' All Some No)
prompt_choice() {
    local question="$1"; shift
    local choices=("$@")
    local labels choice c lc
    labels=$(IFS=/; echo "${choices[*]}")
    while true; do
        choice=$(get_input "$question [$labels]")
        choice=${choice,,}
        for c in "${choices[@]}"; do
            lc=${c,,}
            if [[ "$choice" == "$lc" || "$choice" == "${lc:0:1}" ]]; then
                echo "$lc"
                return 0
            fi
        done
        log_warn "Please answer one of: $labels" >&2
    done
}
