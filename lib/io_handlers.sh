#!/usr/bin/env bash

reset=$(tput sgr0)
bold=$(tput bold)

rcolor=$(tput setaf 7) # Default color (white)
red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
yellow=$(tput setaf 3)

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
	printf "${prefix}${bold}[${blue} .. ${rcolor}]${reset} $1\n"
}

log_success() {
	prefix=$(IFS= indent_prefix)
	printf "${prefix}${bold}[${green} OK ${rcolor}]${reset} $1\n"
}

log_warn() {
	prefix=$(IFS= indent_prefix)
	printf "${prefix}${bold}[${blue} !! ${rcolor}]${reset} $1\n"
}

log_error() {
	prefix=$(IFS= indent_prefix)
	printf "${prefix}${bold}[${red}FAIL${rcolor}]${reset} $1\n"
	echo ''
}

get_input() {
	prefix=$(IFS= indent_prefix)
	local result
	read -p "${prefix}${bold}[${yellow} ?? ${rcolor}]${reset} $1 " result
	echo $result
}

prompt_confirmation() {
    while true; do
        answer=$(get_input "$1")
        case $answer in
            Y|y|Yes|yes) return 0; break;;
            N|n|No|no) return 1; break;;
            *) log_warn "Please answer yes or no." > /dev/tty;;
        esac
    done
}
