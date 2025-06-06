return {
  { "ThePrimeagen/vim-be-good" },
  { "nvim-tree/nvim-web-devicons", opts = {} },
  { "folke/todo-comments.nvim",    event = "VimEnter", dependencies = { "nvim-lua/plenary.nvim" }, opts = { signs = false } },
  {
    "m4xshen/hardtime.nvim",
    opts = {},
    config = function()
      require("hardtime").setup({})

      vim.keymap.set("n", "<leader>H", "<cmd>Hardtime toggle<cr>")
    end,
  },
}
