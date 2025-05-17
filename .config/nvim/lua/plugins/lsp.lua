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
        ensure_installed = { "ts_ls", "bashls", "hyprls" },
      }
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.ts_ls.setup({})
      lspconfig.bashls.setup({})
      lspconfig.hyprls.setup({})

      vim.lsp.config.bashls = {
        cmd = { 'bash-language-server', 'start' },
        filetypes = { 'bash', 'sh', 'zsh' }
      }
      vim.lsp.enable 'bashls'

      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
      vim.keymap.set("n", "<leader>bf", vim.lsp.buf.format)
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
}
