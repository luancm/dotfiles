# Copied and modified from https://wiki.archlinux.org/index.php/zsh (16/02/2021)

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Ctrl-Left]="${terminfo[kLFT5]}"
key[Ctrl-Right]="${terminfo[kRIT5]}"

# setup key accordingly
[[ -n "${key[Home]}"       ]] && bindkey -- "${key[Home]}"        beginning-of-line
[[ -n "${key[End]}"        ]] && bindkey -- "${key[End]}"         end-of-line
[[ -n "${key[Insert]}"     ]] && bindkey -- "${key[Insert]}"      overwrite-mode
[[ -n "${key[Backspace]}"  ]] && bindkey -- "${key[Backspace]}"   backward-delete-char
[[ -n "${key[Delete]}"     ]] && bindkey -- "${key[Delete]}"      delete-char
[[ -n "${key[Up]}"         ]] && bindkey -- "${key[Up]}"          up-line-or-history
[[ -n "${key[Down]}"       ]] && bindkey -- "${key[Down]}"        down-line-or-history
[[ -n "${key[Left]}"       ]] && bindkey -- "${key[Left]}"        backward-char
[[ -n "${key[Right]}"      ]] && bindkey -- "${key[Right]}"       forward-char
[[ -n "${key[PageUp]}"     ]] && bindkey -- "${key[PageUp]}"      beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"   ]] && bindkey -- "${key[PageDown]}"    end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}"  ]] && bindkey -- "${key[Shift-Tab]}"   reverse-menu-complete

if [ ! is_mac_os ]; then
	[[ -n "${key[Ctrl-Left]}"  ]] && bindkey -- "${key[Ctrl-Left]}"   backward-word
	[[ -n "${key[Ctrl-Right]}" ]] && bindkey -- "${key[Ctrl-Right]}"  forward-word
	[[ -n "${key[Cmd-Left]}"   ]] && bindkey -- "${key[Cmd-Left]}"    beginning-of-line
	[[ -n "${key[Cmd-Right]}"  ]] && bindkey -- "${key[Cmd-Right]}"   end-of-line
else
	bindkey "^[^[[C" forward-word
	bindkey "^[^[[D" backward-word
	bindkey "^A" beginning-of-line
	bindkey "^E" end-of-line
fi

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'  ;# without /

# History seach
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi