#!/bin/sh

git config --global alias.st status
git config --global alias.co checkout

git config --global alias.lsd "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"