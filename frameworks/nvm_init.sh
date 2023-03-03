if [ "$nvm_initialized" = true ]; then
    log_info 'NVM already initialized'
    return
else
    log_info 'Initializing NVM'
fi

export NVM_DIR="$HOME/.nvm"

if command -v brew > /dev/null; then
    source $(brew --prefix nvm)/nvm.sh
    source $(brew --prefix nvm)/etc/bash_completion.d/nvm
else
    [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
    [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
fi

autoload -U add-zsh-hook

load-nvmrc() {
    if [[ -f .nvmrc && -r .nvmrc ]]; then
        nvm use
    fi
}

add-zsh-hook chpwd load-nvmrc

nvm_initialized=true