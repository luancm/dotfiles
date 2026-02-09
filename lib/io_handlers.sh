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
	tab_count=$(($SHLVL - 1))
	prefix=''
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
	read result
	echo $result
}

prompt_confirmation() {
    while true; do
        answer=$(get_input "$1")
        case $answer in
            Y|y|Yes|yes) return 0; break;;
            N|n|No|no) return 1; break;;
            *) log_warn "Please answer yes or no.";;
        esac
    done
}
