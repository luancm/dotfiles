#!/bin/sh

git config --global alias.st status
git config --global alias.co checkout

git config --global alias.lsd "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"

git config --global alias.branches "! git for-each-ref --sort=-committerdate refs/heads --format='%(HEAD)%(color:yellow)%(refname:short)|%(color:bold green)%(committerdate:relative)|%(color:blue)%(subject)|%(color:magenta)%(authorname)%(color:reset)' --color=always | column -s\| -t"
git config --global alias.remotebranches "!git ls-remote -h origin | while read b; do PAGER='' git log -n1 --color --pretty=format:'%ct%C(yellow)%d%Creset - %Cred%h%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%n' --abbrev-commit $( echo $b | cut -d' ' -f1 ) --; done | sort -rn -k1,10 | cut -c11-"

git config --global alias.sput "!f() { git stash push -m "named_stash_\$1"; }; f"
git config --global alias.sapply '!f() { name="$1"; stash_hash=$(git stash list | grep "named_stash_$name" | head -n 1 | awk -F":" "{print \$1}"); if [ -n "$stash_hash" ]; then git stash apply "$stash_hash"; else echo "Stash with name $name not found."; fi; }; f'
git config --global alias.sdrop '!f() { name="$1"; stash_hash=$(git stash list | grep "named_stash_$name" | head -n 1 | awk -F":" "{print \$1}"); if [ -n "$stash_hash" ]; then git stash drop "$stash_hash"; else echo "Stash with name $name not found."; fi; }; f'
