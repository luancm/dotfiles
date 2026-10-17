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
- go, mise (toolchains; mise manages Node and Java, see below)

Optional:
- yay (who doesn't like yogurt?)
- ssh-keygen (openssh)
- xclip (I like pbcopy and pbpaste 😂)
- FiraCode Nerd Font (the one font the configs use; Arch `ttf-firacode-nerd`, macOS cask `font-fira-code-nerd-font`)
- fzf (fuzzy search for files and scripted pickers; Ctrl-T / sesh)
- atuin (SQLite shell history on Ctrl-R; local by default, optional sync)
- tmux (terminal multiplexer; ships with [TPM](https://github.com/tmux-plugins/tpm) and a Catppuccin status bar)
- zoxide (smarter `cd`; adds `z`/`zi`)
- sesh (fzf-powered tmux session manager; `prefix + T` inside tmux)
- Wayle (bar; replaces Waybar on Hyprland/Linux)
- Vicinae (app launcher and clipboard history on Hyprland/Linux; replaces Walker and cliphist)

On macOS, `homebrew/Brewfile` lists the same tools. `./install` offers it once
(default no), or run `brew bundle --file ~/.dotfiles/homebrew/Brewfile`.

To add a tool that only needs a package, add one line to `lib/tools.list`.
Tools with extra steps have a file in `lib/dependencies/`. When there is no
package, `./install` downloads a pinned release (starship, sesh, delta,
difftastic, lazygit, Go, the nvm installer) and checks it against the sha256 in
`lib/versions.env`. It does not use a download that does not match.

### Node and Java (mise)

[mise](https://mise.jdx.dev) sets the Node and Java versions. Global versions
are in `.config/mise/config.toml` (Node LTS, Temurin 25). In a project, mise
also reads `.nvmrc`, `.node-version`, `.java-version` and `.sdkmanrc`.

When mise is not installed, the shell uses nvm and sdkman (both lazy-loaded)
as before. To move to mise: install it, run `mise install`, then remove the
nvm and sdkman lines from `~/.localrc` and `~/.zshrc`.

### Themes

The Hyprland, Waybar, wlogout, Ghostty, Wayle and ReGreet colours come from
one Catppuccin palette. The templates are in `themes/*.tera`; the flavor is set
in `themes/render.sh`. After you change a template, run the script (needs
[whiskers](https://github.com/catppuccin/whiskers/releases)) and commit the
generated files:

```shell
themes/render.sh          # write the generated files
themes/render.sh --check  # CI: fail if a generated file is out of date
```

### tmux

Config lives at `~/.config/tmux/tmux.conf`. The prefix is `C-a` (press `C-a a` to pass through nested/SSH tmux).
On first launch press `prefix + I` to install plugins via TPM.

Interactive zsh sessions auto-attach to (or create) a tmux session named `main`. 

Aliases: `tma`, `tmat`, `tms`, `tml`, `tmk`, `tmm`.

## Shared agent configuration

Cross-agent guidance (`~/.agents/AGENTS.md`) and skills (`~/.agents/skills`) are owned by `~/.agents`. Each tool gets only symlinks to that source:

| Tool | Guidance | Skills |
| --- | --- | --- |
| Claude Code | `~/.claude/CLAUDE.md` | `~/.claude/skills` (one link; one link per skill if it is a real folder) |
| Codex | `~/.codex/AGENTS.md` | one link per skill in `~/.codex/skills/` |
| opencode | `~/.config/opencode/AGENTS.md` | reads `~/.agents/skills` itself |
| Cursor | no global file (user rules are in Settings) | reads `~/.agents/skills` itself |

`./install` and `./update` refresh these links (`lib/create_agent_symlinks.sh`) after the private configuration hook has prepared `~/.agents`. The linker never replaces a real file or a link to a different target; it shows a warning instead. It removes links to skills that no longer exist. If the shared configuration is unavailable, it leaves the provider configuration unchanged.

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

When you add a machine, read [docs/chezmoi-evaluation.md](docs/chezmoi-evaluation.md)
before you extend the installer. It lists when to move to chezmoi and how this
repository maps to it.
