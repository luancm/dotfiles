return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "mason-org/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = { "ts_ls", "bashls", "hyprls", "jsonls", "gradle_ls", "kotlin_language_server", "clangd", "gopls" },
      }
    end
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "ziglang/zig.vim"
    },
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.ts_ls.setup({})
      lspconfig.bashls.setup({})
      lspconfig.hyprls.setup({})
      lspconfig.jsonls.setup({})
      lspconfig.gradle_ls.setup({})
      lspconfig.kotlin_language_server.setup({})
      lspconfig.clangd.setup({})
      lspconfig.gopls.setup({})

      vim.lsp.config.bashls = {
        cmd = { 'bash-language-server', 'start' },
        filetypes = { 'bash', 'sh', 'zsh' }
      }
      vim.lsp.enable 'bashls'

      -- don't show parse errors in a separate window
      vim.g.zig_fmt_parse_errors = 0
      -- disable format-on-save from `ziglang/zig.vim`
      vim.g.zig_fmt_autosave = 0
      -- enable  format-on-save from nvim-lspconfig + ZLS
      --
      -- Formatting with ZLS matches `zig fmt`.
      -- The Zig FAQ answers some questions about `zig fmt`:
      -- https://github.com/ziglang/zig/wiki/FAQ
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = { "*.zig", "*.zon" },
        callback = function(ev)
          vim.lsp.buf.format()
        end
      })

      local lspconfig = require('lspconfig')
      lspconfig.zls.setup {
        -- Server-specific settings. See `:help lspconfig-setup`

        -- omit the following line if `zls` is in your PATH
        -- cmd = { '/path/to/zls_executable' },
        -- There are two ways to set config options:
        --   - edit your `zls.json` that applies to any editor that uses ZLS
        --   - set in-editor config options with the `settings` field below.
        --
        -- Further information on how to configure ZLS:
        -- https://zigtools.org/zls/configure/
        settings = {
          zls = {
            -- Whether to enable build-on-save diagnostics
            --
            -- Further information about build-on save:
            -- https://zigtools.org/zls/guides/build-on-save/
            -- enable_build_on_save = true,

            -- Neovim already provides basic syntax highlighting
            semantic_tokens = "partial",

            -- omit the following line if `zig` is in your PATH
            -- zig_exe_path = '/path/to/zig_executable'
          }
        }
      }

      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
      vim.keymap.set("n", "<leader>bf", vim.lsp.buf.format)


      vim.cmd("command! LspDef lua vim.lsp.buf.definition()")
      vim.cmd("command! LspDefTab tab split | lua vim.lsp.buf.definition()")
      vim.cmd("command! LspHover lua vim.lsp.buf.hover()")
      vim.cmd("command! LspRename lua vim.lsp.buf.rename()")
      vim.cmd("command! GoToPreview lua require('goto-preview').goto_preview_definition()")
      vim.cmd("command! GoToPreviewImpl lua require('goto-preview').goto_preview_implementation()")
      vim.cmd("command! CloseGoToPreview lua require('goto-preview').close_all_win()")
      vim.cmd("command! OpenFloatDiag lua vim.diagnostic.open_float()")
      vim.keymap.set("n", "gd", ":LspDef<CR>")
      vim.keymap.set("n", "gD", ":LspDefTab<CR>")
      vim.keymap.set("n", "gi", ":LspRename<CR>")
      vim.keymap.set("n", "<C-k>", ":LspHover<CR>")
      vim.keymap.set("n", "gpd", ":GoToPreview<CR>")
      vim.keymap.set("n", "gpi", ":GoToPreviewImpl<CR>")
      vim.keymap.set("n", "gpc", ":CloseGoToPreview<CR>")
      vim.keymap.set("n", "tf", ":OpenFloatDiag<CR>")
    end
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "ray-x/lsp_signature.nvim",
    opts = {
      floating_window = false,
      hint_prefix = {
        above = "↙ ", -- when the hint is on the line above the current line
        current = "← ", -- when the hint is on the same line
        below = "↖ " -- when the hint is on the line below the current line
      }
    }
  },
  {
    "rmagatti/goto-preview",
    dependencies = { "rmagatti/logger.nvim" },
    event = "BufEnter",
    config = true, -- necessary as per https://github.com/rmagatti/goto-preview/issues/88
  },
}
