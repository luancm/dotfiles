# chezmoi evaluation

Status: **deferred**. Keep the bash installer. Evaluate again when you add a
machine.

## Why not now

The repository manages two machine types (`profile=work|personal`). The
installer now has the parts that chezmoi would add: a machine profile, a local
`~/.zshrc` for locstat, pinned and verified downloads, and CI. A migration
touches every file and installer, and the gain for two machines is small.

## When to adopt

Adopt chezmoi when one of these is true:

- You add a machine, and more than one or two files must be different on it.
- You want secrets in the repository as encrypted files, or templates that read
  a password manager.
- You want to see a diff before changes go into your home folder
  (`chezmoi diff`), or you want to find drift on each machine.

## How the repository maps

| Today | chezmoi |
|---|---|
| `lib/create_symlinks.sh` links `*.symlink` and `.config/*` | `dot_` source names. `mode = "symlink"` keeps plain files as links. |
| `machine.conf` (`profile=…`), asked once | `.chezmoi.toml.tmpl` with `promptChoiceOnce` writes `[data] profile` |
| `zsh/profiles/zprofile-{work,personal}.zsh` | Templates (`{{ if eq .profile "work" }}`) or a templated `.chezmoiignore` |
| Local `~/.zshrc` stub that locstat appends to | `create_dot_zshrc`: created once, then never changed |
| `cache/install-answers` (`remembered_confirmation`) | `promptBoolOnce` in `.chezmoi.toml.tmpl` |
| `lib/tools.list` and the package manager | A `run_onchange_` script that includes a hash of the list, so it runs again when the list changes |
| `lib/download.sh` and `lib/versions.env` | `.chezmoiexternal.toml` entries (`archive-file`, `checksum.sha256`, one sum per CPU type in a template) |
| TPM clone in `tmux.sh` | `.chezmoiexternal.toml` entry with `type = "git-repo"` |
| `remove_dangling_links` | `.chezmoiremove` |
| `guard_hyprland_stub` | Not necessary in copy mode: `chezmoi apply` writes the file again. In symlink mode the problem stays. |
| `themes/render.sh` (whiskers) | Keep it. Commit the output, or run it from a `run_onchange_before_` script. |
| `system_configs/etc/*` (copied with sudo) | Outside the home target. Keep a `run_onchange_` script that uses sudo. |
| `~/.dotfiles-private` hooks | Keep a separate checkout and call its hook from a `run_` script, or move the files in as `encrypted_` (age) files. |
| `./update` | `chezmoi update` (git pull, then apply) |

## Cost (large)

- Rename all source files to chezmoi names (`dot_`, `private_`,
  `executable_`): one `*.symlink` file and 12 `.config` trees. `chezmoi add`
  does the rename.
- Rewrite the installers as `run_` scripts: the tool-list runner, the 14 files
  in `lib/dependencies/`, and the three `*/install.sh` hooks.
- The edit flow changes. In copy mode, edit with `chezmoi edit` or copy changes
  back with `chezmoi re-add`. Files that tools write (Neovim `lazy-lock.json`,
  the Hyprland stub) need symlink mode or a `.chezmoiignore` entry.
- CI changes. The smoke test runs `chezmoi init --apply` in the container. Test
  the templates with `chezmoi execute-template`.

## Steps when you start

1. Install chezmoi from the package manager (not `curl | sh`).
2. Put the source state in a subfolder (`.chezmoiroot` contains `home`), so
   `README.md`, `test/` and `themes/` stay at the root. Set
   `sourceDir = "~/.dotfiles"`.
3. Move `zshrc` and one `.config` tree first, with `mode = "symlink"`. Compare
   with `chezmoi diff` on each machine before the first `chezmoi apply`.
4. Move `machine.conf` into `.chezmoi.toml.tmpl`.
5. Move the installers last. Keep `./install` as a thin wrapper until all
   machines use chezmoi.

## References

- [Source state attributes](https://www.chezmoi.io/reference/source-state-attributes/)
- [Target types and symlink mode](https://www.chezmoi.io/reference/target-types/)
- [Machine-to-machine differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)
- [`.chezmoiexternal` format](https://www.chezmoi.io/reference/special-files/chezmoiexternal-format/)
- [`.chezmoiroot`](https://www.chezmoi.io/reference/special-files/chezmoiroot/)
