# My Dotfiles

This is a simple dotfile for my basic setup

## Dependencies

The `install` script tries to install dependencies automatically. On macOS,
homebrew is a good thing to have; on Arch, `yay` is installed for AUR packages.

Core:
- zsh
- starship (prompt)
- antidote (plugin manager)
- ripgrep, fd (search, used by fzf and Neovim/Telescope)
- luarocks, wget (Neovim plugin tooling)
- go, nvm (toolchains, lazy-loaded in the shell)

Optional:
- yay (who doesn't like yogurt?)
- ssh-keygen (openssh)
- xclip (I like pbcopy and pbpaste 😂)
- some nerd-font
- fzf (fuzzy search change lives)

## Setting Up

```shell
git clone https://github.com/luancm/dotfiles ~/.dotfiles
bash ~/.dotfiles/install
```

## Updating

Pull the latest changes, re-run the (idempotent) dependency installers, and
refresh symlinks:

```shell
bash ~/.dotfiles/update
```

## Machine-specific config

Anything that should not be tracked in the repo (secrets, work env vars,
host-specific PATH entries) goes in `~/.localrc`, which is sourced from the
zshrc if present:

```shell
cp ~/.dotfiles/.localrc.example ~/.localrc
```

On macOS, list any Homebrew formulae to skip during `update` (one substring
per line) in `homebrew/exclude.local`. The file is gitignored.