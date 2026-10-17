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
- fzf (fuzzy search for files and scripted pickers; Ctrl-T / sesh)
- atuin (SQLite shell history on Ctrl-R; local by default, optional sync)
- tmux (terminal multiplexer; ships with [TPM](https://github.com/tmux-plugins/tpm) and a Catppuccin status bar)
- zoxide (smarter `cd`; adds `z`/`zi`)
- sesh (fzf-powered tmux session manager; `prefix + T` inside tmux)
- Wayle (bar; replaces Waybar on Hyprland/Linux)
- Vicinae (app launcher and clipboard history on Hyprland/Linux; replaces Walker and cliphist)

### tmux

Config lives at `~/.config/tmux/tmux.conf`. The prefix is `C-a` (press `C-a a` to pass through nested/SSH tmux).
On first launch press `prefix + I` to install plugins via TPM.

Interactive zsh sessions auto-attach to (or create) a tmux session named `main`. 

Aliases: `tma`, `tmat`, `tms`, `tml`, `tmk`, `tmm`.

## Shared agent configuration

Cross-agent guidance and skills are owned by `~/.agents`. Provider-specific directories only link to that canonical source: Codex receives `~/.codex/AGENTS.md` and one symlink per shared skill in `~/.codex/skills/`. This keeps Claude, Codex, and other supported agents on the same configuration without copying files.

`./install` and `./update` refresh these Codex links after the private configuration hook has prepared `~/.agents`. If the shared configuration is unavailable, the linker reports a warning and leaves existing provider configuration unchanged.

## Setting Up

```shell
git clone https://github.com/luancm/dotfiles ~/.dotfiles
bash ~/.dotfiles/install
```

Optional bundles (kubernetes, clipboard, docker, git tools, Hyprland session
management, …) only prompt when something is actually missing. Multi-choice
prompts default to the first option on Enter (shown as `[ALL/some/no]`).

Answers are remembered under `cache/install-answers` (gitignored) so re-runs of
`./install` / `./update` stay quiet. Forget them and re-prompt with:

```shell
bash ~/.dotfiles/install --forget-answers
# or
bash ~/.dotfiles/update --forget-answers
```

Non-interactive / CI (accept each prompt default without a TTY):

```shell
bash ~/.dotfiles/install --yes
# equivalent: DOTFILES_YES=1 bash ~/.dotfiles/install
```

Requires **Bash 4+** (`brew install bash` on macOS if `bash --version` is 3.x).
Core tools (curl, openssh, zsh, build tools, yay) install before optional
bundles. `apt update` runs at most once per install run.

## Updating

Pull the latest changes, re-run the (idempotent) dependency installers, and
refresh symlinks:

```shell
bash ~/.dotfiles/update
```

## Testing

CI (`.github/workflows/ci.yml`) runs both checks on each push and pull request:

```shell
test/lint.sh            # shellcheck (warning level) + zsh -n
test/install-smoke.sh   # ./install --yes in a clean Ubuntu container (needs docker)
```

## Machine-specific config

`~/.zshrc` is a small local file, not a link. It sources `zsh/zshrc.symlink`.
Tools that append to `~/.zshrc` (locstat, sdkman) write to this local file, not
into the repo. Keep their blocks below the source line.

Anything that should not be tracked in the repo (work env vars, host-specific
PATH entries) goes in `~/.localrc`, which is sourced from the zshrc if present.
`./install` creates it from `.localrc.example` and keeps it private
(`chmod go-rwx`). Do not export secrets there; read them when a command needs
them.

On macOS, list any Homebrew formulae to skip during `update` (one substring
per line) in `homebrew/exclude.local`. The file is gitignored.
