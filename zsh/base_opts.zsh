# remove annoying beep
setopt NO_BEEP
setopt PROMPT_SUBST
setopt COMPLETE_IN_WORD

# History. SHARE_HISTORY writes each command at once and reads other
# sessions' commands; do not add INC_APPEND_HISTORY with it.
setopt SHARE_HISTORY
# add timestamps to history
setopt EXTENDED_HISTORY
# keep one copy of each command (also covers HIST_IGNORE_DUPS)
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
# skip duplicates when searching history (Ctrl-R)
setopt HIST_FIND_NO_DUPS

# directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# extended globbing (^, #, ~ operators)
setopt EXTENDED_GLOB
# ...which makes HEAD^ and HEAD~2 globs. git expands its own pathspecs
# (git add '*.lua'), so pass git arguments unexpanded.
alias git='noglob git'