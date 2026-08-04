return {
  {
    -- nvim-treesitter `main` is a full rewrite (Nvim 0.12+).
    -- Highlight/indent are no longer configured via nvim-treesitter.configs.
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})

      local ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        "zig",
      }

      -- Async; no-op for parsers already installed.
      require("nvim-treesitter").install(ensure_installed)

      vim.api.nvim_create_autocmd("FileType", {
        desc = "Enable treesitter highlight + indent",
        callback = function(args)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
          if ok and stats and stats.size > max_filesize then
            return
          end

          -- Provided by Neovim core.
          pcall(vim.treesitter.start)

          -- Experimental indent from nvim-treesitter.
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
