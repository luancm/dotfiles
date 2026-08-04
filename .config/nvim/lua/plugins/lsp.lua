return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    config = function()
      -- hyprls is Linux/Hyprland-only; skip ensure on macOS.
      local ensure = {
        "lua_ls",
        "ts_ls",
        "bashls",
        "jsonls",
        "gradle_ls",
        "kotlin_language_server",
        "clangd",
        "gopls",
        "rust_analyzer",
        "zls",
      }
      if vim.fn.has("mac") == 0 then
        table.insert(ensure, "hyprls")
      end
      require("mason-lspconfig").setup({
        ensure_installed = ensure,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "ziglang/zig.vim",
    },
    config = function()
      -- Prefer nvim-lspconfig defaults; only override settings that differ.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("zls", {
        settings = {
          zls = {
            -- Neovim already provides basic syntax highlighting
            semantic_tokens = "partial",
          },
        },
      })

      -- don't show parse errors in a separate window
      vim.g.zig_fmt_parse_errors = 0
      -- disable format-on-save from zig.vim (conform handles format-on-save)
      vim.g.zig_fmt_autosave = 0

      local servers = {
        "lua_ls",
        "ts_ls",
        "bashls",
        "jsonls",
        "gradle_ls",
        "kotlin_language_server",
        "clangd",
        "gopls",
        "rust_analyzer",
        "zls",
      }
      if vim.fn.has("mac") == 0 then
        table.insert(servers, "hyprls")
      end
      vim.lsp.enable(servers)

      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP hover" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ction" })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "[G]o to [D]efinition (LSP)" })
      vim.keymap.set("n", "gD", function()
        vim.cmd("tab split")
        vim.lsp.buf.definition()
      end, { desc = "[G]o to [D]efinition in tab (LSP)" })
      vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "[C]ode [R]ename" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "[G]o to [R]eferences (LSP)" })
      vim.keymap.set("n", "gpd", function()
        require("goto-preview").goto_preview_definition()
      end, { desc = "[G]o to [P]review [D]efinition (LSP)" })
      vim.keymap.set("n", "gpi", function()
        require("goto-preview").goto_preview_implementation()
      end, { desc = "[G]o to [P]review [I]mplementation (LSP)" })
      vim.keymap.set("n", "gpc", function()
        require("goto-preview").close_all_win()
      end, { desc = "[G]o to [P]review [C]lose (LSP)" })
      vim.keymap.set("n", "<leader>tf", vim.diagnostic.open_float, { desc = "[T]oggle [F]loat Diagnostics (LSP)" })
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "rmagatti/goto-preview",
    dependencies = { "rmagatti/logger.nvim" },
    event = "BufEnter",
    config = true, -- necessary as per https://github.com/rmagatti/goto-preview/issues/88
  },
}
