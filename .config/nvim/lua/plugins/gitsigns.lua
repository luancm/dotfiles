return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged = {
          add          = { text = '┃' },
          change       = { text = '┃' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signs_staged_enable = true,
        signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
          follow_files = true
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
          delay = 1000,
          ignore_whitespace = false,
          virt_text_priority = 100,
          use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        blame_formatter = nil, -- Use default
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
          -- Options passed to nvim_open_win
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1
        },
        on_attach = function(bufnr)
          local gs = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gs.nav_hunk('next')
            end
          end, { desc = 'Next hunk' })

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gs.nav_hunk('prev')
            end
          end, { desc = 'Prev hunk' })

          -- Actions
          map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
          map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })

          map('v', '<leader>hs', function()
            gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, { desc = 'Stage hunk' })

          map('v', '<leader>hr', function()
            gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, { desc = 'Reset hunk' })

          map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage buffer' })
          map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset buffer' })
          map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
          map('n', '<leader>hi', gs.preview_hunk_inline, { desc = 'Preview hunk inline' })

          map('n', '<leader>hb', function()
            gs.blame_line({ full = true })
          end, { desc = 'Blame line' })

          map('n', '<leader>hd', gs.diffthis, { desc = 'Diff this' })

          map('n', '<leader>hD', function()
            gs.diffthis('~')
          end, { desc = 'Diff this ~' })

          map('n', '<leader>hQ', function() gs.setqflist('all') end, { desc = 'Hunks (all) → quickfix' })
          map('n', '<leader>hq', gs.setqflist, { desc = 'Hunks → quickfix' })

          -- Toggles
          map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'Toggle blame' })
          map('n', '<leader>tw', gs.toggle_word_diff, { desc = 'Toggle word diff' })

          -- Text object
          map({ 'o', 'x' }, 'ih', gs.select_hunk, { desc = 'Select hunk' })
        end,
      },
    },
  }

