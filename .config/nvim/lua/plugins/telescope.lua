return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'echasnovski/mini.icons', version = '*' },
    },
    config = function()
      local config = require('telescope')
      config.setup({
        defaults = {
          -- Default configuration for telescope goes here:
          -- config_key = value,
          mappings = {
            i = {
              -- map actions.which_key to <C-h> (default: <C-/>)
              -- actions.which_key shows the mappings for your picker,
              -- e.g. git_{create, delete, ...}_branch for the git_branches picker
              ["<C-h>"] = "which_key"
            }
          }
        },
        pickers = {
          find_files = {
            hidden = true
          },
          buffers = {
            sort_mru = true,
            mappings = {
              i = {
                -- Map Ctrl+Tab to cycle to next item when in insert mode
                ["<C-i>"] = function(...)
                  require("telescope.actions").move_selection_next(...)
                end,
              },
              n = {
                -- Map Ctrl+Tab to cycle to next item when in normal mode
                ["<C-i>"] = function(...)
                  require("telescope.actions").move_selection_next(...)
                end,
              },
            },
          }
        },
      })

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
      vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<C-i>', builtin.buffers, { desc = 'Telescope buffers' })
    end
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      local telescope = require("telescope")

      telescope.setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
              -- even more opts
            }
          }
        }
      }

      telescope.load_extension("ui-select")
    end
  }
}
