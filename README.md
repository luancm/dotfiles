# My Dotfiles

This is a simple dotfile for my basic setup

## Dependencies

If using MacOS, homebrew is a good thing to have, the script tries to install dependencies automatically
(for Arch, yay is installed for AUR packages)

- zsh
- starship (prompt)
- antidote (plugin manager)
  
Optional:
- yay (who doesn't like yogurt?)
- ssh-keygen (openssh)
- xclip (I like pbcopy and pbpaste 😂)
- some nerd-font
- fzf (fuzzy search change lives)

## Setting Up

```shell
git clone https://github.com/luancm/dotfiles ~/.dotfiles
source ~/.dotfiles/install
```

## Private dotfiles (optional)

If a sibling repo exists at `~/.dotfiles-private` (or wherever `$DOTFILES_PRIVATE` points), its `install` script is invoked at the end of `./install`, and `./update` will `git pull` it and run its `update` (or `install` as a fallback) script. The private repo is expected to provide an executable `install` and may reuse helpers via `source "$DOTFILES/lib/io_handlers.sh"`.