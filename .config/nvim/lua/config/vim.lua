vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.undofile = true

-- vim.opt.clipboard = "unnamedplus"
vim.opt.smartindent = true

vim.g.mapleader = " "

-- to be used in plugins or custom configs
vim.g.have_nerd_font = true

vim.g.loaded_snippet = 1

-- Keymaps

vim.keymap.set("n", "<C-k>", "<cmd>wincmd k<cr>")
vim.keymap.set("n", "<C-j>", "<cmd>wincmd j<cr>")
vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<cr>")
vim.keymap.set("n", "<C-l>", "<cmd>wincmd l<cr>")
vim.keymap.set({'n', 'v'}, '<C-j>', '<C-d>zz', { desc = 'Half page down' })
vim.keymap.set({'n', 'v'}, '<C-k>', '<C-u>zz', { desc = 'Half page up' })

vim.keymap.set("n", "<leader><space>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- From theprimeagen
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set("n", "<leader>fr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "[F]ind and [Replace]" })

-- Diagnostics
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
	float = { border = "rounded", source = true },
})

vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous [D]iagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next [D]iagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror" })
