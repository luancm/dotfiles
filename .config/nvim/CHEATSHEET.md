# Neovim cheatsheet

Leader is **Space**. Press it and wait: which-key pops up (delay 0) showing every pending binding — the live version of this document. This file covers everything defined in the config, grouped by what it does.

## Find (Telescope)

| Key | Action |
|---|---|
| `<Space>ff` | Find files |
| `<Space>fg` | Live grep (scopes to git repo root when in one) |
| `<Space>fh` | Help tags (vim help / docs) |
| `<Space>fr` | Find and replace word under cursor |
| `Ctrl-p` | Find files |
| `Ctrl-H` (inside picker) | List actions for the current picker |

## Buffers

| Key | Action |
|---|---|
| `<Space>bl` | Buffer list |
| `<Space>bf` | Format buffer (conform; falls back to LSP) |

## Files

| Key | Action |
|---|---|
| `<Space>tt` | Toggle NeoTree file tree |

## Diagnostics and code (LSP)

| Key | Action |
|---|---|
| `<Space>e` | Show diagnostic under cursor |
| `<Space>tf` | Show diagnostic float |
| `[d` / `]d` | Previous / next diagnostic |
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gD` | Go to definition in new tab |
| `gr` | References |
| `<Space>ca` | Code action |
| `<Space>cr` | Rename symbol |
| `gpd` / `gpi` | Preview definition / implementation (floating window) |
| `gpc` | Close preview window |

## Git (gitsigns, buffer-local)

| Key | Action |
|---|---|
| `<Space>hs` / `<Space>hr` | Stage / reset hunk (visual mode: selected lines) |
| `<Space>hS` / `<Space>hR` | Stage / reset whole buffer |
| `<Space>hp` / `<Space>hi` | Preview hunk in float / inline |
| `<Space>hb` | Full blame for line |
| `<Space>hd` / `<Space>hD` | Diff this / diff against last commit (`~`) |
| `<Space>hq` / `<Space>hQ` | Buffer hunks / all-file hunks → quickfix |
| `<Space>tb` / `<Space>tw` | Toggle line blame / toggle word diff |
| `[c` / `]c` | Previous / next hunk |
| `ih` (operator/visual) | Text object: whole hunk |

## AI (99, Claude backend)

| Key | Action |
|---|---|
| `<Space>9v` | Request on visual selection |
| `<Space>9s` | Search |
| `<Space>9b` | Vi[b]e — agentic mode |
| `<Space>9o` | Open last result |
| `<Space>9x` | Stop all requests |

## Multicursor

| Key | Action |
|---|---|
| `Ctrl-up` / `Ctrl-down` | Add cursor above / below |
| `<Space>Ctrl-up` / `<Space>Ctrl-down` | Skip cursor above / below |
| `<Space>md` / `<Space>ms` | Add / skip next match of word or selection |
| `<Space>mD` / `<Space>mS` | Add / skip previous match |
| `Ctrl-q` | Toggle cursor at position |
| `Ctrl-left-click` (+drag) | Add cursor by mouse |
| `<left>` / `<right>` (with cursors) | Switch main cursor |
| `<Space>x` (with cursors) | Delete main cursor |
| `Esc` (with cursors) | Enable / clear cursors |

## Window and scroll

| Key | Action |
|---|---|
| `Ctrl-h/j/k/l` | Move between splits and tmux panes |
| `Ctrl-\` | Previous tmux pane/split |
| `Ctrl-d` / `Ctrl-u` | Half page down / up (keeps cursor centered) |

## Completion (blink.cmp)

| Key | Action |
|---|---|
| `Ctrl-space` | Trigger menu / toggle docs |
| `Enter` / `Right` / `Ctrl-l` | Accept item |
| `Tab` / `Down` / `Ctrl-n` | Next item |
| `Shift-Tab` / `Up` / `Ctrl-p` | Previous item |
| `Ctrl-b` / `Ctrl-f` | Scroll docs up / down |
| `Ctrl-k` | Toggle signature help |
| `Ctrl-e` | Cancel menu |

## Text objects (mini.nvim)

| Key | Action |
|---|---|
| `va)` / `ci(` | Select/change around/inside brackets — any pair works |
| `yinq` | Yank inside next quote |
| `saiw)` / `sd'` / `sr)'` | Surround add word in parens / delete quotes / replace |

## Misc

| Key | Action |
|---|---|
| `<Space><Space>` | Clear search highlight |
| `<Space>y` / `<Space>Y` | Yank to system clipboard |
| `[d` / `]d` | Jump diagnostics |

## Handy commands (no keymap)

| Command | Purpose |
|---|---|
| `:Lazy` | Plugin manager UI |
| `:Mason` | LSP server manager |
| `:ConformInfo` | Formatter status |
| `:checkhealth` | Health report |
| `:Telescope help_tags` | Search help |
| `:vim-be-good` | Practice game |
